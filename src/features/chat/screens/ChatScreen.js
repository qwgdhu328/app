// ChatScreen — message list, day-separator pills, like buttons, animated
// typing dots, consent / offline / blocked / thinking bars, input pill.
//
// Extracted from the monolithic App.js as part of Phase 0.C.
//
// === State ownership ===
// State-derived data (messages, input, thinking, chatBlocked, consentGiven,
// currentLevel, isOffline, likedMessages, toggleLike) reads directly from
// `useChatStore` selectors — zero prop drilling. The four cross-cutting
// callbacks (onSend, onReset, onAcceptConsent, onQuickPick) remain as props
// because they're decisions that App.js owns (the chat lifecycle's 165-line
// `sendMessage` is still in App.js for Phase 0.C; Phase 0.E extracts it into
// a `useChatLogic` hook).
//
// === Day-bucket separators ===
// Reads dayBucket / dayLabel / isLastAssistant from src/utils/date.js —
// they were inlined at the bottom of App.js post-Phase-0.A and are now
// shared with any future feature that surfaces date-grouped content.

import React, { useState, useRef, useEffect } from 'react';
import { StyleSheet, Text, View, FlatList, TextInput, Animated, ActivityIndicator } from 'react-native';
import { C, R, S, T, sh, levelColors } from '../../../constants/theme';
import { useChatStore } from '../../../store/chatStore';
import { dayBucket, dayLabel, isLastAssistant } from '../../../utils/date';
import ChatBubble from '../../../components/ChatBubble';
import AnimatedDots from '../../../components/AnimatedDots';
import PressableScale from '../../../components/PressableScale';
import LikeButton from '../../../components/LikeButton';
import QuickReplies from '../../../components/QuickReplies';
import { renderRich } from '../../../components/RichText';
import { SendIcon, LockIcon } from '../../../../icons';

// Sentences that a quick-reply chip injects into the chat input.
// Keys match the keys used by <QuickReplies> defaults. Local — only the
// chat composition surface uses these, so it stays close to ChatScreen.
const QUICK_REPLY_TEXT = {
  continue:  'Vai avanti, ti ascolto',
  deep:      'Approfondiamo questo punto',
  technique: 'Vorrei provare un esercizio',
  pause:     'Mi prendi una pausa con me?',
};

