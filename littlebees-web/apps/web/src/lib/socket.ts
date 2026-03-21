import { io, Socket } from 'socket.io-client';
import { getAccessToken } from './auth';

const WS_URL = process.env.NEXT_PUBLIC_WS_URL?.replace(/\/$/, '') || '';

let socket: Socket | null = null;

export function getSocket(): Socket {
  if (!WS_URL) {
    throw new Error('NEXT_PUBLIC_WS_URL is not configured');
  }

  if (!socket) {
    socket = io(`${WS_URL}/chat`, {
      auth: { token: getAccessToken() },
      autoConnect: false,
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionAttempts: 5,
    });
  }
  return socket;
}

export function connectSocket() {
  const s = getSocket();
  if (!s.connected) {
    s.auth = { token: getAccessToken() };
    s.connect();
  }
  return s;
}

export function disconnectSocket() {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
}
