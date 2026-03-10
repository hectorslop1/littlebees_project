'use client';

import { Menu } from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';

interface MobileHeaderProps {
  onMenuClick: () => void;
}

export function MobileHeader({ onMenuClick }: MobileHeaderProps) {
  const { user } = useAuth();

  return (
    <header className="fixed top-0 left-0 right-0 z-30 flex h-14 items-center justify-between border-b bg-card px-4 lg:hidden">
      <button
        onClick={onMenuClick}
        className="rounded-lg p-2 hover:bg-primary-50 transition-colors"
      >
        <Menu className="h-5 w-5 text-muted" />
      </button>

      <div className="flex items-center">
        <img 
          src="/logo.png" 
          alt="Littlebees" 
          className="h-8 w-auto"
        />
      </div>

      <Avatar size="sm" name={user ? `${user.firstName} ${user.lastName}` : ''}>
        <AvatarFallback>
          {user?.firstName?.[0]}{user?.lastName?.[0]}
        </AvatarFallback>
      </Avatar>
    </header>
  );
}
