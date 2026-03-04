import { FileQuestion } from 'lucide-react';
import Link from 'next/link';

export default function DashboardNotFound() {
  return (
    <div className="flex min-h-[50vh] flex-col items-center justify-center text-center">
      <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary-50">
        <FileQuestion className="h-8 w-8 text-primary" />
      </div>
      <h2 className="mt-4 text-xl font-semibold font-heading">Página no encontrada</h2>
      <p className="mt-2 max-w-md text-sm text-muted">
        La página que buscas no existe o fue movida.
      </p>
      <Link
        href="/"
        className="mt-6 inline-flex items-center rounded-full bg-primary px-6 py-2 text-sm font-semibold text-white transition-colors hover:bg-primary-600"
      >
        Volver al inicio
      </Link>
    </div>
  );
}
