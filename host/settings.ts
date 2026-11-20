import { ExtensionStorage } from '@bacons/apple-targets';

import { APP_GROUP, KEYS } from './shared';

// Phải khớp với targets/keyboard/Shared/KyxSettings.swift
export type KyxSettings = {
  click: boolean;
  haptic: boolean;
  autocap: boolean;
  doubleSpace: boolean;
  tone: 'new' | 'old';
  defaultLang: 'VI' | 'EN';
  height: number; // 0.85 ... 1.2
  theme: 'system' | 'light' | 'dark';
};

export const DEFAULTS: KyxSettings = {
  click: true,
  haptic: true,
  autocap: true,
  doubleSpace: true,
  tone: 'new',
  defaultLang: 'VI',
  height: 1,
  theme: 'system',
};

export const storage = new ExtensionStorage(APP_GROUP);

export function loadSettings(): KyxSettings {
  try {
    const raw = storage.get(KEYS.settings);
    return raw ? { ...DEFAULTS, ...JSON.parse(raw) } : { ...DEFAULTS };
  } catch {
    return { ...DEFAULTS };
  }
}

export function saveSettings(s: KyxSettings) {
  storage.set(KEYS.settings, JSON.stringify(s));
}

export function readLog(): string[] {
  const raw = storage.get(KEYS.log);
  return raw ? raw.split('\n').filter(Boolean).reverse() : [];
}

export function clearLog() {
  storage.remove(KEYS.log);
}
