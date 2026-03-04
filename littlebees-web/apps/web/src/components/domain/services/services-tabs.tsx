'use client';

import { BookOpen, Wrench, ShoppingBag } from 'lucide-react';
import { ServiceType } from '@kinderspace/shared-types';
import type { ExtraServiceResponse } from '@kinderspace/shared-types';
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
} from '@/components/ui/tabs';
import { EmptyState } from '@/components/ui/empty-state';
import { ServiceCard } from './service-card';

interface ServicesTabsProps {
  services: ExtraServiceResponse[];
  onAdd?: () => void;
  onEdit?: (service: ExtraServiceResponse) => void;
}

interface TabConfig {
  value: ServiceType;
  label: string;
  icon: React.ReactNode;
  emptyTitle: string;
  emptyDescription: string;
}

const tabs: TabConfig[] = [
  {
    value: ServiceType.CLASS,
    label: 'Clases Extra',
    icon: <BookOpen />,
    emptyTitle: 'No hay clases extra',
    emptyDescription:
      'Aun no se han registrado clases extra. Agrega una para comenzar.',
  },
  {
    value: ServiceType.WORKSHOP,
    label: 'Talleres',
    icon: <Wrench />,
    emptyTitle: 'No hay talleres',
    emptyDescription:
      'Aun no se han registrado talleres. Agrega uno para comenzar.',
  },
  {
    value: ServiceType.MARKETPLACE_ITEM,
    label: 'Tienda',
    icon: <ShoppingBag />,
    emptyTitle: 'No hay articulos en la tienda',
    emptyDescription:
      'Aun no se han registrado articulos. Agrega uno para comenzar.',
  },
];

export function ServicesTabs({ services, onEdit }: ServicesTabsProps) {
  return (
    <Tabs defaultValue={ServiceType.CLASS}>
      <TabsList>
        {tabs.map((tab) => (
          <TabsTrigger key={tab.value} value={tab.value}>
            {tab.label}
          </TabsTrigger>
        ))}
      </TabsList>

      {tabs.map((tab) => {
        const filtered = services.filter((s) => s.type === tab.value);

        return (
          <TabsContent key={tab.value} value={tab.value}>
            {filtered.length > 0 ? (
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {filtered.map((service) => (
                  <ServiceCard
                    key={service.id}
                    service={service}
                    onEdit={onEdit}
                  />
                ))}
              </div>
            ) : (
              <EmptyState
                icon={tab.icon}
                title={tab.emptyTitle}
                description={tab.emptyDescription}
              />
            )}
          </TabsContent>
        );
      })}
    </Tabs>
  );
}
