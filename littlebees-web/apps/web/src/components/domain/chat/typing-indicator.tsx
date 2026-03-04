'use client';

interface TypingIndicatorProps {
  users: string[];
}

export function TypingIndicator({ users }: TypingIndicatorProps) {
  if (users.length === 0) return null;

  const text =
    users.length === 1
      ? `${users[0]} esta escribiendo`
      : `${users.join(', ')} estan escribiendo`;

  return (
    <div className="flex items-center gap-2 px-4 py-1.5">
      <div className="flex items-center gap-0.5">
        <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-muted-foreground [animation-delay:0ms]" />
        <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-muted-foreground [animation-delay:150ms]" />
        <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-muted-foreground [animation-delay:300ms]" />
      </div>
      <span className="text-xs text-muted-foreground italic">{text}...</span>
    </div>
  );
}
