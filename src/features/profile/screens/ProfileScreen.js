// ProfileScreen — favorites + mood streak + sparkline + privacy + emergency.
//
// Extracted from the monolithic App.js as part of Phase 0.C.
//
// === State ownership (mixed across 3 stores) ===
// - userName / setUserName / totalSessions / totalTurns ← useUserStore
// - moodHistory ← useMoodStore (drives streak + today-chip)
// - turnCount / levelHistory / likedMessages / messages / toggleLike ← useChatStore
// - streak ← derived from moodHistory via calcStreak selector
// The two remaining props (`onStartChat`, `onJumpToChat`) are pure navigation
// hops — they switch `activeTab` to 'chat' on the parent. PR_SPARK_HEIGHTS
// + getGreeting stay local to this file. `accentFor` was extracted to
// src/utils/identity.js in Phase 1 so other features can share it.

import React, { useState } from 'react';
import { StyleSheet, Text, View, ScrollView, TextInput } from 'react-native';
import { C, R, S, T, sh, levelColors } from '../../../constants/theme';
import { useUserStore } from '../../../store/userStore';
import { useMoodStore } from '../../../store/moodStore';
import { useChatStore } from '../../../store/chatStore';
import { todayKey, calcStreak } from '../../../utils/date';
import { accentFor } from '../../../utils/identity';
import { MOODS } from '../../../constants/moods';
import MoodIcon from '../../../components/MoodIcon';
import PressableScale from '../../../components/PressableScale';
import LikeButton from '../../../components/LikeButton';
import { renderRich } from '../../../components/RichText';
import { StreakIcon, HeartIcon } from '../../../../icons';
import { getGreeting } from '../../../../src/utils/text';

// Sparkline bar heights per chat level. The 4-step scale intentionally
// gives VERDE bars a quiet short height (positive days don't shout) and
// ARANCIONE / ROSSO a tall height (data is legible at a glance when
// something needs attention). All values are even numbers so the bar tops
// align to the 8pt sub-grid of the surrounding card.
const PR_SPARK_HEIGHTS = { VERDE: 14, GIALLO: 28, ARANCIONE: 46, ROSSO: 60 };

