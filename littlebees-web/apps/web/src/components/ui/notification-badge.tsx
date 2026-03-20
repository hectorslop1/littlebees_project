import { cn } from '@/lib/utils';

interface NotificationBadgeProps {
  count: number;
  max?: number;
  className?: string;
  show?: boolean;
}

export function NotificationBadge({ 
  count, 
  max = 99, 
  className,
  show = true 
}: NotificationBadgeProps) {
  if (!show || count === 0) return null;

  const displayCount = count > max ? `${max}+` : count;

  return (
    <span
      className={cn(
        'absolute -top-1 -right-1 flex h-5 min-w-[20px] items-center justify-center rounded-full bg-red-500 px-1 text-[10px] font-bold text-white',
        className
      )}
    >
      {displayCount}
    </span>
  );
}
