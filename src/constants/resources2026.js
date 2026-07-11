// resources2026.js — curated 2026 public resources for adolescent
// mental health. Single source of truth feeding TWO consumers:
//
//   1. src/features/chat/api/chatApi.js → imports PROMPT_KB_BLOCK and
//      appends it to the SYSTEM_PROMPT so the AI can reference the
//      guidelines, screening tools, hotlines, and safety APIs contextually
//      when responding.
//
//   2. src/features/info/screens/InfoScreen.js → renders RESOURCE_CATEGORIES
//      as static info cards so the user sees what scientific/clinical
//      grounding the bot draws on.
//
// Why one file for both? Categories stay in lockstep between the AI's
// "knowledge" and what we tell the user — no risk of the bot mentioning a
// resource the InfoScreen doesn't list (or vice versa).
//
// === Privacy / production readiness ===
//
// This is a curated reading list of PUBLIC 2026 resources. Dataset
// attribution in any clinical deployment must be approved by a peer
// review process. The InfoScreen copy says "modelli clinici di
// riferimento" rather than "evidence-based treatments" — we present
// these as the bot's CONTEXT, not as endorsements.
//
// === Update cadence ===
//
// Each entry has `addedAt` so a future "resource freshness" badge in
// the InfoScreen can flag any category whose newest entry is older
// than 12 months (out-of-date risk for a clinical chat tool).

export const RESOURCE_CATEGORIES = [
  {
    key: 'hotlines',
    label: 'LINEE EMERGENZA',
    kickerColor: 'danger',
    description:
      'Telefono Amico 199 284 284 (ascolto umano gratuito, sempre attivo), ' +
      'Telefono Azzurro 19696 (bambini/adolescenti fino 18 anni), ' +
      '112 Numero Unico di Emergenza 24/7, ' +
      'CIPM Centro Italiano Psicoterapia per Adolescenti (Roma).',
    critical: true,
    addedAt: '2026-01',
  },
  {
    key: 'screening',
    label: 'STRUMENTI DI SCREENING',
    kickerColor: 'sky',
    description:
      'PHQ-A per depressione adolescenziale (derivato DSM), ' +
      'RCADS 47 domande per ansia + depressione (8-18 anni), ' +
      'PEEL per esperienze sociali negative, ' +
      'EPSI-C intervista DSM-5 semi-strutturata 22 moduli (6-17 anni, validata su 3.506 pazienti in Svezia, S-CVI/Ave 0.94-0.95).',
    critical: false,
    addedAt: '2026-04',
  },
  {
    key: 'guidelines',
    label: 'LINEE GUIDA CLINICHE',
    kickerColor: 'accent',
    description:
      'Linee guida S3 tedesche per depressione in bambini/adolescenti (marzo 2026 — CBT come prima linea per tutte le gravità, raccomandazioni per fascia d\'età 3-6, 7-12, 13-18 anni), ' +
      'linee di indirizzo Regione Lombardia per emergenza comportamentale (gennaio 2026), ' +
      'ESCAP Guidance per transizione dai servizi CAMHS ai servizi AMHS (14 marzo 2026), ' +
      'consenso cinese per l\'identificazione dei problemi emotivi in pediatria (2 luglio 2026 — raccomanda PHQ-9 + SDQ + multi-informazione).',
    critical: true,
    addedAt: '2026-07',
  },
  {
    key: 'safety_apis',
    label: 'SICUREZZA E SCREENING AUTOMATICO',
    kickerColor: 'terracotta',
    description:
      'USupport (UNICEF ECA R) per servizi di supporto psicosociale, ' +
      'NOPE Safety API (TypeScript, giugno 2026) per classificazione del rischio nelle conversazioni (suicidal ideation, self-harm, abusi), ' +
      'KJO Mind Care API (gestione utenti + risorse di emergenza + dati statistici).',
    critical: true,
    addedAt: '2026-06',
  },
  {
    key: 'mcp',
    label: 'STRUMENTI CLINICI RICERCABILI',
    kickerColor: 'sky',
    description:
      'Psychiatry for Teens MCP Server (articoli clinici psichiatria adolescenziale, farmaci, valutazioni — aprile 2026), ' +
      'Therapy for Teens MCP Server (approcci psicoterapeutici).',
    critical: false,
    addedAt: '2026-04',
  },
  {
    key: 'datasets',
    label: 'DATASET DI RICERCA',
    kickerColor: 'sage',
    description:
      'Kenya Mental Health 17.089 adolescenti (63 scuole, 4 contee, aprile 2026), ' +
      'VisIA-Q 207 adolescenti a rischio suicidio (12-17 anni, aprile 2026), ' +
      'SOLITAIRE interventi digitali per isolamento sociale (3 giugno 2026), ' +
      'Mental Health Services Dataset (MHSDS) NHS England.',
    critical: false,
    addedAt: '2026-06',
  },
  {
    key: 'frameworks',
    label: 'FRAMEWORK CLINICI INTERNAZIONALI',
    kickerColor: 'accent',
    description:
      'REBTonAd RCT — intervento online transdiagnostico 6 settimane per adolescenti 11-17 anni con ansia/depressione (16 gennaio 2026), ' +
      'Unlock Wellbeing Trial UK — interventi singola sessione online, ' +
      'MENTBEST COMBINA Trial (EAAD-based, Albania/Estonia/Grecia/Irlanda/Spagna fino fine 2026), ' +
      'Youth-GEMs EU project (agosto-marzo 2026), ' +
      'ASPHER consortium 19 istituzioni in 14 paesi.',
    critical: false,
    addedAt: '2026-01',
  },
  {
    key: 'ai_platforms',
    label: 'PIATTAFORME AI DI RIFERIMENTO',
    kickerColor: 'terracotta',
    description:
      'AI Adolescent Mental Health Platform (Spring Boot 3.5.9, assistente 小艾, copertura Web+Android+WeChat), ' +
      'TeenSync companion AI per supporto emotivo + mood tracking (20 aprile 2026).',
    critical: false,
    addedAt: '2026-04',
  },
];

