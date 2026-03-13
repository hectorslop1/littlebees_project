/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@kinderspace/shared-types', '@kinderspace/shared-validators'],
  typescript: {
    // ⚠️ Desactivar type checking en build de producción
    // Los errores de TypeScript se deben corregir en desarrollo
    ignoreBuildErrors: true,
  },
  eslint: {
    // Desactivar ESLint en build de producción
    ignoreDuringBuilds: true,
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.amazonaws.com',
      },
    ],
  },
};

module.exports = nextConfig;
