import * as React from 'react';
import { cn } from '@/lib/utils';

interface ProgressProps {
  value: number;
  className?: string;
  color?: string;
}

const Progress = React.forwardRef<HTMLDivElement, ProgressProps>(
  ({ value, className, color }, ref) => {
    const clampedValue = Math.min(100, Math.max(0, value));

    return (
      <div
        ref={ref}
        className={cn('h-2 rounded-full bg-primary-50', className)}
      >
        <div
          className={cn(
            'h-full rounded-full transition-all duration-500',
            color || 'bg-primary'
          )}
          style={{ width: `${clampedValue}%` }}
        />
      </div>
    );
  }
);
Progress.displayName = 'Progress';

export { Progress };
export type { ProgressProps };
