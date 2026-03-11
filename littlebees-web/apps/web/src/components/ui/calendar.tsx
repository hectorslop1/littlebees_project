'use client';

import * as React from 'react';
import { DayPicker } from 'react-day-picker';
import { es } from 'date-fns/locale';

import { cn } from '@/lib/utils';
import { buttonVariants } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

export type CalendarProps = React.ComponentProps<typeof DayPicker>;

function Calendar({
  className,
  classNames,
  showOutsideDays = false,
  ...props
}: CalendarProps) {
  const [month, setMonth] = React.useState<Date>(() => {
    if ('selected' in props && props.selected instanceof Date) {
      return props.selected;
    }
    return new Date();
  });

  React.useEffect(() => {
    if ('selected' in props && props.selected instanceof Date) {
      setMonth(props.selected);
    }
  }, [props]);

  const years = React.useMemo(() => {
    const currentYear = new Date().getFullYear();
    const startYear = currentYear - 100;
    return Array.from({ length: 101 }, (_, i) => startYear + i);
  }, []);

  const months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  const weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  return (
    <div className="p-3">
      <div className="flex justify-center gap-2 mb-4">
        <Select
          value={month.getMonth().toString()}
          onValueChange={(value) => {
            const newDate = new Date(month);
            newDate.setMonth(parseInt(value));
            setMonth(newDate);
          }}
        >
          <SelectTrigger className="w-[130px]">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {months.map((m, i) => (
              <SelectItem key={i} value={i.toString()}>
                {m}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Select
          value={month.getFullYear().toString()}
          onValueChange={(value) => {
            const newDate = new Date(month);
            newDate.setFullYear(parseInt(value));
            setMonth(newDate);
          }}
        >
          <SelectTrigger className="w-[100px]">
            <SelectValue />
          </SelectTrigger>
          <SelectContent className="max-h-[200px]">
            {years.reverse().map((year) => (
              <SelectItem key={year} value={year.toString()}>
                {year}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Custom weekday headers */}
      <div className="flex justify-between mb-2 px-1">
        {weekDays.map((day) => (
          <div key={day} className="w-10 text-center text-xs font-medium text-muted-foreground">
            {day}
          </div>
        ))}
      </div>

      <DayPicker
        locale={es}
        showOutsideDays={showOutsideDays}
        month={month}
        onMonthChange={setMonth}
        weekStartsOn={1}
        className={cn('', className)}
        components={{
          CaptionLabel: () => <></>,
          Nav: () => <></>,
        }}
        classNames={{
          months: 'flex flex-col sm:flex-row',
          month: 'space-y-2',
          month_caption: 'hidden',
          caption: 'hidden',
          caption_label: 'hidden',
          button_previous: 'hidden',
          button_next: 'hidden',
          nav: 'hidden',
          month_grid: 'w-full border-collapse space-y-1',
          weekdays: 'hidden',
          weekday: 'hidden',
          week: 'flex w-full mt-2',
          day: 'h-10 w-10 text-center text-sm p-0 relative [&:has([aria-selected].day-range-end)]:rounded-r-md [&:has([aria-selected].day-outside)]:bg-accent/50 [&:has([aria-selected])]:bg-accent first:[&:has([aria-selected])]:rounded-l-md last:[&:has([aria-selected])]:rounded-r-md focus-within:relative focus-within:z-20',
          day_button: cn(
            buttonVariants({ variant: 'ghost' }),
            'h-10 w-10 p-0 font-normal aria-selected:opacity-100'
          ),
          range_end: 'day-range-end',
          selected:
            'bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground',
          today: 'bg-accent text-accent-foreground',
          outside:
            'day-outside text-muted-foreground opacity-50 aria-selected:bg-accent/50 aria-selected:text-muted-foreground aria-selected:opacity-30',
          disabled: 'text-muted-foreground opacity-50',
          range_middle:
            'aria-selected:bg-accent aria-selected:text-accent-foreground',
          hidden: 'invisible',
          ...classNames,
        }}
        {...props}
      />
    </div>
  );
}
Calendar.displayName = 'Calendar';

export { Calendar };
