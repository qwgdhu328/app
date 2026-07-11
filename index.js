import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { registerRootComponent } from 'expo';
import { SafeAreaProvider, initialWindowMetrics } from 'react-native-safe-area-context';

import ErrorBoundary from './src/components/ErrorBoundary';
import { C } from './src/constants/theme';

// Dynamic require with try/catch so a module-level crash in App.js
// (e.g. react-native-mmkv native init failure) shows an error UI
// instead of a blank black screen.
let AppComponent;
let loadError;
try {
  AppComponent = require('./App').default;
} catch (e) {
  console.error('[BenessereBot] Fatal: App module failed to load:', e);
  loadError = e;
}

function Root() {
  if (!AppComponent) {
    return (
      <View style={styles.errorWrap}>
        <Text style={styles.errorTitle}>Errore di avvio</Text>
        <Text style={styles.errorBody}>
          {loadError ? loadError.toString() : 'Modulo principale non caricabile'}
        </Text>
      </View>
    );
  }

  return (
    <ErrorBoundary>
      <SafeAreaProvider initialMetrics={initialWindowMetrics}>
        <AppComponent />
      </SafeAreaProvider>
    </ErrorBoundary>
  );
}

registerRootComponent(Root);

const styles = StyleSheet.create({
  errorWrap: {
    flex: 1,
    backgroundColor: '#1A0F14',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  errorTitle: {
    color: '#fff',
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 12,
    textAlign: 'center',
  },
  errorBody: {
    color: 'rgba(255,255,255,0.6)',
    fontSize: 14,
    lineHeight: 22,
    textAlign: 'center',
  },
});
