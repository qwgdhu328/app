// gps-spoofer-app/src/features/intro/screens/IntroScreen.js
//
// Phase 3.z — "Horizon Ember Glow" branded intro.
//
// Replaces the cyan/navy template from Phase 3.y with a fully on-brand
// screen: the actual app logo (assets/splash-icon.png, the brand
// silhouette) sits inside a framed halo/lens arrangement, on top of a
// deep-aubergine gradient (C.bg → C.bgWarm), surrounded by mood-palette
// particles that drift upward using the application's full mood axis
// (primary, accent, sage, terracotta, amber, sky). All hex colors come
// from src/constants/theme.js — no stray palette values.
//
// Complexity layers (per design brief — at least 2 geometry layers +
// 8 mood-pool particles + multi-stage entry/exit):
//   Z=1 Particles (8 mood-color orbs, drift-only loops)
//   Z=2 Outer dashed accent ring (slow rotate, 25 s loop)
//   Z=2 Inner solid pulse ring (scale 1→1.15, breathe loop)
//   Z=3 Logo plate (130×130 with bgWarm fill + C.borderHi rim, the brand
//       silhouette Image clipped via resizeMode="contain")
//   Z=4 Title + subtitle + tagline pill (staggered content shift)
//   Z=5 Coral→peach CTA + "Nessun dato viene memorizzato" footer
//              (lock-open icon, honest about local-only handling)
//
// Performance budget: 13 concurrent Animated.Values (1 logoScale + 1
// contentAnim + 1 btnScale + 1 pulseRing + 1 rotateRing + 1 exitFade +
// 8 particles), all useNativeDriver=true so they stay on the native
// thread. No animated .width/.height — width interpolation would force
// JS-driven animation.
//
// Entry choreography (≤ 2.6 s total):
//   • +100ms : logoScale spring (tension 70, friction 7)
//   • +400ms : contentAnim timing (Exp out, 800 ms) → drives Y-translate
//              + fade on title/subtitle/tagline pill/footer
//   • +900ms : btnScale spring (tension 90, friction 6) — CTA drops in
//   •   0ms : rotateRing loop (25 s) + pulseRing loop (4.5 s) + 8 particle
//              loops (5–9 s each)
//
// Exit choreography (≤ 700 ms after CTA tap):
//   • 0 ms  : Haptics.ImpactFeedbackStyle.Medium + btnScale → 0.9 (120 ms)
//   • +120ms: parallel
//              - logoScale → 0.2 (Back in, 400 ms)
//              - contentAnim → 0 (300 ms)
//              - exitFade → 0 (500 ms, delayed 100 ms inside the parallel)
//   • end   : onDone() → App.js flips showIntro=false → Home takes over
//
// API contract: default-export IntroScreen({ onDone }) matches the
// consumer in App.js: <IntroScreen onDone={() => setShowIntro(false)} />.

import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Animated,
  Easing,
  Dimensions,
  StatusBar,
  TouchableOpacity,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';

// NOTE: from src/features/intro/screens/ → 3 `..` (not 4) reaches gps-spoofer-app/src/,
// where constants/theme.js lives. Off-by-one level would resolve to the project root,
// producing an empty bundle. The previous splash-icon PNG path stayed at 4 `..` because
// assets/ lives at the project root, but the intro no longer hard-requires that PNG
// — BrandMark.js renders the same mark inline as SVG.
import { C, T, R, S } from '../../../constants/theme';
import BrandMark from '../../../components/BrandMark';

const { width, height } = Dimensions.get('window');

// 8 mood-pool particles — drawn from the full mood axis so the void
// reads as "alive with subtle warmth / cool balance" rather than a
// monochrome haze. Order chosen so adjacent particles contrast (warm
// vs cool).
const PARTICLE_COUNT = 8;
const PARTICLE_COLORS = [
  C.primary,     // coral mango
  C.accent,      // goldenrod
  C.sage,        // mint positive
  C.terracotta,  // peach
  C.amber,       // gold
  C.sky,         // periwinkle
  C.primary,     // duplicate so warm tones weigh 3 of 8
  C.accent,
];

