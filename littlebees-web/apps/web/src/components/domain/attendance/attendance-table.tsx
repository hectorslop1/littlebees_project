'use client';

import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { ClipboardList } from 'lucide-react';
import { Avatar } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { EmptyState } from '@/components/ui/empty-state';
import type { AttendanceRecordResponse } from '@kinderspace/shared-types';

interface AttendanceTableProps {
  records: AttendanceRecordResponse[];
  onCheckIn: (childId: string) => void;
  onCheckOut: (childId: string) => void;
  isLoading: boolean;
}

function formatTime(isoString: string | null): string {
  if (!isoString) return '\u2014';
  try {
    return format(new Date(isoString), 'hh:mm a', { locale: es });
  } catch {
    return '\u2014';
  }
}

type RecordRow = AttendanceRecordResponse & Record<string, unknown>;

export function AttendanceTable({
  records,
  onCheckIn,
  onCheckOut,
  isLoading,
}: AttendanceTableProps) {
  const columns: Column<RecordRow>[] = [
    {
      key: 'childName',
      header: 'Ni\u00f1o',
      render: (record) => (
        <div className="flex items-center gap-3">
          <Avatar size="sm" name={record.childName} />
          <span className="font-medium">{record.childName}</span>
        </div>
      ),
    },
    {
      key: 'group',
      header: 'Grupo',
      render: () => <span className="text-muted-foreground">\u2014</span>,
    },
    {
      key: 'checkInAt',
      header: 'Entrada',
      render: (record) => (
        <span className={record.checkInAt ? 'text-foreground' : 'text-muted-foreground'}>
          {formatTime(record.checkInAt)}
        </span>
      ),
    },
    {
      key: 'checkOutAt',
      header: 'Salida',
      render: (record) => (
        <span className={record.checkOutAt ? 'text-foreground' : 'text-muted-foreground'}>
          {formatTime(record.checkOutAt)}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Estado',
      render: (record) => (
        <StatusBadge status={record.status} />
      ),
    },
    {
      key: 'actions',
      header: 'Acciones',
      render: (record) => {
        if (!record.checkInAt) {
          return (
            <Button
              size="sm"
              variant="primary"
              onClick={(e) => {
                e.stopPropagation();
                onCheckIn(record.childId);
              }}
            >
              Registrar Entrada
            </Button>
          );
        }

        if (record.checkInAt && !record.checkOutAt) {
          return (
            <Button
              size="sm"
              variant="outline"
              onClick={(e) => {
                e.stopPropagation();
                onCheckOut(record.childId);
              }}
            >
              Registrar Salida
            </Button>
          );
        }

        return (
          <span className="text-xs text-muted-foreground">Completado</span>
        );
      },
    },
  ];

  const data: RecordRow[] = records.map((r) => ({ ...r }) as RecordRow);

  if (!isLoading && records.length === 0) {
    return (
      <EmptyState
        icon={<ClipboardList />}
        title="Sin registros de asistencia"
        description="No se encontraron registros de asistencia para la fecha seleccionada."
      />
    );
  }

  return (
    <DataTable<RecordRow>
      columns={columns}
      data={data}
      isLoading={isLoading}
      emptyMessage="No se encontraron registros de asistencia."
    />
  );
}
