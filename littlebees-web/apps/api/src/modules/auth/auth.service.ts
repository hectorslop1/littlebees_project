import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as argon2 from 'argon2';
import { PrismaService } from '../prisma/prisma.service';
import { LoginRequest, JwtPayload, RefreshTokenRequest, UserRole } from '@kinderspace/shared-types';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

  async login(dto: LoginRequest) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
      include: {
        userTenants: {
          where: { active: true },
          take: 1,
        },
      },
    });

    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const passwordValid = await argon2.verify(user.passwordHash, dto.password);
    if (!passwordValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    if (user.userTenants.length === 0) {
      throw new UnauthorizedException('Usuario sin acceso a ninguna institución');
    }

    const userTenant = user.userTenants[0];

    // Check MFA
    if (user.mfaEnabled) {
      const tempToken = this.jwtService.sign(
        { sub: user.id, mfa: true },
        { expiresIn: '5m' },
      );
      return { mfaRequired: true, tempToken };
    }

    return this.generateTokens(user.id, userTenant.tenantId, userTenant.role as UserRole);
  }

  async refresh(dto: RefreshTokenRequest) {
    if (!dto.refreshToken?.trim()) {
      throw new UnauthorizedException('Refresh token requerido');
    }

    const payload = await this.verifyRefreshToken(dto.refreshToken);

    const userTenant = await this.prisma.userTenant.findFirst({
      where: {
        userId: payload.sub,
        tenantId: payload.tid,
        active: true,
      },
      select: {
        tenantId: true,
        role: true,
      },
    });

    if (!userTenant) {
      throw new UnauthorizedException('Acceso a institución inválido');
    }

    const storedRefreshToken = await this.findStoredRefreshToken(payload.sub, dto.refreshToken);
    if (!storedRefreshToken) {
      throw new UnauthorizedException('Refresh token inválido');
    }

    await this.prisma.refreshToken.update({
      where: { id: storedRefreshToken.id },
      data: { revoked: true },
    });

    return this.generateTokens(payload.sub, userTenant.tenantId, userTenant.role as UserRole);
  }

  async generateTokens(userId: string, tenantId: string, role: UserRole) {
    const payload: Omit<JwtPayload, 'iat' | 'exp' | 'iss'> = {
      sub: userId,
      tid: tenantId,
      role,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, {
        secret: this.config.get('JWT_REFRESH_SECRET'),
        expiresIn: this.config.get('JWT_REFRESH_EXPIRES_IN', '7d'),
      }),
    ]);

    // Store refresh token hash in database
    const tokenHash = await argon2.hash(refreshToken);
    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        phone: true,
        avatarUrl: true,
        mfaEnabled: true,
      },
    });

    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: { id: true, name: true, slug: true, logoUrl: true },
    });

    return {
      accessToken,
      refreshToken,
      user: { ...user, role },
      tenant,
    };
  }

  async getMe(userId: string, tenantId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        phone: true,
        avatarUrl: true,
        mfaEnabled: true,
        userTenants: {
          where: { tenantId, active: true },
          select: { role: true },
          take: 1,
        },
      },
    });

    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: { id: true, name: true, slug: true, logoUrl: true },
    });

    const role = user?.userTenants[0]?.role;
    const { userTenants, ...userData } = user || {};

    return {
      user: { ...userData, role },
      tenant,
    };
  }

  async hashPassword(password: string): Promise<string> {
    return argon2.hash(password);
  }

  private async verifyRefreshToken(refreshToken: string): Promise<JwtPayload> {
    try {
      return await this.jwtService.verifyAsync<JwtPayload>(refreshToken, {
        secret: this.config.get<string>('JWT_REFRESH_SECRET'),
      });
    } catch {
      throw new UnauthorizedException('Refresh token inválido');
    }
  }

  private async findStoredRefreshToken(userId: string, refreshToken: string) {
    const candidates = await this.prisma.refreshToken.findMany({
      where: {
        userId,
        revoked: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    for (const candidate of candidates) {
      const matches = await argon2.verify(candidate.tokenHash, refreshToken);
      if (matches) {
        return candidate;
      }
    }

    return null;
  }
}
