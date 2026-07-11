import { View, Text } from 'react-native';
import { C, R, S, sh } from '../constants/theme';
import PressableScale from './PressableScale';

/**
 * Chip row of suggested quick-replies shown immediately under a bot message.
 * Picking a chip injects the chip's `text` into the chat input and triggers
 * the send callback — the same path as a user typing the same words.
 *
 * Default options are tuned to keep the conversation alive without making
 * the bot feel like a multiple-choice quiz:
 *   • "Vai avanti"      — ask for more on the same topic
 *   • "Approfondisci"   — request a deeper reflection
 *   • "Una tecnica"     — ask for a CBT/ACT technique
 *   • "Fammi una pausa" — softer check-out, including a breath prompt
 *
 * Callers can override options to fit the conversation state (e.g. hide
 * "Una tecnica" if a technique was just offered).
 */
export default function QuickReplies({ onPick, options }) {
  const items = options || DEFAULT_OPTIONS;
  return (
    <View
      style={{
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: S.sm,
        marginTop: S.xs,
        marginBottom: S.lg,
        paddingLeft: S.lg,
      }}
      accessibilityRole="menu"
    >
      {items.map((opt) => (
        <PressableScale
          key={opt.key}
          onPress={() => onPick(opt)}
          accessibilityLabel={`Risposta rapida: ${opt.label}`}
          style={{ ...chipStyle.chipBase, ...(opt.tint ? chipStyle[opt.tint] : {}) }}
        >
          <Text style={chipStyle.chipText}>
            {opt.label}
          </Text>
        </PressableScale>
      ))}
    </View>
  );
}

const DEFAULT_OPTIONS = [
  { key: 'continue',   label: 'Vai avanti',      tint: 'lime' },
  { key: 'deep',       label: 'Approfondisci',  tint: 'violet' },
  { key: 'technique',  label: 'Una tecnica',     tint: 'violet' },
  { key: 'pause',      label: 'Fammi una pausa', tint: 'lime' },
];

const chipStyle = {
  chipBase: {
    paddingVertical: 8,
    paddingHorizontal: 14,
    borderRadius: R.pill,
    backgroundColor: C.cardHi,
    borderWidth: 1,
    borderColor: C.border,
    ...sh.chip,
  },
  lime: {
    backgroundColor: C.primaryLight,
    borderColor: C.primary,
  },
  violet: {
    backgroundColor: C.accentLight,
    borderColor: C.accent,
  },
  chipText: {
    color: C.text,
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 0.2,
  },
};
