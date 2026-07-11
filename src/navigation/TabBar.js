import React from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import { BlurView } from 'expo-blur';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
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

  return (
    <View style={[styles.wrapper, { paddingBottom: insets.bottom + 4 }]}>
      <BlurView intensity={80} tint="dark" style={styles.blur}>
        <View style={styles.inner}>
          {TABS.map(({ key, icon: Icon, label }) => {
            const active = activeTab === key;
            return (
              <PressableScale key={key} onPress={() => onTabPress(key)} style={styles.tab}>
                <View style={[styles.indicator, active && styles.indicatorActive]} />
                <Icon active={active} />
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

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    zIndex: 100,
  },
  blur: {
    overflow: 'hidden',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: 'rgba(255,255,255,0.08)',
  },
  inner: {
    flexDirection: 'row',
    paddingTop: 6,
    paddingBottom: 2,
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 4,
    gap: 2,
  },
  indicator: {
    width: 20,
    height: 2,
    borderRadius: 1,
    backgroundColor: 'transparent',
    marginBottom: 2,
  },
  indicatorActive: {
    backgroundColor: C.primary,
  },
  label: {
    fontSize: 10,
    color: C.textMuted,
    letterSpacing: 0.3,
  },
  labelActive: {
    color: C.primary,
    fontWeight: '600',
  },
});
