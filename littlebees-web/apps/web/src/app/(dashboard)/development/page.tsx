'use client';

import { useState, useMemo } from 'react';
import { Plus, TrendingUp } from 'lucide-react';
import { DevelopmentCategory } from '@kinderspace/shared-types';
import { useChildren } from '@/hooks/use-children';
import {
  useDevelopmentSummary,
  useDevelopmentRecords,
} from '@/hooks/use-development';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import { EmptyState } from '@/components/ui/empty-state';
import { CategoryOverviewCards } from '@/components/domain/development/category-overview-cards';
import { MilestonesList } from '@/components/domain/development/milestones-list';
import { EvaluationFormDialog } from '@/components/domain/development/evaluation-form-dialog';

const CATEGORY_FILTER_OPTIONS: { value: string; label: string }[] = [
  { value: 'all', label: 'Todas las categorías' },
  { value: DevelopmentCategory.MOTOR_FINE, label: 'Motriz Fina' },
  { value: DevelopmentCategory.MOTOR_GROSS, label: 'Motriz Gruesa' },
  { value: DevelopmentCategory.COGNITIVE, label: 'Cognitivo' },
  { value: DevelopmentCategory.LANGUAGE, label: 'Lenguaje' },
  { value: DevelopmentCategory.SOCIAL, label: 'Social' },
  { value: DevelopmentCategory.EMOTIONAL, label: 'Emocional' },
];

export default function DevelopmentPage() {
  const [selectedChildId, setSelectedChildId] = useState<string>('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [showEvalDialog, setShowEvalDialog] = useState(false);

  const { data: childrenData } = useChildren();

  const { data: summary, isLoading: summaryLoading } =
    useDevelopmentSummary(selectedChildId);

  const recordsParams = useMemo(
    () => ({
      childId: selectedChildId || undefined,
      ...(selectedCategory !== 'all' ? { category: selectedCategory } : {}),
    }),
    [selectedChildId, selectedCategory],
  );

  const { data: recordsData, isLoading: recordsLoading } =
    useDevelopmentRecords(recordsParams);

  const records = useMemo(() => recordsData?.data ?? [], [recordsData]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-2xl font-bold font-heading">Desarrollo</h1>

        <div className="flex flex-wrap items-center gap-3">
          {/* Child selector */}
          <Select value={selectedChildId} onValueChange={setSelectedChildId}>
            <SelectTrigger className="w-[220px]">
              <SelectValue placeholder="Selecciona un niño" />
            </SelectTrigger>
            <SelectContent>
              {childrenData?.data?.map((child) => (
                <SelectItem key={child.id} value={child.id}>
                  {child.firstName} {child.lastName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {selectedChildId && (
            <Button onClick={() => setShowEvalDialog(true)}>
              <Plus className="h-4 w-4" />
              Agregar Evaluación
            </Button>
          )}
        </div>
      </div>

      {/* Content */}
      {!selectedChildId ? (
        <EmptyState
          icon={<TrendingUp />}
          title="Selecciona un niño"
          description="Selecciona un niño para ver su desarrollo y evaluaciones."
        />
      ) : summaryLoading ? (
        <div className="space-y-6">
          {/* Category cards skeleton */}
          <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-6">
            {Array.from({ length: 6 }).map((_, i) => (
              <Skeleton key={i} className="h-40 w-full rounded-2xl" />
            ))}
          </div>
          {/* Records skeleton */}
          <Skeleton className="h-10 w-48 rounded-xl" />
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-24 w-full rounded-2xl" />
            ))}
          </div>
        </div>
      ) : (
        <>
          {/* Summary info */}
          {summary && (
            <p className="text-sm text-muted-foreground">
              {summary.childName} &mdash; {summary.ageMonths} meses de edad
            </p>
          )}

          {/* Category overview cards */}
          {summary?.categories && (
            <CategoryOverviewCards categories={summary.categories} />
          )}

          {/* Category filter + records */}
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <Select
                value={selectedCategory}
                onValueChange={setSelectedCategory}
              >
                <SelectTrigger className="w-[220px]">
                  <SelectValue placeholder="Filtrar por categoría" />
                </SelectTrigger>
                <SelectContent>
                  {CATEGORY_FILTER_OPTIONS.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {recordsLoading ? (
              <div className="space-y-3">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-24 w-full rounded-2xl" />
                ))}
              </div>
            ) : (
              <MilestonesList records={records} />
            )}
          </div>
        </>
      )}

      {/* Evaluation form dialog */}
      {selectedChildId && (
        <EvaluationFormDialog
          open={showEvalDialog}
          onOpenChange={setShowEvalDialog}
          childId={selectedChildId}
        />
      )}
    </div>
  );
}
