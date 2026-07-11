// One-shot migration: replace hard-coded emoji/🐍jsontchr code points with SVG icons.
// Deterministic string/regex replacements — never touches anything that does
// not match exactly. Run once, verify, then delete this file.

const fs = require('fs');

function countBeforeAfter(label, before, after, marker) {
  const was = before.split(marker).length - 1;
  const now = after.split(marker).length - 1;
  console.log(`  · ${label}: ${was} -> ${now}`);
}

// ───────────────────────── App.js ─────────────────────────
let app = fs.readFileSync('App.js', 'utf8');

const APP_REPLACEMENTS = [
  // 1. Extend icons import block + add MoodIcon import
  {
    label: 'imports',
    find: "import {\n  HomeIcon, ChatIcon, ProfileIcon, PenIcon, InfoIcon,\n  BackIcon, LockIcon, HeartIcon, StreakIcon,\n} from './icons';",
    replace: "import {\n  HomeIcon, ChatIcon, ProfileIcon, PenIcon, InfoIcon,\n  BackIcon, LockIcon, HeartIcon, StreakIcon,\n  SparklesIcon, ShieldIcon,\n} from './icons';\nimport MoodIcon from './src/components/MoodIcon';",
  },
  // 2. MOODS data — rename emoji → iconName
  {
    label: 'MOODS.great',
    find: /\{ key: 'great',   emoji: '[^']*', +/,
    replace: "{ key: 'great',   iconName: 'sparkle',     label: 'Top',       color: C.sage,        light: C.sageLight },",
  },
  {
    label: 'MOODS.good',
    find: /\{ key: 'good',    emoji: '[^']*', +/,
    replace: "{ key: 'good',    iconName: 'sun',         label: 'Bene',      color: C.sky,         light: C.skyLight },",
  },
  {
    label: 'MOODS.meh',
    find: /\{ key: 'meh',     emoji: '[^']*', +/,
    replace: "{ key: 'meh',     iconName: 'meh',         label: 'Così così', color: C.amber,       light: C.amberLight },",
  },
  {
    label: 'MOODS.low',
    find: /\{ key: 'low',     emoji: '[^']*', +/,
    replace: "{ key: 'low',     iconName: 'cloud_rain',  label: 'Giù',       color: C.terracotta,  light: C.terracottaLight },",
  },
  {
    label: 'MOODS.anxious',
    find: /\{ key: 'anxious', emoji: '[^']*', +/,
    replace: "{ key: 'anxious', iconName: 'heart_pulse', label: 'Ansioso/a', color: C.accent,      light: C.accentLight },",
  },
  {
    label: 'MOODS.tired',
    find: /\{ key: 'tired',   emoji: '[^']*', +/,
    replace: "{ key: 'tired',   iconName: 'moon',        label: 'Esausto/a',color: C.textMuted,    light: 'rgba(124,114,134,0.18)' },",
  },
  // 3. MoodToday pill — emoji text → MoodIcon in a view that preserves the style
  {
    label: 'moodToday renderer',
    find: "<Text style={h.moodTodayEmoji}>{(MOODS.find((m) => m.key === moodToday.key) || MOODS[0]).emoji}</Text>",
    replace: "<View style={h.moodTodayEmoji}><MoodIcon name={(MOODS.find((m) => m.key === moodToday.key) || MOODS[0]).iconName} color={(MOODS.find((m) => m.key === moodToday.key) || MOODS[0]).color} size={28} /></View>",
  },
  // 4. Mood picker chip — emoji text inside PressableScale (preserve scale transform)
  {
    label: 'mood chip renderer',
    find: "<Text style={[h.moodEmoji, picked && { transform: [{ scale: 1.15 }] }]}>{m.emoji}</Text>",
    replace: "<View style={[h.moodEmoji, picked && { transform: [{ scale: 1.15 }] }]}><MoodIcon name={m.iconName} color={picked ? C.primaryInk : m.color} size={26} /></View>",
  },
  // 5. Quick card top-left sparkle (✦)
  {
    label: '✦ quick card',
    find: "<Text style={[h.quickEmoji, { color: C.primary }]}>✦</Text>",
    replace: "<SparklesIcon size={22} color={C.primary} />",
  },
  // 6. Quick card ‘i’ placeholder for Info
  {
    label: 'i quick card',
    find: "<Text style={[h.quickEmoji, { color: C.sky }]}>i</Text>",
    replace: "<InfoIcon size={22} color={C.sky} />",
  },
  // 7. StreakToday mood emoji
  {
    label: 'streakToday mood',
    find: "<Text style={pr.streakTodayEmoji}>{(MOODS.find((m) => m.key === moodHistory.find((h) => h.day === todayKey())?.key) || MOODS[2]).emoji}</Text>",
    replace: "<View style={pr.streakTodayEmoji}><MoodIcon name={(MOODS.find((m) => m.key === moodHistory.find((h) => h.day === todayKey())?.key) || MOODS[2]).iconName} color={(MOODS.find((m) => m.key === moodHistory.find((h) => h.day === todayKey())?.key) || MOODS[2]).color} size={28} /></View>",
  },
  // 8–12. Community stories data — emoji → iconName
  {
    label: 'story 1 sprout',
    find: /\{ id: 1, emoji: '\\u\{1F331\}', testo: [^}]+ },\n/,
    replace: "{ id: 1, iconName: 'sprout',         testo: 'Oggi ho fatto pace con una parte di me che evitavo da anni. Piano piano.', reazioni: 24 },\n",
  },
  {
    label: 'story 2 sun',
    find: /\{ id: 2, emoji: '\\u\{2600\}\\uFE0F', testo: [^}]+ },\n/,
    replace: "{ id: 2, iconName: 'sun',            testo: 'Questa settimana sono riuscito a fare 3 passeggiate. Per me \\u00e8 una vittoria enorme.', reazioni: 18 },\n",
  },
  {
    label: 'story 3 bolt',
    find: /\{ id: 3, emoji: '\\u\{1F4AA\}', testo: [^}]+ },\n/,
    replace: "{ id: 3, iconName: 'bolt',           testo: 'Ho chiesto aiuto per la prima volta. Spaventoso, ma liberatorio.', reazioni: 37 },\n",
  },
  {
    label: 'story 4 pen_alt',
    find: /\{ id: 4, emoji: '\\u\{1F4DD\}', testo: [^}]+ },\n/,
    replace: "{ id: 4, iconName: 'pen_alt',        testo: 'Scrivere i miei pensieri ogni sera mi ha aiutato a dormire meglio.', reazioni: 31 },\n",
  },
  {
    label: 'story 5 smile_concern',
    find: /\{ id: 5, emoji: '\\u\{1F62C\}', testo: [^}]+ },\n/,
    replace: "{ id: 5, iconName: 'smile_concern',  testo: 'Oggi ho ascoltato un amico senza giudicare. Mi sono sentito bene anche io.', reazioni: 42 },\n",
  },
  // 13. Community story emoji renderer
  {
    label: 'story renderer',
    find: "<Text style={co.storyEmoji}>{st.emoji}</Text>",
    replace: "<View style={co.storyEmoji}><MoodIcon name={st.iconName} color={C.sage} size={26} /></View>",
  },
  // 14. 🛟 guide pill
  {
    label: 'shield guide pill',
    find: "<Text style={co.guidePillIcon}>🛡️</Text>",
    replace: "<ShieldIcon size={13} color={C.primary} />",
  },
];

