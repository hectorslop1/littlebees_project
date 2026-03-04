'use client';

import { Card, CardContent } from '@/components/ui/card';
import { Avatar } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { StatusBadge } from '@/components/ui/status-badge';
import type { ChildResponse } from '@kinderspace/shared-types';

interface ChildCardProps {
  child: ChildResponse;
  onClick: (child: ChildResponse) => void;
}

export function ChildCard({ child, onClick }: ChildCardProps) {
  const fullName = `${child.firstName} ${child.lastName}`;

  return (
    <Card
      hover
      className="cursor-pointer"
      onClick={() => onClick(child)}
    >
      <CardContent className="flex flex-col items-center gap-3 p-6">
        <Avatar
          size="xl"
          name={fullName}
          src={child.photoUrl ?? undefined}
        />

        <div className="text-center">
          <p className="text-sm font-semibold text-foreground">
            {fullName}
          </p>
          <p className="text-xs text-muted-foreground">
            {child.age} anos
          </p>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-2">
          <Badge variant="secondary" size="sm">
            {child.groupName}
          </Badge>
          <StatusBadge status={child.status} />
        </div>
      </CardContent>
    </Card>
  );
}
