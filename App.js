import React from 'react';
import { View, Text } from 'react-native';
import { StatusBar } from 'expo-status-bar';

export default function App() {
  return (
    <View style={{ flex: 1, backgroundColor: '#ff0000', justifyContent: 'center', alignItems: 'center' }}>
      <StatusBar style="light" />
      <Text style={{ color: 'white', fontSize: 24, fontWeight: 'bold' }}>TEST</Text>
      <Text style={{ color: 'white', fontSize: 16, marginTop: 8 }}>Se vedi questo, il bundle funziona</Text>
    </View>
  );
}
