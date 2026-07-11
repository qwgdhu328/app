// chatStore — zustand store for the chat conversation + ephemeral session UI
// state. Strictly in-memory by design.
//
// === Why NO `persist` middleware here ===
//
// The privacy contract — "Niente viene memorizzato" / "Le parole che scrivi
// qui le legge un modello di AI — di passaggio, niente di più" — is enforced
// STRUCTURALLY by not wiring MMKV/AsyncStorage to this store. On reload
// (Metro fast-refresh, OS kill, manual app reopen), the store rehydrates
// empty: same effect as `/forget`.
//
// Per-session UI flags (consentGiven, thinking, chatBlocked, level history,
// offeredTechniques, nightWarningShown, durationWarningLevel,
// professionalReminderShown, likedMessages) ride the same in-memory lifecycle
// so they reset cleanly between sessions.
//
// === Id minting convention ===
//
// Day-bucket separators in <ChatPage> parse message ids with the regex
//   /^m-(\d{10,15})-/
// (see src/utils/date.js → `_dayBucketTs`). To SEAL that seam at the store
// level so Phase 1's App.js migration cannot accidentally inject a message
// without the right id, we expose `pushUserMessage` / `pushAssistantMessage`
// factory actions that auto-mint the id:
//   id = `m-${Date.now()}-${messages.length}`
// Callers should use these factories — they should NOT call `appendMessage`
// directly with a hand-rolled id (that's now an internal path used by
// `resetChat` and, in the future, by the system-prompt bootstrap).

import { create } from 'zustand';

const mintId = (messagesLen) => `m-${Date.now()}-${messagesLen}`;

export const useChatStore = create((set, get) => ({
  // ── Conversation state ────────────────────────────────────────────────
  /** @type {Array<{id:string,role:'user'|'assistant',text:string,level?:string,emotion?:string,technique?:string|null,showEmergency?:boolean}>} */
  messages: [],
  input: '',
  thinking: false,
  chatBlocked: false,
  consentGiven: false,

  // ── Telemetry + safety ───────────────────────────────────────────────
  turnCount: 0,
  currentLevel: 'VERDE',
  /** @type {Array<{level:string,emotion:string,time:number}>} */
  levelHistory: [],

  // ── Session-scoped warning flags ──────────────────────────────────────
  offeredTechniques: new Set(),
  nightWarningShown: false,
  durationWarningLevel: null,
  professionalReminderShown: false,

  // ── Favorites within the current session ──────────────────────────────
  likedMessages: new Set(),

  // ── Connectivity ──────────────────────────────────────────────────────
  isOffline: false,

  // ── Phase 2: Escalation telemetry ─────────────────────────────────────
  // escalatedAt:    timestamp (ms) when the AI's [ESCALATE:...] marker
  //                 (or App.js's client-side heuristic) triggered the
  //                 10-min cooldown. null when no escalation is active.
  // escalateReason: short human-readable reason captured at trigger time.
  // cooldownMs:     10 minutes in ms — read by App.js's interval to
  //                 auto-clear when elapsed.
  escalatedAt:    null,
  escalateReason: null,
  cooldownMs:     600000,

  // ── Plain setters (use the factory helpers below for new messages) ────
  setMessages:                  (v) => set((s) => ({ messages:                  typeof v === 'function' ? v(s.messages) : v })),
  setInput:                     (v) => set({ input: v }),
  setThinking:                  (v) => set({ thinking: v }),
  setChatBlocked:               (v) => set({ chatBlocked: v }),
  setConsentGiven:              (v) => set({ consentGiven: v }),
  setTurnCount:                 (v) => set({ turnCount: v }),
  setCurrentLevel:              (v) => set({ currentLevel: v }),
  setLevelHistory:              (v) => set((s) => ({ levelHistory: typeof v === 'function' ? v(s.levelHistory) : v })),
  setOfferedTechniques:         (v) => set({ offeredTechniques: v }),
  setNightWarningShown:         (v) => set({ nightWarningShown: v }),
  setDurationWarningLevel:      (v) => set({ durationWarningLevel: v }),
  setProfessionalReminderShown: (v) => set({ professionalReminderShown: v }),
  setLikedMessages:             (v) => set((s) => ({ likedMessages: typeof v === 'function' ? v(s.likedMessages) : v })),
  setIsOffline:                 (v) => set({ isOffline: v }),
  setEscalatedAt:               (v) => set({ escalatedAt: v }),
  setEscalateReason:            (v) => set({ escalateReason: v }),

  // ── Factory actions (preferred path for any new chat message) ─────────

  // Auto-mints an id that day-bucket parsers can recognize. Returns the
  // new id so the caller can reference it (e.g. for the assistant message
  // it appends when its user message's id needs to be in a red-flag
  // matched-pair).
  pushUserMessage: (text) => {
    const id = mintId(get().messages.length);
    set((s) => ({ messages: [...s.messages, { id, role: 'user', text }] }));
    return id;
  },

  pushAssistantMessage: (text, opts = {}) => {
    const id = mintId(get().messages.length);
    set((s) => ({
      messages: [...s.messages, {
        id,
        role: 'assistant',
        text,
        level: opts.level ?? null,
        emotion: opts.emotion ?? null,
        technique: opts.technique ?? null,
        showEmergency: opts.showEmergency ?? false,
      }],
    }));
    return id;
  },

  // Internal — used by the consent flow so the user/assistant pair share
  // atomic state (consentGiven flips exactly once).
  appendConsentExchange: (userText, assistantText) => set((s) => ({
    consentGiven: true,
    messages: [...s.messages,
      { role: 'user',      text: userText },
      { role: 'assistant', text: assistantText, level: 'VERDE' },
    ],
  })),

  // ── Compound actions ──────────────────────────────────────────────────

  // Reset everything (e.g. user taps "Nuova conversazione" or `/forget`).
  // Note: deliberately DOES NOT touch input here — handle in the same call
  // if the caller wants a clear composer (resetChat's caller typically
  // does setInput('') too).
  resetChat: () => set({
    messages: [],
    thinking: false,
    chatBlocked: false,
    consentGiven: false,
    turnCount: 0,
    currentLevel: 'VERDE',
    levelHistory: [],
    offeredTechniques: new Set(),
    nightWarningShown: false,
    durationWarningLevel: null,
    professionalReminderShown: false,
    likedMessages: new Set(),
    isOffline: false,
    // Phase 2: clear escalation telemetry on /forget too — a fresh
    // conversation is by definition a fresh start.
    escalatedAt:    null,
    escalateReason: null,
  }),

  // Toggle a single message's like state. Returns a NEW Set so React's
  // shallow-equality on the Set reference trips the re-render — zustand
  // doesn't deep-equal.
  toggleLike: (id) => set((s) => {
    const next = new Set(s.likedMessages);
    if (next.has(id)) next.delete(id);
    else               next.add(id);
    return { likedMessages: next };
  }),

  // ── Phase 2: Compound escalation actions ──────────────────────────────

  // Trigger escalation. Sets the cooldown start timestamp, captures
  // the trigger reason, and flips chatBlocked to true so the chat
  // input pill disappears immediately. Used by App.js's client-side
  // heuristic AND by detected AI [ESCALATE:...] markers.
  escalate: (reason) => set({
    escalatedAt:    Date.now(),
    escalateReason: String(reason || 'AI Escalation Directive').slice(0, 120),
    chatBlocked:    true,
  }),

  // Clear the escalation (manually or after App.js detects the
  // 10-minute cooldown has elapsed via setInterval).
  clearEscalation: () => set({
    escalatedAt:    null,
    escalateReason: null,
    chatBlocked:    false,
  }),
}));
