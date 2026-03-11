import { LucideIcon } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

interface QuickAction {
  label: string;
  icon: LucideIcon;
  onClick: () => void;
  variant?: 'primary' | 'outline' | 'secondary' | 'ghost' | 'danger';
}

interface QuickActionsProps {
  title?: string;
  actions: QuickAction[];
}

export function QuickActions({ title = 'Acciones Rápidas', actions }: QuickActionsProps) {
  return (
    <Card className="p-6">
      <h3 className="text-lg font-semibold font-heading mb-4">{title}</h3>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
        {actions.map((action, index) => {
          const Icon = action.icon;
          return (
            <Button
              key={index}
              variant={action.variant || 'outline'}
              className="justify-start h-auto py-3"
              onClick={action.onClick}
            >
              <Icon className="h-4 w-4 mr-2 shrink-0" />
              <span className="text-sm">{action.label}</span>
            </Button>
          );
        })}
      </div>
    </Card>
  );
}
