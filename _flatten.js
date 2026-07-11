// gps-spoofer-app/_flatten.js — one-shot consolidation script.
// Run from gps-spoofer-app/. Idempotent (overwrites targets on re-run).

const fs = require('fs');
const path = require('path');

// ===== read a source file and strip lines matching any pattern =====
function readStrip(relPath, patterns) {
  let s = fs.readFileSync(relPath, 'utf8');
  if (patterns) {
    for (const p of patterns) {
      s = s.replace(new RegExp(p, 'gm'), '');
    }
  }
  return s.trim();
}

// ===== convert "export default" / "export const" / etc. to internal form =====
function stripDefault(s) {
  s = s.replace(/^export default function /gm, 'function ');
  s = s.replace(/^export default /gm, '');
  s = s.replace(/^export async function /gm, 'async function ');
  s = s.replace(/^export function /gm, 'function ');
  s = s.replace(/^export const /gm, 'const ');
  s = s.replace(/^export class /gm, 'class ');
  return s;
}

// ============================================================
// lib.js — constants + utils + api + stores + components
// ============================================================

const libHeader = [
  '// gps-spoofer-app/lib.js — consolidated core library.',
  '//',
  '// After Phase 2 flattening, the entire src/ tree is collapsed into this',
  '// single file plus screens.js + TabBar.js. The user reported that the',
  '// multi-file layout made debugging slow — 7 root-level files are easier',
  '// to navigate than 30+ files scattered through src/api, src/store,',
  '// src/features/<f>/screens/, etc.',
  '//',
  '// === Section index ===',
  '//  1. THEME CONSTANTS    (C, R, S, T, M, sh, levelColors, emotionColors)',
  '//  2. BOT DATA           (RED_FLAGS, EMOTION_KEYWORDS, TECNICHE)',
  '//  3. MOODS              (MOODS array)',
  '//  4. DATE UTILS         (todayKey, calcStreak, dayBucket, ...)',
  '//  5. IDENTITY UTILS     (accentFor)',
  '//  6. RESPONSIVE UTILS   (BREAKPOINTS, useResponsiveTokens, useScaledValue)',
  '//  7. TEXT UTILS         (cleanupMarkdown, hasRedFlag, isNightMode, ...)',
  '//  8. API PRIMITIVES     (fetchWithTimeout, dedupe)',
  '//  9. STORAGE ADAPTER    (MMKV try/catch + web noop fallback)',
  '// 10. CHAT STORE         (useChatStore)',
  '// 11. MOOD STORE         (useMoodStore)',
  '// 12. USER STORE         (useUserStore)',
  '// 13. CHAT API           (chatWithAI + SYSTEM_PROMPT)',
  '// 14. COMPONENTS         (PressableScale, MoodIcon, LikeButton,',
  '//                         renderRich, ChatBubble, AnimatedDots,',
  '//                         QuickReplies, ErrorBoundary)',
  '',
  "import React, { useEffect, useRef, useState, memo, useCallback } from 'react';",
  "import { Platform, Animated, AccessibilityInfo, View, Text, Pressable, TouchableOpacity, StyleSheet, useWindowDimensions } from 'react-native';",
  "import { create } from 'zustand';",
  "import { createJSONStorage } from 'zustand/middleware';",
  'import {',
  '  HeartIcon, ShieldIcon, SparklesIcon, PenIcon, InfoIcon,',
  '  SunIcon, FireIcon, CloudRainIcon, HeartPulseIcon, FrownIcon,',
  '  SproutIcon, BoltIcon, SmileConcernIcon, MoonIcon, MehIcon,',
  '} from \'./icons\';',
  '',
].join('\n');

const inlineStorageAdapter = [
  '// react-native-mmkv is NATIVE-ONLY — the underlying NativeModule is',
  '// undefined on web, so BACKTICKnew MMKV()BACKTICK throws at module-load time and',
  '// kills the entire JS thread BEFORE React can mount. We detect',
  '// Platform.OS === \'web\' and return a no-op StateStorage so the zustand',
  '// BACKTICKpersistBACKTICK middleware stays happy.',
  'let MMKV;',
  'try {',
  '  MMKV = require(\'react-native-mmkv\').MMKV;',
  '} catch (e) {',
  '  MMKV = null;',
  '}',
  '',
  'const noopStorage = {',
  '  getItem:    () => null,',
  '  setItem:    () => {},',
  '  removeItem: () => {},',
  '};',
  '',
  'const createBbotStorage = () =>',
  '  (Platform.OS === \'web\' || !MMKV) ? noopStorage : new MMKV({ id: \'benesserebot\' });',
].join('\n').replace(/BACKTICK/g, '`');

