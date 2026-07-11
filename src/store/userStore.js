// userStore — zustand store for the user's profile metadata + lifetime
// accumulated stats. PERSISTED via the shared bbot MMKV instance.
//
// === Why user stats are persistent ===
//
// The Profile screen shows "X sessioni · Y messaggi" — those counters are
// the user's lifetime reflection. Without persistence they'd reset to zero
// on every app open, defeating the point of the page.
//
// === Why session metrics like `userLastActiveAt` are NOT here ===
//
// `lastActive` timestamps were tempting to persist, but they're forensic
// (someone with access to the device storage could infer "this user
// opened the app every day"). The privacy disclosure says stats exist on
// the device — meta-statistics about WHEN the user was active are a step
// further than what the user opted into. Session-scoped timestamps live
// in chatStore / moodStore.pickMood's `at` field (a mood-pick is consent-
// rich by definition).
//
// === Setters ===
//
// The store keeps setters simple and one-purpose. Compound actions
// (incrSessions) live next to the bare setters for callers that want
// the atomic increment.
//
// IMPORTANT: likedMessages lives in chatStore (ephemeral) — see that
// store's comment for the rationale. This store has NO favorites field.

import { create } from 'zustand';
import { createJSONStorage } from 'zustand/middleware';
import { Platform } from 'react-native';

// react-native-mmkv is NATIVE-ONLY — its NativeModule is undefined on
// web, so `new MMKV()` throws at module-load time and kills the entire
// JS thread before React can mount. We detect Platform.OS === 'web'
// (or a failed import) and return a no-op StateStorage so zustand's
// `persist` middleware stays happy. See moodStore.js for the longer
// rationale; the same adapter is shared conceptually (one MMKV
// instance, one no-op fallback) but each store creates its own.
//
// The `require` is wrapped in try/catch because the import itself can
// fail at evaluation time on web — this lets the file load without a
// hard error at import time.
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

export const useUserStore = create((set) => ({
  // === State ===
  userName: '',
  userCity:  '',
  totalSessions: 0,
  totalTurns: 0,
  // Phase 4: gates the feature-tour OnboardingScreen. Persisted so the
  // tour only runs on the user's FIRST launch — every subsequent open
  // goes straight from the brand-splash (IntroScreen) to HomeScreen.
  // Stored alongside userName/city/stats because all three are "device
  // identity" entries the user can see + clear (see resetOnboarding).
  onboardingCompleted: false,

  // === Plain setters ===
  setUserName: (v) => set({ userName: String(v || '').trim() }),
  // Phase 2: city used by PsychologistsScreen during the escalation
  // cooldown to look up the local directory. Voluntary text input —
  // never geolocate.
  setUserCity:  (v) => set({ userCity:  String(v || '').trim() }),
  // Phase 4: OnboardingScreen onAdvance() flips this true. App.js's
  // showOnboarding useState mirrors it; the storage record survives
  // app restarts so we don't re-run the tour after the first time.
  setOnboardingCompleted: (v) => set({ onboardingCompleted: !!v }),

  // === Compound actions ===

  // Snapshot the just-finished chat session. Called from ChatPage /
  // TabBar's reset path with the number of turns the user just produced.
  incrSessions: (turnsToAdd) => set((s) => ({
    totalSessions: s.totalSessions + 1,
    totalTurns:    s.totalTurns + (Number(turnsToAdd) || 0),
  })),

  // Reset counters (e.g. testing / dev builds). Does NOT clear userName
  // — that's identity, not a counter.
  resetAccumulated: () => set({ totalSessions: 0, totalTurns: 0 }),
  // Phase 4: dev helper. Re-runs OnboardingScreen on next app launch.
  // Pairs with resetAccumulated for QA — both strip the user's
  // session traces back to "fresh install" state. Does NOT touch
  // userName / userCity (those survive a reset).
  resetOnboarding: () => set({ onboardingCompleted: false }),
}), {
  name: 'benesserebot.user',
  storage: createJSONStorage(() => createBbotStorage()),
  version: 1,
});
