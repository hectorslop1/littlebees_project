'use client';

import { UserCheck, Mail, Phone } from 'lucide-react';
import { useUsers } from '@/hooks/use-users';
import { Badge } from '@/components/ui/badge';

export default function TeachersPage() {
  const { data: users, isLoading } = useUsers();

  const teachers = users?.filter((user: any) => 
    user.userTenants[0]?.role === 'teacher'
  ) || [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Maestras</h1>
        <p className="text-muted-foreground">Vista del equipo docente</p>
      </div>

      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="h-48 rounded-lg bg-gray-100 animate-pulse" />
          ))}
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {teachers.map((teacher: any) => (
            <div
              key={teacher.id}
              className="rounded-lg border bg-card p-6 space-y-4 hover:shadow-md transition-shadow"
            >
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary-50">
                    <UserCheck className="h-6 w-6 text-primary" />
                  </div>
                  <div>
                    <h3 className="font-semibold">
                      {teacher.firstName} {teacher.lastName}
                    </h3>
                    <Badge className="mt-1 bg-yellow-100 text-yellow-800">
                      Maestra
                    </Badge>
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-sm">
                <div className="flex items-center gap-2 text-muted-foreground">
                  <Mail className="h-4 w-4" />
                  <span>{teacher.email}</span>
                </div>
                {teacher.phone && (
                  <div className="flex items-center gap-2 text-muted-foreground">
                    <Phone className="h-4 w-4" />
                    <span>{teacher.phone}</span>
                  </div>
                )}
              </div>

              <div className="pt-4 border-t">
                <p className="text-sm text-muted-foreground">
                  Miembro del equipo docente
                </p>
              </div>
            </div>
          ))}
        </div>
      )}

      {!isLoading && teachers.length === 0 && (
        <div className="text-center py-12">
          <UserCheck className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
          <h3 className="text-lg font-semibold mb-2">No hay maestras registradas</h3>
          <p className="text-muted-foreground">
            Los usuarios con rol de maestra aparecerán aquí
          </p>
        </div>
      )}
    </div>
  );
}