const libSections = [
  { title: 'THEME CONSTANTS', file: 'src/constants/theme.js' },
  { title: 'BOT DATA', file: 'src/constants/botData.js' },
  { title: 'MOODS', file: 'src/constants/moods.js', strip: ["import \\{ C \\} from '\\./theme';"] },
  { title: 'DATE UTILS', file: 'src/utils/date.js' },
  { title: 'IDENTITY UTILS', file: 'src/utils/identity.js', strip: ["import \\{ C \\} from '\\.\\./constants/theme';"] },
  { title: 'RESPONSIVE UTILS', file: 'src/utils/responsive.js' },
  { title: 'TEXT UTILS', file: 'src/utils/text.js' },
  { title: 'API PRIMITIVES', file: 'src/api/_core.js' },
  { title: 'STORAGE ADAPTER (MMKV + web noop)', inline: inlineStorageAdapter },
  { title: 'CHAT STORE', file: 'src/store/chatStore.js', strip: ["import \\{ create \\} from 'zustand';"] },
  {
    title: 'MOOD STORE',
    file: 'src/store/moodStore.js',
    strip: [
      "import \\{ create \\} from 'zustand';",
      "import \\{ createJSONStorage \\} from 'zustand/middleware';",
      "import \\{ Platform \\} from 'react-native';",
      "import \\{ MMKV \\} from 'react-native-mmkv';",
      "import \\{ todayKey \\} from '\\.\\./utils/date';",
      // Drop the prior local MMKV adapter block (lives in SECTION 9).
      "// === Storage adapter ===[\\s\\S]*?const createBbotStorage = \\(\\) =>\\s*\\(Platform\\.OS === 'web' \\|\\| !MMKV\\) \\? noopStorage : new MMKV\\(\\{ id: 'benesserebot' \\}\\);\\n*",
    ],
  },
  {
    title: 'USER STORE',
    file: 'src/store/userStore.js',
    strip: [
      "import \\{ create \\} from 'zustand';",
      "import \\{ createJSONStorage \\} from 'zustand/middleware';",
      "import \\{ Platform \\} from 'react-native';",
      "import \\{ MMKV \\} from 'react-native-mmkv';",
      "// react-native-mmkv is NATIVE-ONLY[\\s\\S]*?const createBbotStorage = \\(\\) =>\\s*\\(Platform\\.OS === 'web' \\|\\| !MMKV\\) \\? noopStorage : new MMKV\\(\\{ id: 'benesserebot' \\}\\);\\n*",
    ],
  },
  {
    title: 'CHAT API',
    file: 'src/features/chat/api/chatApi.js',
    strip: ["import \\{ fetchWithTimeout, dedupe \\} from '\\.\\.\\/\\.\\.\\/\\.\\./api/_core';"],
  },
  {
    title: 'COMPONENT: PressableScale',
    file: 'src/components/PressableScale.js',
    strip: [
      "import \\{ useRef \\} from 'react';",
      "import \\{ Pressable, Animated \\} from 'react-native';",
      "import \\{ M \\} from '\\.\\./constants/theme';",
    ],
  },
  {
    title: 'COMPONENT: MoodIcon',
    file: 'src/components/MoodIcon.js',
    strip: [
      "import React from 'react';",
      "import \\{[\\s\\S]*?\\} from '\\.\\./\\.\\./icons';",
      "import \\{ C \\} from '\\.\\./constants/theme';",
    ],
  },
  {
    title: 'COMPONENT: LikeButton',
    file: 'src/components/LikeButton.js',
    strip: [
      "import \\{ useEffect, useRef \\} from 'react';",
      "import \\{ Animated, Pressable, View \\} from 'react-native';",
      "import \\{ HeartIcon \\} from '\\.\\./\\.\\./icons';",
      "import \\{ C, M \\} from '\\.\\./constants/theme';",
    ],
  },
  {
    title: 'COMPONENT: RichText (renderRich)',
    file: 'src/components/RichText.js',
    strip: ["import \\{ Text \\} from 'react-native';"],
  },
  {
    title: 'COMPONENT: ChatBubble',
    file: 'src/components/ChatBubble.js',
    strip: [
      "import \\{ useEffect, useRef, useState, memo \\} from 'react';",
      "import \\{ Animated, AccessibilityInfo \\} from 'react-native';",
    ],
  },
  {
    title: 'COMPONENT: AnimatedDots',
    file: 'src/components/AnimatedDots.js',
    strip: [
      "import \\{ useEffect, useRef, useState \\} from 'react';",
      "import \\{ Animated, AccessibilityInfo, View \\} from 'react-native';",
      "import \\{ C, M, R \\} from '\\.\\./constants/theme';",
    ],
  },
  {
    title: 'COMPONENT: QuickReplies',
    file: 'src/components/QuickReplies.js',
    strip: [
      "import \\{ View, Text \\} from 'react-native';",
      "import \\{ C, R, S, sh \\} from '\\.\\./constants/theme';",
      "import PressableScale from '\\./PressableScale';",
    ],
  },
  {
    title: 'COMPONENT: ErrorBoundary',
    file: 'src/components/ErrorBoundary.js',
    strip: [
      "import React from 'react';",
      "import \\{ View, Text, TouchableOpacity, StyleSheet \\} from 'react-native';",
      "import \\{ C \\} from '\\.\\./constants/theme';",
    ],
  },
];

