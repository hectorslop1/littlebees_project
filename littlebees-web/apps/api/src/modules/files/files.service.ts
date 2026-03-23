import {
  BadRequestException,
  Injectable,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
  CreateBucketCommand,
  HeadBucketCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { PrismaService } from '../prisma/prisma.service';
import { createHmac, randomUUID, timingSafeEqual } from 'crypto';

@Injectable()
export class FilesService implements OnModuleInit {
  private s3: S3Client;
  private bucket: string;
  private readonly fileLinkSecret: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {
    const endpoint = this.config.get<string>('MINIO_ENDPOINT', 'http://localhost:9000');
    const accessKey = this.config.get<string>('MINIO_ACCESS_KEY', 'kinderspace');
    const secretKey = this.config.get<string>('MINIO_SECRET_KEY', 'kinderspace123');
    this.bucket = this.config.get<string>('MINIO_BUCKET', 'kinderspace-files');
    this.fileLinkSecret = this.config.get<string>(
      'FILE_LINK_SECRET',
      this.config.get<string>('JWT_SECRET', 'littlebees-file-links'),
    );

    this.s3 = new S3Client({
      endpoint,
      region: 'us-east-1',
      credentials: {
        accessKeyId: accessKey,
        secretAccessKey: secretKey,
      },
      forcePathStyle: true,
    });
  }

  async onModuleInit() {
    try {
      await this.s3.send(new HeadBucketCommand({ Bucket: this.bucket }));
    } catch {
      try {
        await this.s3.send(new CreateBucketCommand({ Bucket: this.bucket }));
      } catch (createErr) {
        console.warn('Could not create MinIO bucket:', createErr);
      }
    }
  }

  async upload(
    tenantId: string,
    userId: string,
    file: { originalname: string; mimetype: string; size: number; buffer: Buffer },
    purpose: string,
  ) {
    const fileId = randomUUID();
    const storageKey = `${tenantId}/${purpose}/${fileId}/${file.originalname}`;

    await this.s3.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: storageKey,
        Body: file.buffer,
        ContentType: file.mimetype,
      }),
    );

    const createdFile = await this.prisma.file.create({
      data: {
        tenantId,
        uploadedBy: userId,
        filename: file.originalname,
        mimeType: file.mimetype,
        sizeBytes: file.size,
        storageKey,
        purpose,
      },
    });

    return this.serializeFile(createdFile);
  }

  async getPresignedUploadUrl(
    tenantId: string,
    userId: string,
    filename: string,
    mimeType: string,
    purpose: string,
  ) {
    const fileId = randomUUID();
    const storageKey = `${tenantId}/${purpose}/${fileId}/${filename}`;

    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: storageKey,
      ContentType: mimeType,
    });

    const uploadUrl = await getSignedUrl(this.s3, command, { expiresIn: 900 });

    const file = await this.prisma.file.create({
      data: {
        tenantId,
        uploadedBy: userId,
        filename,
        mimeType,
        sizeBytes: 0,
        storageKey,
        purpose,
      },
    });

    return {
      uploadUrl,
      fileId: file.id,
      expiresAt: new Date(Date.now() + 900 * 1000).toISOString(),
    };
  }

  async findById(tenantId: string, fileId: string) {
    const file = await this.prisma.file.findFirst({
      where: { id: fileId, tenantId },
    });

    if (!file) {
      throw new NotFoundException('Archivo no encontrado');
    }

    const command = new GetObjectCommand({
      Bucket: this.bucket,
      Key: file.storageKey,
    });

    const url = await getSignedUrl(this.s3, command, { expiresIn: 900 });

    return { ...this.serializeFile(file), url };
  }

  getPublicFileUrl(fileId: string) {
    const expiresAt = Math.floor(Date.now() / 1000) + 60 * 60 * 24;
    const signature = this.signFileUrl(fileId, expiresAt);
    return `/files/public/${fileId}?expires=${expiresAt}&signature=${signature}`;
  }

  resolveStoredFileUrl(value?: string | null) {
    if (!value) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://') || value.startsWith('/')) {
      return value;
    }

    return this.getPublicFileUrl(value);
  }

  async getPublicFile(fileId: string, expires: string, signature: string) {
    const expiresAt = Number(expires);
    if (!Number.isFinite(expiresAt)) {
      throw new BadRequestException('Enlace de archivo inválido');
    }

    if (expiresAt < Math.floor(Date.now() / 1000)) {
      throw new BadRequestException('Enlace de archivo expirado');
    }

    const expectedSignature = this.signFileUrl(fileId, expiresAt);
    const expectedBuffer = Buffer.from(expectedSignature, 'hex');
    const actualBuffer = Buffer.from(signature, 'hex');

    if (
      expectedBuffer.length !== actualBuffer.length ||
      !timingSafeEqual(expectedBuffer, actualBuffer)
    ) {
      throw new BadRequestException('Firma de archivo inválida');
    }

    const file = await this.prisma.file.findUnique({
      where: { id: fileId },
    });

    if (!file) {
      throw new NotFoundException('Archivo no encontrado');
    }

    const object = await this.s3.send(
      new GetObjectCommand({
        Bucket: this.bucket,
        Key: file.storageKey,
      }),
    );

    const body = object.Body;
    if (!body || typeof body.transformToByteArray !== 'function') {
      throw new NotFoundException('No fue posible abrir el archivo');
    }

    const bytes = await body.transformToByteArray();

    return {
      ...this.serializeFile(file),
      buffer: Buffer.from(bytes),
    };
  }

  async findAll(
    tenantId: string,
    options?: { purpose?: string; page?: number; limit?: number },
  ) {
    const page = options?.page || 1;
    const limit = options?.limit || 20;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { tenantId };
    if (options?.purpose) where.purpose = options.purpose;

    const [data, total] = await Promise.all([
      this.prisma.file.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.file.count({ where }),
    ]);

    return {
      data: data.map((file) => this.serializeFile(file)),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasNextPage: page * limit < total,
        hasPreviousPage: page > 1,
      },
    };
  }

  async delete(tenantId: string, fileId: string) {
    const file = await this.prisma.file.findFirst({
      where: { id: fileId, tenantId },
    });

    if (!file) {
      throw new NotFoundException('Archivo no encontrado');
    }

    await this.s3.send(
      new DeleteObjectCommand({
        Bucket: this.bucket,
        Key: file.storageKey,
      }),
    );

    await this.prisma.file.delete({ where: { id: fileId } });

    return { success: true, message: 'Archivo eliminado' };
  }

  private serializeFile<T extends { sizeBytes: bigint | number }>(file: T) {
    return {
      ...file,
      sizeBytes: Number(file.sizeBytes),
    };
  }

  private signFileUrl(fileId: string, expiresAt: number) {
    return createHmac('sha256', this.fileLinkSecret)
      .update(`${fileId}:${expiresAt}`)
      .digest('hex');
  }
}
