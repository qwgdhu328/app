// InfoScreen — disclaimer, version, privacy, emergency numbers, commands.
// Extracted from the monolithic App.js as part of Phase 0.C.
//
// Pure static content; no store reads, no store writes, no local state.
// Single back button navigates to home via the parent's `onBack` prop.

import React from 'react';
import { StyleSheet, Text, View, ScrollView } from 'react-native';
import { C, R, S } from '../../../constants/theme';
import PressableScale from '../../../components/PressableScale';
import { BackIcon } from '../../../../icons';

export default function InfoScreen({ onBack }) {
  return (
    <ScrollView style={i.container} contentContainerStyle={i.scroll}>
      <View style={i.headerRow}>
        <PressableScale onPress={onBack} style={i.backBtn} accessibilityLabel="Indietro">
          <BackIcon /><Text style={i.backText}> Indietro</Text>
        </PressableScale>
        <Text style={i.title}>Info</Text>
      </View>

      <View style={[i.card, i.cardLime]}>
        <Text style={i.cardKicker}>VERSIONE</Text>
        <Text style={i.cardTitle}>BenessereBot v4</Text>
        <Text style={i.cardBody}>Assistente digitale per il Primo Ascolto Psicologico. CBT di terza onda (Mindfulness + ACT).</Text>
      </View>

      <View style={[i.card, i.cardViolet]}>
        <Text style={[i.cardKicker, { color: C.accent }]}>DICHIARAZIONE</Text>
        <Text style={i.cardBody}>
          {'1. Sono un\u2019AI. Non sono un medico, non sono un terapeuta, non prescrivo nulla.\n\n'}
          {'2. Le tecniche che proponiamo (CBT, ACT, grounding, respirazione) sono princìpi consolidati, ma **erogati tramite AI non sono clinicamente validati**.\n\n'}
          {'3. In emergenza: \u2018solo\u2019 il **112** o il **Telefono Amico 199 284 284**.\n\n'}
          {'4. Niente viene memorizzato.'}
        </Text>
      </View>

      <View style={[i.card, i.cardRed]}>
        <Text style={[i.cardKicker, { color: C.danger }]}>NUMERI CHE CONTANO</Text>
        <Text style={[i.phoneLine, { color: C.danger }]}>112</Text>
        <Text style={i.cardBody}>Numero Unico di Emergenza</Text>
        <View style={i.phoneDivider} />
        <Text style={[i.phoneLineSm, { color: C.danger }]}>199 284 284</Text>
        <Text style={i.cardBody}>Telefono Amico</Text>
      </View>

      <View style={[i.card, i.cardSky]}>
        <Text style={[i.cardKicker, { color: C.sky }]}>PRIVACY</Text>
        <Text style={i.cardBody}>
          {'I testi delle conversazioni sono elaborati da server AI esterni (USA/UE) per generare le risposte. **Nessun testo viene salvato**.\n\n'}
          {'Le statistiche che vedi nella scheda "Tu" sono solo sul tuo dispositivo.\n\n'}
          {'Per dubbi: dpo@benesserebot.app.'}
        </Text>
      </View>

      <View style={[i.card]}>
        <Text style={i.cardKicker}>COMANDI</Text>
        {[
          ['/forget', 'cancella la conversazione'],
          ['/export', 'esporta il testo della chat'],
          ['/disclaimer', 'mostra la dichiarazione completa'],
        ].map(([cmd, desc], idx) => (        <View key={idx} style={i.cmdRow}>
          <Text style={i.cmdName}>{cmd}</Text>
          <Text style={i.cmdDesc}>{desc}</Text>
        </View>
      ))}
    </View>

    </ScrollView>
  );
}

const i = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg, maxWidth: 600, width: '100%', alignSelf: 'center' },  scroll: { paddingHorizontal: S.lg, paddingBottom: S.xl, paddingTop: S.md },
  headerRow: { flexDirection: 'row', alignItems: 'center', marginBottom: S.lg, paddingTop: S.lg },
  backBtn:   { flexDirection: 'row', alignItems: 'center', marginRight: S.md, paddingVertical: 6, paddingHorizontal: 8, borderRadius: R.pill, backgroundColor: C.card },
  backText:  { color: C.accent, fontSize: 13, fontWeight: '900', marginLeft: 4 },
  title:     { color: C.text, fontSize: 22, fontWeight: '900', letterSpacing: -0.4 },
  card:      { backgroundColor: C.surface, borderRadius: R.xl, padding: S.lg, marginBottom: S.md, borderWidth: 0 },
  cardLime:  { backgroundColor: C.primaryLight, borderColor: C.primary },
  cardViolet:{ backgroundColor: C.accentLight, borderColor: C.accent },
  cardRed:   { backgroundColor: C.dangerLight, borderColor: C.danger },
  cardSky:   { backgroundColor: C.skyLight,    borderColor: C.sky },
  cardKicker:{ color: C.primary, fontSize: 10, fontWeight: '900', letterSpacing: 2, marginBottom: S.sm, textTransform: 'uppercase' },
  cardTitle: { color: C.text, fontSize: 18, fontWeight: '900', marginBottom: 4 },
  cardBody:  { color: C.text,    fontSize: 14, lineHeight: 22 },
  phoneLine:  { color: C.danger, fontSize: 30, fontWeight: '900', letterSpacing: 1 },
  phoneLineSm:{ color: C.danger, fontSize: 22, fontWeight: '800' },
  phoneDivider:{ height: 1, backgroundColor: C.border, marginVertical: S.md, opacity: 0.4 },
  cmdRow: { flexDirection: 'row', alignItems: 'center', marginBottom: S.sm },
  cmdName: { color: C.primary, fontSize: 13, fontWeight: '900', width: 110 },
  cmdDesc: { color: C.textSec, fontSize: 13, flex: 1 },
});