let libBody = '';
for (const sec of libSections) {
  libBody += '\n// ============================================================\n';
  libBody += '// SECTION: ' + sec.title + '\n';
  libBody += '// ============================================================\n\n';
  if (sec.inline) {
    libBody += sec.inline + '\n';
  } else {
    let s = readStrip(sec.file, sec.strip);
    s = stripDefault(s);
    libBody += s + '\n\n';
  }
}

const libFooter = ['', '', '// ============================================================', '// BARREL EXPORT', '// ============================================================', 'export {', '  // constants', '  C, R, S, T, M, sh, levelColors, emotionColors,', '  RED_FLAGS, EMOTION_KEYWORDS, TECNICHE, MOODS,', '  // utils — date', '  todayKey, dayDiff, addDays, calcStreak, dayBucket, dayLabel, isLastAssistant,', '  // utils — identity', '  accentFor,', '  // utils — responsive', '  BREAKPOINTS, REFERENCE_WIDTH, useResponsiveTokens, useScaledValue,', '  // utils — text', '  cleanupMarkdown, hasRedFlag, isNightMode, getGreeting, detectEmotion,', '  // api primitives', '  fetchWithTimeout, dedupe,', '  // api domain', '  chatWithAI,', '  // stores', '  useChatStore, useMoodStore, useUserStore,', '  // components', '  PressableScale, MoodIcon, ICON_REGISTRY, LikeButton, renderRich,', '  ChatBubble, AnimatedDots, QuickReplies, ErrorBoundary,', '};', ''].join('\n');

const libOut = libHeader + libBody + libFooter;
fs.writeFileSync('lib.js', libOut);
console.log('wrote lib.js: ' + libOut.length + ' bytes, ' + libOut.split('\n').length + ' lines');

// ============================================================
// screens.js — the 6 screen components
// ============================================================

const screensHeader = [
  '// gps-spoofer-app/screens.js — all 6 screen components in one file.',
  '//',
  '// The 6 screens were scattered across src/features/<f>/screens/*.js in',
  '// Phase 0.C. Collapsed here for easier debugging. Each screen is a',
  '// top-level function (no default export) — the barrel at the bottom',
  '// re-exports them so App.js does:',
  '//   import { IntroScreen, HomeScreen, ... } from \'./screens\';',
  '',
  "import React, { useRef, useEffect, useState, useMemo, useCallback } from 'react';",
  "import { StyleSheet, View, Text, Animated, ScrollView, FlatList, TextInput, ActivityIndicator, KeyboardAvoidingView, Alert } from 'react-native';",
  'import {',
  '  StreakIcon, PenIcon, SparklesIcon, InfoIcon,',
  '  SendIcon, LockIcon, HeartIcon, ShieldIcon, BackIcon,',
  '} from \'./icons\';',
  'import {',
  '  C, R, S, T, sh, levelColors, MOODS,',
  '  todayKey, addDays, calcStreak, dayBucket, dayLabel, isLastAssistant, accentFor, getGreeting,',
  '  useUserStore, useMoodStore, useChatStore,',
  '  MoodIcon, PressableScale, LikeButton, QuickReplies, renderRich, ChatBubble, AnimatedDots,',
  '} from \'./lib\';',
  '',
].join('\n');