export default function IntroScreen({ onDone }) {
  // ---- ANIMATION REFS ----
  const logoScale    = useRef(new Animated.Value(0.4)).current;
  const contentAnim  = useRef(new Animated.Value(0)).current;
  const btnScale     = useRef(new Animated.Value(0)).current;
  const pulseRing    = useRef(new Animated.Value(0)).current;
  const rotateRing   = useRef(new Animated.Value(0)).current;
  const exitFade     = useRef(new Animated.Value(1)).current;

  // ---- PARTICLE POOL ----
  const particleAnims = useRef(
    Array(PARTICLE_COUNT).fill(0).map(() => new Animated.Value(0))
  ).current;

  // Pre-compute particles' physical layout once. Half-spread vertically
  // so they emerge from the lower middle and drift up — feels grounded,
  // not random tv-static.
  const particleConfigs = useRef(
    Array(PARTICLE_COUNT).fill(0).map((_, i) => ({
      x: Math.random() * width,
      y: (Math.random() * (height * 0.45)) + (height * 0.5),
      size: Math.random() * 5 + 4,
      duration: Math.random() * 4000 + 5500,
      delay: Math.random() * 2000,
      color: PARTICLE_COLORS[i],
    }))
  ).current;

  const [isExiting, setIsExiting] = useState(false);

  // ---- MOUNT: choreographed entry + loops ----
  useEffect(() => {
    // 1) Logo spring-in (focal point arrives first)
    Animated.sequence([
      Animated.delay(100),
      Animated.spring(logoScale, {
        toValue: 1,
        tension: 70,
        friction: 7,
        useNativeDriver: true,
      }),
    ]).start();

    // 2) Content stagger-reveal (title/subtitle/tagline pill/footer)
    Animated.sequence([
      Animated.delay(400),
      Animated.timing(contentAnim, {
        toValue: 1,
        duration: 800,
        easing: Easing.out(Easing.exp),
        useNativeDriver: true,
      }),
    ]).start();

    // 3) CTA spring-in (last)
    Animated.sequence([
      Animated.delay(900),
      Animated.spring(btnScale, {
        toValue: 1,
        tension: 90,
        friction: 6,
        useNativeDriver: true,
      }),
    ]).start();

    // 4) Continuous geometry: 25-second dashed ring rotation
    Animated.loop(
      Animated.timing(rotateRing, {
        toValue: 1,
        duration: 25000,
        easing: Easing.linear,
        useNativeDriver: true,
      })
    ).start();

    // 5) Pulse ring breathing loop (4.5 s: 2500 ms expand + 2000 ms reset)
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulseRing, {
          toValue: 1,
          duration: 2500,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(pulseRing, {
          toValue: 0,
          duration: 2000,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ])
    ).start();

    // 6) Particle drift loops — each particle gets its own duration &
    // delay, but uses the same `useNativeDriver: true` for low JS cost.
    particleAnims.forEach((anim, i) => {
      const cfg = particleConfigs[i];
      Animated.loop(
        Animated.timing(anim, {
          toValue: 1,
          duration: cfg.duration,
          delay: cfg.delay,
          easing: Easing.linear,
          useNativeDriver: true,
        })
      ).start();
    });

    return () => {
      // Defensive stopAnimation so re-mounts don't leak previous drivers.
      logoScale.stopAnimation();
      contentAnim.stopAnimation();
      btnScale.stopAnimation();
      rotateRing.stopAnimation();
      pulseRing.stopAnimation();
      exitFade.stopAnimation();
      particleAnims.forEach((a) => a.stopAnimation());
    };
  }, []);

  // ---- CTA handler: choreographed exit ----
  const handleCTA = () => {
    // Guard against double-tap during the ~700 ms exit choreography.
    if (isExiting) return;
    setIsExiting(true);

    if (Haptics) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(() => {});
    }

    // 1) Button compress (squishy feedback)
    Animated.timing(btnScale, {
      toValue: 0.9,
      duration: 120,
      easing: Easing.out(Easing.quad),
      useNativeDriver: true,
    }).start(() => {
      // 2) World-collapse: logo shrinks (Back-in), content fades down,
      //    whole screen crossfades out. handoff to App.js.
      Animated.parallel([
        Animated.timing(logoScale, {
          toValue: 0.2,
          duration: 400,
          easing: Easing.in(Easing.back(1.5)),
          useNativeDriver: true,
        }),
        Animated.timing(contentAnim, {
          toValue: 0,
          duration: 300,
          useNativeDriver: true,
        }),
        Animated.timing(exitFade, {
          toValue: 0,
          duration: 500,
          delay: 100,
          easing: Easing.out(Easing.ease),
          useNativeDriver: true,
        }),
      ]).start(() => {
        if (onDone) onDone();
      });
    });
  };

  // ---- Particle rendering helper ----
  const renderParticles = () =>
    particleAnims.map((anim, index) => {
      const cfg = particleConfigs[index];
      const translateY = anim.interpolate({
        inputRange: [0, 1],
        outputRange: [0, -height * 0.7],
      });
      const opacity = anim.interpolate({
        inputRange: [0, 0.2, 0.8, 1],
        outputRange: [0, 0.6, 0.6, 0],
      });
      return (
        <Animated.View
          key={`p-${index}`}
          style={[
            styles.particle,
            {
              backgroundColor: cfg.color,
              width: cfg.size,
              height: cfg.size,
              left: cfg.x,
              top: cfg.y,
              opacity,
              transform: [{ translateY }],
            },
          ]}
        />
      );
    });

  return (
    <Animated.View style={[styles.container, { opacity: exitFade }]}>
      <StatusBar hidden />

      <LinearGradient
        colors={[C.bg, C.bgWarm, C.bg]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.gradient}
      >
        {/* Z=1: mood-palette particles */}
        {renderParticles()}

        <View style={styles.contentLayer}>
          {/* Z=2 + Z=3: hero halos + logo plate (single spring point) */}
          <Animated.View style={[styles.heroBox, { transform: [{ scale: logoScale }] }]}>
            {/* Outer dashed accent ring — slow rotation */}
            <Animated.View
              style={[
                styles.outerRing,
                {
                  transform: [
                    {
                      rotate: rotateRing.interpolate({
                        inputRange: [0, 1],
                        outputRange: ['0deg', '360deg'],
                      }),
                    },
                  ],
                },
              ]}
            />
            {/* Inner solid pulse ring — breathing */}
            <Animated.View
              style={[
                styles.pulseRing,
                {
                  transform: [
                    {
                      scale: pulseRing.interpolate({
                        inputRange: [0, 1],
                        outputRange: [1, 1.15],
                      }),
                    },
                  ],
                  opacity: pulseRing.interpolate({
                    inputRange: [0, 1],
                    outputRange: [1, 0],
                  }),
                },
              ]}
            />
            {/* Z=3: on-brand logo (src/components/BrandMark.js) — a
                coral→peach gradient plate with a centered white "B"
                monogram and a goldenrod accent dot. Replaces the previous
                bgWarm platform + splash-icon.png Image composition; the
                SVG component pulls colors live from C.* tokens, so a
                palette swap on C.primary/C.terracotta/C.accent propagates
                automatically. */}
            <BrandMark size={130} variant="mark" />
          </Animated.View>

          {/* Z=4: text content. contentAnim drives BOTH opacity (0→1)
              and translateY (40→0) — single value, twice interpolated. */}
          <Animated.View
            style={[
              styles.textContainer,
              {
                opacity: contentAnim,
                transform: [
                  {
                    translateY: contentAnim.interpolate({
                      inputRange: [0, 1],
                      outputRange: [40, 0],
                    }),
                  },
                ],
              },
            ]}
          >
            <Text style={styles.title}>BenessereBot</Text>
            <Text style={styles.subtitle}>
              Il tuo compagno per il benessere mentale
            </Text>

            <View style={styles.taglinePill}>
              <Text style={styles.tagline}>Ascolta</Text>
              <View style={styles.taglineDot} />
              <Text style={styles.tagline}>Comprendi</Text>
              <View style={styles.taglineDot} />
              <Text style={styles.tagline}>Supporta</Text>
            </View>
          </Animated.View>

          {/* Z=5: CTA + footer */}
          <View style={styles.footerZone}>
            <Animated.View style={{ transform: [{ scale: btnScale }] }}>
              <TouchableOpacity
                style={styles.ctaOuter}
                activeOpacity={0.85}
                onPress={handleCTA}
              >
                <LinearGradient
                  colors={[C.primary, C.terracotta]}
                  start={{ x: 0, y: 0.5 }}
                  end={{ x: 1, y: 0.5 }}
                  style={styles.ctaGradient}
                >
                  <Text style={styles.ctaText}>Inizia il tuo viaggio</Text>
                  <Ionicons name="arrow-forward" size={20} color="#FFFFFF" />
                </LinearGradient>
              </TouchableOpacity>
            </Animated.View>

            <Animated.View style={[styles.secureContainer, { opacity: contentAnim }]}>
              {/* lock-open (not lock-closed): BenessereBot has no auth or
                  encryption; the honest signal is "data stays local" not
                  "data is secured in the cloud". */}
              <Ionicons name="lock-open" size={14} color={C.textMuted} />
              <Text style={styles.secureText}>Nessun dato viene memorizzato</Text>
            </Animated.View>
          </View>
        </View>
      </LinearGradient>
    </Animated.View>
  );
}

