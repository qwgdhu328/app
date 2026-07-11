// gps-spoofer-app/src/features/home/screens/HomeScreen.js
//
// === Phase 4: Compact, non-moving Home ===
//
// Previous version (last reviewed in Phase 0.C) wrapped the page in a
// ScrollView and stacked seven sections vertically:
//   hero · streak · mood capture · CTA · 2×2 quick grid · week strip
//   · 3-cell stats bar · emergency pill · disclaimer.
//
// The user tightened the brief to "small + non-moving" — i.e. the page
// should fit a phone viewport WITHOUT scroll, and shouldn't auto-
// animate. This rewrite fixes that by:
//
//   1. Dropping ScrollView (the page is now a single View with
//      `flex: 1` and the sections distribute cleanly via gap spacing,
//      no nested scroll surface).
//   2. Dropping the weekly mood strip and the 3-cell stats bar — both
//      duplicate Profile's stats section, which lives a single tap
//      away via the "Tu" quick card. Keeping them here doubled the
//      page length without giving the user anything new.
//   3. Dropping the disclaimer text — the same sentence is repeated
//      in InfoScreen's DICHIARAZIONE card; carrying it here too was
//      wallpaper, not information.
//   4. Condensing the 2×2 quick grid into a single 1×4 row of small
//      chips (Sfogo libero / Spazio / Info / Tu) — same four actions,
//      one row instead of two. Visual rhythm reads as "the user
//      came here for one of four reasons".
//   5. Removing the week-history `useMemo` (no longer needed) and
//      the totalSessions/totalTurns imports (no longer used).
//
// "Non-moving" interpretation by design:
//   • No auto-mount animations (the page paints once).
//   • The container is a flex View, not a ScrollView, so the device's
//     keyboard show/hide can't reflow it — and there's no horizontal
//     swipe to compete with the user.
//   • Micro-interactions on buttons (PressableScale's 0.96 press + the
//     1.15 scale on the picked mood-emoji) stay — they're user-
//     initiated, not "the page moving on its own".
//
// === State ownership ===
// Unchanged from previous iteration: HomeScreen consumes UserStore +
// MoodStore via granular selectors. Navigation callbacks
// (onNavigate, onFreeWrite) and `onPickMood` are still props because
// they cross App.js boundaries.

import React from 'react';
import { StyleSheet, Text, View, ScrollView } from 'react-native';
import { C, R, S, T } from '../../../constants/theme';
import { MOODS } from '../../../constants/moods';
import { useUserStore } from '../../../store/userStore';
import { useMoodStore } from '../../../store/moodStore';
import { calcStreak } from '../../../utils/date';
import MoodIcon from '../../../components/MoodIcon';
import PressableScale from '../../../components/PressableScale';
import { StreakIcon, PenIcon, SparklesIcon, InfoIcon, ProfileIcon } from '../../../../icons';

// Local helper — short Italian month names for the date kicker.
// Equivalent to the one in src/utils/text.js if/when it gets exported.
function formatDate(d) {
  const months = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];
  return `${d.getDate()} ${months[d.getMonth()]}`;
}

