'use client';

import { AlertTriangle, Phone, Mail, User, Heart, Stethoscope, FileText } from 'lucide-react';
import { useChildProfile } from '@/hooks/use-children';
import { useAuth } from '@/hooks/use-auth';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Skeleton } from '@/components/ui/skeleton';

interface ChildProfileDialogProps {
  childId: string | null;
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

export function ChildProfileDialog({
  childId,
  open,
  onOpenChange,
}: ChildProfileDialogProps) {
  const { data: profile, isLoading } = useChildProfile(childId || '');
  const { role } = useAuth();

  if (!childId) return null;

  const isStaff = role === 'teacher' || role === 'director' || role === 'admin' || role === 'super_admin';

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Perfil Completo</DialogTitle>
        </DialogHeader>

        {isLoading ? (
          <div className="space-y-4">
            <Skeleton className="h-24 w-full" />
            <Skeleton className="h-32 w-full" />
            <Skeleton className="h-32 w-full" />
          </div>
        ) : profile ? (
          <div className="space-y-6">
            {/* Header con foto y datos básicos */}
            <div className="flex items-start gap-4">
              <Avatar size="xl" name={`${profile.firstName} ${profile.lastName}`}>
                <AvatarFallback className="text-2xl">
                  {profile.firstName[0]}{profile.lastName[0]}
                </AvatarFallback>
              </Avatar>
              <div className="flex-1">
                <h2 className="text-2xl font-bold">
                  {profile.firstName} {profile.lastName}
                </h2>
                <p className="text-muted-foreground">
                  {profile.age} {profile.age === 1 ? 'año' : 'años'} • {profile.gender === 'male' ? 'Niño' : 'Niña'}
                </p>
                <p className="text-sm text-muted-foreground mt-1">
                  Grupo: {profile.groupName}
                </p>
                <p className="text-sm text-muted-foreground">
                  Fecha de nacimiento: {formatDate(profile.dateOfBirth)}
                </p>
              </div>
            </div>

            <Separator />

            {/* Información Médica */}
            {profile.medicalInfo && (
              <>
                <div className="space-y-3">
                  <h3 className="text-lg font-semibold flex items-center gap-2">
                    <Stethoscope className="h-5 w-5 text-primary" />
                    Información Médica
                  </h3>

                  {/* Alergias - Destacadas */}
                  {profile.medicalInfo.allergies && profile.medicalInfo.allergies.length > 0 && (
                    <div className="rounded-lg border-2 border-red-200 bg-red-50 p-4">
                      <div className="flex items-start gap-2">
                        <AlertTriangle className="h-5 w-5 text-red-600 mt-0.5" />
                        <div>
                          <h4 className="font-semibold text-red-900">Alergias</h4>
                          <div className="flex flex-wrap gap-2 mt-2">
                            {profile.medicalInfo.allergies.map((allergy: string, idx: number) => (
                              <Badge key={idx} className="bg-red-100 text-red-800 border-red-300">
                                {allergy}
                              </Badge>
                            ))}
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Tipo de sangre */}
                  {profile.medicalInfo.bloodType && (
                    <div className="flex items-center gap-2">
                      <Heart className="h-4 w-4 text-muted-foreground" />
                      <span className="text-sm">
                        <strong>Tipo de sangre:</strong> {profile.medicalInfo.bloodType}
                      </span>
                    </div>
                  )}

                  {/* Condiciones médicas */}
                  {profile.medicalInfo.conditions && profile.medicalInfo.conditions.length > 0 && (
                    <div>
                      <h4 className="text-sm font-semibold mb-2">Condiciones médicas</h4>
                      <div className="flex flex-wrap gap-2">
                        {profile.medicalInfo.conditions.map((condition: string, idx: number) => (
                          <Badge key={idx} variant="secondary">
                            {condition}
                          </Badge>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Medicamentos */}
                  {profile.medicalInfo.medications && profile.medicalInfo.medications.length > 0 && (
                    <div>
                      <h4 className="text-sm font-semibold mb-2">Medicamentos</h4>
                      <div className="flex flex-wrap gap-2">
                        {profile.medicalInfo.medications.map((medication: string, idx: number) => (
                          <Badge key={idx} variant="outline">
                            {medication}
                          </Badge>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Diagnóstico - Solo para staff */}
                  {isStaff && profile.diagnosis && (
                    <div className="rounded-lg border bg-blue-50 p-3">
                      <h4 className="text-sm font-semibold mb-1 text-blue-900">Diagnóstico</h4>
                      <p className="text-sm text-blue-800">{profile.diagnosis}</p>
                    </div>
                  )}

                  {/* Notas médicas - Solo para staff */}
                  {isStaff && profile.medicalInfo.medicalNotes && (
                    <div className="rounded-lg border bg-gray-50 p-3">
                      <div className="flex items-start gap-2">
                        <FileText className="h-4 w-4 text-muted-foreground mt-0.5" />
                        <div>
                          <h4 className="text-sm font-semibold mb-1">Notas médicas</h4>
                          <p className="text-sm text-muted-foreground">{profile.medicalInfo.medicalNotes}</p>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Doctor */}
                  {profile.medicalInfo.doctorName && (
                    <div className="text-sm">
                      <strong>Doctor:</strong> {profile.medicalInfo.doctorName}
                      {profile.medicalInfo.doctorPhone && (
                        <span className="text-muted-foreground"> • {profile.medicalInfo.doctorPhone}</span>
                      )}
                    </div>
                  )}
                </div>

                <Separator />
              </>
            )}

            {/* Contactos de Emergencia */}
            {profile.emergencyContacts && profile.emergencyContacts.length > 0 && (
              <>
                <div className="space-y-3">
                  <h3 className="text-lg font-semibold flex items-center gap-2">
                    <Phone className="h-5 w-5 text-primary" />
                    Contactos de Emergencia
                  </h3>
                  <div className="grid gap-3">
                    {profile.emergencyContacts.map((contact: any) => (
                      <div key={contact.id} className="rounded-lg border p-3">
                        <div className="flex items-start justify-between">
                          <div>
                            <h4 className="font-semibold">{contact.name}</h4>
                            <p className="text-sm text-muted-foreground">{contact.relationship}</p>
                          </div>
                          {contact.priority === 1 && (
                            <Badge variant="secondary">Prioritario</Badge>
                          )}
                        </div>
                        <div className="mt-2 space-y-1 text-sm">
                          <div className="flex items-center gap-2">
                            <Phone className="h-3 w-3 text-muted-foreground" />
                            <span>{contact.phone}</span>
                          </div>
                          {contact.email && (
                            <div className="flex items-center gap-2">
                              <Mail className="h-3 w-3 text-muted-foreground" />
                              <span>{contact.email}</span>
                            </div>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <Separator />
              </>
            )}

            {/* Padres/Tutores */}
            {profile.parents && profile.parents.length > 0 && (
              <div className="space-y-3">
                <h3 className="text-lg font-semibold flex items-center gap-2">
                  <User className="h-5 w-5 text-primary" />
                  Padres/Tutores
                </h3>
                <div className="grid gap-3">
                  {profile.parents.map((parent: any) => (
                    <div key={parent.userId} className="rounded-lg border p-3">
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-semibold">
                            {parent.firstName} {parent.lastName}
                          </h4>
                          <p className="text-sm text-muted-foreground">{parent.relationship}</p>
                        </div>
                        <div className="flex gap-2">
                          {parent.isPrimary && (
                            <Badge variant="secondary">Principal</Badge>
                          )}
                          {parent.canPickup && (
                            <Badge variant="outline">Autorizado</Badge>
                          )}
                        </div>
                      </div>
                      <div className="mt-2 space-y-1 text-sm">
                        <div className="flex items-center gap-2">
                          <Mail className="h-3 w-3 text-muted-foreground" />
                          <span>{parent.email}</span>
                        </div>
                        {parent.phone && (
                          <div className="flex items-center gap-2">
                            <Phone className="h-3 w-3 text-muted-foreground" />
                            <span>{parent.phone}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        ) : (
          <div className="text-center py-8 text-muted-foreground">
            No se pudo cargar el perfil
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
