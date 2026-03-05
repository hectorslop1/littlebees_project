/** @type {import('next').NextConfig} */
const nextConfig = {
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

module.exports = nextConfig;
