'use client';

import { type ReactNode, useEffect, useMemo, useRef, useState } from 'react';
import {
  Bell,
  CheckCircle2,
  ImageIcon,
  LayoutDashboard,
  Palette,
  PanelLeft,
  RotateCcw,
  Save,
  Search,
  Sparkles,
  Table2,
  Type,
} from 'lucide-react';
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

const BRAND_COLOR_FIELDS = [
  { key: 'primaryColor', label: 'Primario', description: 'Botones, tabs activas y acciones clave.' },
  { key: 'secondaryColor', label: 'Secundario', description: 'Badges suaves, apoyos visuales y estados ligeros.' },
  { key: 'accentColor', label: 'Acento', description: 'Metricas, highlights y detalles especiales.' },
] as const;

const INTERFACE_COLOR_FIELDS = [
  { key: 'sidebarBg', label: 'Menu lateral', description: 'Fondo principal del sidebar.' },
  { key: 'sidebarText', label: 'Texto menu', description: 'Texto normal del menu lateral.' },
  { key: 'sidebarActiveText', label: 'Texto activo menu', description: 'Texto del item activo y branding.' },
  { key: 'bgPage', label: 'Fondo pagina', description: 'Color base del lienzo de la app.' },
  { key: 'bgSurface', label: 'Tarjetas', description: 'Fondos de tarjetas, modales y paneles.' },
  { key: 'textPrimary', label: 'Texto principal', description: 'Titulos y contenido principal.' },
  { key: 'textSecondary', label: 'Texto secundario', description: 'Subtitulos y ayuda contextual.' },
  { key: 'borderColor', label: 'Bordes', description: 'Inputs, cards, divisores y shells.' },
] as const;

const TABLE_COLOR_FIELDS = [
  { key: 'tableHeaderBg', label: 'Header tabla', description: 'Fondo de encabezados.' },
  { key: 'tableStripeBg', label: 'Fila alterna', description: 'Stripe suave en tablas.' },
  { key: 'tableHoverBg', label: 'Hover tabla', description: 'Hover para filas y listados.' },
] as const;

type FormColorKey =
  | (typeof BRAND_COLOR_FIELDS)[number]['key']
  | (typeof INTERFACE_COLOR_FIELDS)[number]['key']
  | (typeof TABLE_COLOR_FIELDS)[number]['key'];

const DEFAULT_FORM: UpdateCustomizationDto = {
  logoUrl: '',
  primaryColor: '#D4A853',
  secondaryColor: '#8FAE8B',
  accentColor: '#E8B84B',
  sidebarBg: '#1A1410',
  sidebarText: '#D1D5DB',
  sidebarActiveText: '#FFFFFF',
  bgSurface: '#FFFFFF',
  bgPage: '#FBF6E9',
  textPrimary: '#2C2C2C',
  textSecondary: '#6B6B6B',
  borderColor: '#E5E7EB',
  tableHeaderBg: '#F3F4F6',
  tableStripeBg: '#F9FAFB',
  tableHoverBg: '#FBF6E9',
  systemName: '',
  menuLabels: {},
  customCss: '',
};

