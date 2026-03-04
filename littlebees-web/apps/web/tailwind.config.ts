import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: ['class'],
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: { '2xl': '1400px' },
    },
    extend: {
      colors: {
        primary: {
          DEFAULT: '#4ECDC4',
          50: '#E8F8F7',
          100: '#D1F1EF',
          200: '#A3E3DF',
          300: '#75D5CF',
          400: '#4ECDC4',
          500: '#35B5AC',
          600: '#2A908A',
          700: '#1F6C67',
          800: '#154845',
          900: '#0A2422',
        },
        secondary: {
          DEFAULT: '#FF6B6B',
          50: '#FFF0F0',
          100: '#FFE0E0',
          200: '#FFC2C2',
          300: '#FFA3A3',
          400: '#FF8585',
          500: '#FF6B6B',
          600: '#FF3333',
          700: '#FA0000',
          800: '#C20000',
          900: '#8A0000',
        },
        accent: {
          DEFAULT: '#FFE66D',
          50: '#FFFDF0',
          100: '#FFFBE0',
          200: '#FFF7C2',
          300: '#FFF3A3',
          400: '#FFEF85',
          500: '#FFE66D',
          600: '#FFDB35',
          700: '#FCCC00',
          800: '#C49F00',
          900: '#8C7200',
        },
        success: { DEFAULT: '#00B894', 50: '#E6F9F4' },
        warning: { DEFAULT: '#FDCB6E', 50: '#FFF8E6' },
        destructive: { DEFAULT: '#E17055', 50: '#FDF0ED' },
        background: '#F7F9FC',
        foreground: '#2D3436',
        muted: { DEFAULT: '#636E72', foreground: '#B2BEC3' },
        card: { DEFAULT: '#FFFFFF', foreground: '#2D3436' },
        popover: { DEFAULT: '#FFFFFF', foreground: '#2D3436' },
        input: '#DFE6E9',
        border: '#DFE6E9',
        ring: '#4ECDC4',
      },
      fontFamily: {
        heading: ['Quicksand', 'sans-serif'],
        body: ['Nunito', 'Inter', 'sans-serif'],
      },
      borderRadius: {
        card: '12px',
      },
      boxShadow: {
        card: '0 4px 6px rgba(0,0,0,0.05)',
        'card-hover': '0 8px 25px rgba(0,0,0,0.1)',
      },
      keyframes: {
        'fade-in': { from: { opacity: '0' }, to: { opacity: '1' } },
        'slide-in': { from: { opacity: '0', transform: 'translateY(10px)' }, to: { opacity: '1', transform: 'translateY(0)' } },
        'accordion-down': { from: { height: '0' }, to: { height: 'var(--radix-accordion-content-height)' } },
        'accordion-up': { from: { height: 'var(--radix-accordion-content-height)' }, to: { height: '0' } },
      },
      animation: {
        'fade-in': 'fade-in 0.3s ease-out',
        'slide-in': 'slide-in 0.3s ease-out',
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
};

export default config;