export default function ChatScreen({ onSend, onReset, onAcceptConsent, onQuickPick, onNavigate }) {
  // ── Store reads (granular selectors) ─────────────────────────────────
  const messages       = useChatStore((s) => s.messages);
  const input          = useChatStore((s) => s.input);
  const thinking       = useChatStore((s) => s.thinking);
  const chatBlocked    = useChatStore((s) => s.chatBlocked);
  const consentGiven   = useChatStore((s) => s.consentGiven);
  const currentLevel   = useChatStore((s) => s.currentLevel);
  const isOffline      = useChatStore((s) => s.isOffline);
  const likedMessages  = useChatStore((s) => s.likedMessages);
  // setInput + toggleLike toggled via store.setState on each keystroke /
  // like tap. We grab the stable setters once via getState() so the
  // destructured names stay familiar to the rest of this file.
  const { setInput, toggleLike } = useChatStore.getState();

  const levelLabelColors = { VERDE: C.sage, GIALLO: C.amber, ARANCIONE: C.terracotta, ROSSO: C.danger };
  const levelLabels = { VERDE: '', GIALLO: 'Attento', ARANCIONE: 'Supporto', ROSSO: 'Emergenza' };

  // === Input focus animation ===
  // 0 = idle, 1 = focused. Animates the input pill's border + shadow so
  // the chat composer has a live, breathing focus state (iMessage / Linear
  // style). useNativeDriver: false because borderColor + shadowRadius
  // interpolation requires the layout-only driver.
  const [isInputFocused, setIsInputFocused] = useState(false);
  const focusAnim = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.timing(focusAnim, {
      toValue: isInputFocused ? 1 : 0,
      duration: 200,
      useNativeDriver: false,
    }).start();
  }, [isInputFocused]);
  const inputBorderColor   = focusAnim.interpolate({ inputRange: [0, 1], outputRange: [C.border,    C.primary] });
  const inputShadowRadius  = focusAnim.interpolate({ inputRange: [0, 1], outputRange: [4,   14] });
  const inputShadowOpacity = focusAnim.interpolate({ inputRange: [0, 1], outputRange: [0,    0.35] });

  return (
    <View style={c.container}>
      <View style={c.header}>
        <View style={c.headerLeft}>
          {/* "← Home" back chip — replaces the bottom TabBar (Phase 1.x).
              Lets the user escape Chat back to Home, where the other
              entry points (Profile / Spazio / Info / Sfogo libero) live.
              Always visible, regardless of message count or consent. */}
          {onNavigate && (
            <PressableScale
              onPress={() => onNavigate('home')}
              style={c.resetBtn}
              accessibilityRole="button"
              accessibilityLabel="Torna alla home"
            >
              <Text style={c.resetText}>← Home</Text>
            </PressableScale>
          )}
          <View style={c.brandDot} />
          <View>
            <Text style={c.brandTitle}>BenessereBot</Text>
            <Text style={c.brandSub}>{isOffline ? 'offline' : 'qui con te'}</Text>
          </View>
        </View>
        <View style={c.headerRight}>
          {consentGiven && currentLevel !== 'VERDE' && (
            <View style={[c.levelPill, { backgroundColor: levelLabelColors[currentLevel] + '33', borderColor: levelLabelColors[currentLevel] }]}>
              <Text style={[c.levelText, { color: levelLabelColors[currentLevel] }]}>{levelLabels[currentLevel]}</Text>
            </View>
          )}
          {messages.length > 0 && (
            <PressableScale onPress={onReset} style={c.resetBtn} accessibilityLabel="Nuova chat">
              <Text style={c.resetText}>Reset</Text>
            </PressableScale>
          )}
        </View>
      </View>

      <FlatList
        data={messages}
        keyExtractor={(item, index) => String(item.id ?? `tmp-${index}`)}
        contentContainerStyle={c.list}
        renderItem={({ item, index }) => {
          const lastBotId = isLastAssistant(messages, item);
          const showQuick = lastBotId && !thinking && !chatBlocked && (item.text || '').length > 0;
          const prev = index > 0 ? messages[index - 1] : null;
          const curBucket  = dayBucket(item.id);
          const prevBucket = prev ? dayBucket(prev.id) : null;
          const showDayPill = !prev || (curBucket && curBucket !== prevBucket);
          return (
            <View>
              {showDayPill && (
                <View
                  style={c.datePill}
                  accessible
                  accessibilityRole="header"
                  accessibilityLabel={`Sezione del ${dayLabel(curBucket)}`}
                >
                  <View style={c.datePillRule} />
                  <Text style={c.datePillText}>{dayLabel(curBucket)}</Text>
                  <View style={c.datePillRule} />
                </View>
              )}
              <ChatBubble>
                <View style={[
                  c.bubble,
                  item.role === 'user' ? c.bubbleUser : c.bubbleBot,
                  item.level === 'ROSSO' && c.bubbleRed,
                ]}>
                  <Text style={c.bubbleText}>
                    {renderRich(item.text || '', c.bubbleText, c.bubbleBold)}
                  </Text>
                </View>

                {item.role === 'assistant' && !chatBlocked && (
                  <View style={c.bubbleActions}>
                    <LikeButton liked={likedMessages.has(item.id)} onToggle={() => toggleLike(item.id)} />
                  </View>
                )}

                {item.showEmergency && (
                  <View style={c.emergencyBox}>
                    <Text style={c.emergencyTitle}>🚨 Chiama adesso</Text>
                    <Text style={c.emergencyPhone}>112</Text>
                    <Text style={c.emergencySub}>Telefono Amico: 199 284 284</Text>
                  </View>
                )}
              </ChatBubble>

              {showQuick && (
                <QuickReplies
                  onPick={(opt) => onQuickPick(opt.key)}
                  options={
                    currentLevel === 'ARANCIONE'
                      ? [
                          { key: 'pause',    label: 'Fammi una pausa', tint: 'violet' },
                          { key: 'continue', label: 'Ci sono, vai',    tint: 'lime' },
                        ]
                      : item.technique
                        ? [
                            { key: 'continue', label: 'Vai avanti', tint: 'lime' },
                            { key: 'deep',     label: 'Approfondisci', tint: 'violet' },
                            { key: 'pause',    label: 'Fammi una pausa', tint: 'lime' },
                          ]
                        : [
                            { key: 'continue',  label: 'Vai avanti',     tint: 'lime' },
                            { key: 'deep',      label: 'Approfondisci',  tint: 'violet' },
                            { key: 'technique', label: 'Una tecnica',    tint: 'violet' },
                            { key: 'pause',     label: 'Fammi una pausa',tint: 'lime' },
                          ]
                  }
                />
              )}
            </View>
          );
        }}
        ListEmptyComponent={
          consentGiven ? (
            <View style={c.emptyChat}>
              <Text style={c.emptyTitle}>Come stai, qui e ora?</Text>
              <Text style={c.emptySub}>Scrivi la prima cosa che ti viene in mente. Senza ordine, senza fretta.</Text>
            </View>
          ) : (
            <View style={c.emptyChat}>
              <LockIcon />
              <View style={{ height: 16 }} />
              <Text style={c.emptyTitle}>Sei al sicuro qui.</Text>
              <Text style={c.emptySub}>
                Le tue parole restano tra noi.{'\n'}Quando chiudi, spariscono.{'\n\n'}Se invece hai bisogno di qualcuno ora: 112.
              </Text>
              <PressableScale
                onPress={onAcceptConsent}
                style={c.consentBtn}
                accessibilityLabel="Accetta consenso e inizia"
              >
                <Text style={c.consentBtnText}>Sì, ci sono</Text>
              </PressableScale>
            </View>
          )
        }
      />

      {isOffline && (
        <View style={c.offlineBar}>
          <Text style={c.offlineText}>Nessuna connessione</Text>
        </View>
      )}

      {!isOffline && thinking && (
        <View style={c.thinkingBar}>
          <AnimatedDots color={C.primary} size={9} gap={7} />
          <Text style={c.thinkingText}>Sto ascoltando</Text>
        </View>
      )}

      {chatBlocked && (
        <View style={c.blockedBar}>
          <Text style={c.blockedTitle}>Questa conversazione si è chiusa per la tua sicurezza.</Text>
          <PressableScale onPress={onReset} style={c.newChatBtn} accessibilityLabel="Nuova conversazione">
            <Text style={c.newChatText}>Nuova conversazione</Text>
          </PressableScale>
        </View>
      )}

      {!chatBlocked && (
        <View style={c.inputRow}>
          <Animated.View
            style={[
              c.inputPill,
              {
                borderColor:    inputBorderColor,
                shadowRadius:   inputShadowRadius,
                shadowOpacity:  inputShadowOpacity,
              },
            ]}
          >
            <TextInput
              style={c.input}
              placeholder={consentGiven ? 'Scrivi qui, anche un pezzettino...' : 'Scrivi S\u00ec per iniziare...'}
              placeholderTextColor={C.textMuted}
              value={input}
              onChangeText={setInput}
              onFocus={() => setIsInputFocused(true)}
              onBlur={() => setIsInputFocused(false)}
              onSubmitEditing={onSend}
              editable={!thinking}
              multiline={false}
              returnKeyType="send"
            />
          </Animated.View>
          <PressableScale
            onPress={onSend}
            style={[c.sendBtn, thinking && c.sendBtnThinking]}
            disabled={thinking}
            accessibilityLabel={thinking ? 'Sto ascoltando, attendi un attimo' : 'Invia messaggio'}
          >
            {thinking
              ? <ActivityIndicator size="small" color={C.primaryInk} />
              : <SendIcon size={20} color={C.primaryInk} />}
          </PressableScale>
        </View>
      )}
    </View>
  );
}

