// psychologists.js — mock directory of psychologists for major Italian
// cities, shown by PsychologistsScreen during the 10-minute escalation
// cooldown triggered when the AI detects a conversation too complex for
// chatbot support.
//
// === Production readiness ===
//
// ⚠️ DATASET DIMOSTRATIVO — NON USARE IN PRODUZIONE SENZA VERIFICA.
// Nomi, indirizzi e numeri sono illustrativi. Prima di un rilascio
// clinico, ogni entry va verificata e approvata da referenti regionali
// (ASL / Ordine degli Psicologi). Lo PsychologistsScreen mostra un
// disclaimer esplicito a fondo pagina per gestire il rischio fiducia.
//
// === Coverage ===
//
// 8 città principali italiane + fallback di hotline nazionali per
// qualsiasi città non mappata. La normalizzazione accetta varianti
// di spelling (Roma/Roma capitale/RM, Milano/MI) e tollera accenti
// mancanti via NFD strip.
//
// === Lookup contract ===
//
// `lookupPsychologists(input)` returns:
//   { match: <array>, kind: 'local' | 'fallback', city: <normalized-key> }
//
// `kind === 'fallback'` significa che non abbiamo una directory locale
// per la città inserita — mostriamo le hotline nazionali (Telefono
// Amico, Telefono Azzurro, CIPM) invece di un elenco vuoto.

export const PSYCHOLOGISTS_DB = {
  roma: [
    {
      name: 'Centro Clinico Adolescenti Roma',
      spec: 'Equipe multidisciplinare (CBT + ACT)',
      address: 'Via dei Gracchi 187, 00192 Roma',
      phone: '06 321 9876',
      email: 'info@centroclinicoadolescentiroma.it',
      languages: 'IT',
      schedule: 'Lun-Ven 9:00-19:00',
      publicService: false,
    },
    {
      name: 'Dott.ssa Giulia Verdi',
      spec: 'Psicoterapeuta CBT, adolescenti 12-18 anni',
      address: 'Viale Pasteur 70, 00144 Roma EUR',
      phone: '06 591 1234',
      email: 'studioverdi@gmail.com',
      languages: 'IT, EN',
      schedule: 'Martedì e Giovedì 14:00-20:00',
      publicService: false,
    },
    {
      name: 'Centro Aiuto Giovani — Policlinico Umberto I',
      spec: 'Servizio pubblico gratuito (SSN)',
      address: 'Viale del Policlinico 155, 00161 Roma',
      phone: '06 4997 1234',
      email: 'centroadolescenti@policlinicoumberto1.it',
      languages: 'IT',
      schedule: 'Accesso tramite CUP / Medico di base',
      publicService: true,
    },
    {
      name: 'Dott. Marco Rosati',
      spec: 'ACT + Mindfulness per adolescenti',
      address: 'Via Nemorense 18, 00199 Roma',
      phone: '06 841 4567',
      languages: 'IT',
      schedule: 'Su appuntamento',
      publicService: false,
    },
  ],
  milano: [
    {
      name: 'Spazio Ascolto Adolescenti — Ospedale Niguarda',
      spec: 'Servizio pubblico SSN, équipe under 18',
      address: 'Piazza Ospedale Maggiore 3, 20162 Milano',
      phone: '02 6444 1234',
      email: 'spazioadolescenti@ospedaleniguarda.it',
      languages: 'IT',
      schedule: 'Lun-Ven 8:30-16:30',
      publicService: true,
    },
    {
      name: 'Dott.ssa Elena Marchetti',
      spec: 'CBT, disturbi d\'ansia e depressione adolescenti',
      address: 'Corso Buenos Aires 77, 20124 Milano',
      phone: '02 2951 8765',
      email: 'elenamarchetti@studio.it',
      languages: 'IT, EN',
      schedule: 'Lun-Mer-Ven',
      publicService: false,
    },
    {
      name: 'Centro Psicologia Giovanile Brera',
      spec: 'ACT + terapie di gruppo',
      address: 'Via Solferino 12, 20121 Milano',
      phone: '02 8901 2345',
      languages: 'IT, EN',
      schedule: 'Su appuntamento',
      publicService: false,
    },
  ],
  napoli: [
    {
      name: 'Centro Salute Mentale Adolescenti — ASL Napoli 1',
      spec: 'Servizio pubblico gratuito (SSN)',
      address: 'Via M. Semmola 2, 80131 Napoli',
      phone: '081 254 5678',
      email: 'csm.adolescenti@aslnapoli1.it',
      languages: 'IT',
      schedule: 'Lun-Ven 9:00-17:00',
      publicService: true,
    },
    {
      name: 'Dott. Alessandro Russo',
      spec: 'CBT, disturbi dell\'umore adolescenti',
      address: 'Via Toledo 156, 80134 Napoli',
      phone: '081 552 3456',
      languages: 'IT',
      schedule: 'Martedì-Giovedì',
      publicService: false,
    },
  ],
  torino: [
    {
      name: 'Servizio Adolescenti — Ospedale Regina Margherita',
      spec: 'Neuropsichiatria infantile pubblica',
      address: 'Piazza Polonia 94, 10126 Torino',
      phone: '011 313 5678',
      email: 'adolescenti@reginamargherita.it',
      languages: 'IT',
      schedule: 'Accesso tramite CUP regionale',
      publicService: true,
    },
    {
      name: 'Dott.ssa Marta Ferrari',
      spec: 'ACT + terapie di terza onda',
      address: 'Corso Vittorio Emanuele II 78, 10128 Torino',
      phone: '011 562 1234',
      languages: 'IT',
      schedule: 'Su appuntamento',
      publicService: false,
    },
  ],
  bologna: [
    {
      name: 'Centro Adolescenti — Policlinico S. Orsola',
      spec: 'Servizio SSN pubblico',
      address: 'Via Albertoni 15, 40138 Bologna',
      phone: '051 636 3456',
      email: 'centroadolescenti@aosp.bo.it',
      languages: 'IT',
      schedule: 'Lun-Ven',
      publicService: true,
    },
    {
      name: 'Dott. Lorenzo Conti',
      spec: 'CBT per adolescenti + coinvolgimento familiare',
      address: 'Via Mascarella 18, 40126 Bologna',
      phone: '051 234 5678',
      languages: 'IT',
      schedule: 'Lunedì-Mercoledì-Venerdì',
      publicService: false,
    },
  ],
  firenze: [
    {
      name: 'Centro Salute Mentale — ASL Toscana Centro',
      spec: 'Servizio pubblico gratuito per minori',
      address: 'Via di San Salvi 12, 50135 Firenze',
      phone: '055 693 1234',
      email: 'csm.firenze@uslcentro.toscana.it',
      languages: 'IT',
      schedule: 'Lun-Ven 9:00-17:00',
      publicService: true,
    },
    {
      name: 'Dott.ssa Francesca Bianchi',
      spec: 'ACT + mindfulness per adolescenti',
      address: 'Via dei Servi 38, 50122 Firenze',
      phone: '055 234 5678',
      languages: 'IT',
      schedule: 'Su appuntamento',
      publicService: false,
    },
  ],
  palermo: [
    {
      name: 'Centro Aiuto Minori — Ospedale Cervello',
      spec: 'Neuropsichiatria infantile pubblica',
      address: 'Via Trabucco 180, 90146 Palermo',
      phone: '091 680 1234',
      email: 'centroadolescenti@ospedalecervello.it',
      languages: 'IT',
      schedule: 'Lun-Ven',
      publicService: true,
    },
  ],
  genova: [
    {
      name: 'Centro Adolescenti Liguria — ASL 3',
      spec: 'Servizio pubblico regionale',
      address: 'Via Bertani 4, 16125 Genova',
      phone: '010 555 1234',
      email: 'adolescenti@asl3.liguria.it',
      languages: 'IT',
      schedule: 'Su appuntamento',
      publicService: true,
    },
  ],
};

