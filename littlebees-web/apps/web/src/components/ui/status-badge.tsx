import * as React from 'react';
import { Badge, type BadgeProps } from './badge';

type StatusType =
  | 'active'
  | 'inactive'
  | 'present'
  | 'absent'
  | 'late'
  | 'excused'
  | 'paid'
  | 'pending'
  | 'overdue'
  | 'cancelled'
  | 'achieved'
  | 'in_progress'
  | 'not_achieved'
  | 'valid'
  | 'trial';

const statusVariantMap: Record<StatusType, BadgeProps['variant']> = {
  active: 'success',
  present: 'success',
  paid: 'success',
  achieved: 'success',
  valid: 'success',
  pending: 'warning',
  in_progress: 'warning',
  trial: 'warning',
  inactive: 'danger',
  absent: 'danger',
  overdue: 'danger',
  cancelled: 'danger',
  not_achieved: 'danger',
  late: 'info',
  excused: 'info',
};

const statusLabelMap: Record<StatusType, string> = {
  active: 'Activo',
  inactive: 'Inactivo',
  present: 'Presente',
  absent: 'Ausente',
  late: 'Tarde',
  excused: 'Justificado',
  paid: 'Pagado',
  pending: 'Pendiente',
  overdue: 'Vencido',
  cancelled: 'Cancelado',
  achieved: 'Logrado',
  in_progress: 'En progreso',
  not_achieved: 'No logrado',
  valid: 'Válida',
  trial: 'Prueba',
};

export interface StatusBadgeProps extends Omit<BadgeProps, 'variant'> {
  status: string;
}

const StatusBadge = React.forwardRef<HTMLDivElement, StatusBadgeProps>(
  ({ status, children, ...props }, ref) => {
    const variant = statusVariantMap[status as StatusType] || 'default';
    const label = statusLabelMap[status as StatusType] || status;

    return (
      <Badge ref={ref} variant={variant} {...props}>
        {children || label}
      </Badge>
    );
  }
);
StatusBadge.displayName = 'StatusBadge';

export { StatusBadge, statusVariantMap, statusLabelMap };
export type { StatusType };
