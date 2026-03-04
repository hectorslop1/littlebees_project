'use client';

import * as React from 'react';
import * as AvatarPrimitive from '@radix-ui/react-avatar';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const avatarVariants = cva(
  'relative flex shrink-0 overflow-hidden rounded-full',
  {
    variants: {
      size: {
        xs: 'h-6 w-6',
        sm: 'h-8 w-8',
        md: 'h-10 w-10',
        lg: 'h-12 w-12',
        xl: 'h-16 w-16',
      },
    },
    defaultVariants: {
      size: 'md',
    },
  }
);

const avatarFallbackTextVariants = cva('', {
  variants: {
    size: {
      xs: 'text-[10px]',
      sm: 'text-xs',
      md: 'text-sm',
      lg: 'text-base',
      xl: 'text-lg',
    },
  },
  defaultVariants: {
    size: 'md',
  },
});

const statusDotVariants = cva(
  'absolute bottom-0 right-0 block rounded-full border-2 border-white bg-green-500',
  {
    variants: {
      size: {
        xs: 'h-1.5 w-1.5',
        sm: 'h-2 w-2',
        md: 'h-2.5 w-2.5',
        lg: 'h-3 w-3',
        xl: 'h-4 w-4',
      },
    },
    defaultVariants: {
      size: 'md',
    },
  }
);

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((part) => part.charAt(0))
    .join('')
    .toUpperCase()
    .slice(0, 2);
}

export interface AvatarProps
  extends React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>,
    VariantProps<typeof avatarVariants> {
  name?: string;
  src?: string;
  alt?: string;
  online?: boolean;
}

const Avatar = React.forwardRef<
  React.ComponentRef<typeof AvatarPrimitive.Root>,
  AvatarProps
>(({ className, size, name, src, alt, online, ...props }, ref) => (
  <div className="relative inline-flex">
    <AvatarPrimitive.Root
      ref={ref}
      className={cn(avatarVariants({ size }), className)}
      {...props}
    >
      {src && (
        <AvatarImage src={src} alt={alt || name || 'Avatar'} />
      )}
      <AvatarFallback size={size}>
        {name ? getInitials(name) : '?'}
      </AvatarFallback>
    </AvatarPrimitive.Root>
    {online && (
      <span className={cn(statusDotVariants({ size }))} />
    )}
  </div>
));
Avatar.displayName = 'Avatar';

const AvatarImage = React.forwardRef<
  React.ComponentRef<typeof AvatarPrimitive.Image>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Image
    ref={ref}
    className={cn('aspect-square h-full w-full', className)}
    {...props}
  />
));
AvatarImage.displayName = AvatarPrimitive.Image.displayName;

export interface AvatarFallbackProps
  extends React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>,
    VariantProps<typeof avatarFallbackTextVariants> {}

const AvatarFallback = React.forwardRef<
  React.ComponentRef<typeof AvatarPrimitive.Fallback>,
  AvatarFallbackProps
>(({ className, size, ...props }, ref) => (
  <AvatarPrimitive.Fallback
    ref={ref}
    className={cn(
      'flex h-full w-full items-center justify-center rounded-full bg-primary-100 text-primary-700 font-medium',
      avatarFallbackTextVariants({ size }),
      className
    )}
    {...props}
  />
));
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName;

export { Avatar, AvatarImage, AvatarFallback };
