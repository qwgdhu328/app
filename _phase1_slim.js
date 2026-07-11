const fs = require('fs');
let src = fs.readFileSync('App.js', 'utf8');
const linesCount = src.split('\n').length;
console.log('=== Phase 1 App.js slim ===');
console.log('initial lines:', linesCount);

// === EDIT 1: update imports block ===
const oldImportsStart = "import React, { useState, useCallback, useRef, useEffect, useMemo } from 'react';";
const oldImportsEnd = "import InfoScreen from './src/features/info/screens/InfoScreen';";
const startIdx = src.indexOf(oldImportsStart);
const endIdx = src.indexOf(oldImportsEnd);
if (startIdx === -1 || endIdx === -1) throw new Error('EDIT 1 anchors not found');
const endOfImportsBlock = endIdx + oldImportsEnd.length;

const newImports = `import React, { useState, useCallback, useRef, useEffect, useMemo } from 'react';
import {
  StyleSheet, Text, View, Alert, Platform, KeyboardAvoidingView,
} from 'react-native';
// SafeAreaView intentionally imported from react-native-safe-area-context
// (not from 'react-native') so it sources its padding from the
// SafeAreaProvider the index.js wraps <App /> in. RN's built-in
// SafeAreaView only reads iOS's UIEdgeInsets natively — on Android it
// ran off StatusBar.currentHeight, which doesn't reflect real gesture /
// notch cutouts on edge-to-edge OEMs. With this import the top status
// bar gets correct padding on both platforms.
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { chatWithAI } from './src/features/chat/api/chatApi';
import { useChatStore } from './src/store/chatStore';
import { useMoodStore } from './src/store/moodStore';
import { useUserStore } from './src/store/userStore';
import { calcStreak } from './src/utils/date';
import FreeWriteScreen from './FreeWriteScreen';
import { TECNICHE } from './src/constants/botData';
import { cleanupMarkdown, hasRedFlag, isNightMode } from './src/utils/text';

// === Phase 1: navigation + api extracted ===
// - TabBar (with TabIconRenderer + tabStyles) → src/navigation/TabBar.js
// - chatWithAI (with SYSTEM_PROMPT) → src/features/chat/api/chatApi.js
// - fetchWithTimeout + dedupe primitives → src/api/_core.js
// App.js is now a thin root: 3 nav useState + store hooks + chat-lifecycle
// handlers (sendMessage, acceptConsent, handleDeepDive, resetChat,
// handleQuickPick) + screen routing.

import IntroScreen from './src/features/intro/screens/IntroScreen';
import HomeScreen from './src/features/home/screens/HomeScreen';
import ChatScreen from './src/features/chat/screens/ChatScreen';
import ProfileScreen from './src/features/profile/screens/ProfileScreen';
import CommunityScreen from './src/features/community/screens/CommunityScreen';
import InfoScreen from './src/features/info/screens/InfoScreen';
import TabBar from './src/navigation/TabBar';`;

src = src.slice(0, startIdx) + newImports + '\n' + src.slice(endOfImportsBlock);
console.log('EDIT 1: imports block updated');

// === EDIT 2: drop the TABS const ===
const tabsMarker = "// === Module-level constants ===\n// \`TABS\` stays module-level because TabBar (defined further down)\n// references it directly. Navigation is a single-instance App-route\n// concern so the active-tab key decoding lives here, not in a store.\n\nconst TABS = [\n  { key: 'home',       icon: HomeIcon,    label: 'Home' },\n  { key: 'chat',       icon: ChatIcon,    label: 'Chat' },\n  { key: 'community',  icon: InfoIcon,    label: 'Spazio' },\n  { key: 'profile',    icon: ProfileIcon, label: 'Tu' },\n];\n";
if (!src.includes(tabsMarker)) throw new Error('EDIT 2 TABS marker not found');
src = src.replace(tabsMarker, '');
console.log('EDIT 2: TABS const dropped');