export default function ProfileScreen({ onStartChat, onJumpToChat, onNavigate }) {
  // ── Store reads (granular selectors) ─────────────────────────────────
  const { userName, setUserName, totalSessions, totalTurns } = useUserStore();
  const { turnCount, levelHistory, likedMessages, messages, toggleLike } = useChatStore();
  const { moodHistory } = useMoodStore();
  const streak = useMoodStore((s) => calcStreak(s.moodHistory));

  const [editingName, setEditingName] = useState(false);
  const [nameInput, setNameInput] = useState(userName);

  const saveName = () => { setUserName(nameInput.trim() || ''); setEditingName(false); };

  const totalMessages = totalTurns + turnCount;
  const levelCounts = {};
  levelHistory.forEach((h) => { levelCounts[h.level] = (levelCounts[h.level] || 0) + 1; });
  const topLevelEntry = Object.entries(levelCounts).sort((a, b) => b[1] - a[1])[0];
  const topLevelLabel = topLevelEntry ? topLevelEntry[0].charAt(0) + topLevelEntry[0].slice(1).toLowerCase() : '—';

  // Order liked messages by source-array order so the user sees them as they appeared.
  const liked = messages.filter((m) => m.role === 'assistant' && likedMessages.has(m.id));

  return (
    <ScrollView style={pr.container} contentContainerStyle={pr.scroll} showsVerticalScrollIndicator={false}>
      <View style={pr.header}>
        {/* "← Home" back chip — replaces the bottom TabBar (Phase 1.x). */}
        {onNavigate && (
          <PressableScale
            onPress={() => onNavigate('home')}
            style={pr.backChip}
            accessibilityRole="button"
            accessibilityLabel="Torna alla home"
          >
            <Text style={pr.backChipText}>← Home</Text>
          </PressableScale>
        )}
        <View style={pr.avatarGlow} />
        <View style={pr.avatarRing}>
          <Text style={pr.avatarText}>{(userName || '?').trim()[0].toUpperCase()}</Text>
          {userName && userName.trim().length > 1 && (
            <View style={[pr.avatarAccent, { backgroundColor: accentFor(userName) }]} />
          )}
        </View>
        {editingName ? (
          <View style={pr.nameEditRow}>
            <TextInput
              style={pr.nameInput}
              value={nameInput}
              onChangeText={setNameInput}
              placeholder="Il tuo nome"
              placeholderTextColor={C.textMuted}
              onSubmitEditing={saveName}
              autoFocus
            />
            <PressableScale onPress={saveName} style={pr.saveNameBtn}>
              <Text style={pr.saveNameText}>Salva</Text>
            </PressableScale>
          </View>
        ) : (
          <PressableScale
            onPress={() => { setNameInput(userName); setEditingName(true); }}
          >
            <Text style={pr.name}>{userName || 'Il tuo nome'}</Text>
            <Text style={pr.nameHint}>Tocca per modificare</Text>
          </PressableScale>
        )}
        <Text style={pr.greeting}>{getGreeting()}</Text>
      </View>

      <View style={pr.streakCard}>
        <View style={pr.streakLeft}>
          <View style={[pr.streakIconPill, streak > 0 && { backgroundColor: C.primary }]}>
            <StreakIcon color={streak > 0 ? C.primaryInk : C.textMuted} size={20} />
          </View>
          <View>
            <Text style={pr.streakNumber}>{streak}</Text>
            <Text style={pr.streakLabel}>{streak === 1 ? 'giorno di fila' : 'giorni di fila'}</Text>
          </View>
        </View>
        <View style={pr.streakDivider} />
        <View style={pr.streakRight}>
          <Text style={pr.streakTodayKicker}>Mood di oggi</Text>
          {moodHistory.find((h) => h.day === todayKey()) ? (
            <View style={pr.streakToday}>
              <View style={pr.streakTodayEmoji}><MoodIcon name={(MOODS.find((m) => m.key === moodHistory.find((h) => h.day === todayKey())?.key) || MOODS[2]).iconName} color={(MOODS.find((m) => m.key === moodHistory.find((h) => h.day === todayKey())?.key) || MOODS[2]).color} size={28} /></View>
              <Text style={pr.streakTodayLabel}>{(MOODS.find((m) => m.key === moodHistory.find((h) => h.day === todayKey())?.key) || MOODS[2]).label}</Text>
            </View>
          ) : (
            <Text style={pr.streakTodayMissing}>non ancora — e va bene così</Text>
          )}
        </View>
      </View>

      <View style={pr.statsRow}>
        <PressableScale style={[pr.statCard, { borderLeftColor: C.primary }]}>
          <View style={[pr.statIcon, { backgroundColor: C.primaryLight }]}><Text adjustsFontSizeToFit numberOfLines={1} style={[pr.statIconText, { color: C.primary }]}>S</Text></View>
          <View>
            <Text style={pr.statNumber}>{totalSessions}</Text>
            <Text style={pr.statLabel}>Sessioni</Text>
          </View>
        </PressableScale>
        <PressableScale style={[pr.statCard, { borderLeftColor: C.accent }]}>
          <View style={[pr.statIcon, { backgroundColor: C.accentLight }]}><Text adjustsFontSizeToFit numberOfLines={1} style={[pr.statIconText, { color: C.accent }]}>M</Text></View>
          <View>
            <Text style={pr.statNumber}>{totalMessages}</Text>
            <Text style={pr.statLabel}>Messaggi</Text>
          </View>
        </PressableScale>
      </View>

      <PressableScale
        style={[pr.statCard, { borderLeftColor: C.amber, marginHorizontal: 0, marginBottom: S.lg }]}
      >
        <View style={[pr.statIcon, { backgroundColor: C.amberLight }]}><Text adjustsFontSizeToFit numberOfLines={1} style={[pr.statIconText, { color: C.amber }]}>L</Text></View>
        <View>
          <Text style={pr.statNumber}>{topLevelLabel}</Text>
          <Text style={pr.statLabel}>Livello prevalente</Text>
        </View>
      </PressableScale>

      <View style={pr.section}>
        <View style={pr.sectionHeader}>
          <View>
            <Text style={pr.sectionTitle}>I tuoi preferiti</Text>
            <Text style={pr.sectionSub}>{liked.length === 0 ? 'Tocca un cuoricino sotto un messaggio per custodirlo qui.' : `${liked.length} messaggi custoditi`}</Text>
          </View>
          {liked.length > 0 && (
            <PressableScale onPress={onJumpToChat} style={pr.linkBtn}>
              <Text style={pr.linkBtnText}>Vai alla chat →</Text>
            </PressableScale>
          )}
        </View>
        {liked.length === 0 ? (
          <View style={pr.favEmpty}>
            <HeartIcon size={36} color={C.textMuted} />
            <Text style={pr.favEmptyText}>Nessun preferito ancora.</Text>
          </View>
        ) : (
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={pr.favRow}>
            {liked.map((m) => (
              <View key={m.id} style={pr.favCard}>
                <View style={pr.favCardHead}>
                  <LikeButton liked onToggle={() => toggleLike(m.id)} size={16} />
                  <View style={[pr.favBadge, { backgroundColor: (levelColors[m.level] || C.textMuted) + '33' }]}>
                    <Text style={[pr.favBadgeText, { color: levelColors[m.level] || C.textMuted }]}>{(m.level || 'VERDE').toLowerCase()}</Text>
                  </View>
                </View>
                <Text style={pr.favSnippet} numberOfLines={5}>
                  {renderRich(m.text || '', pr.favSnippet, pr.favSnippetBold)}
                </Text>
              </View>
            ))}
          </ScrollView>
        )}
      </View>

      {levelHistory.length > 2 && (
        <View style={pr.section}>
          <Text style={pr.sectionTitle}>Andamento emotivo</Text>
          <View style={pr.sparkCard}>
            <View
              style={pr.sparkRow}
              accessible
              accessibilityRole="image"
              accessibilityLabel={
                `Andamento emotivo degli ultimi ${Math.min(levelHistory.length, 10)} messaggi: ` +
                levelHistory.slice(-10).map((h) => h.level).join(', ')
              }
            >
              {levelHistory.slice(-10).map((h, i) => (
                <View
                  key={i}
                  style={pr.sparkCol}
                  accessibilityElementsHidden
                  importantForAccessibility="no-hide-descendants"
                >
                  <View
                    style={[
                      pr.sparkBar,
                      { height: PR_SPARK_HEIGHTS[h.level] || 14, backgroundColor: levelColors[h.level] || C.textMuted },
                    ]}
                  />
                </View>
              ))}
            </View>
            <View style={pr.sparkBaseline} />
            <View style={pr.sparkLegend}>
              <View style={pr.sparkLegendRow}>
                <View style={[pr.sparkDot, { backgroundColor: C.sage }]} /><Text style={pr.sparkLegendText}>VERDE</Text>
                <View style={[pr.sparkDot, { backgroundColor: C.amber }]} /><Text style={pr.sparkLegendText}>GIALLO</Text>
                <View style={[pr.sparkDot, { backgroundColor: C.terracotta }]} /><Text style={pr.sparkLegendText}>ARANCIONE</Text>
                <View style={[pr.sparkDot, { backgroundColor: C.danger }]} /><Text style={pr.sparkLegendText}>ROSSO</Text>
              </View>
              <Text style={pr.sparkNote}>Ultimi {Math.min(levelHistory.length, 10)} messaggi · altezza = intensità</Text>
            </View>
          </View>
        </View>
      )}

      <PressableScale onPress={onStartChat} style={pr.startChatBtn}>
        <Text style={pr.startChatText}>Torna a parlare</Text>
        <Text style={pr.startChatArrow}>→</Text>
      </PressableScale>

      <View style={pr.privacyCard}>
        <View style={pr.privacyMark} />
        <View style={{ flex: 1 }}>
          <Text style={pr.privacyTitle}>La tua privacy</Text>
          <Text style={pr.privacyText}>Le conversazioni sono anonime e **non vengono memorizzate**. Le statistiche e i preferiti esistono solo sul dispositivo.</Text>
        </View>
      </View>

      <View style={pr.emergencyCard}>
        <Text style={pr.emergencyTitle}>Numeri che contano</Text>
        <Text style={pr.emergencyPhone}>112</Text>
        <Text style={pr.emergencyDesc}>Numero Unico di Emergenza</Text>
        <View style={pr.emergencyDivider} />
        <Text style={pr.emergencyPhoneSm}>199 284 284</Text>
        <Text style={pr.emergencyDesc}>Telefono Amico</Text>
      </View>
    </ScrollView>
  );
}