const THEME_PRESETS: Array<{
  name: string;
  description: string;
  values: Partial<UpdateCustomizationDto>;
}> = [
  {
    name: 'LittleBees Clasico',
    description: 'Calido, suave y natural.',
    values: {
      primaryColor: '#D4A853',
      secondaryColor: '#8FAE8B',
      accentColor: '#E8B84B',
      sidebarBg: '#1A1410',
      sidebarText: '#D1D5DB',
      sidebarActiveText: '#FFFFFF',
      bgPage: '#FBF6E9',
      bgSurface: '#FFFFFF',
      textPrimary: '#2C2C2C',
      textSecondary: '#6B6B6B',
      borderColor: '#E5E7EB',
      tableHeaderBg: '#F3F4F6',
      tableStripeBg: '#F9FAFB',
      tableHoverBg: '#FBF6E9',
    },
  },
  {
    name: 'Bosque Premium',
    description: 'Institucional, natural y sobrio.',
    values: {
      primaryColor: '#7A9D54',
      secondaryColor: '#A3C585',
      accentColor: '#E5B948',
      sidebarBg: '#162312',
      sidebarText: '#CFD8C6',
      sidebarActiveText: '#FFFFFF',
      bgPage: '#F5F7F1',
      bgSurface: '#FFFFFF',
      textPrimary: '#243021',
      textSecondary: '#66725E',
      borderColor: '#D8E0D1',
      tableHeaderBg: '#EEF3E7',
      tableStripeBg: '#FAFCF7',
      tableHoverBg: '#F2F7EB',
    },
  },
  {
    name: 'Azul Ejecutivo',
    description: 'Mas corporativo y moderno.',
    values: {
      primaryColor: '#2E6CE6',
      secondaryColor: '#5DA9E9',
      accentColor: '#F59E0B',
      sidebarBg: '#111B35',
      sidebarText: '#CBD5E1',
      sidebarActiveText: '#FFFFFF',
      bgPage: '#F4F7FB',
      bgSurface: '#FFFFFF',
      textPrimary: '#1E293B',
      textSecondary: '#64748B',
      borderColor: '#D9E2EC',
      tableHeaderBg: '#EBF1F8',
      tableStripeBg: '#F8FBFF',
      tableHoverBg: '#EEF5FF',
    },
  },
  {
    name: 'Terracota Atelier',
    description: 'Mas editorial y boutique.',
    values: {
      primaryColor: '#C56A45',
      secondaryColor: '#D99873',
      accentColor: '#8FBC8F',
      sidebarBg: '#2A1710',
      sidebarText: '#E6D6CC',
      sidebarActiveText: '#FFF8F3',
      bgPage: '#FCF4EE',
      bgSurface: '#FFFDFB',
      textPrimary: '#3B241A',
      textSecondary: '#7A5B4D',
      borderColor: '#EBD8CC',
      tableHeaderBg: '#F7EAE1',
      tableStripeBg: '#FFFBF8',
      tableHoverBg: '#FBEFE8',
    },
  },
];

