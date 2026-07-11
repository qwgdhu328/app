import { requireNativeComponent, Platform } from 'react-native';

const NativeLiquidGlass = Platform.OS === 'ios'
  ? requireNativeComponent('LiquidGlassContainerView')
  : null;

export default function LiquidGlassView({ style, children }) {
  if (!NativeLiquidGlass || Platform.OS !== 'ios') {
    return null;
  }
  return (
    <NativeLiquidGlass style={style}>
      {children}
    </NativeLiquidGlass>
  );
}