export default function HomeScreen({ onNavigate, onFreeWrite, onPickMood }) {
  // === Store reads ===
  const userName      = useUserStore((s) => s.userName);
  const moodToday     = useMoodStore((s) => s.moodToday);
  const streak        = useMoodStore((s) => calcStreak(s.moodHistory));

  // === Time-aware greeting ===
  const hour = typeof Date !== 'undefined' ? new Date().getHours() : 12;
  const hello = hour < 5  ? 'Buonanotte'
              : hour < 12 ? 'Buongiorno'
              : hour < 18 ? 'Buon pomeriggio'
                          : 'Buonasera';
  const greeting = userName ? `${hello}, ${userName}` : hello;
  const tagLine = hour < 5  ? 'Notte fonda. Sono qui con te.'
                : hour < 7  ? 'Hai iniziato presto. Cosa c\u2019è?'
                : hour < 12 ? 'Com\u2019è andata la notte?'
                : hour < 18 ? 'Come ti senti, nel pieno della giornata?'
                            : 'La giornata sta scendendo. Cosa pesa?';

  return (
    // View, not ScrollView — the page is sized to fit one viewport.
    // `gap: S.md` between children handles vertical rhythm; we don't
    // declare per-section explicit margins.
    <View style={h.container}>
      {/* Z=1: Hero — date kicker + greeting + tagline + (conditional)
          streak chip. Padding-top pushes below safe-area insets. */}
      <View style={h.heroWrap}>
        <Text style={h.heroKicker}>{formatDate(new Date()).toUpperCase()}</Text>
        <Text style={h.greeting}>{greeting}</Text>
        <Text style={h.sub}>{tagLine}</Text>

        {streak > 0 && (
          <View style={h.streakChip} accessibilityLabel={`Streak attivo di ${streak} giorni`}>
            <StreakIcon size={14} color={C.primaryInk} />
            <Text style={h.streakChipText}>
              {streak} {streak === 1 ? 'giorno' : 'giorni'} di fila
            </Text>
          </View>
        )}
      </View>

      {/* Z=2: Mood capture card. Same 6-mood grid as before — micro
          micro-interaction on tap (scale 1.15 on the picked emoji, color
          flip) is user-initiated so it doesn't count as "moving". */}
      <View style={h.moodCard}>
        <View style={h.moodHeader}>
          <View>
            <Text style={h.moodHeaderLabel}>Mood di oggi</Text>
            <Text style={h.moodHeaderDate}>Come stai, qui e ora</Text>
          </View>
          {moodToday && (
            <View
              style={[
                h.moodToday,
                { backgroundColor: (MOODS.find((m) => m.key === moodToday.key) || MOODS[0]).light },
              ]}
            >
              <MoodIcon
                name={(MOODS.find((m) => m.key === moodToday.key) || MOODS[0]).iconName}
                color={(MOODS.find((m) => m.key === moodToday.key) || MOODS[0]).color}
                size={28}
              />
              <Text style={h.moodTodayLabel}>
                {(MOODS.find((m) => m.key === moodToday.key) || MOODS[0]).label}
              </Text>
            </View>
          )}
        </View>

        {/* ==== Phase 8: Responsive mood picker ====
            Single-row horizontal ScrollView of 6 fixed-width chips
            (~76pt each). On any viewport — phone portrait, landscape,
            iPad — the 6 chips share one row, and the user can swipe
            horizontally to access all 6. Vertical real estate drops
            from 2 rows (~88pt) to 1 row (~50pt), reclaiming the budget
            the primary CTA "Parla con me" needs to stay above the fold
            on dense / small viewports. The right-edge "peek" of the
            last chip is the discoverability hint that scrolling is
            available.                                  */}
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={h.moodGrid}
          accessibilityRole="radiogroup"
          accessibilityLabel="Selettore mood"
        >
          {MOODS.map((m) => {
            const picked = moodToday?.key === m.key;
            return (
              <PressableScale
                key={m.key}
                onPress={() => onPickMood(m)}
                style={[
                  h.moodBtn,
                  {
                    backgroundColor: picked ? m.color : m.light,
                    borderColor:     picked ? m.color : C.border,
                  },
                ]}
                accessibilityRole="radio"
                accessibilityState={{ checked: picked }}
                accessibilityLabel={`Mood ${m.label}`}
              >
                <View style={[h.moodEmoji, picked && { transform: [{ scale: 1.15 }] }]}>
                  <MoodIcon
                    name={m.iconName}
                    color={picked ? C.primaryInk : m.color}
                    size={22}
                  />
                </View>
                <Text
                  adjustsFontSizeToFit
                  numberOfLines={1}
                  style={[h.moodLabel, picked && { color: C.primaryInk, fontWeight: '800' }]}
                >
                  {m.label}
                </Text>
              </PressableScale>
            );
          })}
        </ScrollView>

        <Text style={h.hint}>Un tap al giorno, se ti va. Non devi farlo per forza.</Text>
      </View>

      {/* Z=3: Big primary CTA — start the chat. */}
      <PressableScale
        onPress={() => onNavigate('chat')}
        accessibilityLabel="Inizia a parlare"
        style={h.startBtn}
      >
        <View style={h.startInner}>
          <View>
            <Text style={h.startKicker}>Pronto/a?</Text>
            <Text style={h.startTitle}>Parla con me</Text>
          </View>
          <View style={h.startArrow}>
            <Text style={h.startArrowText}>→</Text>
          </View>
        </View>
      </PressableScale>

      {/* Z=4: Quick row — 4 chips in one horizontal line. replaces the
          previous 2×2 grid. Same four targets (FreeWrite / Spazio /
          Info / Tu), one row, less vertical real estate. */}
      <View style={h.quickRow}>
        <PressableScale onPress={onFreeWrite} style={[h.quickChip, h.quickChipAccent]}>
          <PenIcon color={C.accent} />
          <Text style={h.quickTitle}>Sfogo</Text>
        </PressableScale>
        <PressableScale onPress={() => onNavigate('community')} style={[h.quickChip, h.quickChipPrimary]}>
          <SparklesIcon size={20} color={C.primary} />
          <Text style={h.quickTitle}>Spazio</Text>
        </PressableScale>
        <PressableScale onPress={() => onNavigate('info')} style={[h.quickChip, h.quickChipSky]}>
          <InfoIcon />
          <Text style={h.quickTitle}>Info</Text>
        </PressableScale>
        <PressableScale onPress={() => onNavigate('profile')} style={[h.quickChip, h.quickChipTerracotta]}>
          <ProfileIcon active={true} />
          <Text style={h.quickTitle}>Tu</Text>
        </PressableScale>
      </View>

      {/* Z=5: Emergency pill — always-visible safety rail. Pinned as
          the LAST element so the user always knows where to find it.
          `minHeight: 44` on the style is the tap-target guarantee —
          the visual pill is ~27pt of content but the StyleSheet
          enforces a 44pt hit area matching the iOS HIG minimum for
          tappable controls. hitSlop was tried but dropped: on a
          full-width pill inside `container` (paddingHorizontal:
          S.md), left/right hitSlop would extend into dead space
          outside the parent, and the vertical hitSlop is redundant
          with minHeight.    */}
      <PressableScale
        onPress={() => onNavigate('chat')}
        style={h.emergencyPill}
        accessibilityLabel="Chiama il 112 ora"
      >
        <Text style={h.emergencyIcon}>🆘</Text>
        <Text style={h.emergencyText}>
          Serve aiuto ora? Chiama il <Text style={{ fontWeight: '800' }}>112</Text>
        </Text>
      </PressableScale>
    </View>
  );
}

