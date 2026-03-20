'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/use-auth';
import { DayScheduleTimeline } from '@/components/domain/day/day-schedule-timeline';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Calendar } from 'lucide-react';

export default function DayPage() {
  const { user } = useAuth();
  const [selectedDate, setSelectedDate] = useState(new Date());

  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('es-MX', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    }).format(date);
  };

  const goToPreviousDay = () => {
    const newDate = new Date(selectedDate);
    newDate.setDate(newDate.getDate() - 1);
    setSelectedDate(newDate);
  };

  const goToNextDay = () => {
    const newDate = new Date(selectedDate);
    newDate.setDate(newDate.getDate() + 1);
    setSelectedDate(newDate);
  };

  const goToToday = () => {
    setSelectedDate(new Date());
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold font-heading">Programación del Día</h1>
          <p className="text-muted-foreground mt-1">
            {formatDate(selectedDate)}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={goToPreviousDay}>
            ← Día anterior
          </Button>
          <Button variant="outline" size="sm" onClick={goToToday}>
            <Calendar className="h-4 w-4 mr-2" />
            Hoy
          </Button>
          <Button variant="outline" size="sm" onClick={goToNextDay}>
            Día siguiente →
          </Button>
        </div>
      </div>

      <Card className="p-6">
        <DayScheduleTimeline date={selectedDate} userRole={user?.role} />
      </Card>
    </div>
  );
}
