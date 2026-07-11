// gps-spoofer-app/src/features/onboarding/screens/OnboardingScreen.js
//
// === Phase 4: Feature-tour onboarding ===
//
// Single-screen tour showing the six main functions of BenessereBot.
// Rendered ONCE after the brand-mark splash (IntroScreen) completes,
// GATED by `useUserStore.onboardingCompleted` so subsequent launches
// go straight from splash to Home. The advance tap persists
// `onboardingCompleted = true` via the App.js onAdvance callback.
//
// === Layout ===
//   Z=1 Header: red-coral kicker "QUICK TOUR" + display title
//               "Cosa posso fare per te" + subtitle.
//   Z=2 Grid:   2×3 feature cards. Each card has:
//                   • feature-specific icon (existing icons.js export)
//                   • feature-specific tinted background (theme token)
//                   • title + single-line description.
//               Order matches the routing menu users discover naturally
//               (primary action first, secondary actions behind).
//   Z=3 Footer: coral pill CTA "Inizia" calling onAdvance().
//
// === Why a single screen (not a swipeable carousel) ===
// We chose the single page because: (a) the 6 features fit in one
// screen on any modern phone, (b) avoiding swipe-onboarding removes a
// tap the user has to learn before reaching the actual app,
// (c) the page is non-scrollable so the user can't miss any feature,
// and (d) the single CTA — "Inizia" — sets up the muscle memory that
// tapping a coral pill is the way to advance. Both the IntroScreen
// CTA ("Inizia il tuo viaggio") and this one use the same coral pill
// for that reason.
//
// === Performance ===
// No animated values. PressableScale micro-interaction on the CTA is
// native-driver. Default-export, no providers.
//
// === API ===
// <OnboardingScreen onAdvance={() => { ... persist + dismiss }} />

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { C, R, S, T } from '../../../constants/theme';
import PressableScale from '../../../components/PressableScale';
import {
  ChatIcon, SparklesIcon, PenIcon, SproutIcon, ProfileIcon, InfoIcon,
} from '../../../../icons';

// === Feature menu ===
// Each entry: title (imperative, short), description (one line, no jargon),
// Icon (existing icons.js export — note some hardcode their stroke color),
// bg (theme token tinted to the feature's leading hue).
// Order matters: chat first (primary action), then mood (the daily
// micro-commitment), then secondary entries (FreeWrite/Spazio/Tu/Info).
// This mirrors the natural discovery order from the HomeScreen quickGrid.
const FEATURES = [
  {
    key:       'chat',
    title:     'Parla con me',
    desc:      'Un primo posto dove fermarti quando non sai dove andare.',
    Icon:      ChatIcon,
    bg:        C.primaryLight,
    iconColor: C.primary,
  },
  {
    key:       'mood',
    title:     'Mood di oggi',
    desc:      'Un tap al giorno, se ti va. Non devi farlo per forza.',
    Icon:      SparklesIcon,
    bg:        C.terracottaLight,
    iconColor: C.terracotta,
  },
  {
    key:       'freewrite',
    title:     'Sfogo libero',
    desc:      'Scrivi a ruota libera, poi metti in mappa i nodi.',
    Icon:      PenIcon,
    bg:        C.accentLight,
    iconColor: C.accent,
  },
  {
    key:       'community',
    title:     'Spazio',
    desc:      'Storie della community. Lettura, non interazione.',
    Icon:      SproutIcon,
    bg:        C.sageLight,
    iconColor: C.sage,
  },
  {
    key:       'profile',
    title:     'Tu',
    desc:      'Streak, preferiti, statistiche personali.',
    Icon:      ProfileIcon,
    bg:        C.skyLight,
    iconColor: C.sky,
  },
  {
    key:       'info',
    title:     'Info',
    desc:      'Privacy, comandi, numeri che contano.',
    Icon:      InfoIcon,
    bg:        C.dangerLight,
    iconColor: C.danger,
  },
];

export default function OnboardingScreen({ onAdvance }) {
  return (
    <View style={o.container}>
      <View style={o.header}>
        <Text style={o.kicker}>QUICK TOUR</Text>
        <Text style={o.title}>Cosa posso fare per te</Text>
        <Text style={o.sub}>
          Sei funzioni, una per ogni spazio in cui respirare. Puoi
          rivedere questo elenco dalla scheda Tu.
        </Text>
      </View>

      <View style={o.grid}>
        {FEATURES.map(({ key, title, desc, Icon, bg, iconColor }) => (
          <View key={key} style={[o.card, { backgroundColor: bg }]}>
            {/* Some icons (ChatIcon/ProfileIcon) accept an `active` bool;
                others (InfoIcon) ignore color props and hardcode their
                stroke. Wrapper color bubbles below swallow any drift so
                the icon always reads as the feature's brand hue. */}
            <View
              style={[o.iconBubble, { backgroundColor: iconColor + '22' }]}
              accessibilityElementsHidden
            >
              {/* ChatIcon / ProfileIcon accept `active={true}` so their
                  strokes render in C.primary (the brand-coral default).
                  PenIcon / SparklesIcon / SproutIcon accept a `color`
                  prop. InfoIcon hardcodes C.accent — pass-through
                  iconColor is set anyway so future icon swaps inherit
                  the feature's hue. */}
              {Icon === ChatIcon || Icon === ProfileIcon
                ? <Icon active={true} />
                : <Icon color={iconColor} />}
            </View>
            <Text style={o.cardTitle}>{title}</Text>
            <Text style={o.cardDesc}>{desc}</Text>
          </View>
        ))}
      </View>

      <View style={o.footer}>
        <PressableScale onPress={onAdvance} style={o.cta} accessibilityLabel="Inizia">
          <Text style={o.ctaText}>Inizia</Text>
        </PressableScale>
      </View>
    </View>
  );
}

const o = StyleSheet.create({
  // Tablet guard — same 600pt cap as every other screen in the app.
  container: {
    flex: 1,
    backgroundColor: C.bg,
    paddingHorizontal: S.lg,
    paddingTop: S.lg,
    paddingBottom: S.md,
    maxWidth: 600,
    width: '100%',
    alignSelf: 'center',
  },

  header: { paddingTop: S.md, marginBottom: S.md },
  kicker: { ...T.micro, color: C.primary, marginBottom: S.sm },
  title:  { ...T.display, color: C.text, marginBottom: S.sm },
  sub:    { ...T.body, color: C.textSec, lineHeight: T.body.lineHeight },

  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: S.md,
    marginTop: S.md,
    marginBottom: S.lg,
  },
  card: {
    flexBasis: '47%',
    flexGrow: 1,
    borderRadius: R.lg,
    padding: S.md,
    minHeight: 110,
  },
  iconBubble: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: S.sm,
  },
  cardTitle: { ...T.body, color: C.text, fontWeight: '800' },
  cardDesc:  { ...T.caption, color: C.textSec, marginTop: 2, lineHeight: 18 },

  footer: {
    paddingTop: S.md,
    paddingBottom: S.sm,
    alignItems: 'center',
  },
  cta: {
    backgroundColor: C.primary,
    borderRadius: R.pill,
    paddingVertical: 14,
    paddingHorizontal: S.xl + S.md,
    minWidth: 220,
    alignItems: 'center',
  },
  ctaText: {
    ...T.h3,
    color: C.primaryInk,
    fontWeight: '800',
    letterSpacing: 0.2,
  },
});
