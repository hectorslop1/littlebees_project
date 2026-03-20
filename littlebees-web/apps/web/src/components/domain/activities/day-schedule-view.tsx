'use client';

import { useDaySchedule } from '@/hooks/use-daily-logs';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { 
  CheckCircle2, 
  Circle, 
  Clock,
  Users,
  UserCheck,
  UserX,
  LogIn,
  Utensils,
  Moon,
  Activity,
  LogOut
} from 'lucide-react';
import { useState } from 'react';
import { QuickRegisterDialog } from './quick-register-dialog';

interface DayScheduleViewProps {
  groupId: string;
  date?: string;
}

const activityIcons = {
  check_in: LogIn,
  meal: Utensils,
  nap: Moon,
  activity: Activity,
  check_out: LogOut,
};

export function DayScheduleView({ groupId, date }: DayScheduleViewProps) {
  const { data: schedule, isLoading } = useDaySchedule(groupId, date);
  const [selectedChild, setSelectedChild] = useState<{ id: string; name: string } | null>(null);
  const [registerDialogOpen, setRegisterDialogOpen] = useState(false);

  if (isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (!schedule) {
    return (
      <Card>
        <CardContent className="pt-6">
          <p className="text-center text-muted-foreground">
            No se pudo cargar la programación del día
          </p>
        </CardContent>
      </Card>
    );
  }

  const handleQuickRegister = (childId: string, firstName: string, lastName: string) => {
    setSelectedChild({ id: childId, name: `${firstName} ${lastName}` });
    setRegisterDialogOpen(true);
  };

  return (
    <div className="space-y-6">
      {/* Estadísticas del grupo */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total de Niños</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{schedule.totalChildren}</div>
            <p className="text-xs text-muted-foreground">En el grupo {schedule.groupName}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Presentes</CardTitle>
            <UserCheck className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{schedule.presentChildren}</div>
            <p className="text-xs text-muted-foreground">
              {((schedule.presentChildren / schedule.totalChildren) * 100).toFixed(0)}% de asistencia
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Ausentes</CardTitle>
            <UserX className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{schedule.absentChildren}</div>
            <p className="text-xs text-muted-foreground">Sin registro de entrada</p>
          </CardContent>
        </Card>
      </div>

      {/* Timeline del día */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Clock className="h-5 w-5" />
            Programación del Día
          </CardTitle>
          <CardDescription>
            {new Date(schedule.date).toLocaleDateString('es-MX', {
              weekday: 'long',
              year: 'numeric',
              month: 'long',
              day: 'numeric',
            })}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {schedule.schedule.map((item: any, index: number) => {
              const Icon = activityIcons[item.type as keyof typeof activityIcons] || Activity;
              return (
                <div
                  key={index}
                  className="flex items-center gap-3 rounded-lg border p-3 hover:bg-accent/50 transition-colors"
                >
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10">
                    <Icon className="h-5 w-5 text-primary" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium">{item.label}</p>
                    <p className="text-sm text-muted-foreground">{item.time}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Estado de los niños */}
      <Card>
        <CardHeader>
          <CardTitle>Estado de Actividades por Niño</CardTitle>
          <CardDescription>
            Haz clic en un niño para registrar una actividad
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {schedule.children.map((child: any) => (
              <div
                key={child.childId}
                className="flex items-center gap-4 rounded-lg border p-4 hover:bg-accent/50 transition-colors cursor-pointer"
                onClick={() => handleQuickRegister(child.childId, child.firstName, child.lastName)}
              >
                {/* Avatar y nombre */}
                <Avatar className="h-12 w-12">
                  <AvatarImage src={child.photoUrl} alt={child.firstName} />
                  <AvatarFallback>
                    {child.firstName[0]}
                    {child.lastName[0]}
                  </AvatarFallback>
                </Avatar>

                <div className="flex-1 min-w-0">
                  <p className="font-medium truncate">
                    {child.firstName} {child.lastName}
                  </p>
                  <div className="flex items-center gap-2 mt-1">
                    {child.checkInTime && (
                      <Badge variant="secondary" className="text-xs">
                        Entrada: {child.checkInTime}
                      </Badge>
                    )}
                    {child.checkOutTime && (
                      <Badge variant="secondary" className="text-xs">
                        Salida: {child.checkOutTime}
                      </Badge>
                    )}
                  </div>
                  {child.lastActivity && (
                    <p className="text-xs text-muted-foreground mt-1">
                      Última: {child.lastActivity}
                    </p>
                  )}
                </div>

                {/* Indicadores de actividades */}
                <div className="flex items-center gap-2">
                  <div className="flex items-center gap-1" title="Entrada">
                    {child.hasCheckIn ? (
                      <CheckCircle2 className="h-5 w-5 text-green-600" />
                    ) : (
                      <Circle className="h-5 w-5 text-gray-300" />
                    )}
                  </div>
                  <div className="flex items-center gap-1" title="Comida">
                    {child.hasMeal ? (
                      <CheckCircle2 className="h-5 w-5 text-orange-600" />
                    ) : (
                      <Circle className="h-5 w-5 text-gray-300" />
                    )}
                  </div>
                  <div className="flex items-center gap-1" title="Siesta">
                    {child.hasNap ? (
                      <CheckCircle2 className="h-5 w-5 text-blue-600" />
                    ) : (
                      <Circle className="h-5 w-5 text-gray-300" />
                    )}
                  </div>
                  <div className="flex items-center gap-1" title="Actividad">
                    {child.hasActivity ? (
                      <CheckCircle2 className="h-5 w-5 text-purple-600" />
                    ) : (
                      <Circle className="h-5 w-5 text-gray-300" />
                    )}
                  </div>
                  <div className="flex items-center gap-1" title="Salida">
                    {child.hasCheckOut ? (
                      <CheckCircle2 className="h-5 w-5 text-red-600" />
                    ) : (
                      <Circle className="h-5 w-5 text-gray-300" />
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Dialog de registro rápido */}
      {selectedChild && (
        <QuickRegisterDialog
          open={registerDialogOpen}
          onOpenChange={setRegisterDialogOpen}
          childId={selectedChild.id}
          childName={selectedChild.name}
        />
      )}
    </div>
  );
}