const screenFiles = [
  { title: 'IntroScreen', file: 'src/features/intro/screens/IntroScreen.js' },
  { title: 'HomeScreen', file: 'src/features/home/screens/HomeScreen.js' },
  { title: 'ChatScreen', file: 'src/features/chat/screens/ChatScreen.js' },
  { title: 'ProfileScreen', file: 'src/features/profile/screens/ProfileScreen.js' },
  { title: 'CommunityScreen', file: 'src/features/community/screens/CommunityScreen.js' },
  { title: 'InfoScreen', file: 'src/features/info/screens/InfoScreen.js' },
];

// Strip patterns common to all screens (inter-file imports)
const screenStripCommon = [
  "import React(?:, \\{ useRef, useEffect \\}|, \\{ useState, useRef, useEffect \\}|, \\{ useState \\})? from 'react';",
  "import \\{[^}]*\\} from 'react-native';",
  "import \\{ C, R, S, T, sh(?:, levelColors)? \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/constants/theme';",
  "import \\{ MOODS \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/constants/moods';",
  "import \\{ useUserStore \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/store/userStore';",
  "import \\{ useMoodStore \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/store/moodStore';",
  "import \\{ useChatStore \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/store/chatStore';",
  "import \\{ todayKey(?:, addDays(?:, calcStreak)?)?(?:, dayBucket, dayLabel, isLastAssistant)? \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/utils/date';",
  "import \\{ accentFor \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/utils/identity';",
  "import \\{ getGreeting \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/\\.\\.\\/\\.\\.\\/src/utils/text';",
  "import MoodIcon from '\\.\\.\\/\\.\\.\\/\\.\\.\\/components/MoodIcon';",
  "import PressableScale from '\\.\\.\\/\\.\\.\\/\\.\\.\\/components/PressableScale';",
  "import LikeButton from '\\.\\.\\/\\.\\.\\/\\.\\.\\/components/LikeButton';",
  "import \\{ renderRich \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/components/RichText';",
  "import ChatBubble from '\\.\\.\\/\\.\\.\\/\\.\\.\\/components/ChatBubble';",
  "import AnimatedDots from '\\.\\.\\/\\.\\.\\/\\.\\.\\/components/AnimatedDots';",
  "import QuickReplies from '\\.\\.\\/\\.\\.\\/\\.\\.\\/components/QuickReplies';",
  "import \\{ StreakIcon, PenIcon, SparklesIcon, InfoIcon, SendIcon, LockIcon, HeartIcon, ShieldIcon, BackIcon \\} from '\\.\\.\\/\\.\\.\\/\\.\\.\\/\\.\\.\\/icons';",
];

let screensBody = '';
for (const s of screenFiles) {
  screensBody += '// ============================================================\n';
  screensBody += '// SCREEN: ' + s.title + '\n';
  screensBody += '// ============================================================\n\n';
  let content = readStrip(s.file, screenStripCommon);
  content = stripDefault(content);
  screensBody += content + '\n\n';
}

const screensFooter = ['', '', '// ============================================================', '// BARREL EXPORT', '// ============================================================', 'export { IntroScreen, HomeScreen, ChatScreen, ProfileScreen, CommunityScreen, InfoScreen };', ''].join('\n');

const screensOut = screensHeader + screensBody + screensFooter;
fs.writeFileSync('screens.js', screensOut);
console.log('wrote screens.js: ' + screensOut.length + ' bytes, ' + screensOut.split('\n').length + ' lines');

// ============================================================
// TabBar.js — moved from src/navigation/ to root
// ============================================================
let tabBar = readStrip('src/navigation/TabBar.js', null);
tabBar = tabBar.replace(/from '\.\.\/\.\.\/icons';/g, "from './icons';");
tabBar = tabBar.replace(/from '\.\.\/constants\/theme';/g, "from './lib';");
tabBar = tabBar.replace(/from '\.\.\/components\/PressableScale';/g, "from './lib';");

fs.writeFileSync('TabBar.js', tabBar);
console.log('wrote TabBar.js: ' + tabBar.length + ' bytes, ' + tabBar.split('\n').length + ' lines');

console.log('=== consolidation done ===');