export default function CustomizationPage() {
  const { isAdmin, isDirector } = useAuth();
  const { applyTheme } = useTheme();
  const { data: customization, isLoading } = useCustomization();
  const { data: menu } = useMenu();
  const updateCustomization = useUpdateCustomization();
  const resetCustomization = useResetCustomization();
  const uploadFile = useUploadFile();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [form, setForm] = useState<UpdateCustomizationDto>(DEFAULT_FORM);

  const canEdit = isAdmin || isDirector;

  useEffect(() => {
    if (!customization) return;

    setForm({
      logoUrl: customization.logoUrl || '',
      primaryColor: customization.primaryColor,
      secondaryColor: customization.secondaryColor,
      accentColor: customization.accentColor || DEFAULT_FORM.accentColor,
      sidebarBg: customization.sidebarBg,
      sidebarText: customization.sidebarText,
      sidebarActiveText: customization.sidebarActiveText,
      bgSurface: customization.bgSurface,
      bgPage: customization.bgPage,
      textPrimary: customization.textPrimary,
      textSecondary: customization.textSecondary,
      borderColor: customization.borderColor,
      tableHeaderBg: customization.tableHeaderBg,
      tableStripeBg: customization.tableStripeBg,
      tableHoverBg: customization.tableHoverBg,
      systemName: customization.systemName,
      menuLabels: { ...(customization.menuLabels || {}) },
      customCss: customization.customCss || '',
    });
  }, [customization]);

  const editableMenuItems = useMemo(() => {
    return (menu?.items || []).filter((item) => !['ai-assistant'].includes(item.id));
  }, [menu]);

  const preview = useMemo(
    () => ({
      systemName: form.systemName || 'LittleBees',
      logoUrl: form.logoUrl || '',
      primaryColor: form.primaryColor || DEFAULT_FORM.primaryColor!,
      secondaryColor: form.secondaryColor || DEFAULT_FORM.secondaryColor!,
      accentColor: form.accentColor || DEFAULT_FORM.accentColor!,
      sidebarBg: form.sidebarBg || DEFAULT_FORM.sidebarBg!,
      sidebarText: form.sidebarText || DEFAULT_FORM.sidebarText!,
      sidebarActiveText: form.sidebarActiveText || DEFAULT_FORM.sidebarActiveText!,
      bgSurface: form.bgSurface || DEFAULT_FORM.bgSurface!,
      bgPage: form.bgPage || DEFAULT_FORM.bgPage!,
      textPrimary: form.textPrimary || DEFAULT_FORM.textPrimary!,
      textSecondary: form.textSecondary || DEFAULT_FORM.textSecondary!,
      borderColor: form.borderColor || DEFAULT_FORM.borderColor!,
      tableHeaderBg: form.tableHeaderBg || DEFAULT_FORM.tableHeaderBg!,
      tableStripeBg: form.tableStripeBg || DEFAULT_FORM.tableStripeBg!,
      tableHoverBg: form.tableHoverBg || DEFAULT_FORM.tableHoverBg!,
    }),
    [form],
  );

  const handleColorChange = (key: FormColorKey, value: string) => {
    setForm((current) => ({ ...current, [key]: value }));
  };

  const applyPreset = (values: Partial<UpdateCustomizationDto>) => {
    setForm((current) => ({
      ...current,
      ...values,
      menuLabels: current.menuLabels,
      customCss: current.customCss,
      systemName: current.systemName,
      logoUrl: current.logoUrl,
    }));
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
      toast.success('Tema institucional actualizado');
    } catch (error: any) {
      toast.error(error.message || 'No fue posible guardar la personalizacion');
    }
  };

  const handleReset = async () => {
    try {
      const reset = await resetCustomization.mutateAsync();
      applyTheme(customizationToThemeConfig(reset));
      toast.success('Tema restablecido');
    } catch (error: any) {
      toast.error(error.message || 'No fue posible restablecer la personalizacion');
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
              <h1 className="text-2xl font-bold">Personalizacion</h1>
              <p className="text-muted-foreground">
                Solo direccion y administracion pueden modificar el tema institucional.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-7xl space-y-6">
      <div className="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
          <div className="mb-2 inline-flex items-center gap-2 rounded-full bg-primary-50 px-3 py-1 text-xs font-semibold text-primary">
            <Sparkles className="h-3.5 w-3.5" />
            Theme Studio institucional
          </div>
          <h1 className="text-3xl font-bold">Tema y branding</h1>
          <p className="mt-2 max-w-3xl text-muted-foreground">
            Disena la experiencia visual de tu guarderia: branding, menu lateral, superficies, textos y etiquetas
            de navegacion para que toda la app web se sienta propia.
          </p>
        </div>

        <div className="flex gap-3">
          <Button variant="outline" onClick={handleReset} loading={resetCustomization.isPending}>
            <RotateCcw className="h-4 w-4" />
            Restablecer
          </Button>
          <Button onClick={handleSave} loading={updateCustomization.isPending}>
            <Save className="h-4 w-4" />
            Guardar tema
          </Button>
        </div>
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Branding</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex flex-col gap-4 rounded-3xl border border-border/70 bg-primary-50/40 p-5 md:flex-row md:items-center">
                <Avatar
                  size="xl"
                  name={preview.systemName}
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

              <ColorFieldGrid
                title="Colores de marca"
                icon={<Palette className="h-4 w-4" />}
                fields={BRAND_COLOR_FIELDS}
                values={form}
                onChange={handleColorChange}
              />
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Interfaz y menu lateral</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-4">
                <div className="flex items-center gap-2 text-sm font-semibold text-foreground">
                  <span className="rounded-full bg-primary-50 p-2 text-primary">
                    <Sparkles className="h-4 w-4" />
                  </span>
                  Presets rapidos
                </div>
                <div className="grid gap-4 md:grid-cols-2">
                  {THEME_PRESETS.map((preset) => (
                    <button
                      key={preset.name}
                      type="button"
                      onClick={() => applyPreset(preset.values)}
                      className="rounded-3xl border border-border/70 bg-card p-4 text-left transition-transform hover:-translate-y-0.5 hover:shadow-sm"
                    >
                      <div className="mb-3 flex gap-2">
                        {[
                          preset.values.primaryColor,
                          preset.values.secondaryColor,
                          preset.values.accentColor,
                          preset.values.sidebarBg,
                        ].map((color) => (
                          <span
                            key={color}
                            className="h-8 w-8 rounded-2xl border border-border/60"
                            style={{ backgroundColor: color }}
                          />
                        ))}
                      </div>
                      <p className="font-semibold">{preset.name}</p>
                      <p className="mt-1 text-sm text-muted-foreground">{preset.description}</p>
                    </button>
                  ))}
                </div>
              </div>

              <ColorFieldGrid
                title="Estructura de interfaz"
                icon={<PanelLeft className="h-4 w-4" />}
                fields={INTERFACE_COLOR_FIELDS}
                values={form}
                onChange={handleColorChange}
              />

              <ColorFieldGrid
                title="Tablas y listados"
                icon={<Table2 className="h-4 w-4" />}
                fields={TABLE_COLOR_FIELDS}
                values={form}
                onChange={handleColorChange}
              />
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Etiquetas del menu</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
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
                className="min-h-[200px] font-mono text-xs"
              />
              <p className="text-xs text-muted-foreground">
                Usalo para ajustes finos del tenant. El branding principal debe salir de la configuracion visual superior.
              </p>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6 xl:sticky xl:top-6 xl:self-start">
          <ThemePreviewCard preview={preview} menuItems={editableMenuItems} menuLabels={form.menuLabels || {}} />

          <Card>
            <CardHeader>
              <CardTitle>Resumen rapido</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-3 sm:grid-cols-2">
              <ColorSummaryChip label="Primario" value={preview.primaryColor} />
              <ColorSummaryChip label="Menu lateral" value={preview.sidebarBg} />
              <ColorSummaryChip label="Fondo pagina" value={preview.bgPage} />
              <ColorSummaryChip label="Tarjetas" value={preview.bgSurface} />
              <ColorSummaryChip label="Texto" value={preview.textPrimary} />
              <ColorSummaryChip label="Bordes" value={preview.borderColor} />
            </CardContent>
          </Card>
        </div>
      </div>

      {isLoading && (
        <Card>
          <CardContent className="py-6 text-sm text-muted-foreground">
            Cargando configuracion actual...
          </CardContent>
        </Card>
      )}
    </div>
  );
}

