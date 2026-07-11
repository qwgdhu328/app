import { useRef } from 'react';
import { Pressable, Animated } from 'react-native';
import { M } from '../constants/theme';

/**
 * Pressable wrapper that scales content to 0.96 on press-in and springs back
 * to 1 on press-out. Used for every CTA, chip, and tab to give the app the
 * "modern playfulness" tactile feel.
 *
 * Note: scale uses transform (native driver) so it stays smooth at 60fps
 * even on slower devices.
 */
export default function PressableScale({ children, onPress, style, pressedScale = 0.96, accessibilityLabel, accessibilityRole = 'button', disabled, ...rest }) {
  const scale = useRef(new Animated.Value(1)).current;

  const handleIn = () => {
    Animated.spring(scale, { toValue: pressedScale, ...M.springBounce }).start();
  };
  const handleOut = () => {
    Animated.spring(scale, { toValue: 1, ...M.springIn }).start();
  };

  return (
    <Animated.View style={{ transform: [{ scale }] }}>
      <Pressable
        onPress={onPress}
        onPressIn={handleIn}
        onPressOut={handleOut}
        disabled={disabled}
        accessibilityRole={accessibilityRole}
        accessibilityLabel={accessibilityLabel}
        style={style}
        {...rest}
      >
        {children}
      </Pressable>
    </Animated.View>
  );
}
