'use client';

import { useState } from 'react';
import { useQuickRegister } from '@/hooks/use-daily-logs';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { toast } from 'sonner';
import { 
  LogIn, 
  Utensils, 
  Moon, 
  Activity, 
  LogOut,
  Camera,
  Loader2 
} from 'lucide-react';

type ActivityType = 'check_in' | 'meal' | 'nap' | 'activity' | 'check_out';

interface QuickRegisterDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  childId: string;
  childName: string;
  defaultType?: ActivityType;
}

const activityTypes = [
  { value: 'check_in', label: 'Entrada', icon: LogIn, color: 'text-green-600' },
  { value: 'meal', label: 'Comida', icon: Utensils, color: 'text-orange-600' },
  { value: 'nap', label: 'Siesta', icon: Moon, color: 'text-blue-600' },
  { value: 'activity', label: 'Actividad', icon: Activity, color: 'text-purple-600' },
  { value: 'check_out', label: 'Salida', icon: LogOut, color: 'text-red-600' },
];

export function QuickRegisterDialog({
  open,
  onOpenChange,
  childId,
  childName,
  defaultType = 'check_in',
}: QuickRegisterDialogProps) {
  const [type, setType] = useState<ActivityType>(defaultType);
  const [notes, setNotes] = useState('');
  const [photoUrl, setPhotoUrl] = useState('');
  const [foodEaten, setFoodEaten] = useState('');
  const [napDuration, setNapDuration] = useState('');
  const [activityDescription, setActivityDescription] = useState('');
  const [mood, setMood] = useState('');

  const quickRegister = useQuickRegister();

  const selectedActivity = activityTypes.find((a) => a.value === type);
  const Icon = selectedActivity?.icon || Activity;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const metadata: any = {};
    
    if (notes) metadata.notes = notes;
    if (photoUrl) metadata.photoUrl = photoUrl;
    if (mood) metadata.mood = mood;
    
    if (type === 'meal' && foodEaten) {
      metadata.foodEaten = foodEaten;
    }
    
    if (type === 'nap' && napDuration) {
      metadata.napDuration = parseInt(napDuration, 10);
    }
    
    if (type === 'activity' && activityDescription) {
      metadata.activityDescription = activityDescription;
    }

    quickRegister.mutate(
      {
        childId,
        type,
        metadata: Object.keys(metadata).length > 0 ? metadata : undefined,
      },
      {
        onSuccess: (data) => {
          toast.success(data.message || 'Actividad registrada exitosamente');
          onOpenChange(false);
          resetForm();
        },
        onError: (error: any) => {
          toast.error(error.message || 'Error al registrar actividad');
        },
      }
    );
  };

  const resetForm = () => {
    setNotes('');
    setPhotoUrl('');
    setFoodEaten('');
    setNapDuration('');
    setActivityDescription('');
    setMood('');
  };

  const needsPhoto = type === 'check_in' || type === 'check_out';

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Icon className={`h-5 w-5 ${selectedActivity?.color}`} />
            Registro Rápido - {childName}
          </DialogTitle>
          <DialogDescription>
            Registra una actividad del día para este niño/a
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Tipo de actividad */}
          <div className="space-y-2">
            <Label htmlFor="type">Tipo de actividad</Label>
            <Select value={type} onValueChange={(v) => setType(v as ActivityType)}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {activityTypes.map((activity) => {
                  const ActivityIcon = activity.icon;
                  return (
                    <SelectItem key={activity.value} value={activity.value}>
                      <div className="flex items-center gap-2">
                        <ActivityIcon className={`h-4 w-4 ${activity.color}`} />
                        {activity.label}
                      </div>
                    </SelectItem>
                  );
                })}
              </SelectContent>
            </Select>
          </div>

          {/* Foto (para entrada/salida) */}
          {needsPhoto && (
            <div className="space-y-2">
              <Label htmlFor="photo" className="flex items-center gap-2">
                <Camera className="h-4 w-4" />
                Foto {type === 'check_in' ? 'de entrada' : 'de salida'}
              </Label>
              <Input
                id="photo"
                type="url"
                placeholder="URL de la foto"
                value={photoUrl}
                onChange={(e) => setPhotoUrl(e.target.value)}
              />
              <p className="text-xs text-muted-foreground">
                Toma una foto del niño/a al momento de {type === 'check_in' ? 'entrar' : 'salir'}
              </p>
            </div>
          )}

          {/* Estado de ánimo */}
          {type === 'check_in' && (
            <div className="space-y-2">
              <Label htmlFor="mood">Estado de ánimo</Label>
              <Select value={mood} onValueChange={setMood}>
                <SelectTrigger>
                  <SelectValue placeholder="Selecciona el estado de ánimo" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="happy">😊 Feliz</SelectItem>
                  <SelectItem value="calm">😌 Tranquilo</SelectItem>
                  <SelectItem value="sad">😢 Triste</SelectItem>
                  <SelectItem value="tired">😴 Cansado</SelectItem>
                  <SelectItem value="excited">🤩 Emocionado</SelectItem>
                </SelectContent>
              </Select>
            </div>
          )}

          {/* Comida consumida */}
          {type === 'meal' && (
            <div className="space-y-2">
              <Label htmlFor="foodEaten">¿Qué comió?</Label>
              <Input
                id="foodEaten"
                placeholder="Ej: Todo, La mitad, Solo la fruta"
                value={foodEaten}
                onChange={(e) => setFoodEaten(e.target.value)}
              />
            </div>
          )}

          {/* Duración de siesta */}
          {type === 'nap' && (
            <div className="space-y-2">
              <Label htmlFor="napDuration">Duración (minutos)</Label>
              <Input
                id="napDuration"
                type="number"
                placeholder="Ej: 60"
                value={napDuration}
                onChange={(e) => setNapDuration(e.target.value)}
              />
            </div>
          )}

          {/* Descripción de actividad */}
          {type === 'activity' && (
            <div className="space-y-2">
              <Label htmlFor="activityDescription">Descripción de la actividad</Label>
              <Input
                id="activityDescription"
                placeholder="Ej: Pintura, Juego libre, Música"
                value={activityDescription}
                onChange={(e) => setActivityDescription(e.target.value)}
              />
            </div>
          )}

          {/* Notas adicionales */}
          <div className="space-y-2">
            <Label htmlFor="notes">Notas adicionales (opcional)</Label>
            <Textarea
              id="notes"
              placeholder="Observaciones generales..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={3}
            />
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
              disabled={quickRegister.isPending}
            >
              Cancelar
            </Button>
            <Button type="submit" disabled={quickRegister.isPending}>
              {quickRegister.isPending && (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              )}
              Registrar
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
