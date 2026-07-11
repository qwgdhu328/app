// gps-spoofer-app/App.js — Phase 1 thin root component.
//
// === Phase 0.A → 1 arc ===
// After three rounds of extraction, App.js is now a thin root that owns
// only what genuinely can't move out: the 3 nav useState, the zustand
// selectors the routing needs, and the chat-lifecycle handlers
// (sendMessage, acceptConsent, handleDeepDive, resetChat,
// handleQuickPick) that cross screen boundaries.
//
// What lives elsewhere now:
//   - 6 screens (Home/Chat/Profile/Community/Info/Intro) → src/features/<feature>/screens/*.js
//   - TabBar + TabIconRenderer + tabStyles                  → src/navigation/TabBar.js
//   - chatWithAI + SYSTEM_PROMPT                            → src/features/chat/api/chatApi.js
//   - fetchWithTimeout + dedupe primitives                  → src/api/_core.js
//   - accentFor helper                                      → src/utils/identity.js
//   - date utilities                                         → src/utils/date.js
//   - MOODS constant                                         → src/constants/moods.js
//
// Remaining sendMessage body (~165 lines) extracts to a useChatLogic
// hook in a future phase — keeping it inline for now so this phase
// focuses on the navigation + api split.

import React, { useState, useCallback, useRef, useEffect, useMemo } from 'react';
import {
  StyleSheet, Text, View, Alert, Platform, KeyboardAvoidingView,
} from 'react-native';
// SafeAreaView intentionally imported from react-native-safe-area-context
// (not from 'react-native') so it sources its padding from the
// SafeAreaProvider the index.js wraps <App /> in. RN's built-in
// SafeAreaView only reads iOS's UIEdgeInsets natively — on Android it
// ran off StatusBar.currentHeight, which doesn't reflect real gesture /
// notch cutouts on edge-to-edge OEMs. With this import the top status
// bar gets correct padding on both platforms.
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { chatWithAI } from './src/features/chat/api/chatApi';
import { useChatStore } from './src/store/chatStore';
import { useMoodStore } from './src/store/moodStore';
import { useUserStore } from './src/store/userStore';
import { calcStreak } from './src/utils/date';
import FreeWriteScreen from './FreeWriteScreen';
import { C } from './src/constants/theme';
import { TECNICHE } from './src/constants/botData';
import { cleanupMarkdown, hasRedFlag, isNightMode } from './src/utils/text';

// === Phase 0.C: 6 screens extracted to feature folders ===
// Each consumes its own store via granular selectors + own handlers. App.js
// passes only navigation callbacks + chat-lifecycle handlers (sendMessage,
// resetChat, acceptConsent, handleQuickPick).
import IntroScreen from './src/features/intro/screens/IntroScreen';
import OnboardingScreen from './src/features/onboarding/screens/OnboardingScreen';
import HomeScreen from './src/features/home/screens/HomeScreen';
import ChatScreen from './src/features/chat/screens/ChatScreen';
import PsychologistsScreen from './src/features/chat/screens/PsychologistsScreen';
import ProfileScreen from './src/features/profile/screens/ProfileScreen';
import CommunityScreen from './src/features/community/screens/CommunityScreen';
import InfoScreen from './src/features/info/screens/InfoScreen';
import TabBar from './src/navigation/TabBar';

// TabBar (with TabIconRenderer + tabStyles + TABS const + GlassView +
// icons + PressableScale + useWindowDimensions deps) still lives in
// src/navigation/TabBar.js. App.js no longer imports or renders it —
// the bottom-floating capsule was hiding the bottom of each page on
// small screens / landscape, so navigation now lives inline on each
// screen: HomeScreen quickGrid has a "Tu" card → Profile; every non-
// Home screen has a "← Home" back chip in its own header.


// `pick` — random array picker used by sendMessage for the multiple-variant
// greeting injection (night-warning phrases, professional-reminder phrases,
// technique offer phrases). Kept at module-level so all sendMessage
// branches share one helper.
const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];

