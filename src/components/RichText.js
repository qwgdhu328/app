import { Text } from 'react-native';

/**
 * Render a string with **bold** markers converted to nested <Text> nodes
 * with boldStyle applied. Italic *markers* are still stripped for now
 * (italic in React Native requires custom font work).
 *
 * The split regex keeps the **xxx** segments in the parts array (capture
 * group) and discards them in alternations, so the output is a stable
 * sequence of plain + bold segments.
 */
export function renderRich(text, baseStyle, boldStyle) {
  if (!text) return null;
  const parts = String(text).split(/(\*\*[^*]+?\*\*)/g);
  return parts.map((part, i) => {
    if (part.startsWith('**') && part.endsWith('**') && part.length >= 4) {
      return (
        <Text key={i} style={[baseStyle, boldStyle]}>
          {part.slice(2, -2)}
        </Text>
      );
    }
    if (part === '') return null;
    return (
      <Text key={i} style={baseStyle}>
        {part}
      </Text>
    );
  });
}
