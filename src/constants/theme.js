// Theme tokens for BenessereBot v5 — "Horizon Ember Glow".
//
// Single source of truth for colours, radii, spacing, motion, and shadow
// presets. Import from any component instead of redeclaring locally.
//
// Palette shift from v4 (electric lime #C6FF4D + violet #B084FF on deep
// charcoal) to v5 (coral mango + goldenrod on deep aubergine). All
// legacy semantic keys are preserved (primary, accent, sage, terracotta,
// amber, danger, sky, rose) so existing imports continue to resolve —
// only the colour values change.
//
// Mood axis rationale:
//   sage       = positive / safe (mint green pops on the plum bg)
//   terracotta = warmth (peach, sits between Gold and Coral)
//   amber      = warmth peak (gold)
//   danger     = strong alert (hot coral-red)
//   sky        = cool counterweight / introspection (periwinkle)
//
// Foreground: warm off-white #FDF5F2 instead of #F4F0E6 — slightly more
// pink-bias to harmonise with the orange-coral brand, but still readable.

export const C = {
  // Surfaces — deep aubergine base, lighter plum cards on top.
  bg:      '#1A0F14',
  bgWarm:  '#24141B',
  card:    '#2D1A23',
  cardHi:  '#3B232E',
  cardAlt: '#492D3B',
  hero:    '#1D1016',

  // Foreground
  text:      '#FDF5F2',
  textSec:   '#D4C0CA',
  textMuted: '#A8909B',

  // Brand: coral mango (was electric lime).
  primary:     '#FF6B55',
  primaryInk:  '#1A0F14',
  primaryLight:'rgba(255, 107, 85, 0.18)',

  // Secondary brand: goldenrod (was violet).
  accent:     '#FFD300',
  accentInk:  '#1A0F14',
  accentLight:'rgba(255, 211, 0, 0.18)',

  // Mood palette (legacy aliases — semantic values for the FreeWrite bars
  // and the chat emotion-level scale).
  sage:        '#6CD85E',
  sageLight:   'rgba(108, 216, 94, 0.16)',
  terracotta:  '#FFA07A',
  terracottaLight:'rgba(255, 160, 122, 0.16)',
  amber:       '#FFD166',
  amberLight:  'rgba(255, 209, 102, 0.16)',
  danger:      '#FF2E63',
  dangerLight: 'rgba(255, 46, 99, 0.16)',
  rose:        '#FFA07A',
  roseLight:   'rgba(255, 160, 122, 0.16)',

  // Emotion axes
  sky:       '#7BA0FF',
  skyLight:  'rgba(123, 160, 255, 0.16)',

  border:    'rgba(253, 245, 242, 0.1)',
  borderHi:  'rgba(253, 245, 242, 0.2)',

  ink1:     '#FDF5F2',
  ink2:     '#D4C0CA',
  ink3:     '#A8909B',
  ink4:     'rgba(253, 245, 242, 0.1)',
  surface:  '#2D1A23',
  surface2: '#3B232E',
};

// Semantic mapping for the chat emotion level (VERDE/GIALLO/ARANCIONE/ROSSO).
// Distances on the colour wheel are clear: green → gold → peach → coral-red.
export const levelColors = {
  VERDE:     C.sage,
  GIALLO:    C.amber,
  ARANCIONE: C.terracotta,
  ROSSO:     C.danger,
};

// Per-emotion colours used in the FreeWrite analysis. terracotta (paura)
// and amber (sorpresa) are close on the wheel by design — both read as
// warmth-with-a-twist but the size/position of each mind-map node keeps
// them clearly separable.
export const emotionColors = {
  rabbia:   C.danger,        // hot coral-red
  paura:    C.terracotta,    // peach
  tristezza:C.sky,           // periwinkle (cool counterweight)
  gioia:    C.sage,          // mint positive
  disgusto: '#A8504D',        // deep terracotta-coral — reads as "repulsed / turned away" on the Sunset palette
  sorpresa: C.amber,         // gold
};

// Reusable radius scale.
export const R = {
  xs:   6,
  sm:   12,
  md:   20,
  lg:   28,
  xl:   40,
  pill: 999,
};

// Spacing scale (4 px grid).
export const S = {
  xs:    4,
  sm:    8,
  md:    12,
  lg:    16,
  xl:    24,
  xxl:   32,
  jumbo: 48,
};

// Motion presets. Spring configs are tuned to feel snappy but not jumpy.
export const M = {
  fast:         180,
  base:         280,
  slow:         420,
  springIn:     { tension: 140, friction: 9,  useNativeDriver: true },
  springBounce: { tension: 200, friction: 6,  useNativeDriver: true },
  springSoft:   { tension: 80,  friction: 11, useNativeDriver: true },
};

// Typography scale — single source of truth for type hierarchy. Each token
// is a pre-composed style fragment so consumers spread it into their
// stylesheet: `style={[h.greeting, T.h1]}`. Numbers picked to harmonize:
// display (marketing/hero), h1 (page titles), h2 (card titles), h3 (section
// headers), bodyLg (chat bubbles), body (paragraphs), bodySm (captions),
// caption (helper), micro (eyebrows — always uppercase + tracked), microLoose
// (decorative stat labels in remapped contexts).
export const T = {
  // Phase 1.x — Minimal editorial. Sizes slightly smaller, weights 800
  // instead of 900 (less shouty), letter-spacing relaxed, and line-height
  // ratios that read like editorial print (1.5x for body, ~1.15x for
  // display). Body text bumped 15→16 / 23→24 lineHeight so paragraphs
  // breathe. Components that spread these tokens (`style={[x, T.h1]}`)
  // pick up the new tokens automatically.
  display:   { fontSize: 38, fontWeight: '800', letterSpacing: -1.0, lineHeight: 44 },
  h1:        { fontSize: 28, fontWeight: '800', letterSpacing: -0.7, lineHeight: 34 },
  h2:        { fontSize: 22, fontWeight: '700', letterSpacing: -0.4, lineHeight: 28 },
  h3:        { fontSize: 18, fontWeight: '700', letterSpacing: -0.3, lineHeight: 24 },
  bodyLg:    { fontSize: 18, fontWeight: '400', lineHeight: 27 },
  body:      { fontSize: 16, fontWeight: '400', lineHeight: 24 },
  bodySm:    { fontSize: 14, fontWeight: '500', lineHeight: 20 },
  caption:   { fontSize: 13, fontWeight: '500', lineHeight: 18 },
  micro:     { fontSize: 11, fontWeight: '700', letterSpacing: 0.6, textTransform: 'uppercase' },
  microLoose:{ fontSize: 10, fontWeight: '700', letterSpacing: 1.0, textTransform: 'uppercase' },
};


// Phase 1.x — Minimal editorial: drop shadow presets flattened to no-ops.
// Components still spread these into their stylesheets so existing
// references keep working, but the values are no-op. Cards stand out
// via C.surface vs C.bg contrast + generous radii + the ink/surface
// alias scale — never elevation. Depth comes from typography hierarchy
// (T.display vs T.body) and whitespace, not drop shadows.
export const sh = {
  card:       {},
  cardSoft:   {},
  chip:       {},
  glow:       {},
  glowViolet: {},
};
