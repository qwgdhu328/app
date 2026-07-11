// gps-spoofer-app/src/components/BrandMark.js
//
// BenessereBot brand mark — "Horizon Ember Glow" v5.
//
// Single source of truth for the logo. Renders as a React Native SVG so
// the mark stays crisp at any size and pulls its colors LIVE from
// src/constants/theme.js — a future palette swap on C.primary /
// C.terracotta / C.accent propagates everywhere the BrandMark is used
// without touching individual call sites.
//
// Composition (back to front, matching the procedural PNG generator in
// tools/generate_brand_pngs.py):
//   1. Optional outer ring (variant === 'icon' only) — C.accent at
//      0.5 alpha, strokeWidth = 0.025 × size.
//   2. Rounded-square plate (rx = 0.22 × size) with a diagonal
//      linear gradient C.primary (top-left) → C.terracotta
//      (bottom-right). Favicon variant skips the gradient and uses a
//      solid C.primary fill for ≤48 px legibility.
//   3. Centered white "B" monogram (fontSystem, fontWeight 800,
//      fontSize ≈ 0.58 × size visually). Native font fallback gives
//      a consistently bold but warm feel across iOS / Android / Web.
//   4. Goldenrod accent dot — radius 0.04 × size, positioned at
//      (0.68, 0.68) of the plate (bottom-right quadrant).
//
// Variants:
//   mark     — plate + B + dot. In-app surfaces (intro, future chat
//              header, etc.). No halo.
//   icon     — mark + halo. App icon / splash export.
//   favicon  — solid C.primary (no gradient) + B + dot. ≤48 px target.
//   adaptive — transparent background, just B + dot centered at
//              Android adaptive-icon safe area (66% of the canvas).
//
// API:
//   <BrandMark size={130} variant="mark" />
//   <BrandMark size={1024} variant="icon" />
//   <BrandMark size={48} variant="favicon" />
//   <BrandMark size={1024} variant="adaptive" />

import React, { useRef } from 'react';
import Svg, {
  Defs,
  LinearGradient,
  Stop,
  Rect,
  Text as SvgText,
  Circle,
} from 'react-native-svg';

import { C } from '../constants/theme';

export default function BrandMark({
  size = 96,
  variant = 'mark',
}) {
  // Each BrandMark mount needs a deterministic, instance-unique gradient
  // id so two BrandMark SVGs on the same screen never collide on a
  // shared <Defs> key (react-native-svg defs are document-scoped).
  const gradId = useRef(
    `brandGrad-${variant}-${size}-${Math.random().toString(36).slice(2, 8)}`
  ).current;

  const hasHalo = variant === 'icon';
  const isFlat = variant === 'favicon';
  const isAdaptive = variant === 'adaptive';

  // Boxing — viewBox is 0..100, plate is 6..94 (88 wide), monogram
  // character "B" centered around (50, 56) since uppercase characters
  // sit slightly above the visual midline, and the dot is at (68,68).
  const plateX = 6;
  const plateY = 6;
  const plateW = 88;
  const plateH = 88;
  const plateRx = 22;

  return (
    <Svg width={size} height={size} viewBox="0 0 100 100">
      <Defs>
        {!isFlat && !isAdaptive && (
          <LinearGradient
            id={gradId}
            x1="0"
            y1="0"
            x2="1"
            y2="1"
          >
            <Stop offset="0" stopColor={C.primary} stopOpacity="1" />
            <Stop offset="1" stopColor={C.terracotta} stopOpacity="1" />
          </LinearGradient>
        )}
      </Defs>

      {/* Layer 1 — halo (icon variant only) */}
      {hasHalo && (
        <Circle
          cx="50"
          cy="50"
          r="48"
          fill="none"
          stroke={C.accent}
          strokeOpacity="0.5"
          strokeWidth="2.5"
        />
      )}

      {/* Layer 2 — rounded plate (gradient / flat / absent on adaptive) */}
      {!isAdaptive && (
        <Rect
          x={plateX}
          y={plateY}
          width={plateW}
          height={plateH}
          rx={plateRx}
          fill={
            isFlat
              ? C.primary
              : `url(#${gradId})`
          }
        />
      )}

      {/* Layer 3 — centered "B" monogram in white. RN-SVG maps
          fontWeight="800" to whichever bold variant the platform's
          system font ships, so the visual is consistent on iOS
          (SF Pro Heavy), Android (Roboto Bold), and Web (SF-style
          system fallback). */}
      <SvgText
        x="50"
        y={(isAdaptive ? 54 : 56)}
        fontSize={isAdaptive ? 60 : 58}
        fontWeight="800"
        fontFamily="System"
        fill="#FFFFFF"
        textAnchor="middle"
      >
        B
      </SvgText>

      {/* Layer 4 — accent dot. Position differs between adaptive (a
          touch lower, smaller) and the icon/mark variants (consistent
          bottom-right). */}
      <Circle
        cx={isAdaptive ? 56 : 68}
        cy={isAdaptive ? 70 : 68}
        r={isAdaptive ? 4.5 : 4}
        fill={C.accent}
      />
    </Svg>
  );
}