// ============================================================
// STYLES — phase 1.x design mandate: sh.glow is a no-op now
// (depth comes from color contrast, typography, spacing — not
// drop shadow). All shadows/elevations removed. All colors come
// from C.* theme tokens (no stray hex outside #FFFFFF for CTA
// glyph + arrow which deliberately sit ON the coral gradient).
// ============================================================
const styles = StyleSheet.create({
  // ---- STYLES ----
  // Phase 1.x design mandate: sh.glow is a no-op (depth comes from
  // color contrast, typography, spacing — never from drop shadow).
  // All shadows/elevations removed.
  //
  // Hex usage: chrome comes from C.* theme tokens. Two intentional
  // derivations:
  //   • #FFFFFF for ctaText + arrow-forward icon — sits ON the
  //     coral→peach gradient; white pops against warm coral.
  //   • pulseRing borderColor uses 'rgba(255, 126, 103, 0.5)' — a
  //     C.primary hex derivation so the breathing animation stays
  //     visible against C.bg (C.primaryLight at 0.18 alpha is too
  //     faint when multiplied by the opacity drive).
  container: {
    flex: 1,
    backgroundColor: C.bg,
  },
  gradient: {
    flex: 1,
    paddingHorizontal: S.xl,
  },
  contentLayer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 10,
  },
  particle: {
    position: 'absolute',
    borderRadius: 99,
  },
  heroBox: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 240,
    height: 240,
    marginTop: S.xl,
    marginBottom: S.xl,
  },
  outerRing: {
    position: 'absolute',
    width: 200,
    height: 200,
    borderRadius: 100,
    borderWidth: 1.5,
    borderColor: C.accentLight,
    borderStyle: 'dashed',
  },
  pulseRing: {
    position: 'absolute',
    width: 170,
    height: 170,
    borderRadius: 85,
    borderWidth: 3,
    // 0.5 alpha derivation from C.primary. C.primaryLight (0.18 alpha)
    // is too faint once multiplied by the breathing opacity drive;
    // raising the base alpha keeps the ring visible against C.bg
    // without dropping the breathing contrast. One of the only two
    // intentional non-token hex usages in this file — see STYLES
    // block header for the other (CTA white glyphs).
    borderColor: 'rgba(255, 126, 103, 0.5)',
  },
  textContainer: {
    alignItems: 'center',
    marginBottom: S.xxl * 1.5,
  },
  title: {
    ...T.display,
    color: C.text,
    textAlign: 'center',
    marginBottom: S.sm,
  },
  subtitle: {
    ...T.bodyLg,
    color: C.textSec,
    textAlign: 'center',
    marginBottom: S.xl,
    paddingHorizontal: S.md,
  },
  taglinePill: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: S.sm,
    paddingHorizontal: S.lg,
    backgroundColor: C.primaryLight,
    borderRadius: R.pill,
  },
  tagline: {
    ...T.caption,
    color: C.primary,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 1.2,
  },
  taglineDot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: C.primary,
    marginHorizontal: S.md,
    opacity: 0.6,
  },
  footerZone: {
    position: 'absolute',
    bottom: height * 0.08,
    alignItems: 'center',
    width: '100%',
  },
  ctaOuter: {
    width: width * 0.85,
    height: 58,
    borderRadius: R.pill,
    overflow: 'hidden',
    marginBottom: S.lg,
  },
  ctaGradient: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  ctaText: {
    ...T.h3,
    color: '#FFFFFF',
    marginRight: S.sm,
    letterSpacing: 0.2,
  },
  secureContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    opacity: 0.7,
  },
  secureText: {
    ...T.caption,
    color: C.textMuted,
    marginLeft: S.xs,
  },
});