const c = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg, maxWidth: 600, width: '100%', alignSelf: 'center' },
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: S.lg, paddingTop: S.lg, paddingBottom: S.md,
  },
  headerLeft:  { flexDirection: 'row', alignItems: 'center', gap: S.md },
  headerRight: { flexDirection: 'row', alignItems: 'center', gap: S.sm },
  brandDot:    { width: 10, height: 10, borderRadius: 5, backgroundColor: C.primary },
  brandTitle:  { color: C.text, fontSize: 17, fontWeight: '900', letterSpacing: -0.3 },
  brandSub:    { color: C.textMuted, fontSize: 11, fontWeight: '600', letterSpacing: 0.5, textTransform: 'uppercase' },
  levelPill:   { paddingVertical: 4, paddingHorizontal: 12, borderRadius: R.pill, borderWidth: 1 },
  levelText:   { fontSize: 10, fontWeight: '900', letterSpacing: 0.8, textTransform: 'uppercase' },
  resetBtn:    { paddingVertical: 6, paddingHorizontal: 12, borderRadius: R.pill, backgroundColor: C.card },
  resetText:   { color: C.accent, fontSize: 12, fontWeight: '800' },

  list: { paddingHorizontal: S.xl, paddingBottom: S.lg, flexGrow: 1 },
  bubble: {
    maxWidth: 460,
    paddingVertical: 14, paddingHorizontal: 18,
    marginBottom: 6, borderRadius: R.lg,
  },
  bubbleUser: {
    backgroundColor: C.primary,
    alignSelf: 'flex-end',
    borderTopRightRadius: 6,
    ...sh.chip,
  },
  bubbleBot: {
    backgroundColor: C.surface,
    alignSelf: 'flex-start',
    borderTopLeftRadius: R.sm,
    borderWidth: 0,
  },
  bubbleRed: {
    borderWidth: 0,
    backgroundColor: C.dangerLight,
  },
  bubbleText:   { ...T.body, color: C.text },
  bubbleBold:   { fontWeight: '800' },
  bubbleActions:{ flexDirection: 'row', justifyContent: 'flex-end', paddingRight: S.sm, marginTop: -2, marginBottom: 8 },

  datePill: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    marginVertical: S.md,
    marginHorizontal: S.xl,
    gap: S.sm,
  },
  datePillRule: { flex: 1, height: 1, backgroundColor: C.border, opacity: 0.6 },
  datePillText: { ...T.micro, color: C.textMuted, fontWeight: '800' },

  emergencyBox: {
    backgroundColor: C.dangerLight, borderRadius: R.lg, padding: S.lg,
    marginTop: -2, marginBottom: S.lg,
    borderWidth: 1.5, borderColor: C.danger,
  },
  emergencyTitle: { color: C.danger, fontSize: 14, fontWeight: '900', marginBottom: S.sm },
  emergencyPhone: { color: C.text,    fontSize: 30, fontWeight: '900', letterSpacing: 1 },
  emergencySub:   { color: C.textSec, fontSize: 13, marginTop: 4 },

  emptyChat: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: S.xl, paddingTop: S.xl },
  emptyTitle: { color: C.text,    fontSize: 22, fontWeight: '900', textAlign: 'center', letterSpacing: -0.5 },
  emptySub:   { color: C.textSec, fontSize: 14, textAlign: 'center', marginTop: S.md, lineHeight: 22 },
  consentBtn:    { backgroundColor: C.primary, paddingVertical: 16, paddingHorizontal: 36, borderRadius: R.pill, marginTop: S.xl, ...sh.glow },
  consentBtnText:{ color: C.primaryInk, fontSize: 15, fontWeight: '900', letterSpacing: 0.5 },

  offlineBar: { backgroundColor: C.danger, paddingVertical: 8, alignItems: 'center' },
  offlineText: { color: '#fff', fontSize: 11, fontWeight: '800', letterSpacing: 0.5, textTransform: 'uppercase' },

  thinkingBar: {
    flexDirection: 'row', alignItems: 'center', gap: S.md,
    paddingVertical: 14, paddingHorizontal: S.xl,
    backgroundColor: C.card,
  },
  thinkingText: { color: C.primary, fontSize: 12, fontWeight: '800', letterSpacing: 0.5, textTransform: 'uppercase' },

  blockedBar: {
    paddingHorizontal: S.xl, paddingVertical: S.lg,
    backgroundColor: C.dangerLight, borderTopWidth: 1, borderTopColor: C.danger,
    alignItems: 'center',
  },
  blockedTitle:{ color: C.danger, fontSize: 13, fontWeight: '800', textAlign: 'center', marginBottom: S.md },
  newChatBtn:  { backgroundColor: C.danger, paddingVertical: 12, paddingHorizontal: 28, borderRadius: R.pill },
  newChatText: { color: '#fff', fontWeight: '900', fontSize: 13, letterSpacing: 0.5 },

  inputRow: {
    flexDirection: 'row', alignItems: 'flex-end', gap: S.sm,
    paddingHorizontal: S.lg, paddingTop: S.sm, paddingBottom: S.sm,
  },
  inputPill: {
    flex: 1, backgroundColor: C.surface2, borderRadius: R.pill,
    borderWidth: 0,
    paddingHorizontal: S.xl, paddingVertical: S.md,
  },
  input:  { color: C.text, fontSize: 15, maxHeight: 120 },
  sendBtn:{ backgroundColor: C.primary, paddingHorizontal: 18, paddingVertical: 14, borderRadius: R.pill, ...sh.glow, justifyContent: 'center', alignItems: 'center', minWidth: 52 },
  sendBtnThinking: { backgroundColor: C.cardAlt, borderWidth: 1, borderColor: C.primary, opacity: 1 },
  sendText:{ color: C.primaryInk, fontWeight: '900', fontSize: 14, letterSpacing: 0.5 },
});