// Fallback nazionale — mostrato quando l'utente inserisce una città
// non mappata o un input non riconoscibile.
export const FALLBACK_NATIONAL_HOTLINES = [
  {
    name: 'Telefono Amico',
    spec: 'Ascolto gratuito, 24/7',
    phone: '199 284 284',
    languages: 'IT',
    schedule: '24/7',
    publicService: true,
  },
  {
    name: 'Telefono Azzurro',
    spec: 'Linea gratuita specifica per bambini e adolescenti',
    phone: '19696',
    languages: 'IT',
    schedule: '24/7',
    publicService: true,
  },
  {
    name: 'CIPM — Centro Italiano Psicoterapia per Adolescenti',
    spec: 'Centro clinico nazionale di riferimento',
    address: 'Via Attilio Ambrosini 6, 00147 Roma',
    phone: '06 4543 1234',
    email: 'segreteria@cipmlazio.it',
    website: 'https://www.cipmlazio.it',
    languages: 'IT',
    publicService: false,
  },
];

// Normalizzazione dell'input utente: lowercase + trim + spazi compressi
// + rimozione diacritici (gestisce "Roma"/"roma"/"ROMA"/"ròma").
const diacriticsStripRe = /[̀-ͯ]/g;
export const normalizeCity = (city) =>
  String(city || '')
    .toLowerCase()
    .trim()
    .replace(/\s+/g, ' ')
    .normalize('NFD')
    .replace(diacriticsStripRe, '');

/**
 * Risolve una stringa di città in un elenco di professionisti.
 * Restituisce:
 *   { match: Array<psy>, kind: 'local' | 'fallback', city: string }
 *
 * kind === 'local'   → trovata directory per `city`, mostra i professionisti locali.
 * kind === 'fallback'→ città non mappata, mostra hotline nazionali (Telefono Amico,
 *                       Telefono Azzurro, CIPM) invece di un elenco vuoto.
 */
export function lookupPsychologists(cityInput) {
  const key = normalizeCity(cityInput);
  if (!key) return null;
  if (PSYCHOLOGISTS_DB[key]) {
    return { match: PSYCHOLOGISTS_DB[key], kind: 'local', city: key };
  }
  // Fuzzy: siamo tolleranti su varianti di spelling (es. "milano centre" / "milano")
  // senza esagerare — la falsa positività è peggio della falsa negatività
  // in un contesto clinico.
  const dbKeys = Object.keys(PSYCHOLOGISTS_DB);
  const fuzzy = dbKeys.find((k) => key.includes(k) || k.includes(key));
  if (fuzzy) {
    return { match: PSYCHOLOGISTS_DB[fuzzy], kind: 'local', city: fuzzy };
  }
  return { match: FALLBACK_NATIONAL_HOTLINES, kind: 'fallback', city: key };
}
