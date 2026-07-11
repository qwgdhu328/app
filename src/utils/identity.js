// gps-spoofer-app/src/utils/identity.js — identity → presentation helpers.
//
// Phase 1 extracted `accentFor(name)` from ProfileScreen.js where it was
// a local function next to the avatar it styled. The reason for the
// extraction is forward-looking: any future feature that wants to give
// a user-derived visual identity (Profile avatar accent, FreeWrite
// mind-map author dot, "your turn" badge in Community, etc.) can
// share one implementation instead of copy-pasting the hash + palette
// walk.
//
// === Why this is in `identity.js` and not `color.js` ===
//
// The function maps a STRING (a user identity) to a COLOR. It's
// identity-driven — the same person gets the same colour every time —
// not color-driven (no palette manipulation, no theming). If we later
// add `displayName(user)`, `gravatarUrl(user)`, or `initialsFor(user)`,
// they live here too.

import { C } from '../constants/theme';

/**
 * Pick a stable accent colour for a given user name.
 *
 * Same name → same colour across sessions (the hash is deterministic,
 * not random), so the user's Profile avatar accent dot never flickers
 * between renders. The hash is the classic djb2-ish multiplier
 * `h = h * 31 + c` cast to uint32 — small enough to inline but
 * well-distributed across the palette for typical short names.
 *
 * @param {string|null|undefined} name
 *   The user's display name. Falsy → returns `C.accent` (the default
 *   plum).
 * @returns {string} A colour from the theme palette.
 */
export function accentFor(name) {
  if (!name) return C.accent;
  const palette = [C.primary, C.accent, C.sky, C.sage, C.terracotta, C.amber];
  let h = 0;
  for (let i = 0; i < name.length; i++) h = (h * 31 + name.charCodeAt(i)) >>> 0;
  return palette[h % palette.length];
}
