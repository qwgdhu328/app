// gps-spoofer-app/src/features/chat/api/chatApi.js — chat-domain API.
//
// Phase 1 extracted the chat-specific code from the old ./api.js (which
// was 225 lines mixing generic fetch plumbing with chat domain logic).
// Now:
//   - Generic plumbing lives in src/api/_core.js (fetchWithTimeout + dedupe).
//   - Chat domain lives here: OpenRouter config, SYSTEM_PROMPT, chatWithAI.
//
// Phase 2:
//   - SYSTEM_PROMPT rewired to be clinical-professional + injects a
//     curated knowledge base (PROMPT_KB_BLOCK in src/constants/resources2026.js).
//   - chatWithAI now parses a new [ESCALATE: <motivo>] marker so the
//     model can self-mark when a conversation is clinically beyond
//     chatbot scope, exposing `escalated: true` + `escalateReason: string`
//     in the discriminated-union success variant. App.js wires this to
//     a 10-minute cooldown + PsychologistsScreen handoff.
//
// Why per-feature `api/` folders?
// - Keeps the chat SYSTEM_PROMPT co-located with the chatWithAI function
//   that consumes it (no 200-line prompts floating in a generic /api).
// - Makes it trivial to add a second feature api later (e.g.
//   src/features/community/api/storiesApi.js) without touching the
//   chat code at all.
// - The `api/` subdirectory inside the feature is the per-domain
//   convention — screens import from `../api/chatApi`, not from a
//   cross-cutting /api/ directory.
//
// === Dedupe strategy ===
// chatWithAI is wrapped in `dedupe(key, fn)` where the key is derived
// from the LAST message id in the conversation. Because App.js's
// sendMessage mints each new user message as `m-${Date.now()}-${len}`
// (a unique id per send), distinct sends always have distinct keys and
// fire distinct requests.

import { fetchWithTimeout, dedupe } from '../../../api/_core';
import { PROMPT_KB_BLOCK } from '../../../constants/resources2026';

// === OpenRouter config ===
// API_KEY loaded from .env (via EXPO_PUBLIC_* exposed at runtime by Expo
// SDK 49+). DO NOT hardcode keys here. See .env.example for setup.
//
// SECURITY NOTE: EXPO_PUBLIC_* vars are inlined in the JS bundle at
// build time and are visible to anyone using the app. They are NOT a
// secret defense. For a privacy-sensitive production deployment, route
// requests through a backend proxy and keep the key on the server.
const API_KEY    = (typeof process !== 'undefined' && process.env && process.env.EXPO_PUBLIC_OPENROUTER_API_KEY) || '';

const MODEL      = (typeof process !== 'undefined' && process.env && process.env.EXPO_PUBLIC_OPENROUTER_MODEL) || 'meta-llama/llama-3.2-3b-instruct:free';
const API_URL    = 'https://openrouter.ai/api/v1/chat/completions';
const TIMEOUT_MS = 30000;

// Cap how many prior turns we send: long sessions otherwise blow the
// token budget of the upstream model (and slow the response down).
// 20 turns keeps the bot aware of recent context while staying cheap.
const MAX_HISTORY_TURNS = 20;

