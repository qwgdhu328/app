import { useState, useRef, useEffect, useMemo, useCallback } from 'react';
import {
  StyleSheet, Text, View, TouchableOpacity,
  TextInput, ScrollView, Animated, useWindowDimensions, Alert, AccessibilityInfo
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
// Note: `Dimensions` was removed in favour of `useWindowDimensions` so the
// mind-map nodes re-center on rotation / iPad split without a stale
// module-level SCREEN_W captured at launch.
import { BackIcon } from './icons';
import MoodIcon from './src/components/MoodIcon';
import PressableScale from './src/components/PressableScale';
import { C, emotionColors } from './src/constants/theme';

const TOPIC_KEYWORDS = {
  Lavoro: ['lavoro', 'carriera', 'ufficio', 'colleghi', 'capo', 'stipendio', 'professione', 'impiego', 'carriera'],
  Relazioni: ['relazione', 'partner', 'amore', 'famiglia', 'amici', 'madre', 'padre', 'fratello', 'sorella', 'matrimonio', 'separazione'],
  Ansia: ['ansia', 'paura', 'preoccupazione', 'timore', 'panico', 'stress', 'tensione', 'nervoso'],
  Futuro: ['futuro', 'domani', 'prossimo', 'cambiamento', 'obiettivo', 'progetto', 'crescita', 'possibilità'],
  Passato: ['passato', 'ricordo', 'infanzia', 'trauma', 'errore', 'rimpianto', 'rimorso', 'ferita'],
  Salute: ['salute', 'corpo', 'dolore', 'medico', 'terapia', 'sonno', 'fatica', 'energia', 'malattia'],
  Autostima: ['autostima', 'valore', 'merito', 'capacità', 'inadeguato', 'insufficienza', 'fallimento', 'successo', 'fiducia'],
  Rabbia: ['rabbia', 'frustrazione', 'ingiustizia', 'delusione', 'risentimento', 'ira', 'odio'],
};

const PLUTCHIK = {
  rabbia: { keywords: ['rabbia', 'arrabbiato', 'furioso', 'irritato', 'odio'], iconName: 'fire' },
  paura: { keywords: ['paura', 'ansia', 'terrore', 'panico', 'spaventato'], iconName: 'heart_pulse' },
  tristezza: { keywords: ['triste', 'tristezza', 'deluso', 'malinconico', 'piango', 'disperazione'], iconName: 'cloud_rain' },
  gioia: { keywords: ['felice', 'contento', 'gioia', 'bene', 'sereno'], iconName: 'sun' },
  disgusto: { keywords: ['disgusto', 'schifo', 'repulsione', 'antipatia'], iconName: 'frown' },
  sorpresa: { keywords: ['sorpreso', 'stupore', 'shock', 'inaspettato'], iconName: 'sparkle' },
};

// NOTE: SCREEN_W used to be read at MODULE LOAD from Dimensions.get(), which
// froze it forever. After rotation / iPad resize, the mind-map nodes would
// stay positioned for the launch-time width. Now `SCREEN_W` is provided by
// `useWindowDimensions()` INSIDE the component — every re-render gets the
// current value and analyzeText repositions nodes correctly.
function analyzeText(text, SCREEN_W) {
  if (!text.trim()) return null;
  const lower = text.toLowerCase();
  const sentences = text.split(/[.!?\n]+/).filter(Boolean);

  const topicScores = {};
  for (const [topic, words] of Object.entries(TOPIC_KEYWORDS)) {
    let count = 0;
    for (const w of words) {
      const regex = new RegExp('\\b' + w + '\\b', 'gi');
      const matches = lower.match(regex);
      if (matches) count += matches.length;
    }
    if (count > 0) topicScores[topic] = count;
  }

  const emotionScores = {};
  let totalEmo = 0;
  for (const [emotion, data] of Object.entries(PLUTCHIK)) {
    let count = 0;
    for (const kw of data.keywords) {
      const regex = new RegExp('\\b' + kw + '\\b', 'gi');
      const matches = lower.match(regex);
      if (matches) count += matches.length;
    }
    emotionScores[emotion] = count;
    totalEmo += count;
  }

  const topTopics = Object.entries(topicScores)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5);

  const topEmotions = Object.entries(emotionScores)
    .filter(([_, c]) => c > 0)
    .sort((a, b) => b[1] - a[1]);

  // Build the connection graph from the SAME topics we'll display (top 4),
  // so positions and lines stay coherent and we never get self-loops or -1 indices.
  const top3Topics = topTopics.slice(0, 4);
  const connections = [];
  for (let i = 0; i < top3Topics.length; i++) {
    for (let j = i + 1; j < top3Topics.length; j++) {
      const [topicA] = top3Topics[i];
      const [topicB] = top3Topics[j];
      let coOccur = 0;
      for (const sent of sentences) {
        const s = sent.toLowerCase();
        const wordsA = TOPIC_KEYWORDS[topicA];
        const wordsB = TOPIC_KEYWORDS[topicB];
        const hasA = wordsA.some(w => s.includes(w));
        const hasB = wordsB.some(w => s.includes(w));
        if (hasA && hasB) coOccur++;
      }
      if (coOccur > 0) connections.push({ from: topicA, to: topicB, strength: coOccur });
    }
  }

  const nodePositions = {};
  const angleStep = (2 * Math.PI) / top3Topics.length;
  const radius = 100;
  top3Topics.forEach(([t], i) => {
    const angle = angleStep * i - Math.PI / 2;
    nodePositions[t] = {
      x: SCREEN_W / 2 - 40 + radius * Math.cos(angle),
      y: 140 + radius * Math.sin(angle),
    };
  });

  const extractedSentences = {};
  top3Topics.forEach(([topic]) => {
    const words = TOPIC_KEYWORDS[topic];
    const relevant = [];
    for (const sent of sentences) {
      const s = sent.toLowerCase();
      if (words.some(w => s.includes(w))) {
        relevant.push(sent.trim());
        if (relevant.length >= 2) break;
      }
    }
    extractedSentences[topic] = relevant;
  });

  return {
    topics: top3Topics.map(([t, s]) => ({ name: t, score: s, sentences: extractedSentences[t] || [] })),
    connections,
    emotions: topEmotions.map(([e, c]) => ({ name: e, count: c, pct: totalEmo > 0 ? c / totalEmo : 0, iconName: PLUTCHIK[e].iconName })),
    nodePositions,
    totalEmo,
  };
}

