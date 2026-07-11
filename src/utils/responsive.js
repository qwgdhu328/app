import { useWindowDimensions } from 'react-native';

// === Responsive breakpoints (tuned for this app's content density) ===
//
// Thresholds match device-class conventions (Apple HIG / Google Material) so
// the same flag is meaningful across components. Don't over-tweak the values
// — they're calibrated so that isSmallPhone = true corresponds exactly to
// "cramped enough that font scaling may overflow tile labels".
export const BREAKPOINTS = {
  xs: 360,
  sm: 414,
  md: 600,
  lg: 900,
};

// === Reference width for useScaledValue() ===
//
// Designers compose on this baseline (iPhone 11/12 — 390pt). The scale() helper
// rates the current screen against it. Settled on 390 not 375 so the most
// common modern phones (iPhone 14 Pro = 393, iPhone 15 = 393) hover at ~1.0×
// without drifting up.
export const REFERENCE_WIDTH = 390;

/**
 * Hook that derives (and reactivates on rotation / foldable open/close / iPad
 * multitasking resize) the responsive tokens this app uses to switch layout
 * tiers.
 *
 * ALWAYS call inside a component (i.e. inside the function body, NOT at
 * module load like Dimensions.get()). The hook re-runs on every relevant
 * dimension change so that, for example, a foldable open/close or an iPad
 * multitasking split reflows layouts correctly.
 *
 * @returns {{
 *   width: number,    // current viewport width in pt
 *   height: number,   // current viewport height in pt
 *   tier: 'xs'|'sm'|'md'|'lg',
 *   isCompactPhone: boolean,           // ≤360pt (iPhone SE-class)
 *   isSmallPhone:   boolean,           // ≤414pt (regular phones)
 *   isRegularPhone: boolean,           // 414-600pt (Plus/Max)
 *   isLargePhone:   boolean,           // 600-900pt (large phones / small tablets)
 *   isTablet:       boolean,           // ≥600pt
 * }}
 */
export function useResponsiveTokens() {
  const { width, height } = useWindowDimensions();

  const tier =
    width < BREAKPOINTS.xs ? 'xs' :
    width < BREAKPOINTS.sm ? 'sm' :
    width < BREAKPOINTS.md ? 'md' :
    'lg';

  return {
    width,
    height,
    tier,
    isCompactPhone: width < BREAKPOINTS.xs,                            // ≤360pt
    isSmallPhone:   width < BREAKPOINTS.sm,                            // ≤414pt
    isRegularPhone: width >= BREAKPOINTS.sm && width < BREAKPOINTS.md, // 414-600pt
    isLargePhone:   width >= BREAKPOINTS.md && width < BREAKPOINTS.lg, // 600-900pt
    isTablet:       width >= BREAKPOINTS.md,                           // ≥600pt
  };
}

/**
 * Scaled-value hook: returns `value` multiplied by a factor derived from the
 * current screen width relative to REFERENCE_WIDTH.
 *
 * IMPORTANT: only use for one-line typographic values that need to scale
 * gracefully across viewport sizes (e.g. hero greeting, intro title — which
 * would otherwise wrap awkwardly on iPhone SE-class). Do NOT scale generic
 * padding/margin — flexbox already adapts those, and re-deriving them wastes
 * cycles on every render.
 *
 * The result is rounded to the nearest integer so the consuming StyleSheet
 * still gets a clean numeric (StyleSheet.create doesn't accept fractional
 * dimensions).
 *
 * @param value        base value at REFERENCE_WIDTH
 * @param opts.factor  scaling power (default 1.0 = linear). 0.5 ≈ "subtle"
 *                     growth across screen sizes (good for hero titles).
 * @param opts.max     upper cap on the multiplier (default 1.4) so the value
 *                     doesn't grow unbounded on tablets (where the column
 *                     is already clamped via the 600pt screen caps elsewhere).
 */
export function useScaledValue(value, opts = {}) {
  const { width } = useWindowDimensions();
  const factor = (width / REFERENCE_WIDTH) * (opts.factor ?? 1);
  const capped = Math.min(factor, opts.max ?? 1.4);
  return Math.round(value * capped);
}
