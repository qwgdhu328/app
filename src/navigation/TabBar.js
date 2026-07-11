import React from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import { BlurView } from 'expo-blur';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { C } from '../constants/theme';
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
    <View style={[styles.wrapper, { paddingBottom: insets.bottom + 8 }]}>
      <BlurView intensity={60} tint="dark" style={styles.glass}>
        <View style={styles.inner}>
          {TABS.map(({ key, icon: Icon, label }) => {
            const active = activeTab === key;
            return (
              <PressableScale key={key} onPress={() => handlePress(key)} style={styles.tab} scaleTo={0.88}>
                <View style={[styles.iconWrap, active && styles.iconWrapActive]}>
                  <Icon active={active} />
                </View>
                <Text style={[styles.label, active && styles.labelActive]}>
                  {label}
                </Text>
              </PressableScale>
            );
          })}
        </View>
      </BlurView>
    </View>
  );
}

const TAB_BAR_HEIGHT = 50;
const ICON_SIZE = 24;

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    bottom: 0,
    left: 12,
    right: 12,
    zIndex: 100,
  },
  glass: {
    borderRadius: 28,
    overflow: 'hidden',
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: 'rgba(255,255,255,0.12)',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.4,
        shadowRadius: 24,
      },
    }),
  },
  inner: {
    flexDirection: 'row',
    height: TAB_BAR_HEIGHT,
    alignItems: 'center',
    backgroundColor: 'rgba(26, 15, 20, 0.15)',
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    height: TAB_BAR_HEIGHT,
    gap: 2,
  },
  iconWrap: {
    width: ICON_SIZE + 8,
    height: ICON_SIZE + 8,
    borderRadius: (ICON_SIZE + 8) / 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconWrapActive: {
    backgroundColor: 'rgba(255, 107, 85, 0.15)',
  },
  label: {
    fontSize: 10,
    color: C.textMuted,
    letterSpacing: 0.3,
    fontWeight: '500',
  },
  labelActive: {
    color: C.primary,
    fontWeight: '700',
  },
});
