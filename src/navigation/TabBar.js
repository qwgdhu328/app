import React, { useRef } from 'react';
import { View, Text, StyleSheet, Animated, Platform } from 'react-native';
import { BlurView } from 'expo-blur';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { C, R, S } from '../constants/theme';
import { HomeIcon, ChatIcon, GlobeIcon, ProfileIcon } from '../../icons';
import PressableScale from '../components/PressableScale';

const TABS = [
  { key: 'home',      icon: HomeIcon,    label: 'Home' },
  { key: 'chat',      icon: ChatIcon,    label: 'Chat' },
  { key: 'community', icon: GlobeIcon,   label: 'Spazio' },
  { key: 'profile',   icon: ProfileIcon, label: 'Tu' },
];

export default function TabBar({ activeTab, onTabPress }) {
  const insets = useSafeAreaInsets();

  const handlePress = (key) => {
    if (key !== activeTab) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
    }
    onTabPress(key);
  };

  return (
    <View style={[styles.wrapper, { paddingBottom: insets.bottom + 6 }]}>
      <BlurView intensity={90} tint="dark" style={styles.blur}>
        <View style={styles.inner}>
          {TABS.map(({ key, icon: Icon, label }) => {
            const active = activeTab === key;
            return (
              <PressableScale key={key} onPress={() => handlePress(key)} style={styles.tab} scaleTo={0.92}>
                <View style={styles.iconWrap}>
                  <Icon active={active} />
                </View>
                <Text style={[styles.label, active && styles.labelActive]}>
                  {label}
                </Text>
                {active && <View style={styles.dot} />}
              </PressableScale>
            );
          })}
        </View>
      </BlurView>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    bottom: 0,
    left: 8,
    right: 8,
    zIndex: 100,
  },
  blur: {
    borderRadius: 24,
    overflow: 'hidden',
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: 'rgba(255,255,255,0.1)',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -2 },
        shadowOpacity: 0.3,
        shadowRadius: 12,
      },
    }),
  },
  inner: {
    flexDirection: 'row',
    paddingTop: 8,
    paddingBottom: 6,
    backgroundColor: 'rgba(26, 15, 20, 0.2)',
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 2,
    gap: 1,
  },
  iconWrap: {
    width: 28,
    height: 28,
    alignItems: 'center',
    justifyContent: 'center',
  },
  dot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: C.primary,
    marginTop: 1,
  },
  label: {
    fontSize: 10,
    color: C.textMuted,
    letterSpacing: 0.2,
    marginTop: 1,
  },
  labelActive: {
    color: C.primary,
    fontWeight: '700',
  },
});
