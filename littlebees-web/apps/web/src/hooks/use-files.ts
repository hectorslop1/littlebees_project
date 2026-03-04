'use client';

import { useMutation } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

export function useUploadFile() {
  return useMutation({
    mutationFn: async ({ file, purpose }: { file: File; purpose: string }) => {
      const formData = new FormData();
      formData.append('file', file);
      formData.append('purpose', purpose);
      return api.upload('/files/upload', formData);
    },
  });
}
