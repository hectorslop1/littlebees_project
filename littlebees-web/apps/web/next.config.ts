import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  transpilePackages: ['@kinderspace/shared-types', '@kinderspace/shared-validators'],
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.amazonaws.com',
      },
    ],
  },
};

export default nextConfig;
