'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { ImageIcon, Palette, RotateCcw, Save, Sparkles } from 'lucide-react';
import { toast } from 'sonner';
import { useAuth } from '@/hooks/use-auth';
import {
  useCustomization,
  useResetCustomization,
  useUpdateCustomization,
  type UpdateCustomizationDto,
} from '@/hooks/use-customization';
import { useUploadFile } from '@/hooks/use-files';
import { useMenu } from '@/hooks/use-menu';
import { customizationToThemeConfig, useTheme } from '@/lib/theme-provider';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Avatar } from '@/components/ui/avatar';

const COLOR_FIELDS = [
  { key: 'primaryColor', label: 'Color primario', description: 'Botones, estados activos y elementos principales.' },
  { key: 'secondaryColor', label: 'Color secundario', description: 'Badges, acentos suaves y acciones alternativas.' },
  { key: 'accentColor', label: 'Color acento', description: 'Highlights visuales y métricas destacadas.' },
] as const;

type ColorFieldKey = (typeof COLOR_FIELDS)[number]['key'];

export default function CustomizationPage() {
  const { isAdmin, isDirector } = useAuth();
  const { applyTheme } = useTheme();
  const { data: customization, isLoading } = useCustomization();
  const { data: menu } = useMenu();
  const updateCustomization = useUpdateCustomization();
  const resetCustomization = useResetCustomization();
  const uploadFile = useUploadFile();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [form, setForm] = useState<UpdateCustomizationDto>({
    logoUrl: '',
    primaryColor: '#D4A853',
    secondaryColor: '#8FAE8B',
    accentColor: '#E8B84B',
    systemName: '',
    menuLabels: {},
    customCss: '',
  });

  const canEdit = isAdmin || isDirector;

  useEffect(() => {
    if (!customization) return;

    setForm({
      logoUrl: customization.logoUrl || '',
      primaryColor: customization.primaryColor,
      secondaryColor: customization.secondaryColor,
      accentColor: customization.accentColor || '#E8B84B',
      systemName: customization.systemName,
      menuLabels: { ...(customization.menuLabels || {}) },
      customCss: customization.customCss || '',
    });
  }, [customization]);

  const editableMenuItems = useMemo(() => {
    return (menu?.items || []).filter((item) => !['ai-assistant'].includes(item.id));
  }, [menu]);

  const handleColorChange = (key: ColorFieldKey, value: string) => {
    setForm((current) => ({ ...current, [key]: value }));
  };

  const handleMenuLabelChange = (id: string, value: string) => {
    setForm((current) => ({
      ...current,
      menuLabels: {
        ...(current.menuLabels || {}),
        [id]: value,
      },
    }));
  };

  const handleSave = async () => {
    try {
      const payload: UpdateCustomizationDto = {
        ...form,
        menuLabels: Object.fromEntries(
          Object.entries(form.menuLabels || {}).filter(([, value]) => value?.trim()),
        ),
      };

      const saved = await updateCustomization.mutateAsync(payload);
      applyTheme(customizationToThemeConfig(saved));
      toast.success('Personalización actualizada');
    } catch (error: any) {
      toast.error(error.message || 'No fue posible guardar la personalización');
    }
  };

  const handleReset = async () => {
    try {
      const reset = await resetCustomization.mutateAsync();
      applyTheme(customizationToThemeConfig(reset));
      toast.success('Personalización restablecida');
    } catch (error: any) {
      toast.error(error.message || 'No fue posible restablecer la personalización');
    }
  };

  const handleLogoUpload = async (file: File) => {
    try {
      const uploaded = (await uploadFile.mutateAsync({ file, purpose: 'branding_logo' })) as { id: string };
      setForm((current) => ({ ...current, logoUrl: uploaded.id }));
      toast.success('Logo listo para guardarse');
    } catch (error: any) {
      toast.error(error.message || 'No fue posible subir el logo');
    }
  };

  if (!canEdit) {
    return (
      <div className="mx-auto max-w-3xl">
        <Card>
          <CardContent className="flex min-h-[320px] flex-col items-center justify-center gap-4 text-center">
            <div className="rounded-full bg-primary-50 p-4 text-primary">
              <Palette className="h-8 w-8" />
            </div>
            <div className="space-y-2">
              <h1 className="text-2xl font-bold">Personalización</h1>
              <p className="text-muted-foreground">
                Solo dirección y administración pueden modificar el tema institucional.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <div className="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mb-2 inline-flex items-center gap-2 rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary">
            <Sparkles className="h-3.5 w-3.5" />
            Personalización institucional
          </div>
          <h1 className="text-3xl font-bold">Tema y branding</h1>
          <p className="mt-2 text-muted-foreground">
            Ajusta colores, logo, nombre del sistema y etiquetas del menú para esta institución.
          </p>
        </div>

        <div className="flex gap-3">
          <Button
            variant="outline"
            onClick={handleReset}
            loading={resetCustomization.isPending}
          >
            <RotateCcw className="h-4 w-4" />
            Restablecer
          </Button>
          <Button onClick={handleSave} loading={updateCustomization.isPending}>
            <Save className="h-4 w-4" />
            Guardar cambios
          </Button>
        </div>
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Identidad</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex flex-col gap-4 rounded-3xl border border-border/70 bg-primary-50/50 p-5 md:flex-row md:items-center">
                <Avatar
                  size="xl"
                  name={form.systemName || 'LittleBees'}
                  src={form.logoUrl || undefined}
                  className="h-20 w-20 rounded-3xl"
                />
                <div className="flex-1 space-y-3">
                  <Input
                    label="Nombre del sistema"
                    value={form.systemName || ''}
                    onChange={(e) => setForm((current) => ({ ...current, systemName: e.target.value }))}
                    placeholder="LittleBees Petit Soleil"
                  />
                  <div className="flex flex-wrap gap-3">
                    <Button
                      variant="outline"
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      disabled={uploadFile.isPending}
                    >
                      <ImageIcon className="h-4 w-4" />
                      {uploadFile.isPending ? 'Subiendo logo...' : 'Subir logo'}
                    </Button>
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={(e) => {
                        const file = e.target.files?.[0];
                        if (file) {
                          void handleLogoUpload(file);
                        }
                      }}
                    />
                    {form.logoUrl && (
                      <Button
                        variant="ghost"
                        type="button"
                        onClick={() => setForm((current) => ({ ...current, logoUrl: '' }))}
                      >
                        Quitar logo
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Paleta de color</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-4 md:grid-cols-3">
                {COLOR_FIELDS.map((field) => (
                  <div key={field.key} className="rounded-3xl border border-border/70 bg-card p-4">
                    <div className="mb-4 flex items-center justify-between">
                      <div>
                        <p className="font-semibold">{field.label}</p>
                        <p className="mt-1 text-xs text-muted-foreground">{field.description}</p>
                      </div>
                      <div
                        className="h-10 w-10 rounded-2xl border border-border shadow-sm"
                        style={{ backgroundColor: form[field.key] || '#ffffff' }}
                      />
                    </div>
                    <div className="flex items-center gap-3">
                      <input
                        type="color"
                        value={form[field.key] || '#ffffff'}
                        onChange={(e) => handleColorChange(field.key, e.target.value)}
                        className="h-11 w-14 cursor-pointer rounded-xl border border-border bg-transparent p-1"
                      />
                      <Input
                        value={form[field.key] || ''}
                        onChange={(e) => handleColorChange(field.key, e.target.value)}
                        placeholder="#000000"
                      />
                    </div>
                  </div>
                ))}
              </div>

              <div className="grid gap-4 md:grid-cols-3">
                <div className="rounded-3xl border p-5 shadow-sm" style={{ backgroundColor: form.primaryColor }}>
                  <p className="text-xs font-semibold uppercase tracking-[0.2em] text-white/80">Primario</p>
                  <p className="mt-8 text-2xl font-bold text-white">Acción principal</p>
                </div>
                <div className="rounded-3xl border p-5 shadow-sm" style={{ backgroundColor: form.secondaryColor }}>
                  <p className="text-xs font-semibold uppercase tracking-[0.2em] text-white/80">Secundario</p>
                  <p className="mt-8 text-2xl font-bold text-white">Estados suaves</p>
                </div>
                <div className="rounded-3xl border p-5 shadow-sm" style={{ backgroundColor: form.accentColor }}>
                  <p className="text-xs font-semibold uppercase tracking-[0.2em] text-white/80">Acento</p>
                  <p className="mt-8 text-2xl font-bold text-white">Métricas y highlights</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Etiquetas del menú</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {editableMenuItems.map((item) => (
                <div key={item.id} className="rounded-2xl border border-border/70 p-4">
                  <Label htmlFor={`menu-${item.id}`}>/{item.id}</Label>
                  <Input
                    id={`menu-${item.id}`}
                    value={form.menuLabels?.[item.id] ?? item.label}
                    onChange={(e) => handleMenuLabelChange(item.id, e.target.value)}
                    className="mt-2"
                  />
                </div>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>CSS adicional</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <Textarea
                label="Custom CSS"
                value={form.customCss || ''}
                onChange={(e) => setForm((current) => ({ ...current, customCss: e.target.value }))}
                placeholder=".hero-banner { border-radius: 32px; }"
                className="min-h-[220px] font-mono text-xs"
              />
              <p className="text-xs text-muted-foreground">
                Usa este espacio solo para ajustes puntuales del tenant. El tema principal debe resolverse con la paleta anterior.
              </p>
            </CardContent>
          </Card>
        </div>
      </div>

      {isLoading && (
        <Card>
          <CardContent className="py-6 text-sm text-muted-foreground">
            Cargando configuración actual...
          </CardContent>
        </Card>
      )}
    </div>
  );
}
