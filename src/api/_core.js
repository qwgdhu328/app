// gps-spoofer-app/src/api/_core.js — generic API primitives.
//
// Phase 1 extracted these out of the chat-specific ./api.js so the
// fetch + dedupe + AbortController plumbing can be reused by future
// per-feature api/* files (community api, mood sync api, etc.) without
// copy-pasting the timeout + dedupe boilerplate.
//
// Public surface:
//   - fetchWithTimeout(url, options, timeoutMs) -> Response
//   - dedupe(key, fn)                             -> Promise<T>
//
// Design notes:
// - fetchWithTimeout wires the AbortController INSIDE the call so callers
//   don't have to manage it. The controller aborts when either (a) the
//   timeout fires, or (b) the response settles. The timer is cleared in
//   a `finally` so we never leak a setTimeout that could trigger after
//   the response is consumed.
// - dedupe is keyed by an arbitrary string the caller provides. If a
//   request with the same key is already in flight, the existing promise
//   is returned instead of starting a new round-trip. The entry is
//   cleared in `finally` (both on resolve AND reject) so a failed call
//   doesn't permanently lock subsequent calls out of the slot.
// - The dedupe map is module-local; it's intentionally NOT exposed
//   because there's no reason a caller should need to introspect it.
//   Test seams can stub the entire module if needed.

/**
 * fetch() that aborts after `timeoutMs` via AbortController. Returns
 * the same `Response` object as the underlying fetch. The caller is
 * responsible for `res.json()` / `res.text()`.
 *
 * If the timeout fires first, the AbortError propagates and the caller's
 * catch should detect `e.name === 'AbortError'` if it wants to
 * distinguish timeout from network failure.
 */
export async function fetchWithTimeout(url, options, timeoutMs) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { ...options, signal: controller.signal });
    return res;
  } finally {
    clearTimeout(timer);
  }
}

// Module-local in-flight registry. Keyed by an arbitrary string the
// caller provides (e.g. `'chat:msg-123'` for per-message dedupe, or
// `'chatInFlight'` for a stricter "one call at a time" semantic).
const inFlight = new Map();

/**
 * Run `fn()` but de-duplicate concurrent calls with the same `key`.
 *
 * If a call with `key` is already running, the existing promise is
 * returned — `fn` is NOT invoked a second time. The slot is released
 * in `finally`, so a rejection (timeout, network error) does NOT
 * permanently lock future calls out of the slot.
 *
 * IMPORTANT: the caller is responsible for choosing a key that
 * distinguishes the requests it intends to dedupe. Examples:
 *
 *   // Per-call unique key — distinct calls fire distinct requests
 *   dedupe(`chat:${lastMsg.id}`, () => doFetch());
 *
 *   // Single-flight — only one chat call at a time across the app
 *   dedupe('chatInFlight', () => doFetch());
 *
 *   // Per-message-text dedupe — retried identical messages reuse the
 *   // in-flight response instead of hitting the network twice
 *   dedupe(`chat:${hash(text)}`, () => doFetch());
 */
export function dedupe(key, fn) {
  const existing = inFlight.get(key);
  if (existing) return existing;
  const p = (async () => {
    try {
      return await fn();
    } finally {
      inFlight.delete(key);
    }
  })();
  inFlight.set(key, p);
  return p;
}
