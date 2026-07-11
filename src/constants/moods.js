// MOODS — the 6 mood tiles used by HomeScreen (mood capture card) and
// ProfileScreen (streak-today chip + sparkline). Extracted from the
// monolithic App.js as part of the feature-folder refactor (Phase 0.C).
//
// Keeping this in `src/constants/` (rather than per-screen duplication)
// is the right call: the shape is identical between the two screens —
// HomeScreen reads MOODS for the picker + the today-chip, ProfileScreen
// reads it for the today-chip + the avatar accent when relevant. Every
// field is consumed by at least one of the two screens.
//
// Tone & copy rationale (kept verbatim from the App.js v5 "Horizon Ember
// Glow" pass):
//   sage        → great      — positive / safe (mint on plum)
//   sky         → good       — cool counterweight (periwinkle)
//   amber       → meh        — sits mid range (warm gold)
//   terracotta  → low        — peach with weight
//   accent      → anxious    — goldenrod alert
//   textMuted   → tired      — quietest of the six, deliberately
//                              desaturated so it sits well on the
//                              dark aubergine bg.

import { C } from './theme';

export const MOODS = [
  { key: 'great',   iconName: 'sparkle',     label: 'Top',        color: C.sage,        light: C.sageLight },
  { key: 'good',    iconName: 'sun',         label: 'Bene',       color: C.sky,         light: C.skyLight },
  { key: 'meh',     iconName: 'meh',         label: 'Così così',  color: C.amber,       light: C.amberLight },
  { key: 'low',     iconName: 'cloud_rain',  label: 'Giù',        color: C.terracotta,  light: C.terracottaLight },
  { key: 'anxious', iconName: 'heart_pulse', label: 'Ansioso/a',  color: C.accent,      light: C.accentLight },
  { key: 'tired',   iconName: 'moon',        label: 'Esausto/a',  color: C.textMuted,   light: 'rgba(124,114,134,0.18)' },
];
