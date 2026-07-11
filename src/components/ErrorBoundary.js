import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { C } from '../constants/theme';

/**
 * Last-resort safety net for render errors.
 *
 * If any subtree throws during render or commit, React would unmount the
 * entire app. We intercept that here so the user sees a recoverable error
 * screen instead of a blank/black app.
 *
 * For a clinical, single-screen mental-health app this is critical: a crash
 * mid-conversation could be disorienting for someone already in distress.
 */
export default class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { error: null };
  }

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidCatch(error, info) {
    // eslint-disable-next-line no-console
    console.error('[BenessereBot] Caught by ErrorBoundary:', error, info?.componentStack);
  }

  handleReset = () => {
    this.setState({ error: null });
  };

  render() {
    if (!this.state.error) return this.props.children;
    return (
      <View style={styles.wrap}>
        <Text style={styles.title}>Qualcosa è andato storto</Text>
        <Text style={styles.body}>
          L'app ha riscontrato un errore inatteso. La tua sessione non è stata
          memorizzata, quindi puoi ripartire in sicurezza.
        </Text>
        <TouchableOpacity style={styles.btn} onPress={this.handleReset} accessibilityRole="button">
          <Text style={styles.btnText}>Riprova</Text>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  wrap: {
    flex: 1,
    backgroundColor: C.bg,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  title: {
    color: C.text,
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 12,
    textAlign: 'center',
  },
  body: {
    color: C.textSec,
    fontSize: 14,
    lineHeight: 22,
    textAlign: 'center',
    marginBottom: 24,
  },
  btn: {
    backgroundColor: C.primary,
    paddingVertical: 14,
    paddingHorizontal: 28,
    borderRadius: 100,
  },
  btnText: { color: '#fff', fontSize: 15, fontWeight: '700' },
});
