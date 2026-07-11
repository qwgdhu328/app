import { useEffect, useRef, useState, memo } from 'react';
import { Animated, AccessibilityInfo } from 'react-native';

/**
 * Animated wrapper for chat messages.
 *
 * On mount, slides up (translateY 12 → 0) and fades in (opacity 0 → 1).
 * Respects `AccessibilityInfo.isReduceMotionEnabled()`:
 *  - If reduced motion is on by the user, the message appears immediately
 *    (no fade/slide at all).
 *  - We wait for the system to answer the async check before deciding —
 *    otherwise users with reduce-motion enabled would briefly see a flash
 *    of the animation (P0 fix).
 *
 * Because the animation only fires on mount, existing messages do not
 * re-animate when the FlatList is updated. Use stable `keyExtractor` keys
 * based on a per-message id to keep this guarantee even if messages are
 * ever inserted in the middle.
 */
function ChatBubble({ children, style }) {
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(12)).current;
  // null = "we have not yet asked the OS" → animation must wait.
  const [reduceMotion, setReduceMotion] = useState(null);

  useEffect(() => {
    let cancelled = false;
    AccessibilityInfo.isReduceMotionEnabled()
      .then((enabled) => {
        if (!cancelled) setReduceMotion(Boolean(enabled));
      })
      .catch(() => {
        if (!cancelled) setReduceMotion(false);
      });
    const sub = AccessibilityInfo.addEventListener(
      'reduceMotionChanged',
      (enabled) => setReduceMotion(Boolean(enabled))
    );
    return () => {
      cancelled = true;
      sub.remove();
    };
  }, []);

  useEffect(() => {
    // Don't decide anything until we know the user's preference.
    if (reduceMotion === null) return;
    if (reduceMotion) {
      opacity.setValue(1);
      translateY.setValue(0);
      return;
    }
    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration: 280,
        useNativeDriver: true,
      }),
      Animated.spring(translateY, {
        toValue: 0,
        friction: 9,
        tension: 60,
        useNativeDriver: true,
      }),
    ]).start();
  }, [reduceMotion]);

  return (
    <Animated.View style={[{ opacity, transform: [{ translateY }] }, style]}>
      {children}
    </Animated.View>
  );
}

export default memo(ChatBubble);
