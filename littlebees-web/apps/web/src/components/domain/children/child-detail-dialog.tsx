'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Pencil, Trash2 } from 'lucide-react';
import { toast } from 'sonner';
import { api } from '@/lib/api-client';
import { useDeleteChild } from '@/hooks/use-children';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Avatar } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { StatusBadge } from '@/components/ui/status-badge';
import { Separator } from '@/components/ui/separator';
import { Skeleton } from '@/components/ui/skeleton';
import { Gender } from '@kinderspace/shared-types';
import { ChildFormDialog } from './child-form-dialog';
import type {
  ChildResponse,
  MedicalInfoResponse,
  EmergencyContactResponse,
} from '@kinderspace/shared-types';

interface ChildDetailDialogProps {
  child: ChildResponse | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

function genderLabel(gender: Gender): string {
  return gender === Gender.MALE ? 'Masculino' : 'Femenino';
}

export function ChildDetailDialog({
  child,
  open,
  onOpenChange,
}: ChildDetailDialogProps) {
  const [showEditDialog, setShowEditDialog] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const deleteChild = useDeleteChild();
  const childId = child?.id ?? '';

  const { data: medicalInfo, isLoading: medicalLoading } = useQuery({
    queryKey: ['children', childId, 'medical-info'],
    queryFn: () =>
      api.get<MedicalInfoResponse>(`/children/${childId}/medical-info`),
    enabled: open && !!childId,
  });

  const { data: contacts, isLoading: contactsLoading } = useQuery({
    queryKey: ['children', childId, 'emergency-contacts'],
    queryFn: () =>
      api.get<EmergencyContactResponse[]>(
        `/children/${childId}/emergency-contacts`,
      ),
    enabled: open && !!childId,
  });

  if (!child) return null;

  const fullName = `${child.firstName} ${child.lastName}`;

  async function handleDelete() {
    if (!child) return;
    try {
      await deleteChild.mutateAsync(child.id);
      toast.success('Niño eliminado exitosamente');
      setShowDeleteConfirm(false);
      onOpenChange(false);
    } catch {
      toast.error('Error al eliminar el niño. Intenta de nuevo.');
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[85vh] overflow-y-auto sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Detalle del Niño</DialogTitle>
        </DialogHeader>

        {/* Action buttons */}
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowEditDialog(true)}
            className="flex-1"
          >
            <Pencil className="mr-2 h-4 w-4" />
            Editar
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowDeleteConfirm(true)}
            className="flex-1 text-destructive hover:bg-destructive hover:text-destructive-foreground"
          >
            <Trash2 className="mr-2 h-4 w-4" />
            Eliminar
          </Button>
        </div>

        {/* Informacion general */}
        <div className="flex flex-col items-center gap-3">
          <Avatar
            size="xl"
            name={fullName}
            src={child.photoUrl ?? undefined}
          />
          <h2 className="text-lg font-semibold">{fullName}</h2>
          <StatusBadge status={child.status} />
        </div>

        <div className="grid grid-cols-2 gap-x-6 gap-y-3 text-sm">
          <div>
            <span className="font-medium text-muted-foreground">
              Fecha de nacimiento
            </span>
            <p>{formatDate(child.dateOfBirth)}</p>
          </div>
          <div>
            <span className="font-medium text-muted-foreground">Edad</span>
            <p>{child.age} años</p>
          </div>
          <div>
            <span className="font-medium text-muted-foreground">Genero</span>
            <p>{genderLabel(child.gender)}</p>
          </div>
          <div>
            <span className="font-medium text-muted-foreground">Grupo</span>
            <p>{child.groupName}</p>
          </div>
          <div className="col-span-2">
            <span className="font-medium text-muted-foreground">
              Fecha de inscripcion
            </span>
            <p>{formatDate(child.enrollmentDate)}</p>
          </div>
        </div>

        <Separator />

        {/* Informacion medica */}
        <div>
          <h3 className="mb-3 text-sm font-semibold">Informacion Medica</h3>
          {medicalLoading ? (
            <div className="space-y-2">
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-4 w-3/4" />
            </div>
          ) : medicalInfo ? (
            <div className="space-y-3 text-sm">
              {medicalInfo.allergies.length > 0 && (
                <div>
                  <span className="font-medium text-muted-foreground">
                    Alergias
                  </span>
                  <div className="mt-1 flex flex-wrap gap-1">
                    {medicalInfo.allergies.map((allergy) => (
                      <Badge key={allergy} variant="danger" size="sm">
                        {allergy}
                      </Badge>
                    ))}
                  </div>
                </div>
              )}

              {medicalInfo.conditions.length > 0 && (
                <div>
                  <span className="font-medium text-muted-foreground">
                    Condiciones
                  </span>
                  <div className="mt-1 flex flex-wrap gap-1">
                    {medicalInfo.conditions.map((condition) => (
                      <Badge key={condition} variant="warning" size="sm">
                        {condition}
                      </Badge>
                    ))}
                  </div>
                </div>
              )}

              {medicalInfo.bloodType && (
                <div>
                  <span className="font-medium text-muted-foreground">
                    Tipo de sangre
                  </span>
                  <p>{medicalInfo.bloodType}</p>
                </div>
              )}

              {medicalInfo.medications.length > 0 && (
                <div>
                  <span className="font-medium text-muted-foreground">
                    Medicamentos
                  </span>
                  <div className="mt-1 flex flex-wrap gap-1">
                    {medicalInfo.medications.map((med) => (
                      <Badge key={med} variant="info" size="sm">
                        {med}
                      </Badge>
                    ))}
                  </div>
                </div>
              )}

              {medicalInfo.observations && (
                <div>
                  <span className="font-medium text-muted-foreground">
                    Observaciones
                  </span>
                  <p>{medicalInfo.observations}</p>
                </div>
              )}

              {(medicalInfo.doctorName || medicalInfo.doctorPhone) && (
                <div>
                  <span className="font-medium text-muted-foreground">
                    Medico
                  </span>
                  <p>
                    {medicalInfo.doctorName}
                    {medicalInfo.doctorPhone && ` - ${medicalInfo.doctorPhone}`}
                  </p>
                </div>
              )}

              {!medicalInfo.allergies.length &&
                !medicalInfo.conditions.length &&
                !medicalInfo.bloodType &&
                !medicalInfo.medications.length &&
                !medicalInfo.observations &&
                !medicalInfo.doctorName && (
                  <p className="text-muted-foreground">
                    Sin informacion medica registrada.
                  </p>
                )}
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">
              Sin informacion medica registrada.
            </p>
          )}
        </div>

        <Separator />

        {/* Contactos de emergencia */}
        <div>
          <h3 className="mb-3 text-sm font-semibold">
            Contactos de Emergencia
          </h3>
          {contactsLoading ? (
            <div className="space-y-2">
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-4 w-3/4" />
            </div>
          ) : contacts && contacts.length > 0 ? (
            <div className="space-y-3">
              {contacts.map((contact) => (
                <div
                  key={contact.id}
                  className="rounded-xl border border-input p-3 text-sm"
                >
                  <p className="font-medium">{contact.name}</p>
                  <p className="text-muted-foreground">
                    {contact.relationship}
                  </p>
                  <p className="text-muted-foreground">{contact.phone}</p>
                  {contact.email && (
                    <p className="text-muted-foreground">{contact.email}</p>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">
              Sin contactos de emergencia registrados.
            </p>
          )}
        </div>
      </DialogContent>

      {/* Edit dialog */}
      <ChildFormDialog
        open={showEditDialog}
        onOpenChange={setShowEditDialog}
        child={child}
        onSuccess={() => {
          setShowEditDialog(false);
        }}
      />

      {/* Delete confirmation dialog */}
      <Dialog open={showDeleteConfirm} onOpenChange={setShowDeleteConfirm}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>¿Eliminar niño?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            ¿Estás seguro de que deseas eliminar a <strong>{fullName}</strong>?
            Esta acción no se puede deshacer.
          </p>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setShowDeleteConfirm(false)}
            >
              Cancelar
            </Button>
            <Button
              variant="danger"
              onClick={handleDelete}
              loading={deleteChild.isPending}
            >
              Eliminar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Dialog>
  );
}
