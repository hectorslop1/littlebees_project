import * as React from 'react';
import { cn } from '@/lib/utils';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  color?: string;
  className?: string;
}

function StatCard({ title, value, icon, trend, color, className }: StatCardProps) {
  return (
    <div className={cn('rounded-2xl bg-card p-5 shadow-card', className)}>
      <div className="flex items-start justify-between">
        <div className="space-y-1">
          <p className="text-sm text-muted">{title}</p>
          <p className="text-2xl font-bold text-foreground">{value}</p>
          {trend && (
            <div className="flex items-center gap-1">
              <svg
                width="12"
                height="12"
                viewBox="0 0 12 12"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                className={cn(
                  trend.isPositive ? 'text-green-500' : 'text-red-500 rotate-180'
                )}
              >
                <path
                  d="M6 2.5L10 7.5H2L6 2.5Z"
                  fill="currentColor"
                />
              </svg>
              <span
                className={cn(
                  'text-xs font-medium',
                  trend.isPositive ? 'text-green-500' : 'text-red-500'
                )}
              >
                {trend.value}%
              </span>
            </div>
          )}
        </div>
        <div
          className={cn(
            'flex h-10 w-10 items-center justify-center rounded-full',
            color || 'bg-primary-50 text-primary'
          )}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}

export { StatCard };
export type { StatCardProps };