function ColorFieldGrid({
  title,
  icon,
  fields,
  values,
  onChange,
}: {
  title: string;
  icon: ReactNode;
  fields: readonly { key: FormColorKey; label: string; description: string }[];
  values: UpdateCustomizationDto;
  onChange: (key: FormColorKey, value: string) => void;
}) {
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 text-sm font-semibold text-foreground">
        <span className="rounded-full bg-primary-50 p-2 text-primary">{icon}</span>
        {title}
      </div>
      <div className="grid gap-4 md:grid-cols-2">
        {fields.map((field) => (
          <div key={field.key} className="rounded-3xl border border-border/70 bg-card p-4">
            <div className="mb-4 flex items-start justify-between gap-4">
              <div>
                <p className="font-semibold">{field.label}</p>
                <p className="mt-1 text-xs text-muted-foreground">{field.description}</p>
              </div>
              <div
                className="h-10 w-10 rounded-2xl border border-border shadow-sm"
                style={{ backgroundColor: values[field.key] || '#ffffff' }}
              />
            </div>
            <div className="flex items-center gap-3">
              <input
                type="color"
                value={values[field.key] || '#ffffff'}
                onChange={(e) => onChange(field.key, e.target.value)}
                className="h-11 w-14 cursor-pointer rounded-xl border border-border bg-transparent p-1"
              />
              <Input
                value={values[field.key] || ''}
                onChange={(e) => onChange(field.key, e.target.value)}
                placeholder="#000000"
              />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ThemePreviewCard({
  preview,
  menuItems,
  menuLabels,
}: {
  preview: {
    systemName: string;
    logoUrl: string;
    primaryColor: string;
    secondaryColor: string;
    accentColor: string;
    sidebarBg: string;
    sidebarText: string;
    sidebarActiveText: string;
    bgSurface: string;
    bgPage: string;
    textPrimary: string;
    textSecondary: string;
    borderColor: string;
    tableHeaderBg: string;
    tableStripeBg: string;
    tableHoverBg: string;
  };
  menuItems: Array<{ id: string; label: string }>;
  menuLabels: Record<string, string>;
}) {
  const items = menuItems.slice(0, 5);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <LayoutDashboard className="h-4 w-4 text-primary" />
          Vista previa
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div
          className="overflow-hidden rounded-[28px] border shadow-sm"
          style={{ backgroundColor: preview.bgPage, borderColor: preview.borderColor }}
        >
          <div className="grid min-h-[420px] grid-cols-[180px_1fr]">
            <div className="flex flex-col" style={{ backgroundColor: preview.sidebarBg }}>
              <div className="border-b px-4 py-4" style={{ borderColor: `${preview.sidebarText}26` }}>
                <div className="flex items-center gap-3">
                  <Avatar
                    size="md"
                    name={preview.systemName}
                    src={preview.logoUrl || undefined}
                    className="rounded-2xl"
                  />
                  <div className="min-w-0">
                    <p className="truncate text-sm font-bold" style={{ color: preview.sidebarActiveText }}>
                      {preview.systemName}
                    </p>
                    <p className="truncate text-[11px]" style={{ color: preview.sidebarText }}>
                      Panel institucional
                    </p>
                  </div>
                </div>
              </div>

              <div className="space-y-1 px-3 py-4">
                {items.map((item, index) => {
                  const active = index === 0;
                  return (
                    <div
                      key={item.id}
                      className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium"
                      style={{
                        backgroundColor: active ? `${preview.primaryColor}40` : 'transparent',
                        color: active ? preview.sidebarActiveText : preview.sidebarText,
                      }}
                    >
                      <div
                        className="h-2.5 w-2.5 rounded-full"
                        style={{ backgroundColor: active ? preview.accentColor : preview.sidebarText }}
                      />
                      {menuLabels[item.id] || item.label}
                    </div>
                  );
                })}
              </div>
            </div>

            <div className="p-4">
              <div
                className="mb-4 flex items-center justify-between rounded-2xl border px-4 py-3"
                style={{ backgroundColor: preview.bgSurface, borderColor: preview.borderColor }}
              >
                <div>
                  <p className="text-sm font-semibold" style={{ color: preview.textPrimary }}>
                    Dashboard
                  </p>
                  <p className="text-xs" style={{ color: preview.textSecondary }}>
                    Visual institucional en tiempo real
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <div
                    className="flex h-10 items-center rounded-full border px-3 text-xs"
                    style={{ borderColor: preview.borderColor, color: preview.textSecondary }}
                  >
                    <Search className="mr-2 h-3.5 w-3.5" />
                    Buscar
                  </div>
                  <div
                    className="grid h-10 w-10 place-items-center rounded-full border"
                    style={{ borderColor: preview.borderColor, backgroundColor: preview.bgSurface, color: preview.textPrimary }}
                  >
                    <Bell className="h-4 w-4" />
                  </div>
                </div>
              </div>

              <div className="mb-4 grid gap-3 md:grid-cols-3">
                {[
                  { label: 'Asistencia', value: '94%', color: preview.primaryColor },
                  { label: 'Pagos', value: '18', color: preview.secondaryColor },
                  { label: 'Alertas', value: '4', color: preview.accentColor },
                ].map((stat) => (
                  <div
                    key={stat.label}
                    className="rounded-2xl border p-4"
                    style={{ backgroundColor: preview.bgSurface, borderColor: preview.borderColor }}
                  >
                    <p className="text-[11px] uppercase tracking-[0.16em]" style={{ color: preview.textSecondary }}>
                      {stat.label}
                    </p>
                    <p className="mt-4 text-2xl font-bold" style={{ color: stat.color }}>
                      {stat.value}
                    </p>
                  </div>
                ))}
              </div>

              <div
                className="overflow-hidden rounded-2xl border"
                style={{ backgroundColor: preview.bgSurface, borderColor: preview.borderColor }}
              >
                <div
                  className="grid grid-cols-[1.2fr_1fr_0.8fr] gap-px px-4 py-3 text-xs font-semibold"
                  style={{ backgroundColor: preview.tableHeaderBg, color: preview.textSecondary }}
                >
                  <span>Alumno</span>
                  <span>Grupo</span>
                  <span>Estatus</span>
                </div>
                {[
                  ['Sofia Ramirez', 'Lactantes', 'Activa'],
                  ['Santiago Ramirez', 'Preescolar 2', 'Activo'],
                  ['Maria Luna', 'Preescolar 1', 'Al dia'],
                ].map((row, index) => (
                  <div
                    key={row[0]}
                    className="grid grid-cols-[1.2fr_1fr_0.8fr] items-center gap-px px-4 py-3 text-sm"
                    style={{
                      backgroundColor: index % 2 === 1 ? preview.tableStripeBg : preview.bgSurface,
                      color: preview.textPrimary,
                    }}
                  >
                    <span>{row[0]}</span>
                    <span style={{ color: preview.textSecondary }}>{row[1]}</span>
                    <span className="inline-flex items-center gap-1 font-medium" style={{ color: preview.primaryColor }}>
                      <CheckCircle2 className="h-4 w-4" />
                      {row[2]}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        <div className="rounded-3xl border border-border/70 bg-card p-4">
          <div className="mb-3 flex items-center gap-2 text-sm font-semibold">
            <Type className="h-4 w-4 text-primary" />
            Jerarquia de texto
          </div>
          <p className="text-lg font-bold" style={{ color: preview.textPrimary }}>
            El tema debe sentirse institucional, calido y profesional.
          </p>
          <p className="mt-2 text-sm" style={{ color: preview.textSecondary }}>
            Este preview usa los colores de fondo, tarjetas, bordes y menu lateral que acabas de configurar.
          </p>
        </div>
      </CardContent>
    </Card>
  );
}

function ColorSummaryChip({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center gap-3 rounded-2xl border border-border/70 bg-card px-3 py-3">
      <span className="h-8 w-8 rounded-xl border border-border/70" style={{ backgroundColor: value }} />
      <div>
        <p className="text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">{label}</p>
        <p className="text-sm font-medium">{value}</p>
      </div>
    </div>
  );
}
