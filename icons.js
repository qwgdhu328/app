import React from 'react';
import Svg, { Path, Circle, Rect, Line } from 'react-native-svg';
import { C } from './src/constants/theme';

// Stroke width adjusted to 2.4 for a chunkier, more playful look.
// Active color stays electric lime so nav icons pop on the dark bg.

const w = 2.4;

export function HomeIcon({ active }) {
  const c = active ? C.primary : C.textMuted;
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Path d="M3 12L12 3L21 12" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M5 10V20H19V10" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M9 20V14H15V20" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Rect x={10.5} y={16} width={3} height={2.5} fill={c} />
    </Svg>
  );
}

export function ChatIcon({ active }) {
  const c = active ? C.primary : C.textMuted;
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Path d="M21 12C21 16.9706 16.9706 21 12 21C10.5 21 9.5 20.8 8 20L3 21L4 16C3.3 14.7 3 13.4 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Circle cx={8.5}  cy={12} r={1.4} fill={c} />
      <Circle cx={12}   cy={12} r={1.4} fill={c} />
      <Circle cx={15.5} cy={12} r={1.4} fill={c} />
    </Svg>
  );
}

export function ProfileIcon({ active }) {
  const c = active ? C.primary : C.textMuted;
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={8} r={4} stroke={c} strokeWidth={w} />
      <Path d="M4 21C4 17 8 14 12 14C16 14 20 17 20 21" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

export function PenIcon({ color }) {
  const c = color || C.accent;
  return (
    <Svg width={22} height={22} viewBox="0 0 24 24" fill="none">
      <Path d="M17 3C17.5 2.5 18.5 2.5 19 3L21 5C21.5 5.5 21.5 6.5 21 7L8 20L3 21L4 16L17 3Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M14 6L18 10" stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

export function HeartIcon({ size = 22, color, filled = false }) {
  const c = color || C.danger;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? c : 'none'}>
      <Path
        d="M12 21C12 21 3 14.5 3 8.5C3 5.5 5.4 3 8.4 3C10 3 11.3 3.9 12 5C12.7 3.9 14 3 15.6 3C18.6 3 21 5.5 21 8.5C21 14.5 12 21 12 21Z"
        stroke={c}
        strokeWidth={w}
        strokeLinejoin="round"
      />
    </Svg>
  );
}

export function StreakIcon({ size = 16, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M12 2C12 2 5 9 5 14C5 18 8 21 12 21C16 21 19 18 19 14C19 9 12 2 12 2Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M9 14C9.5 15.5 10.7 16 12 16.5" stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

export function ArrowRight() {
  return (
    <Svg width={18} height={18} viewBox="0 0 24 24" fill="none">
      <Path d="M5 12H19M19 12L13 6M19 12L13 18" stroke={C.textMuted} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

export function StarIcon() {
  return (
    <Svg width={22} height={22} viewBox="0 0 24 24" fill="none">
      <Path d="M12 2L15 9H22L16 14L18 21L12 17L6 21L8 14L2 9H9L12 2Z" stroke={C.primary} strokeWidth={w} strokeLinejoin="round" />
    </Svg>
  );
}

export function InfoIcon() {
  return (
    <Svg width={22} height={22} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={9} stroke={C.accent} strokeWidth={w} />
      <Path d="M12 8V12M12 16H12.01" stroke={C.accent} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

export function BreathIcon() {
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Path d="M3 12C3 12 5 8 8 8C11 8 12 12 12 12C12 12 13 16 16 16C19 16 21 12 21 12" stroke={C.primary} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

export function MindIcon() {
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={6} stroke={C.accent} strokeWidth={w} />
      <Path d="M12 9V12L14 14" stroke={C.accent} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

export function WriteIcon() {
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Rect x={4} y={4} width={16} height={16} rx={3} stroke={C.primary} strokeWidth={w} />
      <Line x1={8}  y1={9}  x2={16} y2={9}  stroke={C.primary} strokeWidth={w} strokeLinecap="round" />
      <Line x1={8}  y1={13} x2={14} y2={13} stroke={C.primary} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

export function CalmIcon() {
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Path d="M12 3C7 3 4 7 4 12C4 17 7 21 12 21C17 21 20 17 20 12" stroke={C.primary} strokeWidth={w} strokeLinecap="round" />
      <Circle cx={9}  cy={11} r={1.5} fill={C.primary} />
      <Circle cx={15} cy={11} r={1.5} fill={C.primary} />
      <Path d="M9 16C10 17 11 17.5 12 17.5C13 17.5 14 17 15 16" stroke={C.primary} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

export function BackIcon() {
  return (
    <Svg width={22} height={22} viewBox="0 0 24 24" fill="none">
      <Path d="M19 12H5M5 12L11 18M5 12L11 6" stroke={C.accent} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

export function LockIcon() {
  return (
    <Svg width={56} height={56} viewBox="0 0 24 24" fill="none">
      <Rect x={5} y={11} width={14} height={10} rx={3} stroke={C.textMuted} strokeWidth={w} />
      <Path d="M8 11V8C8 5.8 9.8 4 12 4C14.2 4 16 5.8 16 8V11" stroke={C.textMuted} strokeWidth={w} strokeLinecap="round" />
      <Circle cx={12} cy={16} r={1.6} fill={C.primary} />
    </Svg>
  );
}

// ────────────────────────────────────────────────────────────────────────────
//  New icons (added to fill UI gaps: chat send, shield, AI sparkle, etc.)
//  All accept { size, color } with theme defaults; some accept { active }.
// ────────────────────────────────────────────────────────────────────────────

// Paper plane, used for the chat send button.
export function SendIcon({ size = 22, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M3 11L21 3L13 21L11 13L3 11Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M11 13L21 3"  stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Heraldic shield with a checkmark — replaces text-only safety badges.
export function ShieldIcon({ size = 17, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M12 3L5 6V11C5 16 8 19 12 21C16 19 19 16 19 11V6L12 3Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M9 12L11 14L15 10" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// Two four-point sparkles for AI / welcome / quick-replies tone.
export function SparklesIcon({ size = 18, color }) {
  const c = color || C.accent;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M11 3L12.5 8.5L18 10L12.5 11.5L11 17L9.5 11.5L4 10L9.5 8.5L11 3Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M18 15L18.7 17.3L21 18L18.7 18.7L18 21L17.3 18.7L15 18L17.3 17.3L18 15Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// Triangle warning + exclamation — for red-flag, consent declined, errors.
export function WarningIcon({ size = 20, color }) {
  const c = color || C.danger;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M12 3L21 19H3L12 3Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M12 10V14" stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Circle cx={12} cy={17} r={1.2} fill={c} />
    </Svg>
  );
}

// Stylised handset — for emergency contact, /call SOS actions.
// Split into outer shell + inner curl detail for cleaner geometry.
export function PhoneIcon({ size = 20, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M5 4L9.5 7.4L17.8 15.6L19 18C18.7 19.3 17 21 12 21C7 21 3 17 3 12C3 5.7 5 4 5 4Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M9.5 7.4L9.7 9.2C10.2 11 11.8 12.8 13.6 13.3L17.8 15.6" stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Open book with center spine — for FreeWrite / journal screens.
export function BookIcon({ size = 24, color }) {
  const c = color || C.accent;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M4 4.5C4 4.5 6 3.5 12 3.5C18 3.5 20 4.5 20 4.5V19.5C20 19.5 18 18.5 12 18.5C6 18.5 4 19.5 4 19.5V4.5Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Line x1={12} y1={3.5} x2={12} y2={18.5} stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Calendar grid with top binding rings — for streak timeline / mood history.
export function CalendarIcon({ size = 20, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Rect x={3} y={5} width={18} height={16} rx={2.5} stroke={c} strokeWidth={w} />
      <Line x1={3} y1={10} x2={21} y2={10} stroke={c} strokeWidth={w} />
      <Line x1={8} y1={3}  x2={8}  y2={7} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={16} y1={3} x2={16} y2={7} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Circle cx={8}  cy={14} r={1} fill={c} />
      <Circle cx={12} cy={14} r={1} fill={c} />
      <Circle cx={16} cy={14} r={1} fill={c} />
      <Circle cx={8}  cy={18} r={1} fill={c} />
    </Svg>
  );
}

// Two segmented circular arrows — for "new chat", reset, retry.
export function RefreshIcon({ size = 20, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M20 11C19 7 16 4 12 4C8 4 4.5 7 4 12" stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Path d="M4 13C5 17 8 20 12 20C16 20 19.5 17 20 12" stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Path d="M4 7V12H9"   stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M20 17V12H15" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// Bold checkmark in a soft circle — for confirmed / pinned / acknowledged states.
export function CheckIcon({ size = 18, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={9.5} stroke={c} strokeWidth={w} />
      <Path d="M7.5 12.5L10.5 15.5L16.5 9" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// Ringing bell with base tongue — for reminders, streak alerts.
export function BellIcon({ size = 20, color }) {
  const c = color || C.accent;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M6 17C6 13 6.2 9 12 9C17.8 9 18 13 18 17H6Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M10 20C10 21 11 21.5 12 21.5C13 21.5 14 21 14 20" stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={12} y1={6} x2={12} y2={9} stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Gear with eight spokes — generic settings.
export function SettingsIcon({ size = 20, color }) {
  const c = color || C.textMuted;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={3.2} stroke={c} strokeWidth={w} />
      <Line x1={12} y1={3.5}  x2={12} y2={6.5}  stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={12} y1={17.5} x2={12} y2={20.5} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={3.5}  y1={12} x2={6.5}  y2={12} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={17.5} y1={12} x2={20.5} y2={12} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={5.6}  y1={5.6}  x2={7.7}  y2={7.7}  stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={16.3} y1={16.3} x2={18.4} y2={18.4} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={18.4} y1={5.6}  x2={16.3} y2={7.7}  stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={7.7}  y1={16.3} x2={5.6}  y2={18.4} stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Bookmark tab — for "pinned technique", saved messages slot.
export function BookmarkIcon({ size = 18, color, filled = false }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? c : 'none'}>
      <Path d="M6 4.5C6 3.5 7 3 8 3H16C17 3 18 3.5 18 4.5V20.5L12 16.8L6 20.5V4.5Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// ────────────────────────────────────────────────────────────────────────────
//  Mood / emotion / community icons — used by MoodIcon renderer.
// ────────────────────────────────────────────────────────────────────────────

// Radiant sun — joy, "great" mood, community 🌱 story #2.
export function SunIcon({ size = 22, color }) {
  const c = color || C.primary;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={4.5} stroke={c} strokeWidth={w} />
      <Line x1={12}   y1={2}    x2={12}   y2={5}    stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={12}   y1={19}   x2={12}   y2={22}   stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={2}    y1={12}   x2={5}    y2={12}   stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={19}   y1={12}   x2={22}   y2={12}   stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={4.5}  y1={4.5}  x2={6.6}  y2={6.6}  stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={17.4} y1={17.4} x2={19.5} y2={19.5} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={19.5} y1={4.5}  x2={17.4} y2={6.6}  stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={6.6}  y1={17.4} x2={4.5}  y2={19.5} stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Single flame — anger/rabbia mood.
export function FireIcon({ size = 22, color }) {
  const c = color || C.terracotta;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M12 3C9 6 7 8 7 12C7 16 9 19 12 21C15 19 17 16 17 12.5C17 10 15 8 12 3Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M9.5 14C10 15.5 11 16.5 12 17" stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Cloud with three droplets — sadness / low mood.
export function CloudRainIcon({ size = 22, color }) {
  const c = color || C.sky;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M7 15C5 15 3 13 3 11C3 8.5 5 7 7 7.5C7.5 5.5 9.5 4 12 4C14.5 4 16.5 5.5 17 7.5C19 7.5 21 9 21 11C21 13 19 15 17 15H7Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Line x1={8}  y1={17} x2={7}  y2={20} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={12} y1={17} x2={11} y2={21} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Line x1={16} y1={17} x2={15} y2={20} stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Heart + ECG pulse — anxiety.
export function HeartPulseIcon({ size = 22, color }) {
  const c = color || C.accent;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M2 9L6 9L8 5L10 13L12 9H15L17 11L20 9H22" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M12 21C12 21 4 16 4 11C4 8 5.5 6 8 6C9.5 6 11 7 12 8.5C13 7 14.5 6 16 6C18.5 6 20 8 20 11C20 16 12 21 12 21Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// Face with downward-curved mouth — disgust / strong uneasiness.
export function FrownIcon({ size = 22, color }) {
  const c = color || C.terracotta;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={9} stroke={c} strokeWidth={w} />
      <Circle cx={9}  cy={10} r={1.2} fill={c} />
      <Circle cx={15} cy={10} r={1.2} fill={c} />
      <Path d="M8.5 16.5C10 15 14 15 15.5 16.5" stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Two-leaf seedling on a ground line — community growth story.
export function SproutIcon({ size = 22, color }) {
  const c = color || C.sage;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Line x1={12} y1={22} x2={12} y2={13} stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Path d="M12 13C12 9 8.5 7 5.5 7C5.5 11 8.5 13 12 13Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M12 13C12 9 15.5 7 18.5 7C18.5 11 15.5 13 12 13Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Line x1={6} y1={22} x2={18} y2={22} stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Lightning bolt — energy / strength (community 💬 story).
export function BoltIcon({ size = 22, color }) {
  const c = color || C.amber;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M13 3L5 13H10L9 21L17 11H12L13 3Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// Face with mild upward mouth + flat eyes — slight concern / soft surprise (community 😬).
export function SmileConcernIcon({ size = 22, color }) {
  const c = color || C.accent;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={9} stroke={c} strokeWidth={w} />
      <Circle cx={9}  cy={10} r={1.2} fill={c} />
      <Circle cx={15} cy={10} r={1.2} fill={c} />
      <Path d="M9 16.5C10.5 16 13.5 16 15 16.5" stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Crescent moon — tiredness / rest.
export function MoonIcon({ size = 22, color }) {
  const c = color || C.accent;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M21 14C19 17.5 15.5 19.5 12 19.5C8 19.5 4.5 16.5 4 12.5C7 13 10 11 12 8C13 6 13 4 12 3C16 3 19.5 6 20.5 10C21 11.5 21 13 21 14Z" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

// Neutral face with a straight mouth — "meh" / feeling nothing.
export function MehIcon({ size = 22, color }) {
  const c = color || C.amber;
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={9} stroke={c} strokeWidth={w} />
      <Circle cx={9}  cy={10} r={1.2} fill={c} />
      <Circle cx={15} cy={10} r={1.2} fill={c} />
      <Line x1={9} y1={16} x2={15} y2={16} stroke={c} strokeWidth={w} strokeLinecap="round" />
    </Svg>
  );
}

// Globe — community / Spazio tab.
export function GlobeIcon({ active }) {
  const c = active ? C.primary : C.textMuted;
  return (
    <Svg width={26} height={26} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={12} r={9} stroke={c} strokeWidth={w} />
      <Path d="M3 12H21" stroke={c} strokeWidth={w} strokeLinecap="round" />
      <Path d="M12 3C14 5 15 8 15 12C15 16 14 19 12 21" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
      <Path d="M12 3C10 5 9 8 9 12C9 16 10 19 12 21" stroke={c} strokeWidth={w} strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}
