import { Injectable, NotFoundException, OnModuleInit } from '@nestjs/common';
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
import { randomUUID } from 'crypto';

@Injectable()
export class FilesService implements OnModuleInit {
  private s3: S3Client;
  private bucket: string;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {
    const endpoint = this.config.get<string>('MINIO_ENDPOINT', 'http://localhost:9000');
    const accessKey = this.config.get<string>('MINIO_ACCESS_KEY', 'kinderspace');
    const secretKey = this.config.get<string>('MINIO_SECRET_KEY', 'kinderspace123');
    this.bucket = this.config.get<string>('MINIO_BUCKET', 'kinderspace-files');

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

    return this.prisma.file.create({
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

    return { ...file, url };
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
      data,
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
}