if (!API_KEY || API_KEY === 'your_openrouter_api_key_here') {
  if (typeof console !== 'undefined') {
    console.warn(
      '[BenessereBot] EXPO_PUBLIC_OPENROUTER_API_KEY non configurata. ' +
      'Aggiungi la tua chiave in .env. La chat non funzionerà finché non è impostata.'
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  System prompt — Phase 2: professionale clinico + KB clinica 2026 + escalation.
//
//  Three composable blocks kept under ~3k tokens total:
//   1. BASE_STYLE_PROMPT — role, professional-clinical tone, anti-template
//      rules, style constraints (12-15 word sentences, max 1 emoji),
//      body-exploration rules, exercise gating, anti-repetition rules.
//      "Evidence-based" version of the previous casual rules — no more
//      generic reassurance, explicit clinical framing.
//   2. PROMPT_KB_BLOCK — injected from src/constants/resources2026.js.
//      Contains German S3 depression guidelines, RCADS/PHQ-A/EPSI-C
//      screening frameworks, USupport/NOPE Safety API, Italian hotlines,
//      Youth-GEMs, MENTBEST COMBINA. Updateable without touching
//      chatApi.js.
//   3. PROMPT_TAIL — ESCALATE rules, LIVELLO/EMOZIONE classification
//      requirement, red-flag/emergency block, CHI SONO.
//
//  The ESCALATE marker is the main Phase 2 addition: the model
//  self-marks when it detects clinical complexity beyond chatbot scope
//  (persistent veiled suicidal ideation, complex trauma disclosure,
//  possible psychotic symptoms, severe repeating distress that doesn't
//  improve with VERDE). The client then locks the chat for 10 minutes
//  and routes to PsychologistsScreen with local professionals.
// ══════════════════════════════════════════════════════════════════════════════
const BASE_STYLE_PROMPT = `[RUOLO — PROFESSIONALE CLINICO, NON INFORMALE]
Sei BenessereBot, primo ascolto digitale evidence-based per adolescenti italiani.

Cornici operative (in ordine di priorità):
1. Ascolto rogersiano (validazione, non giudizio, calco sull'esperienza del paziente).
2. ACT — Acceptance & Commitment Therapy (defusione + valori + azione).
3. CBT di terza onda (mindfulness-based).
4. Grounding 5-4-3-2-1, respirazione 4-7-8, behavioral activation singola-sessione (Unlock Wellbeing RCT UK).

NON sei un medico, NON sei un terapeuta, NON prescrivi nulla. Sei un primo punto di ascolto, non un sostituto di percorso clinico.

[TONO]
Professionale, clinico ma accessibile. Evidence-based.
- Niente cameratismo adolescenziale forzato ("tot", "bro", emoji-flooding).
- Niente moralismo ("devi", "dovresti").
- Niente superegno terapeutico ("sei vulnerabile", "hai bisogno di lavorare su questo").

[REGOLA ZERO — ANTI-TEMPLATE]
Le tre mosse che fanno subito AI generico, da evitare in modo assoluto:
1. "Mi dispiace sentire questo"
2. "Capisco come ti senti"
3. "È del tutto normale provare..."

Se serve empatia, usa una frase SPECIFICA, breve, calata sulla persona: "Suona a delusione, non a rabbia" / "C'è qualcosa lì sotto" — non un generatore di comfort generico.

[DIRETTIVE OPERATIVE]
1. Riformula SOLO se onesto: a volte il miglior servizio è non commentare e basta.
2. Varia struttura di turno in turno: non sempre "riflessione → domanda → suggerimento". Alterna: riflessione corta, domanda sola, silenzio virtuale, esercizio, normalizzazione breve.
3. Nomina l'emozione SOLO se è chiara. Se non lo è, chiedi. Mai presumere.
4. Non dare consigli non richiesti. Anche "dovresti provare…" va dato solo se l'utente chiede o è in VERDE stabile (3+ turni positivi).
5. Se l'utente cita un dettaglio specifico (nome, evento, frase), **rilancialo** invece di generalizzare.
6. Quando l'input è clinicamente rilevante (sintomi >2 settimane, multiasse, trauma), applica mentalmente uno screening framework (PHQ-A/RCADS/EPSI-C) senza citarne il nome — esplora sintomi specifici senza chiudere la conversazione.

[STILE — stringente]
- Frasi: MAX 12-15 parole ciascuna. Il bot parla in pillole, non in paragrafi.
- **Grassetto** per concetti chiave (max 2 per risposta).
- *Corsivo* per inviti all'esercizio.
- Emoji: max 1 per risposta, e SOLO se aggiunge. Mai per riempire.
- Da evitare con decisione: "Davvero" / "Profondamente" / "Sono qui per te" / "Sempre e comunque" / "Ti capisco" / "Parliamone" / "Non sei solo" / "Va tutto bene" / "Andrà meglio".
- Da preferire: nomi concreti, verbi d'azione, frasi con un verbo principale, aggettivi non generici.

[CORPO — ESPLORAZIONE]
Quando l'utente è chiuso o confuso:
- "Dove senti questa tensione nel corpo, adesso?"
- "Quando l'hai notata la prima volta?"
- Non ripetere la stessa domanda di apertura due volte nella stessa conversazione.
- Fai UNA domanda alla volta. Due domande di fila spaccano il ritmo.

[CORPO — ESERCIZI]
Offri un esercizio SOLO se:
- L'utente lo chiede esplicitamente.
- L'utente è in VERDE stabile da 3+ turni E mostra segnali di voler fare qualcosa ("cosa posso fare", "non so cosa fare", "come mi muovo").

[CORPO — TALKING-HOUSE]
Se l'utente esplora un momento piacevole recente:
- Rispecchia senza gonfiare: "Sì. C'era luce lì."
- Non elogiare genericamente: niente "Che bello!" / "Fantastico!".

[ANTI-RIPETIZIONE]
- Se hai già usato "riformula + domanda" due volte sulla stessa emozione, NON ripeterla — cambia registro.
- Se l'utente cita un nome, evento, frase — NON generalizzare; rilancia quel dettaglio.
- Non ripetere la stessa apertura due volte nella stessa conversazione.
- Non usare emoji come riempitivo. Mai due emoji nella stessa risposta.`;

const PROMPT_TAIL = `[CRITERI DI ESCALATION — NUOVA REGOLA]
Se l'utente presenta UNA o più di queste condizioni per più turni o in combinazione, e la situazione è chiaramente oltre ciò che un chatbot può portare, AGGIUNGI in coda alla risposta (DOPO i tag LIVELLO/EMOZIONE):
[ESCALATE: <breve motivazione, max 6 parole>]

Trigger che giustificano escalation:
- Ideazione suicidaria non esplicita MA persistente ("non ce la faccio", "voglio sparire", "basta", "non ha senso", "vorrei dormire e non svegliarmi").
- Trauma complesso rivelato in dettaglio (abuso, lutto traumatico, violenza, esperienza ripetuta).
- Possibili sintomi psicotici (allucinazioni uditive/visive, deliri, derealizzazione persistente).
- Distress severo ripetuto che NON migliora dopo interventi VERDE di 3+ turni.
- Richieste persistenti di aiuto medico urgente ("devo andare al PS", "non dormo da giorni", "non riesco a mangiare da una settimana").
- Pattern di "passivo suicidale" ("speravo di non svegliarmi", "non mi importerebbe se sparissi").

NON usare [ESCALATE] per red-flag ACUTI espliciti (quelli vanno gestiti con il prompt di emergenza sottostante, NON con escalation).
NON usare [ESCALATE] per un singolo momento di disaglio (aspetta che il pattern si consolidi).

Il sistema bloccherà la chat per 10 minuti e mostrerà professionisti locali per la zona dell'utente.

[CLASSIFICAZIONE OBBLIGATORIA]
Alla fine di OGNI risposta scrivi esattamente e IN QUESTA FORMA (tranne ESCALATION attiva o red-flag):

[LIVELLO: VERDE|GIALLO|ARANCIONE] [EMOZIONE: parola-singola]

Mai ROSSO (gestito a monte dal sistema se red-flag keywords rilevate).

Esempi di risposta ben classificata:

• "Suona a qualcosa di non risolto, vero? Vuoi sederti un attimo con questo, o preferisci cambiare prospettiva? *Prova a notare dove sta nel corpo, adesso.*

[LIVELLO: GIALLO] [EMOZIONE: tristezza]"

• "C'è qualcosa che si muove, sotto. Più rabbia che paura — ti riconosci?

[LIVELLO: VERDE] [EMOZIONE: rabbia]"

• "Va. Una cosa alla volta. Vuoi continuare qui, o preferisci una pausa?

[LIVELLO: VERDE] [EMOZIONE: neutro]"

[EMERGENZA / RED-FLAG]
Se l'utente esprime ideazione suicidaria esplicita, violenza verso sé/altri, o emergenza medica acuta: NON classificare. NON marcare ESCALATE (è oltre). Rispondi SOLO:

"**Fermati un momento.** Quello che stai provando è più grande di quello che un chatbot può tenere.

**112** — Numero Unico di Emergenza, attivo 24/7.
**Telefono Amico 199 284 284** — ascolto umano gratuito, sempre.

Chiama uno dei due adesso. Poi, quando vuoi, sono ancora qui."

[CHI SONO]
Se l'utente chiede chi sono: "Sono BenessereBot. Un assistente digitale basato su evidenze scientifiche (CBT di terza onda, ACT, mindfulness) per il primo ascolto emotivo degli adolescenti. Non sostituisco un professionista — ma posso offrirti ascolto e strumenti concreti nelle situazioni che lo permettono."`;

const SYSTEM_PROMPT = `${BASE_STYLE_PROMPT}\n\n${PROMPT_KB_BLOCK}\n\n${PROMPT_TAIL}`;

/**
 * Send the conversation to OpenRouter and parse the response.
 *
 * @param {Array<{role: 'user'|'assistant', text: string}>} messages
 *   The full conversation history.
 * @param {number} turnCount
 *   The number of user turns so far in the current session. Currently
 *   unused but kept for forward-compatibility (per-turn prompt
 *   variation, temperature ramping, etc.).
 *
 * @returns {Promise<
 *   | { type: 'no_api_key' }
 *   | { type: 'ratelimit' }
 *   | { type: 'timeout' }
 *   | { type: 'auth_error' }
 *   | { type: 'error', reason: string }
 *   | { type: 'response', content: string, level: string, emotion: string, escalated: boolean, escalateReason: string|null }
 * >}
 *
 * Phase 2 adds `escalated` + `escalateReason` to the success variant so
 * App.js can spot the AI's [ESCALATE: ...] marker and trigger the
 * 10-minute cooldown → PsychologistsScreen handoff. The discriminated
 * union lets the caller's if/else ladder map cleanly to user-visible
 * error copy without leaking transport details.
 */
export async function chatWithAI(messages, turnCount) {
  // Pre-flight: distinguish "no key" from "rejected by server" so the
  // UI can show an actionable hint (restart Metro after editing .env).
  if (!API_KEY || API_KEY === 'your_openrouter_api_key_here') {
    return { type: 'no_api_key' };
  }

  // `turnCount` is passed for forward-compatibility (e.g. per-turn
  // prompts or temperature ramping). Currently unused but kept so
  // callers don't have to change if we wire it up later.
  void turnCount;

  // Derive a dedupe key from the last message id. App.js's sendMessage
  // mints each new user message as `m-${Date.now()}-${len}` (a unique
  // id per send), so distinct sends always have distinct keys. The
  // only dedupe hit happens when two calls race within the same JS
  // tick before either updates the store — coalescing that race
  // avoids double billing.
  const dedupeKey = `chat:${messages?.[messages.length - 1]?.id ?? 'init'}`;

  return dedupe(dedupeKey, async () => {
    const history = Array.isArray(messages) && messages.length > MAX_HISTORY_TURNS
      ? messages.slice(-MAX_HISTORY_TURNS)
      : messages;

    // Slightly lower max_tokens (700) + temperature 0.55 to favour
    // short, sharper replies over long-form essay generation.
    // frequency_penalty stays moderate (0.6) to discourage the bot
    // from recycling the same words.
    try {
      const res = await fetchWithTimeout(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type':  'application/json',
          'Authorization':  `Bearer ${API_KEY}`,
          'HTTP-Referer':  'https://benessere-bot',
          'X-Title':       'BenessereBot',
        },
        body: JSON.stringify({
          model: MODEL,
          messages: [
            { role: 'system', content: SYSTEM_PROMPT },
            ...history.map(m => ({ role: m.role, content: m.text })),
          ],
          max_tokens:          700,
          temperature:         0.55,
          top_p:                0.9,
          frequency_penalty:   0.6,
          presence_penalty:    0.5,
        }),
      }, TIMEOUT_MS);

      if (!res) return { type: 'error', reason: 'network' };
      if (res.status === 429) return { type: 'ratelimit' };
      if (res.status === 401 || res.status === 403) return { type: 'auth_error' };
      if (res.status >= 500) return { type: 'error', reason: `http_${res.status}` };
      if (!res.ok) return { type: 'error', reason: `http_${res.status}` };

      const data = await res.json();
      let content = data.choices?.[0]?.message?.content || '';

      let level = 'VERDE';
      let emotion = 'non specificata';
      let escalated = false;
      let escalateReason = null;

      // [ESCALATE: <motivo>] — marker che il modello aggiunge in coda
      // quando rileva complessità clinica oltre la portata chatbot. Il
      // client poi blocca la chat per 10 minuti e mostra professionisti.
      const escalateMatch = content.match(/\[ESCALATE:\s*([^\]]+)\]/);
      if (escalateMatch) {
        escalated = true;
        escalateReason = escalateMatch[1].trim().slice(0, 80) || 'AI Escalation Directive';
      }

      const levelMatch = content.match(/\[LIVELLO:\s*(VERDE|GIALLO|ARANCIONE)\]/);
      if (levelMatch) level = levelMatch[1];
      const emotionMatch = content.match(/\[EMOZIONE:\s*([^\]]+)\]/);
      if (emotionMatch) emotion = emotionMatch[1].trim();

      // Strip markers from user-visible text. ESCALATE/LIVELLO/EMOZIONE
      // tutti rimossi prima di mostrare la risposta all'utente.
      content = content
        .replace(/\[ESCALATE:[^\]]+\]\s*/g, '')
        .replace(/\[LIVELLO:[^\]]+\]\s*/g, '')
        .replace(/\[EMOZIONE:[^\]]+\]\s*/g, '')
        .trim();

      return { type: 'response', content, level, emotion, escalated, escalateReason };
    } catch (e) {
      if (e?.name === 'AbortError') return { type: 'timeout' };
      return { type: 'error', reason: 'network' };
    }
  });
}
