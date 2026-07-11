// moodStore — zustand store for today's mood + mood history. PERSISTED
// via the shared bbot MMKV instance.
//
// === Why mood is persistent ===
//
// The streak calc reads mood history; without persistence the streak would
// reset to zero on every app launch, defeating the streak feature. The
// privacy contract applies to CHAT messages, not to device-local mood pings
// (the Profile copy says "Le statistiche e i preferiti esistono solo sul
// dispositivo" so the user explicitly opts into on-device persistence for
// stats).
//
// === Why streak is a derived selector, not stored state ===
//
// Storing streak as state creates a sync bug the moment anything changes
// moodHistory (you'd need to either recompute on every mutation OR refetch
// against stale values). Since this store lives behind a selector, callers
// compute it on demand:
//
//   const streak = useMoodStore(s => calcStreak(s.moodHistory));
//
// The cost is one O(N) walk over moodHistory per re-render — fine at N<365.

import { create } from 'zustand';
import { createJSONStorage } from 'zustand/middleware';
import { Platform } from 'react-native';
import { todayKey } from '../utils/date';

// === Storage adapter ===
// react-native-mmkv is NATIVE-ONLY — the underlying NativeModule is
// undefined on web, so `new MMKV()` throws at module-load time and
// kills the entire JS thread BEFORE React can mount. We detect
// Platform.OS === 'web' and return a no-op StateStorage so the zustand
// `persist` middleware stays happy. Persistence on web is therefore
// volatile (a page refresh resets the store) — acceptable for a dev
// web build and consistent with the privacy contract (no data leaves
// the device).
//
// The `require` is wrapped in try/catch because the import itself can
// fail at evaluation time on platforms where the package's native
// module is missing — this lets the file load on web without a hard
// error at import time.
let MMKV;
try {
  MMKV = require('react-native-mmkv').MMKV;
} catch (e) {
  MMKV = null;
}

const noopStorage = {
  getItem:    () => null,
  setItem:    () => {},
  removeItem: () => {},
};

const createBbotStorage = () =>
  (Platform.OS === 'web' || !MMKV) ? noopStorage : new MMKV({ id: 'benesserebot' });

export const useMoodStore = create((set) => ({
  // === State ===
  /** @type {{key: string, day: string} | null} */
  moodToday: null,
  /** @type {Array<{key: string, day: string, at: number}>} */
  moodHistory: [],

  // === Actions ===

  // Pick a mood for today. Clamps the moodHistory (one entry per day — the
  // newest wins) so stale picks don't accumulate over time. `at` is set to
  // Date.now() at the moment of the pick — useful to display "scelto X
  // minuti fa" without exposing a separate debug field.
  pickMood: (mood) => {
    const day = todayKey();
    set((s) => {
      const filtered = s.moodHistory.filter((h) => h.day !== day);
      return {
        moodToday: { key: mood.key, day },
        moodHistory: [...filtered, { key: mood.key, day, at: Date.now() }],
      };
    });
  },
}), {
  name: 'benesserebot.mood',
  storage: createJSONStorage(() => createBbotStorage()),
  // v1 = { key, day, at } on each history entry. Bump if shape changes.
  version: 1,
});
