import * as React from 'react';
import { cn } from '@/lib/utils';
import { Skeleton } from '@/components/ui/skeleton';

interface Column<T> {
  key: string;
  header: string;
  render?: (item: T) => React.ReactNode;
  className?: string;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  onRowClick?: (item: T) => void;
  emptyMessage?: string;
  isLoading?: boolean;
  className?: string;
}

function DataTable<T extends Record<string, unknown>>({
  columns,
  data,
  onRowClick,
  emptyMessage = 'No data available',
  isLoading = false,
  className,
}: DataTableProps<T>) {
  return (
    <div className={cn('overflow-x-auto rounded-xl border', className)}>
      <table className="w-full divide-y divide-border">
        <thead className="bg-gray-50">
          <tr>
            {columns.map((column) => (
              <th
                key={column.key}
                className={cn(
                  'px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-muted-foreground',
                  column.className
                )}
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-border bg-card">
          {isLoading ? (
            Array.from({ length: 5 }).map((_, rowIndex) => (
              <tr key={rowIndex}>
                {columns.map((column) => (
                  <td key={column.key} className="px-4 py-3">
                    <Skeleton className="h-4 w-3/4" />
                  </td>
                ))}
              </tr>
            ))
          ) : data.length === 0 ? (
            <tr>
              <td
                colSpan={columns.length}
                className="px-4 py-12 text-center text-sm text-muted-foreground"
              >
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((item, rowIndex) => (
              <tr
                key={rowIndex}
                className={cn(
                  'transition-colors hover:bg-gray-50',
                  onRowClick && 'cursor-pointer'
                )}
                onClick={() => onRowClick?.(item)}
              >
                {columns.map((column) => (
                  <td
                    key={column.key}
                    className={cn(
                      'whitespace-nowrap px-4 py-3 text-sm text-foreground',
                      column.className
                    )}
                  >
                    {column.render
                      ? column.render(item)
                      : (item[column.key] as React.ReactNode)}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}

export { DataTable };
export type { DataTableProps, Column };
