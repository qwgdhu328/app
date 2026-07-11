# BenessereBot

> Un compagno AI discreto per il benessere emotivo — Expo SDK 54 / React Native 0.81.5 / React 19.1.0

BenessereBot è un'app **privacy-first**, pensata come primo posto dove fermarsi quando
non hai un altro posto dove andare. Non è un medico, non è un terapeuta — è un
compagno di ascolto che propone esercizi basati su princìpi veri (respirazione,
ACT, CBT, grounding) erogati da un modello AI.

## Cosa fa

- 💬 **Chat riflessiva** con classificatori di distress (Verde / Arancione / Rosso)
  e una *safety pipeline hardcoded* per i red-flag: ideazione suicidaria → bypass
  modello, escalation automatica verso linee di ascolto.
- 🧘 **"Flusso di Coscienza"** — modalità free-write con analisi semantica locale
  (`FreeWriteScreen.js`) che genera una mind-map dei nodi emotivi.
- 📊 **Mood tracking** giornaliero su `react-native-mmkv` (persistenza locale, zero cloud).
- 🚨 **Escalation automatica** verso professionisti e linee di ascolto
  (*Telefono Amico 199 284 284* in IT) quando i segnali lo richiedono.
- 🌙 **Night-mode** + timer di sessione (45 / 20 min) per gentilezza d'uso.
- 🔒 **Zero retention**: tutto ciò che scrivi resta solo nella chat corrente.
  `/forget` cancella in-place. `/export` ti fa scaricare il testo.

## Stack

| Layer | Scelta |
|------|--------|
| Runtime | **Expo SDK 54** (iOS, Android, Web) |
| UI | React 19.1.0 + React Native 0.81.5 |
| State | Zustand 5 + `react-native-mmkv` |
| AI | OpenRouter (`/api/v1/chat/completions`) |
| UX | `expo-haptics`, `expo-linear-gradient`, `react-native-svg`, `react-native-safe-area-context` |
| Native peers | `react-native-nitro-modules` (richiesto da `react-native-mmkv@4.x`) |

## Setup

```bash
# 1. Dipendenze
npm install

# 2. Chiave API — NON committare, vedi .env.example
echo "EXPO_PUBLIC_OPENROUTER_API_KEY=sk-or-v1-..." > .env

# 3. Avvio dev server
npm start

# Build nativo. Le cartelle native sono gitignored, quindi su un clone
# fresco GENERALE prima le cartelle /ios e /android (poi lanri il build):
npx expo prebuild --platform ios      # solo iOS
npx expo prebuild --platform android  # solo Android

npm run ios
npm run android
npm run web
```

> Su **Web** il layer MMKV è auto-disattivato (storage no-op): lo stato resta
> in memoria finché non chiudi la pagina.

## Architettura

```
App.js                    # root shell — routing via useState, no nav library
FreeWriteScreen.js        # modal "Flusso di Coscienza" + analisi semantica locale
src/features/             # screens per feature
src/constants/            # design tokens (sage / terracotta / amber / danger / bg / text)
src/store/                # zustand slices: chat / mood / user
src/api/                  # fetchWithTimeout + retry primitives
src/components/           # ChatBubble, MoodIcon, PressableScale, QuickReplies, RichText, ...
```

> Nessuna libreria di navigazione: lo stato di routing è gestito con `useState`
> per `activeTab` + conditional rendering. Scelta consapevole — riduce
> accoppiamento con SDK in rapido movimento.

## Design tokens

```js
const C = {
  sage:       '#7D9B7D',
  terracotta: '#C97B63',
  amber:      '#F0C987',
  danger:     '#B3414A',
  bg:         '#1A1A24',
  text:       '#F4F0EB',
};
```

## Privacy & sicurezza

- **Nessun account, nessun database centrale, nessuna cronologia cloud.**
  Ogni parola che scrivi qui resta *solo* nella chat corrente; chiudi e sparisce.
- `EXPO_PUBLIC_OPENROUTER_API_KEY` viene iniettata al build — **non committare
  `.env`** (`.gitignore` lo esclude già).
- `/forget` svuota la chat in-place.
- Per dubbi GDPR / revoche: `dpo@benesserebot.app`.

## ⚠️ Disclaimer importante

Questa app **non sostituisce cure professionali**. Se stai attraversando un
momento difficile:

- **112** — Numero Unico di Emergenza (IT)
- **Telefono Amico 199 284 284** — ascolto umano, attivo 24/7 (IT)

Per favore, chiama. Anche adesso.

## Build & deploy

EAS è configurato in `eas.json` + workflow GitHub `.github/workflows/ios.yml`
(build iOS ad-hoc su UDID, manual dispatch). Build iOS (consigliato via EAS, niente prebuild locale):

```bash
npx eas-cli device:create                 # la prima volta, registra UDID
eas build --profile development --device <UDID>

# oppure build locale (richiede prebuild):
npx expo prebuild --platform ios
npm run ios
```

---

MIT — vedi `LICENSE`.