const h = StyleSheet.create({
  // === Phase 4: Compact Home ===
  // No ScrollView — the page is a flex View. Vertical rhythm comes
  // from `gap: S.md` on `contentStack` (parent) plus per-section
  // internal padding. On a 320 × 700pt phone this fits without scroll;
  // on larger screens the content stack simply has more breathing
  // room because flex children don't fight for it.
  container: {
    flex: 1,
    backgroundColor: C.bg,
    paddingHorizontal: S.md,
    paddingTop: S.sm,
    paddingBottom: S.sm,
    maxWidth: 600,
    width: '100%',
    alignSelf: 'center',
    gap: S.sm,
  },

  heroWrap:   { paddingTop: S.sm, paddingBottom: 2 },
  heroKicker: { ...T.micro, color: C.primary, marginBottom: 2 },
  greeting:   { ...T.h2, color: C.text, marginTop: 1 },
  sub:        { ...T.bodySm, color: C.textSec, marginTop: 3 },

  streakChip: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    backgroundColor: C.primary,
    paddingVertical: 5,
    paddingHorizontal: S.md,
    borderRadius: R.pill,
    marginTop: S.sm,
    gap: 6,
  },
  streakChipText: { color: C.primaryInk, ...T.micro, letterSpacing: 0.6 },

  moodCard: {
    backgroundColor: C.surface,
    borderRadius: R.xl,
    padding: S.md,
    borderWidth: 0,
  },
  moodHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: S.sm,
  },
  moodHeaderLabel: { ...T.body, color: C.text, fontWeight: '800' },
  moodHeaderDate:  { ...T.caption, color: C.textMuted, marginTop: 1 },
  moodToday: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 5,
    paddingHorizontal: S.md,
    borderRadius: R.pill,
    gap: 6,
  },
  moodTodayLabel: { color: C.text, ...T.bodySm, fontWeight: '700' },
  moodGrid: { flexDirection: 'row', gap: 6, alignItems: 'stretch', paddingRight: 4 },
  moodBtn: {
    width: 76,
    minWidth: 76,
    flexShrink: 0,
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 4,
    borderRadius: R.md,
    borderWidth: 1.5,
    minHeight: 44,
  },
  moodEmoji: { marginBottom: 2 },
  moodLabel: { color: C.text, fontSize: 10, fontWeight: '700', lineHeight: 12 },
  hint: {
    color: C.textMuted,
    fontSize: 11,
    marginTop: 4,
    textAlign: 'center',
  },

  startBtn: {
    backgroundColor: C.primary,
    borderRadius: R.xl,
    paddingVertical: 16,
    paddingHorizontal: S.lg,
    minHeight: 56,
  },
  startInner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  startKicker: { color: C.primaryInk, ...T.micro, letterSpacing: 1.5 },
  startTitle:  { color: C.primaryInk, ...T.h3, letterSpacing: -0.4, marginTop: 1 },
  startArrow: {
    minWidth: 44,
    minHeight: 44,
    borderRadius: 22,
    aspectRatio: 1,
    backgroundColor: C.primaryInk,
    justifyContent: 'center',
    alignItems: 'center',
  },
  startArrowText: { color: C.primary, fontSize: 20, fontWeight: '800' },

  // === Quick row — single horizontal line of four colored chips ===
  quickRow: {
    flexDirection: 'row',
    gap: S.sm,
  },
  quickChip: {
    flex: 1,
    backgroundColor: C.surface,
    borderRadius: R.lg,
    paddingVertical: 9,
    paddingHorizontal: 4,
    alignItems: 'center',
    borderWidth: 0,
    minHeight: 44,
  },
  quickChipAccent:      { backgroundColor: C.accentLight },
  quickChipPrimary:     { backgroundColor: C.primaryLight },
  quickChipSky:         { backgroundColor: C.skyLight },
  quickChipTerracotta:  { backgroundColor: C.terracottaLight },
  quickTitle: {
    color: C.text,
    ...T.caption,
    fontWeight: '700',
    marginTop: 4,
  },

  emergencyPill: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: C.dangerLight,
    borderRadius: R.pill,
    paddingVertical: 7,
    paddingHorizontal: S.md,
    minHeight: 44,
    borderWidth: 1,
    borderColor: C.danger,
    gap: 6,
  },
  emergencyIcon: { fontSize: 15 },
  emergencyText: { color: C.danger, fontSize: 13, fontWeight: '700' },
});