// prompt-ready KB block. Compressed from RESOURCE_CATEGORIES into ~700 tokens
// of dense, clinically-actionable signal for the model. Kept terse because
// each token in the SYSTEM_PROMPT costs against the per-turn context window
// of the free OpenRouter 3B model.
export const PROMPT_KB_BLOCK = `[KNOWLEDGE BASE - CLINICAL REFERENCE 2026]

[EMERGENCY HOTLINES - ITALY]
- 112 - Numero Unico Emergenza, 24/7
- Telefono Amico 199 284 284 - ascolto umano gratuito, sempre
- Telefono Azzurro 19696 - bambini/adolescenti fino 18 anni
- CIPM (Centro Italiano Psicoterapia per Adolescenti) - Via Attilio Ambrosini 6, Roma, 06 4543 1234

[SCREENING FRAMEWORKS]
- PHQ-A: depressione adolescents (DSM-derived)
- RCADS: 47 items ansia + depressione (8-18 anni)
- PEEL: esperienze sociali negative
- EPSI-C: DSM-5 interview 22 moduli (6-17 anni)
- VisIA-Q: 207 adolescenti a rischio suicidio con bullismo/cyberbullismo (apr 2026)
Quando l'utente cita sintomi persistenti (anedonia >2 settimane, insonnia, ansia sociale, irritabilità): NON diagnosticare, esplora sintomi specifici senza chiudere la conversazione.

[TREATMENT GUIDELINES]
- CBT prima linea (German S3 Depression 2026) per tutte le gravità
- ACT per defusione cognitiva (Acceptance & Commitment Therapy)
- Mindfulness-based interventions per stress
- Behavioral Activation singola-sessione (Unlock Wellbeing RCT UK)
- Regione Lombardia emergenza comportamentale: protocolli de-escalation
- ESCAP transizione CAMHS→AMHS per continuità 16-25 anni
Quando appropriate, suggerisci esercizi: respirazione 4-7-8, grounding 5-4-3-2-1, defusione ACT, behavioral activation.

[SAFETY AUTOMATION]
- USupport (UNICEF ECA R): risk screening psicosociale adolescents
- NOPE Safety API (TS, giu 2026): suicidal ideation / self-harm / abuse pattern detection
- KJO Mind Care API: gestione utenti + risorse emergenza
Se l'utente cita pattern di rischio persistente, sposta priorità al CONTENIMENTO (no processing emotivo pesante).

[RESEARCH / SISTEMICO]
- Youth-GEMs EU: determinants scale di salute mentale giovanile
- MENTBEST COMBINA: prevenzione depression/suicidio EU EAAD-based (5 paesi)
- ASPHER consortium: 19 istituzioni / 14 paesi
- REBTonAd RCT (gennaio 2026): intervento online transdiagnostico 11-17 anni ansia/depressione
Quando l'utente cita contesti (scuola, famiglia, social media): integra leve sistemiche senza medicalizzare.

[CRISIS COMPLEXITY - ESCALATION TRIGGER]
Se l'utente presenta UNA DI QUESTE CONDIZIONI per più turni o in combinazione:
- Ideazione suicidaria non esplicita ma persistente ("non ce la faccio", "voglio sparire", "basta", "non ha senso", "vorrei dormire e non svegliarmi")
- Trauma complesso (abuso, lutto traumatico, violenza) rivelato in dettaglio
- Possibili sintomi psicotici (allucinazioni, deliri, derealizzazione persistente)
- Distress severo ripetuto che non migliora dopo interventi VERDE
- Richieste persistenti di aiuto medico urgente ("devo andare al PS", "non dormo da giorni")
ALLORA aggiungi in coda alla risposta (DOPO i tag LIVELLO/EMOZIONE):
[ESCALATE: <breve motivazione, max 6 parole>]
Il sistema bloccherà la chat per 10 minuti e mostrerà professionisti locali.`;