for (const r of APP_REPLACEMENTS) {
  const before = app;
  if (r.find instanceof RegExp) {
    const m = app.match(r.find);
    if (!m) { console.log(`  [SKIP] ${r.label}: no match`); continue; }
    app = app.replace(r.find, r.replace);
  } else {
    if (!app.includes(r.find)) { console.log(`  [SKIP] ${r.label}: no match`); continue; }
    app = app.split(r.find).join(r.replace);
  }
  console.log(`  [OK]   ${r.label}`);
}
fs.writeFileSync('App.js', app);

// Re-verify: any emoji codepoint (\u1F300-\u1FFFF, dingbats) still present?
function countEmoji(s) {
  let n = 0;
  for (const ch of s) {
    const cp = ch.codePointAt(0);
    if ((cp >= 0x1F300 && cp <= 0x1F5FF) || (cp >= 0x1F600 && cp <= 0x1F64F) ||
        (cp >= 0x1F680 && cp <= 0x1F6FF) || (cp >= 0x1F900 && cp <= 0x1F9FF) ||
        (cp >= 0x2600 && cp <= 0x27BF)) n++;
  }
  return n;
}
console.log(`  App.js remaining emoji codepoints: ${countEmoji(app)}`);

// ───────────────────────── FreeWriteScreen.js ─────────────────────────
let fws = fs.readFileSync('FreeWriteScreen.js', 'utf8');

