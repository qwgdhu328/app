import React from 'react';
import { registerRootComponent } from 'expo';
import { SafeAreaProvider, initialWindowMetrics } from 'react-native-safe-area-context';

import App from './App';
import ErrorBoundary from './src/components/ErrorBoundary';

// Wrap the entire app with an error boundary so that any render error in
// any child screen is caught and shows a recoverable screen instead of
// crashing the whole app. For a clinical single-purpose app this is
// critical — a crash mid-conversation could be disorienting for a user
// already in distress.
//
// SafeAreaProvider is INSIDE ErrorBoundary so a theoretical crash in the
// provider itself would also be caught — but in practice the provider is
// just a React context that never crashes. Placing it between
// ErrorBoundary and <App /> means every `useSafeAreaInsets()` call in the
// tree (currently just the TabBar) gets accurate OS-reported insets on
// iOS notches, Android gesture bars, foldables in flex mode, and
// landscape iPad — without any screen-size heuristic in user code.
function Root() {
  return (
    <ErrorBoundary>
      {/* initialMetrics={initialWindowMetrics} populates the safe-area
          context synchronously on first paint. Without it, the
          default 0,0,0,0 insets are returned until the async
          measurement completes (one frame of empty insets, which
          manifested as "non si vede tutta l'app" on web and older
          Android when combined with the SafeAreaView flex gotcha).
          initialWindowMetrics is the package's exported snapshot of
          the device's window insets — static + free. */}
      <SafeAreaProvider initialMetrics={initialWindowMetrics}>
        <App />
      </SafeAreaProvider>
    </ErrorBoundary>
  );
}

// registerRootComponent calls AppRegistry.registerComponent('main', () => Root);
// It also ensures that whether you load the app in Expo Go or in a native build,
// the environment is set up appropriately.
registerRootComponent(Root);
