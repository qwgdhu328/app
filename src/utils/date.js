// Date helpers — extracted from the monolithic App.js so HomePage, ChatPage,
// ProfilePage, the streak calc and any future feature can share one
// implementation.
//
// Privacy note: every helper here operates on already-aggregated day
// strings (YYYY-MM-DD) and on synthetic message-id timestamps, never on
// raw user-provided content. Safe to centralize without relaxing the
// "Niente viene memorizzato" contract.

// === Day-key helpers =========================================================
// Used by mood history (today / +N days / diff between two days) and by the
// week-strip on the Home page. Pure, no side effects, no React state.

export const todayKey = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

export const dayDiff = (a, b) => {
  const da = new Date(a); da.setHours(0, 0, 0, 0);
  const db = new Date(b); db.setHours(0, 0, 0, 0);
  return Math.round((da - db) / 86400000);
};

export const addDays = (key, delta) => {
  const [y, m, d] = key.split('-').map(Number);
  const dt = new Date(y, m - 1, d + delta);
  return `${dt.getFullYear()}-${String(dt.getMonth() + 1).padStart(2, '0')}-${String(dt.getDate()).padStart(2, '0')}`;
};

// === Streak ===============================================================
// The streak calc was previously inlined in the App() default export as
// `calcStreak(moodHistory)`. Same algorithm — 1-day grace window, soft
// penalty on 2-day gaps, break on 3+-day gaps. Pure derivation: a store
// can read it inside a selector without ever storing it as state.
//
// Usage: `const streak = useMoodStore(s => calcStreak(s.moodHistory))`.
export const calcStreak = (history) => {
  const days = [...new Set((history || []).map((h) => h.day))].sort();
  if (!days.length) return 0;
  const today = todayKey();
  // 1-day grace window so a "skipped today" doesn't kill the streak.
  if (days[days.length - 1] !== today && dayDiff(today, days[days.length - 1]) > 1) return 0;

  // Soft-decrement: a 2-day gap counts the day but applies a -1 penalty.
  // Only a 3+ day gap actually breaks the streak.
  let count = 0;
  let pendingPenalty = 0;
  for (let i = days.length - 1; i >= 0; i--) {
    if (i === days.length - 1) { count = 1; continue; }
    const diff = dayDiff(days[i + 1], days[i]);
    if (diff === 1)         count++;
    else if (diff === 2)  { count++; pendingPenalty++; }
    else                    break;
  }
  return Math.max(0, count - pendingPenalty);
};

// === Day-bucket helpers for chat date separators ==========================
// Message ids are formatted `m-${Date.now()}-${index}` (see chatStore's
// message factory). Parsing the timestamp out is more reliable than attaching
// a separate `day` field to every message: it stays a no-op for callers and
// survives any future code that creates messages from outside the chat path
// (e.g. system prompts).

const _dayBucketTs = (id) => {
  const m = String(id || '').match(/^m-(\d{10,15})-/);
  return m ? Number(m[1]) : null;
};

export const dayBucket = (id) => {
  const ts = _dayBucketTs(id);
  if (!ts) return null;
  const d = new Date(ts);
  return `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
};

export const dayLabel = (bucket) => {
  if (!bucket) return '';
  const [y, mo, da] = bucket.split('-').map(Number);
  const d = new Date(y, mo, da);
  const today      = new Date(); today.setHours(0, 0, 0, 0);
  const yMidnight  = new Date(today.getTime() - 86400000);
  if (d.getTime() === today.getTime())     return 'Oggi';
  if (d.getTime() === yMidnight.getTime()) return 'Ieri';
  const months = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];
  return `${d.getDate()} ${months[d.getMonth()]}`;  // "5 apr"
};

// === Chat render helpers ===================================================
// Walks the messages array from the tail and reports whether `item` is the
// last assistant turn. Used by ChatPage to decide when to show quick
// replies below a message.
export const isLastAssistant = (messages, item) => {
  if (!messages || !item || item.role !== 'assistant') return false;
  for (let i = messages.length - 1; i >= 0; i--) {
    if (messages[i].id === item.id)        return true;
    if (messages[i].role === 'assistant')  return false;
  }
  return false;
};