const FWS_REPLACEMENTS = [
  // 1. Add MoodIcon import after the icons import
  {
    label: 'import MoodIcon',
    find: "import { BackIcon } from './icons';",
    replace: "import { BackIcon } from './icons';\nimport MoodIcon from './src/components/MoodIcon';",
  },
  // 2. PLUTCHIK entries — rename icon → iconName
  {
    label: 'PLUTCHIK rabbia',
    find: "rabbia: { keywords: ['rabbia', 'arrabbiato', 'furioso', 'irritato', 'odio'], icon: '🔥' }",
    replace: "rabbia: { keywords: ['rabbia', 'arrabbiato', 'furioso', 'irritato', 'odio'], iconName: 'fire' }",
  },
  {
    label: 'PLUTCHIK paura',
    find: /paura: \{ keywords: \[[^\]]+\], icon: '[^']*' \}/,
    replace: "paura: { keywords: ['paura', 'ansia', 'terrore', 'panico', 'spaventato'], iconName: 'heart_pulse' }",
  },
  {
    label: 'PLUTCHIK tristezza',
    find: /tristezza: \{ keywords: \[[^\]]+\], icon: '[^']*' \}/,
    replace: "tristezza: { keywords: ['triste', 'tristezza', 'deluso', 'malinconico', 'piango', 'disperazione'], iconName: 'cloud_rain' }",
  },
  {
    label: 'PLUTCHIK gioia',
    find: /gioia: \{ keywords: \[[^\]]+\], icon: '[^']*' \}/,
    replace: "gioia: { keywords: ['felice', 'contento', 'gioia', 'bene', 'sereno'], iconName: 'sun' }",
  },
  {
    label: 'PLUTCHIK disgusto',
    find: /disgusto: \{ keywords: \[[^\]]+\], icon: '[^']*' \}/,
    replace: "disgusto: { keywords: ['disgusto', 'schifo', 'repulsione', 'antipatia'], iconName: 'frown' }",
  },
  {
    label: 'PLUTCHIK sorpresa',
    find: /sorpresa: \{ keywords: \[[^\]]+\], icon: '[^']*' \}/,
    replace: "sorpresa: { keywords: ['sorpreso', 'stupore', 'shock', 'inaspettato'], iconName: 'sparkle' }",
  },
  // 8. analyzeText returns `icon: PLUTCHIK[e].icon` — switch to iconName
  {
    label: 'analyzeText return field',
    find: "icon: PLUTCHIK[e].icon",
    replace: "iconName: PLUTCHIK[e].iconName",
  },
  // 9. Emotion bar renderer — Text+emoji → MoodIcon in View
  {
    label: 'emotion bar renderer',
    find: "<Text style={s.barEmoji}>{emo.icon}</Text>",
    replace: "<View style={s.barEmoji}><MoodIcon name={emo.iconName} color={colors[emo.name] || C.sage} size={20} /></View>",
  },
];

for (const r of FWS_REPLACEMENTS) {
  if (r.find instanceof RegExp) {
    const m = fws.match(r.find);
    if (!m) { console.log(`  [SKIP] ${r.label}: no match`); continue; }
    fws = fws.replace(r.find, r.replace);
  } else {
    if (!fws.includes(r.find)) { console.log(`  [SKIP] ${r.label}: no match`); continue; }
    fws = fws.split(r.find).join(r.replace);
  }
  console.log(`  [OK]   ${r.label}`);
}
fs.writeFileSync('FreeWriteScreen.js', fws);
console.log(`  FreeWriteScreen.js remaining emoji codepoints: ${countEmoji(fws)}`);

console.log('Migration done.');
