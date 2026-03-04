import * as React from 'react';
import { cn } from '@/lib/utils';

interface CircularProgressProps {
  value: number;
  size?: number;
  strokeWidth?: number;
  className?: string;
}

const CircularProgress = React.forwardRef<SVGSVGElement, CircularProgressProps>(
  ({ value, size = 80, strokeWidth = 6, className }, ref) => {
    const clampedValue = Math.min(100, Math.max(0, value));
    const radius = (size - strokeWidth) / 2;
    const circumference = radius * 2 * Math.PI;
    const offset = circumference - (clampedValue / 100) * circumference;

    return (
      <div className={cn('relative inline-flex items-center justify-center', className)}>
        <svg
          ref={ref}
          width={size}
          height={size}
          viewBox={`0 0 ${size} ${size}`}
          className="-rotate-90"
        >
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            stroke="currentColor"
            strokeWidth={strokeWidth}
            className="text-primary-100"
          />
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            stroke="currentColor"
            strokeWidth={strokeWidth}
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            strokeLinecap="round"
            className="text-primary transition-all duration-500"
          />
        </svg>
        <span className="absolute text-sm font-semibold text-foreground">
          {Math.round(clampedValue)}%
        </span>
      </div>
    );
  }
);
CircularProgress.displayName = 'CircularProgress';

export { CircularProgress };
export type { CircularProgressProps };
