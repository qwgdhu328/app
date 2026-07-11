import { useEffect, useRef, useState } from 'react';
import { Animated, AccessibilityInfo, View } from 'react-native';
import { C, M, R } from '../constants/theme';

/**
 * Three-dot typing indicator. Each dot bounces up with a small phase offset
 * to give the wave effect; respects `AccessibilityInfo.isReduceMotionEnabled()`.
 *
 * The classic "Sto ascoltando…" string lives next to this in the chat
 * header — the dots provide the visual rhythm that makes the response time
 * feel less awkward.
 */
export default function AnimatedDots({ color = C.primary, size = 8, gap = 6, style }) {
  const [d1] = useState(() => new Animated.Value(0));
  const [d2] = useState(() => new Animated.Value(0));
  const [d3] = useState(() => new Animated.Value(0));
  const reduceMotionRef = useRef(null);

  useEffect(() => {
    let mounted = true;
    AccessibilityInfo.isReduceMotionEnabled()
      .then((v) => {
        if (mounted) reduceMotionRef.current = v;
      })
      .catch(() => {
        if (mounted) reduceMotionRef.current = false;
      });
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', (v) => {
      reduceMotionRef.current = v;
    });
    return () => {
      mounted = false;
      sub.remove();
    };
  }, []);

  useEffect(() => {
    if (reduceMotionRef.current) {
      d1.setValue(0);
      d2.setValue(0);
      d3.setValue(0);
      return;
    }
    const step = (v, delay) =>
      Animated.sequence([
        Animated.delay(delay),
        Animated.loop(
          Animated.sequence([
            Animated.timing(v, { toValue: -4, duration: M.fast, useNativeDriver: true }),
            Animated.timing(v, { toValue: 0, duration: M.fast, useNativeDriver: true }),
          ])
        ),
      ]).start();
    step(d1, 0);
    step(d2, 140);
    step(d3, 280);
    return () => {
      d1.stopAnimation();
      d2.stopAnimation();
      d3.stopAnimation();
    };
  }, [d1, d2, d3]);

  return (
    <View
      accessibilityLabel="Il bot sta scrivendo"
      accessibilityRole="progressbar"
      style={[{ flexDirection: 'row', alignItems: 'center' }, style]}
    >
      {[d1, d2, d3].map((v, i) => (
        <Animated.View
          key={i}
          style={{
            width: size,
            height: size,
            borderRadius: R.pill,
            backgroundColor: color,
            marginLeft: i === 0 ? 0 : gap,
            transform: [{ translateY: v }],
          }}
        />
      ))}
    </View>
  );
}