function BreathingWave({ active }) {
  const anim = useRef(new Animated.Value(0)).current;
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    AccessibilityInfo.isReduceMotionEnabled().then(setReduceMotion);
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', setReduceMotion);
    return () => sub.remove();
  }, []);

  useEffect(() => {
    if (!active || reduceMotion) return;
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(anim, { toValue: 1, duration: 4000, useNativeDriver: true }),
        Animated.timing(anim, { toValue: 0, duration: 4000, useNativeDriver: true }),
      ])
    );
    loop.start();
    return () => loop.stop();
  }, [active, reduceMotion]);

  const scale = anim.interpolate({ inputRange: [0, 1], outputRange: [1, 1.15] });
  const opacity = anim.interpolate({ inputRange: [0, 0.5, 1], outputRange: [0.15, 0.3, 0.15] });

  if (!active) return null;
  return (
    <View style={{ height: 30, justifyContent: 'center', alignItems: 'center', marginTop: 8 }}>
      <Animated.View style={{ width: 60, height: 4, borderRadius: 2, backgroundColor: C.primary, transform: [{ scaleX: scale }], opacity }} />
    </View>
  );
}

function formatTime(sec) {
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${m}:${s.toString().padStart(2, '0')}`;
}

export default function FreeWriteScreen({ onBack, onDeepDive }) {
  // Reactive screen width — updates on rotation, foldable open/close, iPad
  // multitasking split. Passed into analyzeText so the mind-map centers
  // around the current visible width.
  const { width: SCREEN_W } = useWindowDimensions();

  // Safe-area insets. The App root <View> already applies
  //   `paddingTop: insets.top`, so we deliberately drop the prior
  //   `Platform.OS === 'ios' ? 10 : 16` heuristic on s.header /
  //   s.writeHeader entirely — any additional paddingTop here would
  //   double-pad (visible regression on iOS X+ where insets.top ≈ 47pt
  //   would have left ~94pt of dead space at the top). The hook stays
  //   available for future per-screen needs (a sub-modal that needs its
  //   own bottom inset, a sticky CTA that lives just above the home
  //   indicator, etc.).
  const insets = useSafeAreaInsets();
  const [phase, setPhase] = useState('setup');
  const [minutes, setMinutes] = useState(5);
  const [timeLeft, setTimeLeft] = useState(300);
  const [text, setText] = useState('');
  const [selectedNode, setSelectedNode] = useState(null);
  const timerRef = useRef(null);
  const processingTimeoutRef = useRef(null);
  const textRef = useRef('');

  useEffect(() => {
    textRef.current = text;
  }, [text]);

  useEffect(() => {
    if (phase !== 'writing') return;
    const id = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          clearInterval(id);
          handleEnd();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    timerRef.current = id;
    return () => clearInterval(id);
  }, [phase, handleEnd]);

  // Cancel any pending 'processing → map' transition if the screen is torn
  // down while we wait for the 800ms timeout (prevents React "setState on
  // unmounted component" warnings and wasted work).
  useEffect(() => {
    return () => {
      if (processingTimeoutRef.current) {
        clearTimeout(processingTimeoutRef.current);
        processingTimeoutRef.current = null;
      }
    };
  }, []);

  const handleStart = () => {
    setTimeLeft(minutes * 60);
    setPhase('writing');
  };

  const handleEnd = useCallback(() => {
    clearInterval(timerRef.current);
    if (!textRef.current.trim()) {
      setPhase('setup');
      return;
    }
    setPhase('processing');
    if (processingTimeoutRef.current) clearTimeout(processingTimeoutRef.current);
    processingTimeoutRef.current = setTimeout(() => setPhase('map'), 800);
  }, []);

  const handleInterrupt = useCallback(() => {
    Alert.alert('Interrompere?', 'Il testo scritto verrà comunque analizzato.', [
      { text: 'Continua a scrivere', style: 'cancel' },
      { text: 'Interrompi', style: 'destructive', onPress: () => { clearInterval(timerRef.current); handleEnd(); } },
    ]);
  }, [handleEnd]);

  // Exit while writing: the user wants to bail, not analyze. Different
  // verb than `Interrompi`, different outcome (their text is discarded,
  // not run through the analyze pipeline). Same Alert shape so the
  // user has a moment to reconsider — keeps the journaling surface
  // from eating drafts on accidental taps.
  const handleExitFromWriting = useCallback(() => {
    const hasDraft = (textRef.current || '').trim().length > 0;
    if (!hasDraft) {
      onBack();
      return;
    }
    Alert.alert(
      'Uscire senza salvare?',
      'Il testo che hai scritto non verrà analizzato in una mappa mentale e andrà perso.',
      [
        { text: 'Continua a scrivere', style: 'cancel' },
        { text: 'Esci', style: 'destructive', onPress: () => { clearInterval(timerRef.current); onBack(); } },
      ]
    );
  }, [onBack]);


  const mapData = useMemo(() => {
    if (phase !== 'map') return null;
    // SCREEN_W is captured in the closure here; when it changes (rotation),
    // this memo invalidates because the component re-renders, picking up
    // the latest value.
    return analyzeText(textRef.current, SCREEN_W);
  }, [phase, SCREEN_W]);

  const nodeColors = [C.sage, C.terracotta, C.amber, '#7DA0C9', '#C97BA0'];

  if (phase === 'setup') {
    return (
      <View style={s.container}>
        <View style={s.header}>
          <TouchableOpacity onPress={onBack} style={s.backBtn}>
            <BackIcon /><Text style={s.backText}> Indietro</Text>
          </TouchableOpacity>
        </View>
        <ScrollView contentContainerStyle={s.scroll}>
          <View style={s.setupCard}>
            <Text style={s.setupTitle}>Flusso di Coscienza</Text>
            <Text style={s.setupDesc}>
              Per i prossimi minuti, io rimarrò in silenzio. Questo spazio è solo tuo.
              {'\n\n'}Scrivi tutto ciò che ti passa per la testa: paure, rabbia, sogni, parole senza senso.
              Non ti correggerò, non ti fermerò.
              {'\n\n'}Al termine, riceverai una mappa dei tuoi pensieri.
            </Text>
          </View>

          <Text style={s.sliderLabel}>Durata: {minutes} minuti</Text>
          <View style={s.sliderRow}>
            {[3, 4, 5, 6, 7].map(n => (
              <TouchableOpacity
                key={n}
                style={[s.sliderOpt, minutes === n && s.sliderOptActive]}
                onPress={() => setMinutes(n)}
              >
                <Text style={[s.sliderOptText, minutes === n && s.sliderOptTextActive]}>{n}</Text>
              </TouchableOpacity>
            ))}
          </View>

          <TouchableOpacity style={s.startBtn} onPress={handleStart}>
            <Text style={s.startText}>Inizia</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    );
  }

  if (phase === 'writing') {
    const pct = 1 - timeLeft / (minutes * 60);
    return (
      <View style={s.container}>
        <View style={s.writeHeader}>
          <TouchableOpacity onPress={handleInterrupt}>
            <Text style={s.interruptText}>Interrompi</Text>
          </TouchableOpacity>
          <View style={s.timerRow}>
            <View style={[s.timerDot, { backgroundColor: timeLeft < 60 ? C.danger : C.primary }]} />
            <Text style={[s.timerLabel, { color: timeLeft < 60 ? C.danger : C.text }]}>{formatTime(timeLeft)}</Text>
          </View>
          {/* ← Home — discoverable exit while the writing timer is
              running. Tapping here without warning would SILENTLY
              discard the user's draft (the writing session is
              component-local state, not persisted). Same Alert shape
              as handleInterrupt so the user keeps the choice between
              continuing, analyzing, or bailing. */}
          <TouchableOpacity onPress={handleExitFromWriting} style={[s.backBtn, s.headerBackBtn]} accessibilityLabel="Esci dal flusso di scrittura">
            <BackIcon /><Text style={s.backText}> Home</Text>
          </TouchableOpacity>
        </View>
        <View style={s.progressTrack}>
          <View style={[s.progressFill, { width: `${pct * 100}%` }]} />
        </View>

        <TextInput
          style={s.textArea}
          multiline
          autoFocus
          value={text}
          onChangeText={setText}
          placeholder="Scrivi tutto ciò che ti passa per la mente..."
          placeholderTextColor={C.textMuted}
          scrollEnabled
          textAlignVertical="top"
        />

        <BreathingWave active />
      </View>
    );
  }

  // Authentic copy: the analyze phase is shaped like the writing header so
  // the "← Home" chip is always discoverable. Until the 800ms timeout
  // delivers control to the map view, this is the lifetime of the screen.
  if (phase === 'processing') {
    return (
      <View style={s.container}>
        <View style={s.writeHeader}>
          <View style={{ width: 80 }} />
          <View style={s.timerRow}>
            <Text style={[s.timerLabel, { color: C.textMuted }]}>Analisi</Text>
          </View>
          {/* ← Home — same shape as the writing-phase exit. If the
              analysis ever stalls (real-world bug), the user has a
              recovery path that doesn't require waiting. */}
          <TouchableOpacity onPress={handleExitFromWriting} style={[s.backBtn, s.headerBackBtn]} accessibilityLabel="Esci dal flusso di scrittura">
            <BackIcon /><Text style={s.backText}> Home</Text>
          </TouchableOpacity>
        </View>
        <View style={s.processingWrap}>
          <Text style={s.processingText}>Sto leggendo il tuo paesaggio interiore...</Text>
        </View>
      </View>
    );
  }

  // Use the shared emotionColors palette from src/constants/theme.js so the
  // FreeWrite emotion bars stay in sync with the rest of the design system.
  const colors = emotionColors;

  return (
    <View style={s.container}>
      <ScrollView contentContainerStyle={s.scroll}>
        {/* ← Home — discoverable exit at the very top of the mind-map
            view. The "Cancella questa mappa" action at the bottom still
            calls onBack for confirmation, but a top-of-page chip is the
            familiar pattern (matches ChatScreen/ProfileScreen/
            CommunityScreen/PsychologistsScreen) so the user doesn't
            have to scroll to find a way out. */}
        <TouchableOpacity onPress={onBack} style={s.mapBackRow} accessibilityLabel="Torna alla home">
          <Text style={s.mapBackText}>← Home</Text>
        </TouchableOpacity>
        {selectedNode ? (
          <View>
            <TouchableOpacity style={s.backToMapBtn} onPress={() => setSelectedNode(null)}>
              <Text style={s.backToMapText}>← Torna alla mappa</Text>
            </TouchableOpacity>
            <Text style={s.nodeDetailTitle}>{selectedNode}</Text>
            <View style={s.nodeDetailCard}>
              {mapData.topics.find(t => t.name === selectedNode)?.sentences.map((sent, i) => (
                <Text key={i} style={s.nodeSentence}>"{sent}"</Text>
              ))}
              {(!mapData.topics.find(t => t.name === selectedNode)?.sentences.length) && (
                <Text style={s.nodeEmpty}>Seleziona un nodo per vedere le frasi correlate</Text>
              )}
            </View>
          </View>
        ) : (
          <View>
            <View style={s.mapHeader}>
              <Text style={s.mapTitle}>La tua mappa mentale</Text>
              <Text style={s.mapSub}>Tocca un nodo per approfondire</Text>
            </View>

            <View style={s.disclaimerBox}>
              <Text style={s.disclaimerText}>
                Questa è una rappresentazione visiva delle parole che hai scritto, non una diagnosi.
                È uno strumento per aiutarti a riflettere, non per definire chi sei.
              </Text>
            </View>

            {/* === Insight summary card ===
                Replaces the previous math-based circle graph. Pulls the top
                topic + top emotion into a single, scannable card so the
                user gets the headline immediately, then can drill into the
                chips below. Cleaner cross-screen geometry than absolute
                trigonometry and easier to localize. */}
            <View style={s.insightCard}>
              <Text style={s.insightKicker}>SINTESI</Text>
              <View style={s.insightRow}>
                <View style={s.insightCol}>
                  <Text style={s.insightLabel}>Tema principale</Text>
                  <Text style={s.insightValue} numberOfLines={1}>
                    {mapData.topics[0]?.name || '—'}
                  </Text>
                </View>
                {mapData.emotions[0] ? (
                  <View style={[s.insightCol, { alignItems: 'flex-end' }]}>
                    <Text style={s.insightLabel}>Emozione</Text>
                    <View style={s.insightEmoInline}>
                      <MoodIcon
                        name={mapData.emotions[0].iconName}
                        color={colors[mapData.emotions[0].name] || C.sage}
                        size={20}
                      />
                      <Text style={s.insightValue} numberOfLines={1}>
                        {Math.round(mapData.emotions[0].pct * 100)}%
                      </Text>
                    </View>
                  </View>
                ) : null}
              </View>
            </View>

            {/* === Topic cloud ===
                Flex-wrap of the top topics. Tappable chips drop the user
                into the node-detail view (the same one the old graph
                drilled into). No trigonometry — chips reflow on rotation
                / iPad split for free. */}
            <Text style={s.sectionTitle}>Temi che emergono</Text>
            <View style={s.tagCloud}>
              {mapData.topics.map((topic, i) => {
                const color = nodeColors[i % nodeColors.length];
                return (
                  <PressableScale
                    key={topic.name}
                    onPress={() => setSelectedNode(topic.name)}
                    style={[s.tagPill, { borderColor: color, backgroundColor: color + '22' }]}
                    accessibilityRole="button"
                    accessibilityLabel={`Apri il tema ${topic.name}, peso ${topic.score}`}
                  >
                    <View style={[s.tagDot, { backgroundColor: color }]} />
                    <Text style={s.tagLabel}>{topic.name}</Text>
                    <Text style={[s.tagCount, { color }]}>{topic.score}</Text>
                  </PressableScale>
                );
              })}
              {mapData.topics.length === 0 && (
                <Text style={s.noEmo}>Nessun tema specifico rilevato</Text>
              )}
            </View>

            <View style={s.emotionSection}>
              <Text style={s.sectionTitle}>Emozioni rilevate</Text>
              <View style={s.barContainer}>
                {mapData.emotions.map(emo => (
                  <View key={emo.name} style={s.barRow}>
                    <View style={s.barEmoji}><MoodIcon name={emo.iconName} color={colors[emo.name] || C.sage} size={20} /></View>
                    <View style={s.barTrack}>
                      <View style={[s.barFill, { width: `${Math.max(emo.pct * 100, 5)}%`, backgroundColor: colors[emo.name] || C.sage }]} />
                    </View>
                    <Text style={s.barPct}>{Math.round(emo.pct * 100)}%</Text>
                  </View>
                ))}
                {mapData.emotions.length === 0 && (
                  <Text style={s.noEmo}>Nessuna emozione specifica rilevata</Text>
                )}
              </View>
            </View>

            <View style={s.actionRow}>
              <TouchableOpacity style={s.clearBtn} onPress={onBack}>
                <Text style={s.clearText}>Cancella questa mappa</Text>
              </TouchableOpacity>
              <TouchableOpacity style={s.deepBtn} onPress={() => onDeepDive(mapData)}>
                <Text style={s.deepText}>Approfondisci con me</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}
      </ScrollView>
    </View>
  );
}

const s = StyleSheet.create({
  // Tablet guard — same 600pt cap as the App.js pages so the FreeWrite
  // screen reads as a centered column on iPad rather than a full-width
  // text area. (Not strictly needed because the mind-map uses SCREEN_W
  // directly, but keeping visual rhythm consistent with the other tabs.)
  container: { flex: 1, backgroundColor: C.bg, maxWidth: 600, width: '100%', alignSelf: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingBottom: 6 },
  backBtn: { flexDirection: 'row', alignItems: 'center', padding: 4 },
  backText: { color: C.terracotta, fontSize: 15, fontWeight: '600', marginLeft: 4 },
  scroll: { padding: 16, paddingBottom: 28 },
  setupCard: { backgroundColor: C.card, borderRadius: 28, padding: 28, marginBottom: 24, alignItems: 'center' },
  setupTitle: { color: C.text, fontSize: 22, fontWeight: '700', marginBottom: 12, textAlign: 'center' },
  setupDesc: { color: C.textSec, fontSize: 14, lineHeight: 24, textAlign: 'center' },
  sliderLabel: { color: C.text, fontSize: 15, fontWeight: '600', marginBottom: 14, textAlign: 'center' },
  sliderRow: { flexDirection: 'row', justifyContent: 'center', gap: 12, marginBottom: 32 },
  // minWidth/minHeight + aspectRatio: 1 so the slider dots (3 / 4 / 5 / 6 / 7)
  // grow with Dynamic Type rather than clipping the inner number at >1.0×
  // system font scale. Base 54pt preserved for the default font scale.
  sliderOpt: { minWidth: 54, minHeight: 54, borderRadius: 27, aspectRatio: 1, backgroundColor: C.card, justifyContent: 'center', alignItems: 'center' },
  sliderOptActive: { backgroundColor: C.primaryLight },
  sliderOptText: { color: C.textSec, fontSize: 18, fontWeight: '600' },
  sliderOptTextActive: { color: C.primary, fontWeight: '700' },
  disclaimerBox: { backgroundColor: 'rgba(179, 65, 74, 0.1)', borderRadius: 16, padding: 16, marginHorizontal: 16, marginBottom: 16, borderWidth: 1, borderColor: 'rgba(179, 65, 74, 0.2)' },
  disclaimerText: { color: C.textSec, fontSize: 12, lineHeight: 18, textAlign: 'center', fontStyle: 'italic' },
  startBtn: { backgroundColor: C.primary, borderRadius: 24, paddingVertical: 18, alignItems: 'center', marginBottom: 20 },
  startText: { color: '#fff', fontSize: 17, fontWeight: '700' },
  writeHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 20, paddingBottom: 4 },
  // Right-aligned in the writeHeader's flex row, mirrors the
  // justifyContent:'space-between' left slot (Interrompi) so the timer
  // stays visually centered. minWidth:80 keeps "← Home" from wrapping.
  headerBackBtn: { flexDirection: 'row', alignItems: 'center', minWidth: 80, justifyContent: 'flex-end' },
  interruptText: { color: C.terracotta, fontSize: 14, fontWeight: '600' },
  timerRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: C.card, paddingVertical: 6, paddingHorizontal: 14, borderRadius: 20 },
  timerDot: { width: 8, height: 8, borderRadius: 4, marginRight: 8 },
  timerLabel: { fontSize: 16, fontWeight: '700', fontVariant: ['tabular-nums'] },
  progressTrack: { height: 2, backgroundColor: 'rgba(255,255,255,0.06)', marginHorizontal: 20, marginBottom: 14, borderRadius: 1 },
  progressFill: { height: '100%', backgroundColor: C.primary, borderRadius: 1 },
  textArea: { flex: 1, color: C.text, fontSize: 16, lineHeight: 28, paddingHorizontal: 24, paddingVertical: 18, marginHorizontal: 16, backgroundColor: C.card, borderRadius: 24, minHeight: 300 },
  processingWrap: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 40 },
  processingText: { color: C.textSec, fontSize: 16, textAlign: 'center', lineHeight: 24 },
  mapHeader: { alignItems: 'center', paddingVertical: 24 },
  // Top-of-scroll back chip in the map phase. Right-aligned so the
  // user reads it as a navigation seam, not as a section heading.
  // Margins respect the existing paddingHorizontal: 20 ancestor so the
  // chip aligns with the rest of the content.
  mapBackRow:  { alignSelf: 'flex-end', paddingVertical: 8, paddingHorizontal: 4, marginTop: 4 },
  mapBackText: { color: C.terracotta, fontSize: 14, fontWeight: '700', letterSpacing: 0.2 },
  mapTitle: { color: C.text, fontSize: 24, fontWeight: '700' },
  mapSub: { color: C.textMuted, fontSize: 13, marginTop: 4 },

  // === Insight summary card ===
  // Replaces the old math-graph header. Reads as a single, scannable
  // card so the user gets the headline (top topic + top emotion %)
  // immediately, then can drill into the topic cloud below.
  insightCard: {
    backgroundColor: C.card, borderRadius: 24, padding: 22,
    marginBottom: 20, borderWidth: 1, borderColor: C.border,
  },
  insightKicker: { color: C.primary, fontSize: 10, fontWeight: '900', letterSpacing: 2, marginBottom: 12, textTransform: 'uppercase' },
  insightRow:    { flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-between' },
  insightCol:    { flex: 1 },
  insightLabel:  { color: C.textMuted, fontSize: 11, fontWeight: '700', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 4 },
  insightValue:  { color: C.text, fontSize: 22, fontWeight: '900', letterSpacing: -0.5 },
  insightEmoInline: { flexDirection: 'row', alignItems: 'center', gap: 8 },

  // === Topic cloud ===
  // Flex-wrap of the top topics as tappable chips. Each chip is a small
  // pill with a colored dot + topic name + score. Reflows on rotation
  // / iPad split for free.
  sectionTitle: { color: C.text, fontSize: 16, fontWeight: '700', marginBottom: 12, marginTop: 4 },
  tagCloud:     { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 8 },
  tagPill: {
    flexDirection: 'row', alignItems: 'center',
    paddingVertical: 8, paddingHorizontal: 12, borderRadius: 999,
    borderWidth: 1, gap: 6,
  },
  tagDot:   { width: 8, height: 8, borderRadius: 4 },
  tagLabel: { color: C.text, fontSize: 13, fontWeight: '700' },
  tagCount: { fontSize: 11, fontWeight: '900', marginLeft: 2 },
  emotionSection: { backgroundColor: C.card, borderRadius: 24, padding: 22, marginTop: 16 },
  sectionTitle: { color: C.text, fontSize: 16, fontWeight: '600', marginBottom: 16 },
  barContainer: { gap: 12 },
  barRow: { flexDirection: 'row', alignItems: 'center' },
  barTrack: { flex: 1, height: 10, backgroundColor: 'rgba(255,255,255,0.06)', borderRadius: 5, overflow: 'hidden', marginHorizontal: 10 },
  barFill: { height: '100%', borderRadius: 5 },
  barPct: { color: C.textSec, fontSize: 12, width: 36, textAlign: 'right' },
  noEmo: { color: C.textMuted, fontSize: 13, textAlign: 'center' },
  actionRow: { flexDirection: 'row', gap: 12, marginTop: 24, marginBottom: 30 },
  clearBtn: { flex: 1, backgroundColor: C.card, borderRadius: 18, paddingVertical: 16, alignItems: 'center' },
  clearText: { color: C.textMuted, fontSize: 13, fontWeight: '600' },
  deepBtn: { flex: 1, backgroundColor: C.primary, borderRadius: 18, paddingVertical: 16, alignItems: 'center' },
  deepText: { color: '#fff', fontSize: 13, fontWeight: '700' },
  backToMapBtn: { paddingVertical: 12 },
  backToMapText: { color: C.terracotta, fontSize: 15, fontWeight: '600' },
  nodeDetailTitle: { color: C.text, fontSize: 22, fontWeight: '700', marginBottom: 12 },
  nodeDetailCard: { backgroundColor: C.card, borderRadius: 24, padding: 22 },
  nodeSentence: { color: C.textSec, fontSize: 14, lineHeight: 22, marginBottom: 12, fontStyle: 'italic' },
  nodeEmpty: { color: C.textMuted, fontSize: 13, textAlign: 'center' },
});
