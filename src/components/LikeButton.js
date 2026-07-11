import { useEffect, useRef } from 'react';
import { Animated, Pressable, View } from 'react-native';
import { HeartIcon } from '../../icons';
import { C, M } from '../constants/theme';

/**
 * Tap-to-favorite heart button. Used both inline on a bot message in the
 * chat list and on its own in the profile "I miei preferiti" section.
 *
 * Visual: filled coral heart when liked, outline heart when not liked.
 * On toggle the heart scales up briefly (1 → 1.25 → 1) for a delight beat.
 */
export default function LikeButton({ liked, onToggle, size = 22, style, color }) {
  const scale = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    Animated.sequence([
      Animated.timing(scale, { toValue: 1.25, duration: 120, useNativeDriver: true }),
      Animated.spring(scale, { toValue: 1, ...M.springIn }),
    ]).start();
  }, [liked]);

  const tint = color || C.danger;

  return (
    <Pressable
      onPress={(e) => {
        e?.stopPropagation?.();
        onToggle();
      }}
      hitSlop={10}
      accessibilityRole="switch"
      accessibilityState={{ checked: !!liked }}
      accessibilityLabel={liked ? 'Rimuovi dai preferiti' : 'Salva nei preferiti'}
    >
      <Animated.View style={[{ transform: [{ scale }] }, style]}>
        <View style={{ opacity: liked ? 1 : 0.55 }}>
          <HeartIcon size={size} color={tint} filled={liked} />
        </View>
      </Animated.View>
    </Pressable>
  );
}