// === EDIT 3: drop TabBar function (brace-matched) ===
function dropFunction(name) {
  const funcStart = src.indexOf('\nfunction ' + name + '(');
  if (funcStart === -1) throw new Error('function ' + name + ' start not found');
  let dividerStart = src.lastIndexOf('// ───', funcStart);
  if (dividerStart === -1) throw new Error('no divider before ' + name);
  const lineStart = src.lastIndexOf('\n', dividerStart - 1) + 1;
  let depth = 0, endIdx = -1;
  for (let i = funcStart; i < src.length; i++) {
    if (src[i] === '{') depth++;
    else if (src[i] === '}') { depth--; if (depth === 0) { endIdx = i + 1; break; } }
  }
  if (endIdx === -1) throw new Error('no matching } for ' + name);
  src = src.slice(0, lineStart) + src.slice(endIdx);
}
dropFunction('TabBar');
console.log('EDIT 3: TabBar function dropped');
dropFunction('TabIconRenderer');
console.log('EDIT 4: TabIconRenderer function dropped');

// === EDIT 5: drop tabStyles StyleSheet (brace-matched) ===
const tabStylesStart = src.indexOf('\nconst tabStyles = StyleSheet.create({');
if (tabStylesStart === -1) throw new Error('EDIT 5 tabStyles not found');
let tsDepth = 0, tsEnd = -1, tsStarted = false;
for (let i = tabStylesStart; i < src.length; i++) {
  if (src[i] === '{') { tsDepth++; tsStarted = true; }
  else if (src[i] === '}') {
    tsDepth--;
    if (tsStarted && tsDepth === 0) { tsEnd = i + 2; break; }
  }
}
if (tsEnd === -1) throw new Error('tabStyles brace count failed');
let tsDividerStart = src.lastIndexOf('// ───', tabStylesStart);
if (tsDividerStart !== -1) {
  const tsLineStart = src.lastIndexOf('\n', tsDividerStart - 1) + 1;
  src = src.slice(0, tsLineStart) + src.slice(tsEnd);
} else {
  src = src.slice(0, tabStylesStart) + src.slice(tsEnd);
}
console.log('EDIT 5: tabStyles StyleSheet dropped');

// === EDIT 6: update file banner comment ===
const oldBanner = `// gps-spoofer-app/App.js — Phase 0.C slim root component.
//
// === Phase 0.A → 0.C arc ===
// After extracting 6 inline screens to src/features/<feature>/screens/*.js
// in Phase 0.C, App.js is now a thin navigation root + chat lifecycle owner:
//
//   - Local route state (activeTab, showFreeWrite, showIntro) stays here
//     because the route is a single-instance concern, not domain state.
//   - 9 chatStore selectors + 4 moodStore + 4 userStore selectors are
//     read with granular selectors here ONLY for prop drilling to the
//     SharedTabBar (TabBar needs streak/currentLevel) and for the few
//     chat-lifecycle handlers (sendMessage, acceptConsent, resetChat,
//     handleQuickPick, handleDeepDive) that App.js owns because they
//     cross screen boundaries (chat lifecycle, network). The screens
//     consume stores directly themselves — no prop drilling gone to
//     waste.
//   - All UI rendering of Home / Chat / Profile / Community / Info is
//     delegated to extracted feature screens that consume their own
//     store slices. TabBar's body has duplicates of the original inline
//     app shell styles here because it's still in App.js (Phase 0.D)
//     will extract TabBar to a feature folder.`;
const newBanner = `// gps-spoofer-app/App.js — Phase 1 thin root component.
//
// === Phase 0.A → 1 arc ===
// After three rounds of extraction, App.js is now a thin root that owns
// only what genuinely can't move out: the 3 nav useState, the zustand
// selectors the routing needs, and the chat-lifecycle handlers
// (sendMessage, acceptConsent, handleDeepDive, resetChat,
// handleQuickPick) that cross screen boundaries.
//
// What lives elsewhere now:
//   - 6 screens (Home/Chat/Profile/Community/Info/Intro) → src/features/<feature>/screens/*.js
//   - TabBar + TabIconRenderer + tabStyles → src/navigation/TabBar.js
//   - chatWithAI + SYSTEM_PROMPT → src/features/chat/api/chatApi.js
//   - fetchWithTimeout + dedupe primitives → src/api/_core.js
//   - accentFor helper → src/utils/identity.js
//   - date utilities → src/utils/date.js
//   - MOODS constant → src/constants/moods.js
//
// Remaining sendMessage body (165 lines) extracts to a useChatLogic
// hook in a future Phase 1.1 — keeping it here is intentional so the
// phase focuses on the navigation + api split.`;
if (!src.includes(oldBanner)) throw new Error('EDIT 6 banner not found');
src = src.replace(oldBanner, newBanner);
console.log('EDIT 6: banner comment updated to Phase 1');

fs.writeFileSync('App.js', src);
const finalLines = src.split('\n')
