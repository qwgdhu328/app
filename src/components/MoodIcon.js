import React from 'react';
import {
  // existing icons reused in mood/face contexts
  HeartIcon, ShieldIcon, SparklesIcon, PenIcon, InfoIcon,
  // new mood/face icons
  SunIcon, FireIcon, CloudRainIcon, HeartPulseIcon, FrownIcon,
  SproutIcon, BoltIcon, SmileConcernIcon, MoonIcon, MehIcon,
} from '../../icons';
import { C } from '../constants/theme';

// Registry of named icon components. New icons should be added here.
const ICON_REGISTRY = {
  shield:        ShieldIcon,
  sparkle:       SparklesIcon,
  sparkles:      SparklesIcon,
  heart:         HeartIcon,
  info:          InfoIcon,
  pen_alt:       PenIcon,
  sun:           SunIcon,
  fire:          FireIcon,
  cloud_rain:    CloudRainIcon,
  heart_pulse:   HeartPulseIcon,
  frown:         FrownIcon,
  sprout:        SproutIcon,
  bolt:          BoltIcon,
  smile_concern: SmileConcernIcon,
  moon:          MoonIcon,
  meh:           MehIcon,
};

/**
 * Resolve an iconName string to an SVG icon component.
 * Falls back to a small Sparkles dot if the name is unknown so the
 * UI never renders a blank space (or worse, a broken emoji).
 *
 * Note: callers control size/colour via props and wrap in a <View> if they
 * need additional layout (marginRight, padding, etc.). The icon components
 * do NOT accept a style prop themselves.
 */
export default function MoodIcon({ name, size = 22, color, filled = false }) {
  const Cmp = ICON_REGISTRY[name] || SparklesIcon;
  // HeartIcon consumes `filled`; other icons simply ignore it.
  return <Cmp size={size} color={color || C.textMuted} filled={filled} />;
}

export { ICON_REGISTRY };