const pr = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg, maxWidth: 600, width: '100%', alignSelf: 'center' },
  scroll:    { paddingHorizontal: S.lg, paddingBottom: S.xl, paddingTop: S.md },
  backChip:  { alignSelf: 'center', paddingVertical: 6, paddingHorizontal: 12, borderRadius: R.pill, backgroundColor: C.card, marginBottom: S.md, borderWidth: 1, borderColor: C.border },
  backChipText: { color: C.accent, fontSize: 12, fontWeight: '800' },
  header:    { alignItems: 'center', paddingVertical: S.lg },
  avatarGlow:{ position: 'absolute', top: -8, width: 110, height: 110, borderRadius: 55, backgroundColor: C.primaryLight, alignSelf: 'center' },
  avatarRing:{ width: 70, height: 70, borderRadius: 35, backgroundColor: C.primary, justifyContent: 'center', alignItems: 'center', borderWidth: 3, borderColor: C.bg, ...sh.glow },
  avatarText:{ fontSize: 28, fontWeight: '900', color: C.primaryInk, letterSpacing: -1.5 },
  avatarAccent: { position: 'absolute', bottom: 10, right: 10, width: 16, height: 16, borderRadius: 8, borderWidth: 2, borderColor: C.bg },
  name:       { color: C.text, fontSize: 24, fontWeight: '900', letterSpacing: -0.4, marginTop: S.md },
  nameHint:   { color: C.textMuted, fontSize: 11, letterSpacing: 0.5, textTransform: 'uppercase' },
  nameEditRow:{ flexDirection: 'row', alignItems: 'center', marginTop: S.md, marginBottom: S.sm },
  nameInput:  { backgroundColor: C.card, borderRadius: R.md, paddingHorizontal: S.md, paddingVertical: 10, color: C.text, fontSize: 16, width: 200, marginRight: S.sm, textAlign: 'center', borderWidth: 1, borderColor: C.border },
  saveNameBtn:{ backgroundColor: C.primary, paddingHorizontal: 18, paddingVertical: 10, borderRadius: R.md },
  saveNameText:{ color: C.primaryInk, fontWeight: '900', fontSize: 13 },
  greeting:   { color: C.textMuted, fontSize: 13, marginTop: S.sm, fontWeight: '700' },

  streakCard: {
    flexDirection: 'row', backgroundColor: C.surface,
    borderRadius: R.xl, padding: S.lg,
    marginVertical: S.lg, borderWidth: 0,
  },
  streakLeft: { flexDirection: 'row', alignItems: 'center', gap: S.md, flex: 1 },
  streakIconPill:{ minWidth: 44, minHeight: 44, borderRadius: 22, aspectRatio: 1, backgroundColor: C.cardAlt, justifyContent: 'center', alignItems: 'center' },
  streakNumber:  { color: C.text, fontSize: 32, fontWeight: '900', letterSpacing: -1 },
  streakLabel:   { color: C.textMuted, fontSize: 11, fontWeight: '700', letterSpacing: 0.5, textTransform: 'uppercase' },
  streakDivider: { width: 1, height: 36, backgroundColor: C.border, marginHorizontal: S.md },
  streakRight:   { alignItems: 'flex-end', flex: 1 },
  streakTodayKicker: { color: C.textMuted, fontSize: 10, fontWeight: '800', letterSpacing: 0.6, textTransform: 'uppercase' },
  streakToday:  { flexDirection: 'row', alignItems: 'center', backgroundColor: C.cardAlt, paddingVertical: 4, paddingHorizontal: 10, borderRadius: R.pill, marginTop: 4, gap: 6 },
  streakTodayEmoji: { fontSize: 16 },
  streakTodayLabel: { color: C.text, fontSize: 12, fontWeight: '800' },
  streakTodayMissing: { color: C.textMuted, fontSize: 13, fontStyle: 'italic', marginTop: 4 },

  statsRow:    { flexDirection: 'row', gap: S.sm, marginBottom: S.sm },
  statCard:    { flex: 1, flexDirection: 'row', alignItems: 'center', backgroundColor: C.surface, borderRadius: R.xl, padding: S.lg, borderWidth: 0, borderLeftWidth: 4 },
  statIcon:    { minWidth: 36, minHeight: 36, borderRadius: 18, aspectRatio: 1, justifyContent: 'center', alignItems: 'center', marginRight: S.sm },
  statIconText:{ fontSize: 14, fontWeight: '900' },
  statNumber:  { color: C.text,    fontSize: 20, fontWeight: '900' },
  statLabel:   { color: C.textSec, fontSize: 11, marginTop: 2, fontWeight: '700', letterSpacing: 0.5, textTransform: 'uppercase' },

  section: { marginTop: S.xl },
  sectionHeader: { flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: S.md },
  sectionTitle: { color: C.text, fontSize: 17, fontWeight: '900', letterSpacing: -0.3 },
  sectionSub:   { color: C.textMuted, fontSize: 12, marginTop: 2 },
  linkBtn:      { paddingVertical: 6, paddingHorizontal: 10 },
  linkBtnText:  { color: C.primary, fontSize: 12, fontWeight: '900' },

  favEmpty: { backgroundColor: C.card, borderRadius: R.lg, padding: S.xl, alignItems: 'center', borderWidth: 1, borderColor: C.border, borderStyle: 'dashed', gap: 8 },
  favEmptyText: { color: C.textMuted, fontSize: 13 },
  favRow:  { gap: S.md, paddingVertical: S.sm },
  favCard: {
    width: 240, backgroundColor: C.surface,
    borderRadius: R.xl, padding: S.xl, marginRight: S.md,
    borderWidth: 0,
  },
  favCardHead: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: S.sm },
  favBadge:    { paddingHorizontal: 8, paddingVertical: 2, borderRadius: R.pill },
  favBadgeText:{ fontSize: 9, fontWeight: '900', letterSpacing: 0.6, textTransform: 'uppercase' },
  favSnippet:  { color: C.text, fontSize: 13, lineHeight: 20 },
  favSnippetBold:{ fontWeight: '800' },

  sparkCard: {
    backgroundColor: C.surface,
    borderRadius: R.xl,
    borderWidth: 0,
    padding: S.xl,
    marginTop: S.md,
  },
  sparkRow:      { flexDirection: 'row', alignItems: 'flex-end', height: 64, gap: 6 },
  sparkCol:      { flex: 1, alignItems: 'center', justifyContent: 'flex-end' },
  sparkBar:      { width: '70%', borderTopLeftRadius: 4, borderTopRightRadius: 4, minHeight: 4 },
  sparkBaseline: { height: 1, backgroundColor: C.border, marginTop: 4 },
  sparkLegend:   { marginTop: S.md },
  sparkLegendRow:{ flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap', gap: 8, marginBottom: 6 },
  sparkDot:      { width: 8, height: 8, borderRadius: 4, marginRight: 4 },
  sparkLegendText:{ color: C.textSec, ...T.micro, fontWeight: '800', marginRight: S.sm },
  sparkNote:     { color: C.textMuted, fontSize: 11, lineHeight: 14 },

  startChatBtn:    { backgroundColor: C.primary, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingVertical: 18, paddingHorizontal: S.xl, borderRadius: R.xl, marginVertical: S.xl, ...sh.glow },
  startChatText:   { color: C.primaryInk, fontSize: 16, fontWeight: '900', letterSpacing: 0.5 },
  startChatArrow:  { color: C.primaryInk, fontSize: 18, fontWeight: '900', marginLeft: 8 },

  privacyCard: { flexDirection: 'row', backgroundColor: C.card, borderRadius: R.lg, padding: S.lg, marginBottom: S.md, marginTop: S.lg, borderWidth: 1, borderColor: C.border },
  privacyMark: { width: 4, borderRadius: 2, backgroundColor: C.sage, marginRight: S.md },
  privacyTitle:{ color: C.text, fontSize: 14, fontWeight: '800', marginBottom: 4 },
  privacyText: { color: C.textSec, fontSize: 12, lineHeight: 19 },

  emergencyCard: { backgroundColor: C.dangerLight, borderRadius: R.lg, padding: S.lg, marginTop: S.sm, borderWidth: 1, borderColor: C.danger },
  emergencyTitle: { color: C.danger, fontSize: 14, fontWeight: '900', marginBottom: S.sm },
  emergencyPhone: { color: '#fff', fontSize: 32, fontWeight: '900' },
  emergencyPhoneSm: { color: '#fff', fontSize: 22, fontWeight: '800' },
  emergencyDesc: { color: C.textSec, fontSize: 12, marginTop: 2 },
  emergencyDivider: { height: 1, backgroundColor: C.dangerLight, marginVertical: S.md, opacity: 0.4 },
});