// === App() — root component ===

export default function App() {
  // === Phase 0.B: state ownership ===
  // 3 nav useState (activeTab, showFreeWrite, showIntro) live here because
  // they cross screen boundaries and there's only ONE instance of the app
  // shell.
  const [activeTab, setActiveTab] = useState('home');
  const [showFreeWrite, setShowFreeWrite] = useState(false);
  const [showIntro, setShowIntro] = useState(true);
  // === Phase 4: Onboarding gate ===
  // `onboarded` reads the persisted userStore flag. `showOnboarding`
  // mirrors it locally so the App shell can keep using simple useState
  // for routing. The initial useState (!onboarded) reads the selector
  // value synchronously (zustand persist hydrates MMKV at module-load
  // time) — a returning user never sees the tour again, a fresh user
  // sees it once.
  const onboarded = useUserStore((s) => s.onboardingCompleted);
  const [showOnboarding, setShowOnboarding] = useState(!onboarded);

  // ── chatStore (ephemeral, enforces the privacy contract) ────────────
  // Reads are granular selectors (only re-render when the slice identity
  // changes). Setters come from .getState() once per render — stable
  // references in zustand, no subscription cost.
  const messages       = useChatStore((s) => s.messages);
  const input          = useChatStore((s) => s.input);
  const thinking       = useChatStore((s) => s.thinking);
  const chatBlocked    = useChatStore((s) => s.chatBlocked);
  const consentGiven   = useChatStore((s) => s.consentGiven);
  const turnCount      = useChatStore((s) => s.turnCount);
  const currentLevel   = useChatStore((s) => s.currentLevel);
  const levelHistory   = useChatStore((s) => s.levelHistory);
  const isOffline      = useChatStore((s) => s.isOffline);
  // === Bug fix: sendMessage reads these four slices; earlier only their
  // SETTERS were destructured from getState(), so the VALUES were undefined
  // in sendMessage's closure and dep array → "ReferenceError: Property
  // 'offeredTechniques' doesn't exist" surfaced on iOS via ErrorBoundary.
  // Subscribing them as granular selectors here keeps the shell re-render
  // cheap (only re-renders when one of these slices actually changes). ===
  const offeredTechniques        = useChatStore((s) => s.offeredTechniques);
  const nightWarningShown        = useChatStore((s) => s.nightWarningShown);
  const durationWarningLevel     = useChatStore((s) => s.durationWarningLevel);
  const professionalReminderShown = useChatStore((s) => s.professionalReminderShown);
  // === Phase 2: Escalation telemetry ===
  const escalatedAt    = useChatStore((s) => s.escalatedAt);
  const cooldownMs     = useChatStore((s) => s.cooldownMs);
  const escalateReason = useChatStore((s) => s.escalateReason);
  const {
    setMessages, setInput, setThinking, setChatBlocked, setConsentGiven,
    setTurnCount, setCurrentLevel, setLevelHistory,
    setOfferedTechniques, setNightWarningShown, setDurationWarningLevel,
    setProfessionalReminderShown, setLikedMessages, setIsOffline,
    toggleLike,
  } = useChatStore.getState();

  // ── moodStore (persisted via MMKV — used by handlePickMood) ─────────
  // moodToday + moodHistory are unused in this shell anymore (HomeScreen
  // + ProfileScreen read them via their own selectors) but kept as a
  // defensive read in case a future phase needs eager access. `streak`
  // was previously subscribed here to pass down to the bottom TabBar;
  // now that the bar is gone, the shell doesn't need it — each screen
  // computes streak on demand via its own `useMoodStore((s) => calcStreak(...))`.
  const moodToday   = useMoodStore((s) => s.moodToday);
  const moodHistory = useMoodStore((s) => s.moodHistory);
  const pickMood    = useMoodStore((s) => s.pickMood);

  // ── userStore (persisted via MMKV — lifetime stats + name) ──────────
  // userName/totalSessions/totalTurns are read by HomeScreen + TabBar;
  // we read them here for the stats-bar delegation logic when needed.
  const userName      = useUserStore((s) => s.userName);
  const totalSessions = useUserStore((s) => s.totalSessions);
  const totalTurns    = useUserStore((s) => s.totalTurns);
  // NOTE: setUserName reads/writes are now owned by ProfileScreen via
  // its own selector. Subscribing here would over-render the shell on
  // every name-edit — leave it out so App.js only re-renders when a
  // stat the shell actually displays (streak → TabBar) changes.

  // === Refs ===
  // sessionStart: timestamp for duration warnings (45min/20min).
  // messagesRef: mirror of latest messages array so cb closures (e.g.
  // /export via setTimeout) read fresh data without stale state.
  // sendMessageRef: lets quick-reply chips fire sendMessage via
  // setTimeout(0) without capturing the current input-value.
  const sessionStart  = useRef(Date.now());
  const messagesRef   = useRef(messages);
  const sendMessageRef = useRef(null);

  useEffect(() => { messagesRef.current = messages; }, [messages]);

  // === Network status listener (web-only) ===
  // React Native doesn't ship a unified "online/offline" event — only
  // web's window.addEventListener('online'/'offline') maps reliably.
  // On native, isOffline stays false unless chatWithAI reports a
  // network/type:error result, at which point sendMessage flips it.
  useEffect(() => {
    if (typeof navigator !== 'undefined' && navigator.onLine !== undefined) {
      const goOnline  = () => setIsOffline(false);
      const goOffline = () => setIsOffline(true);
      window.addEventListener('online',  goOnline);
      window.addEventListener('offline', goOffline);
      setIsOffline(!navigator.onLine);
      return () => {
        window.removeEventListener('online',  goOnline);
        window.removeEventListener('offline', goOffline);
      };
    }
  }, []);

  // Safe-area insets at the root. The root View takes `paddingTop: insets.top`
  // (status bar / dynamic island). TabBar owns `bottom: insets.bottom + 8`.
  const insets = useSafeAreaInsets();

  // === Phase 2: Cooldown interval ===
  // Polls every second while an escalation is active. When the 10-min
  // window elapses, automatically clear the escalation so the next
  // user action re-routes to ChatScreen without needing a manual
  // tap. Drives the render-branch toggle below (PsychologistsScreen
  // vs ChatScreen when activeTab === 'chat').
  const [isEscalationActive, setIsEscalationActive] = useState(false);
  useEffect(() => {
    if (!escalatedAt) {
      setIsEscalationActive(false);
      return;
    }
    const check = () => {
      if (Date.now() - escalatedAt >= cooldownMs) {
        useChatStore.getState().clearEscalation();
        setIsEscalationActive(false);
      } else {
        setIsEscalationActive(true);
      }
    };
    check();
    const interval = setInterval(check, 1000);
    return () => clearInterval(interval);
  }, [escalatedAt, cooldownMs]);

  // === Handlers ===

  // Mood pick: lightweight haptic + atomic store action.
  const handlePickMood = useCallback((mood) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
    pickMood(mood);
  }, [pickMood]);

  // Consent gate: opens the chat lifecycle with the privacy preamble.
  // Two messages hit the stream at once: user "Sì" + assistant preamble.
  const acceptConsent = useCallback(() => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
    setConsentGiven(true);
    setMessages((prev) => [
      ...prev,
      { role: 'user',      text: 'Sì' },
      {
        role: 'assistant',
        text: '**Bene. Ci siamo.**\n\nLe parole che scrivi qui le legge un modello di AI — di passaggio, niente di più. **Niente si attacca a te.** Non c\u2019è database, non c\u2019è cronologia, non c\u2019è account.\n\nLe parole che scrivi qui appartengono solo a questa conversazione. Quando chiudi, spariscono.\n\n**/forget** cancella tutto. **/export** te le fa scaricare. **/disclaimer** ti mostra i dettagli legali.\n\nPer dubbi sulla privacy: dpo@benesserebot.app.\n\n*E ora, come stai in questo momento?*',
      },
    ]);
  }, []);

  // FreeWrite → Chat handoff: when FreeWrite's "deep dive" finishes a
  // mind-map, it seeds the chat with the surfaced topics list.
  const handleDeepDive = useCallback((mapData) => {
    const topics = mapData?.topics || [];
    const topicNames = topics.map((t) => t.name).join(', ');
    setShowFreeWrite(false);
    setActiveTab('chat');
    setChatBlocked(false);
    setTurnCount(0);
    setOfferedTechniques(new Set());
    setNightWarningShown(false);
    setDurationWarningLevel(null);
    setProfessionalReminderShown(false);
    setMessages([{
      role: 'assistant',
      text: `Ho letto il tuo paesaggio. Vedo forte questi nodi: **${topicNames}**. Da dove vuoi partire — li ascoltiamo uno alla volta?`,
    }]);
    setConsentGiven(true);
  }, []);

  // === sendMessage — the chat-lifecycle core ===
  // Owned by App.js because it touches network (chatWithAI), chatStore
  // setters (11 of them), and input/thinking/conversation state in one
  // transactional flow. A future phase extracts this into a useChatLogic
  // hook; for now it stays inline so this phase focuses on the
  // navigation + api split.
  const sendMessage = useCallback(async () => {
    if (!input.trim() || thinking || chatBlocked) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
    const text = input.trim();

    // === Consent gate ===
    // Without explicit consent ("Sì"), every user message is treated as
    // waiting-for-consent; the only path through is the literal "Sì"
    // (with diacritics/diacritic-stripped normalization).
    if (!consentGiven) {
      if (text.normalize('NFD').replace(/[\s\u0300-\u036f]/g, '').toLowerCase() === 'si') {
        setConsentGiven(true);
        setMessages((prev) => [...prev, { role: 'user', text }]);
        setInput('');
        setMessages((prev) => [...prev, { role: 'assistant', text: '**Bene, ci siamo.**\n\nOra possiamo parlare davvero.' }]);
        return;
      }
      setMessages((prev) => [...prev, { role: 'user', text }]);
      setInput('');
      setMessages((prev) => [...prev, { role: 'assistant', text: 'Per proseguire serve il tuo **consenso informato**.\n\nDigita **"Sì"** per accettare e iniziare, oppure tocca il bottone qui sotto.' }]);
      return;
    }

    // === Slash commands ===
    const cmd = text.toLowerCase();
    if (cmd === '/forget') {
      setMessages([]);
      setInput('');
      setLikedMessages(new Set());
      setMessages((prev) => [...prev, { role: 'assistant', text: '**Fatto.** Chat azzerata. Nessun dato è mai stato memorizzato.' }]);
      return;
    }
    if (cmd === '/export') {
      const exportText = messagesRef.current
        .map((m) => `${m.role === 'user' ? 'Tu' : 'Bot'}: ${cleanupMarkdown(m.text)}`)
        .join('\n\n');
      Alert.alert('Esporta conversazione', 'Copia il testo qui sotto:\n\n' + exportText.slice(0, 2000));
      return;
    }
    if (cmd === '/disclaimer') {
      setMessages((prev) => [...prev, { role: 'user', text }]);
      setInput('');
      setMessages((prev) => [...prev, {
        role: 'assistant',
        text: '**Chi sono (in breve).**\n\nSono questo: un primo posto dove fermarti quando non hai un altro posto dove andare. Non sono un medico, non sono un terapeuta, non ti prescrivo niente. Sono qui per ascoltare — e, se ti va, provare insieme qualche esercizio.\n\nLe tecniche che ti propongo usano princìpi veri (respirazione, ACT, CBT, grounding) — ma **erogati da un\u2019AI non sono un percorso di cura** clinica.\n\n**Se la situazione è seria, chiama il 112 o il Telefono Amico (199 284 284).** Sempre. Anche adesso — anche se non ti sembra "abbastanza grave".\n\n**E niente di quello che scrivi qui viene salvato.** Chiudi l\u2019app e sparisce tutto. Vai tranquilla.',
      }]);
      return;
    }

    // === Red-flag injection (HARDCODED safety layer) ===
    // hasRedFlag(text) detects suicidal/self-harm ideation and pivots
    // the chat to ROSSO + blocks further typing. This is the FIRST
    // line of defense before the AI response (AI would also block,
    // but we want an immediate visible signal that doesn't depend on
    // the model).
    if (hasRedFlag(text)) {
      setChatBlocked(true);
      setCurrentLevel('ROSSO');
      setMessages((prev) => [...prev, { role: 'user', text }]);
      setInput('');
      setMessages((prev) => [...prev, {
        role: 'assistant',
        text: '**TI SENTO. FERMATI UN MOMENTO.**\n\nQuello che stai provando è più grande di quello che un chatbot può tenere. Per favore:\n\n**112** — Numero Unico di Emergenza\n**Telefono Amico 199 284 284** — ascolto umano, sempre attivo\n\n*Prendi il telefono. Fallo adesso. Poi torna qui quando vuoi — io sono ancora qui.*',
        level: 'ROSSO',
        showEmergency: true,
      }]);
      return;
    }

    // === Phase 2: Client-side escalation heuristic ===
    // Catches patterns the AI might miss: persistent ARANCIONE/R in
    // levelHistory OR clear user-distress phrases that warrant
    // immediate professional context. Runs BEFORE the AI call so we
    // don't waste tokens on a response that will be discarded.
    const recentTurns = levelHistory.slice(-3);
    const persistentArancione = recentTurns.length === 3
      && recentTurns.every((l) => l.level === 'ARANCIONE' || l.level === 'ROSSO');
    const userDespairPhrase = /non ce la faccio|voglio sparire|mi voglio male|non ha senso|non ce la faccio pi\u00f9|voglio morire|basta|non voglio pi\u00f9|non mi importerebbe|sparire|sparirmi/i.test(text);
    if ((persistentArancione || userDespairPhrase) && !hasRedFlag(text)) {
      useChatStore.getState().escalate(
        persistentArancione
          ? 'Distress persistente (ARANCIONE)'
          : 'Segnale di disagio rilevato'
      );
      // Mint ids inline so the FlatList's keyExtractor never sees an
      // id=undefined entry — defensive against the duplicate-key
      // collision that surfaced on iOS in Phase 2.
      const ts = Date.now();
      const userMsgId      = `m-${ts}-${levelHistory.length}`;
      const assistantMsgId = `m-${ts}-${levelHistory.length + 1}`;
      setMessages((prev) => [
        ...prev,
        { id: userMsgId,      role: 'user',      text },
        { id: assistantMsgId, role: 'assistant', text: '**Quello che stai attraversando \u00e8 pi\u00f9 di quello che un chatbot pu\u00f2 portare.**\n\nFacciamo una pausa di 10 minuti. Nel frattempo puoi chiamare **Telefono Amico 199 284 284** \u2014 \u00e8 attivo 24/7, oppure sfoglia i professionisti nella tua zona. Poi, se vuoi, torniamo qui.', level: 'ARANCIONE' },
      ]);
      setInput('');
      return;
    }

    // === Send to AI ===
    // Id format `m-${Date.now()}-${messagesLen}` is the day-bucket
    // parser contract — ChatScreen's day-separator reads it.
    const newMsg = { id: `m-${Date.now()}-${messagesRef.current.length}`, role: 'user', text };
    const conv = [...messagesRef.current, newMsg];
    setMessages((prev) => [...prev, newMsg]);
    setInput('');
    setThinking(true);
    setIsOffline(false);

    try {
      const result = await chatWithAI(conv, turnCount);

      if (result.type === 'ratelimit') {
        setMessages((prev) => [...prev, { role: 'assistant', text: '**Respira.** Tanti messaggi insieme — riprova tra qualche secondo.' }]);
        return;
      }
      if (result.type === 'timeout') {
        setIsOffline(true);
        setMessages((prev) => [...prev, { role: 'assistant', text: '**Ci mette troppo.** Scrivi più breve o riprova.' }]);
        return;
      }
      if (result.type === 'auth_error') {
        setMessages((prev) => [...prev, { role: 'assistant', text: '**Errore di autenticazione API.** Chiave OpenRouter rifiutata (401/403). Controlla `.env` e **riavvia Metro** dopo ogni modifica (le env `EXPO_PUBLIC_*` sono inlineate al build).' }]);
        return;
      }
      if (result.type === 'no_api_key') {
        setMessages((prev) => [...prev, { role: 'assistant', text: '**API key mancante.** Metti `EXPO_PUBLIC_OPENROUTER_API_KEY=...` in `.env` e **riavvia Metro**.' }]);
        return;
      }
      if (result.type === 'error') {
        if (result.reason === 'network') setIsOffline(true);
        if (result.reason === 'http_502' || result.reason === 'http_503' || result.reason === 'http_504') {
          setMessages((prev) => [...prev, { role: 'assistant', text: '**L\u2019AI è sovraccarica.** Il modello gratuito di OpenRouter sta rispondendo lentamente in questo momento. Ti va di riprovare fra un minuto? Puoi anche chiudere e riaprire la chat — il contenuto è solo tuo.' }]);
          return;
        }
        setMessages((prev) => [...prev, { role: 'assistant', text: '**Errore di connessione.** Verifica la rete e riprova.' }]);
        return;
      }

      setIsOffline(false);

      // === Phase 2: AI escalation marker ===
      // If the AI self-marked with [ESCALATE: <reason>], call
      // chatStore.escalate(). The interval effect above then renders
      // PsychologistsScreen instead of ChatScreen. We still append this
      // bot turn (with stripped markers) so the user sees the pause as
      // a deliberate boundary, not an error.
      if (result.escalated) {
        useChatStore.getState().escalate(result.escalateReason || 'AI Escalation Directive');
        setMessages((prev) => [...prev, {
          id: `m-${Date.now()}-${prev.length}`,
          role: 'assistant',
          text: (result.content || '') + '\n\n*Andiamo avanti dopo una pausa. In questa schermata trovi i professionisti nella tua zona e le linee di ascolto disponibili 24/7.*',
          level: 'ARANCIONE',
        }]);
        return;
      }

      const level = result.level || 'VERDE';
      setCurrentLevel(level);
      const newTurnCount = turnCount + 1;
      setTurnCount(newTurnCount);
      setLevelHistory((prev) => [...prev, { level, emotion: result.emotion, time: Date.now() }]);

      const elapsed = (Date.now() - sessionStart.current) / 60000;
      let finalText = result.content;

      // === Night-mode warning (1× per session, on first turn after 11pm) ===
      if (isNightMode() && !nightWarningShown && newTurnCount === 1) {
        finalText = pick([
          '\u00c8 molto tardi. Le notti sembrano più lunghe quando si è soli con i propri pensieri. Telefono Amico è sveglio con te: **199 284 284**.\n\n',
          'Notte fonda. Le emozioni si amplificano al buio. Se vuoi una voce umana: **199 284 284**.\n\n',
          'L\u2019alba arriva sempre. Anche quando sembra lontanissima. Intanto: **199 284 284**.\n\n',
        ]) + finalText;
        setNightWarningShown(true);
      }

      // === ARANCIONE professional reminder (after 3+ turns) ===
      if (level === 'ARANCIONE' && newTurnCount >= 3 && !professionalReminderShown) {
        finalText += '\n\n' + pick([
          '**Quello che stai vivendo merita più attenzione.** Hai qualcuno con cui parlare nella vita reale? Telefono Amico (**199 284 284**) può essere un primo passo.',
          '**Non sei leggero/a in questo.** Hai mai pensato di parlare con un professionista? Posso aiutarti a trovare le parole.',
          '**Questa situazione è importante.** Se non l\u2019hai già fatto, parlare con qualcuno di fiducia potrebbe fare la differenza.',
        ]);
        setProfessionalReminderShown(true);
      }

      // === Every-15-turns disclaimer reminder ===
      if (newTurnCount > 0 && newTurnCount % 15 === 0) {
        finalText += '\n\n**Promemoria importante:** sono un\u2019AI. Per un percorso continuativo, un professionista umano è insostituibile.';
      }

      // === Duration warnings (45min + 20min) ===
      if (elapsed > 45 && durationWarningLevel !== 45) {
        finalText += '\n\n**Sei qui da più di 45 minuti.** Bicì d\u2019acqua, una passeggiata, due respiri. A volte chiudere e riaprire fa bene.';
        setDurationWarningLevel(45);
      } else if (elapsed > 20 && !durationWarningLevel) {
        finalText += '\n\n**Sei qui da un po\u2019.** Prenderti una pausa è un atto di cura, non una resa.';
        setDurationWarningLevel(20);
      }

      // === Technique offer ===
      // Maps emotion → technique category (respirazione / grounding /
      // scrittura / defusione / ristrutturazione), then offers the
      // technique if the user has been asking for help OR every 5
      // turns after the 3rd (skipping the first 3 to avoid flooding).
      // Only offered at VERDE/GIALLO — ARANCIONE preempts with the
      // professional reminder.
      const emotion = result.emotion;
      const emoMap = {
        paura: 'grounding', rabbia: 'ristrutturazione',
        tristezza: 'scrittura', disgusto: 'defusione',
        sorpresa: 'grounding',
      };
      const technique = emoMap[emotion] || 'respirazione';
      const isAskingForHelp = /sì|va bene|ok|dai|prova|esercizio|tecnica|aiuto/i.test(input);
      const isEarlyTurn = newTurnCount < 3;
      const alreadyOfferedThis = offeredTechniques.has(technique);
      const shouldOffer = (level === 'VERDE' || level === 'GIALLO')
        && !isEarlyTurn && !alreadyOfferedThis
        && (isAskingForHelp || newTurnCount % 5 === 0);

      if (shouldOffer) {
        const tec = TECNICHE[technique];
        finalText += '\n\n' + pick([
            '**Posso insegnarti un esercizio che potrebbe servirti in questo momento.**',
            '**C\u2019è una cosa piccola che potremmo provare insieme, se ti va.**',
            '**Se ti senti pronto/a, ho un esercizio che ti potrebbe aiutare.**',
          ])
          + '\n\n' + tec.descrizione
          + '\n\n*Per salvarlo per dopo: tocca il cuoricino sotto questo messaggio.*';
        finalText += `\n\n__offer_technique__${technique}__`;
        setOfferedTechniques((prev) => new Set(prev).add(technique));
      }

      setMessages((prev) => [...prev, {
        id: `m-${Date.now()}-${prev.length}`,
        role: 'assistant',
        text: finalText,
        level,
        technique: shouldOffer ? technique : null,
      }]);
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error('[BenessereBot] sendMessage error:', e);
      setIsOffline(true);
      setMessages((prev) => [...prev, { role: 'assistant', text: '**Errore inatteso.** Niente panico — riproviamo tra un attimo.' }]);
    } finally {
      setThinking(false);
    }
  }, [input, thinking, chatBlocked, consentGiven, turnCount, offeredTechniques, nightWarningShown, durationWarningLevel, professionalReminderShown]);

  // Keep the latest sendMessage reference up to date for quick-reply auto-send.
  useEffect(() => { sendMessageRef.current = sendMessage; }, [sendMessage]);

  // Quick-reply chip → fixed text → fire send via timing-safe setTimeout.
  // sendMessageRef.current() reads the latest sendMessage closure without
  // re-creating this callback each render — so deps stay at [setInput].
  const handleQuickPick = useCallback((key) => {
    const map = {
      continue:  'Vai avanti, ti ascolto',
      deep:      'Approfondiamo questo punto',
      technique: 'Vorrei provare un esercizio',
      pause:     'Mi prendi una pausa con me?',
    };
    const text = map[key];
    if (!text) return;
    setInput(text);
    setTimeout(() => {
      if (sendMessageRef.current) sendMessageRef.current();
    }, 0);
  }, [setInput]);

  // Reset chat: atomic 2-store call (chatStore.resetChat() + userStore.incrSessions).
  const resetChat = useCallback(() => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {});
    if (turnCount > 0) useUserStore.getState().incrSessions(turnCount);
    useChatStore.getState().resetChat();
    sessionStart.current = Date.now();
  }, [turnCount]);

  // messagesWithIds: ensures every message carries the `m-…` id chatStore
  // normally mints. Required for ChatScreen's `dayBucket(id)` regex to
  // anchor. Only re-runs when messages identity changes.
  const messagesWithIds = useMemo(
    () => messages.map((m, idx) => (m.id ? m : { ...m, id: `m-${Date.now()}-${idx}` })),
    [messages]
  );

  return (
    // Root View takes inline paddingTop: insets.top + paddingBottom
    // for TabBar, NOT SafeAreaView (which has a documented flex-collapse
    // gotcha at the layout root — that was the "non si vede tutta l'app"
    // regression). TabBar is positioned absolute below the content.
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: 60 }]}>
      <StatusBar style="light" />

      {showIntro && <IntroScreen onDone={() => setShowIntro(false)} />}

      {!showIntro && showOnboarding && (
        <OnboardingScreen
          onAdvance={() => {
            // Persist completion so the tour doesn't run again on the
            // next app launch. setShowOnboarding(false) takes effect
            // immediately so the next render branch (Home/Chat/...)
            // takes over without an intermediate skeleton state.
            useUserStore.getState().setOnboardingCompleted(true);
            setShowOnboarding(false);
          }}
        />
      )}

      {!showIntro && !showOnboarding && showFreeWrite && (
        <FreeWriteScreen
          onBack={() => setShowFreeWrite(false)}
          onDeepDive={handleDeepDive}
        />
      )}

      {!showIntro && !showOnboarding && !showFreeWrite && activeTab === 'home' && (
        <HomeScreen
          onNavigate={setActiveTab}
          onFreeWrite={() => setShowFreeWrite(true)}
          onPickMood={handlePickMood}
        />
      )}

      {!showIntro && !showOnboarding && !showFreeWrite && activeTab === 'chat' && isEscalationActive && (
        <PsychologistsScreen onNavigate={setActiveTab} />
      )}

      {!showIntro && !showOnboarding && !showFreeWrite && activeTab === 'chat' && !isEscalationActive && (
        <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : 'height'} keyboardVerticalOffset={0}>
          <ChatScreen
            onSend={sendMessage}
            onReset={resetChat}
            onAcceptConsent={acceptConsent}
            onQuickPick={handleQuickPick}
            onNavigate={setActiveTab}
          />
        </KeyboardAvoidingView>
      )}

      {!showIntro && !showOnboarding && !showFreeWrite && activeTab === 'profile' && (
        <ProfileScreen
          onStartChat={() => setActiveTab('chat')}
          onJumpToChat={() => setActiveTab('chat')}
          onNavigate={setActiveTab}
        />
      )}

      {!showIntro && !showOnboarding && !showFreeWrite && activeTab === 'community' && (
        <CommunityScreen onNavigate={setActiveTab} />
      )}

      {!showIntro && !showOnboarding && !showFreeWrite && activeTab === 'info' && (
        <InfoScreen onBack={() => setActiveTab('home')} />
      )}

      {!showIntro && !showOnboarding && !showFreeWrite && (
        <TabBar activeTab={activeTab} onTabPress={setActiveTab} />
      )}
    </View>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Style alias — root container.
// ─────────────────────────────────────────────────────────────────────────────
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },
});
