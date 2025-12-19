import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(ts?: bigint) {
  if (!ts || ts === 0n) return "—";
  return new Date(Number(ts) * 1000).toLocaleString();
}

export function formatRemaining(seconds: bigint) {
  if (seconds <= 0n) return "Available now";

  const h = Number(seconds / 3600n);
  const m = Number((seconds % 3600n) / 60n);
  const s = Number(seconds % 60n);

  return `${h}h ${m}m ${s}s`;
}

export function shorten(address?: string) {
  if (!address) return "—";
  return `${address.slice(0, 6)}…${address.slice(-4)}`;
}
