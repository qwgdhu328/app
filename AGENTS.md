# BenessereBot — Production Build

**Expo SDK 54** — React Native 0.81.5 — React 19.1.0

## Key Files
- `App.js` — Main app (Home, Chat, Profile, Info, FreeWrite screens)
- `api.js` — OpenRouter client with 30s timeout, error classification
- `FreeWriteScreen.js` — "Flusso di Coscienza" with local semantic analysis

## Commands
- `npm start` — Expo dev server
- `npm run ios` / `npm run android` — native builds

## Architecture
- No navigation lib — tab state via `activeTab` + conditional rendering
- FreeWrite mode hides tab bar via `showFreeWrite` flag
- Chat uses `messagesRef` to avoid stale closures
- Offline detection via `navigator.onLine` event listeners
- API key hardcoded in `api.js` — move to `.env` before production

## Design Tokens
Defined as `const C = {...}` in both `App.js` and `FreeWriteScreen.js`:
sage=#7D9B7D, terracotta=#C97B63, amber=#F0C987, danger=#B3414A, bg=#1A1A24, text=#F4F0EB
