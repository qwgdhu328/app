// Text helpers used across the chat protocol.
// Pure functions; safe to unit-test without React Native.

import { RED_FLAGS, EMOTION_KEYWORDS } from '../constants/botData';

// Strip simple italic markers (single-asterisk) but KEEP bold markers
// (**xxx**) intact — they're rendered by `RichText` so the system prompt's
// emphasis actually reaches the user. Used by the /export command where
// we want clean plain text and by the alert titles.
export function cleanupMarkdown(text) {
  if (!text) return '';
  return String(text)
    .replace(/\*(?!\*)([^*]+?)(?<!\*)\*/g, '$1');
}

// Detect a coarse emotion label from a free-text input.
// Returns one of: 'rabbia' | 'tristezza' | 'paura' | 'gioia' | 'sorpresa' | 'disgusto' | null
export function detectEmotion(text) {
  if (!text) return null;
  const lower = text.toLowerCase();
  for (const [emotion, keywords] of Object.entries(EMOTION_KEYWORDS)) {
    if (keywords.some(k => lower.includes(k))) return emotion;
  }
  return null;
}

// True when the text contains any known red-flag term (Italian).
export function hasRedFlag(text) {
  if (!text) return false;
  const lower = text.toLowerCase();
  return RED_FLAGS.some(flag => lower.includes(flag));
}

// Night-mode window: 0:00 → 6:00. Used to soften bot tone.
export function isNightMode() {
  const h = new Date().getHours();
  return h >= 0 && h < 6;
}

// Time-of-day greeting used in the Profile header.
export function getGreeting() {
  const h = new Date().getHours();
  if (h < 5)  return 'Ehi, insonne';
  if (h < 12) return 'Buongiorno';
  if (h < 18) return 'Buon pomeriggio';
  return 'Buonasera';
}
