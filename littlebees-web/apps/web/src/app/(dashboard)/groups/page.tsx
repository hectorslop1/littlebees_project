'use client';

import { useState } from 'react';
import { useGroups } from '@/hooks/use-groups';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Users, Calendar, Baby } from 'lucide-react';

export default function GroupsPage() {
  const { data: groupsResponse, isLoading, error } = useGroups();
  
  // Extraer el array de grupos de la respuesta paginada
  const groups = Array.isArray(groupsResponse) ? groupsResponse : (groupsResponse as any)?.data || [];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Cargando grupos...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="text-red-500 mb-4">
            <svg className="w-16 h-16 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h3 className="text-lg font-semibold mb-2">Error al cargar grupos</h3>
          <p className="text-muted-foreground mb-4">No se pudieron cargar los grupos</p>
          <Button onClick={() => window.location.reload()}>
            Intentar de nuevo
          </Button>
        </div>
      </div>
    );
  }

  if (!groups || groups.length === 0) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Mis Grupos</h1>
            <p className="text-muted-foreground mt-1">
              Grupos asignados a tu cargo
            </p>
          </div>
        </div>

        <div className="flex items-center justify-center h-96">
          <div className="text-center">
            <Users className="w-16 h-16 mx-auto text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">No tienes grupos asignados</h3>
            <p className="text-muted-foreground">
              Contacta al administrador para que te asigne grupos
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Mis Grupos</h1>
          <p className="text-muted-foreground mt-1">
            Tienes {groups.length} {groups.length === 1 ? 'grupo' : 'grupos'} asignados
          </p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {groups.map((group) => (
          <Card key={group.id} className="p-6 hover:shadow-lg transition-shadow">
            <div className="space-y-4">
              <div className="flex items-start justify-between">
                <div className="flex items-center space-x-3">
                  <div className="p-2 bg-primary/10 rounded-lg">
                    <Users className="w-6 h-6 text-primary" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-lg">
                      {group.friendlyName}
                      {group.subgroup && (
                        <span className="ml-2 text-sm font-normal text-muted-foreground">
                          Grupo {group.subgroup}
                        </span>
                      )}
                    </h3>
                    <p className="text-xs text-muted-foreground mt-1">
                      {group.ageRangeMin}-{group.ageRangeMax} meses
                    </p>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 pt-4 border-t">
                <div className="flex items-center space-x-2">
                  <Baby className="w-4 h-4 text-muted-foreground" />
                  <div>
                    <p className="text-sm text-muted-foreground">Alumnos</p>
                    <p className="font-semibold">{group.childrenCount || 0}</p>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <Calendar className="w-4 h-4 text-muted-foreground" />
                  <div>
                    <p className="text-sm text-muted-foreground">Capacidad</p>
                    <p className="font-semibold">{group.capacity || 'N/A'}</p>
                  </div>
                </div>
              </div>

              <div className="pt-4 space-y-2">
                <Button 
                  className="w-full" 
                  onClick={() => window.location.href = `/children?groupId=${group.id}`}
                >
                  Ver Alumnos
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full"
                  onClick={() => window.location.href = `/activities?groupId=${group.id}`}
                >
                  Ver Actividades
                </Button>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
