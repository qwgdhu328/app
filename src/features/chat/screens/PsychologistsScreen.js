// Phase 2: src/features/chat/screens/PsychologistsScreen.js
// Shown when the chat is escalated (10-minute cooldown after complex
// clinical content). Live countdown timer, emergency hotline call-out
// pinned at top, inline city prompt (when userCity is empty), and a
// directory of local psychologists filtered by the user's city OR
// the national hotline fallback set when the city isn't mapped.
//
// === Why this lives in chat/screens and not a new professionals/ folder ===
// Because it's the END state of ChatScreen — same activeTab='chat',
// same navigation seam (← Home chip), same enclosing KeyboardAvoidingView
// contract. The escalation marker pulls the user's flow here without
// changing the route, so a sibling layout is the right shape
// architecturally. Sharing the chat feature folder keeps the
// imports/co-location tidy.
//
// === Why a directory and not a "find a therapist" API call ===
// Phase 2 is the static directory. Future phases can swap the static
// map for a backend lookup (a USupport integration, see
// resources2026.js) without changing the screen contract.

import React, { useState, useEffect } from 'react';
import { StyleSheet, Text, View, ScrollView, TextInput, Linking, Alert } from 'react-native';
import { C, R, S, T } from '../../../constants/theme';
import PressableScale from '../../../components/PressableScale';
import { useChatStore } from '../../../store/chatStore';
import { useUserStore } from '../../../store/userStore';
import {
  lookupPsychologists,
  normalizeCity,
  FALLBACK_NATIONAL_HOTLINES,
} from '../../../constants/psychologists';

function safeOpen(href, kind) {
  Linking.openURL(href).catch(() =>
    Alert.alert('Errore', `Impossibile aprire ${kind === 'tel' ? 'il telefono' : kind === 'mailto' ? 'la mail' : 'il link'}`)
  );
}

export default function PsychologistsScreen({ onNavigate }) {
  // ── Store reads (granular selectors) ─────────────────────────────────
  const escalatedAt    = useChatStore((s) => s.escalatedAt);
  const cooldownMs     = useChatStore((s) => s.cooldownMs);
  const escalateReason = useChatStore((s) => s.escalateReason);
  const userCity       = useUserStore((s) => s.userCity);
  const { clearEscalation } = useChatStore.getState();
  const { setUserCity }     = useUserStore.getState();

  // Local state for the inline city input.
  const [cityDraft, setCityDraft] = useState('');

  // === Live countdown ===
  // Recomputes every second. When cooldown elapses, clearEscalation()
  // flips store.escalatedAt to null, App.js's isEscalationActive flag
  // drops false on the next interval tick, and the ChatScreen route
  // becomes active again naturally.
  const [secondsLeft, setSecondsLeft] = useState(() => {
    if (!escalatedAt) return 0;
    return Math.max(0, Math.ceil((cooldownMs - (Date.now() - escalatedAt)) / 1000));
  });
  useEffect(() => {
    if (!escalatedAt) {
      setSecondsLeft(0);
      return;
    }
    const tick = () => {
      const remaining = Math.max(0, Math.ceil((cooldownMs - (Date.now() - escalatedAt)) / 1000));
      setSecondsLeft(remaining);
      if (remaining === 0) {
        clearEscalation();
      }
    };
    tick();
    const interval = setInterval(tick, 1000);
    return () => clearInterval(interval);
  }, [escalatedAt, cooldownMs, clearEscalation]);

  const formatTime = (s) => {
    const mm = Math.floor(s / 60).toString().padStart(2, '0');
    const ss = (s % 60).toString().padStart(2, '0');
    return `${mm}:${ss}`;
  };

  // === Directory lookup ===
  // Use the saved city if any, otherwise fall back to the live draft.
  // lookupPsychologists() returns `kind: 'local'` for an exact/fuzzy
  // hit or `kind: 'fallback'` for the national hotline set.
  const lookupCity = String(userCity || cityDraft || '').trim();
  const lookup = lookupCity ? lookupPsychologists(lookupCity) : null;

  return (
    <ScrollView style={p.container} contentContainerStyle={p.scroll}>
      {/* ← Home — moved from the bottom of the scroll so the user can
          escape the cooldown / directory at any point without having
          to scroll past every card. Same shape as ChatScreen /
          ProfileScreen / CommunityScreen's back chip. */}
      {onNavigate && (
        <PressableScale
          accessibilityRole="button"
          accessibilityLabel="Torna alla home"
          onPress={() => onNavigate('home')}
          style={p.backChipTop}
        >
          <Text style={p.backChipText}>← Home</Text>
        </PressableScale>
      )}

      {/* Cooldown header — large countdown. */}
      <View style={p.cooldownCard}>
        <Text style={p.cooldownKicker}>PAUSA DI SICUREZZA</Text>
        <Text style={p.cooldownTime}>{formatTime(secondsLeft)}</Text>
        <Text style={p.cooldownSub}>
          {secondsLeft > 0
            ? `Torna alla chat fra ${formatTime(secondsLeft)}`
            : 'Cooldown completato. Torna alla chat quando vuoi.'}
        </Text>
        {!!escalateReason && (
          <View style={p.cooldownReasonBox}>
            <Text style={p.cooldownReasonLabel}>MOTIVO ESCALATION</Text>
            <Text style={p.cooldownReason}>{escalateReason}</Text>
          </View>
        )}
      </View>

      {/* Hotlines call-out — pinned because the user might need to
          call NOW, not just browse the directory. Tap-to-dial. */}
      <View style={[p.card, p.cardRed]}>
        <Text style={[p.cardKicker, { color: C.danger }]}>SE HAI BISOGNO ADESSO</Text>
        <PressableScale
          accessibilityRole="button"
          accessibilityLabel="Chiama il 112"
          onPress={() => safeOpen('tel:112', 'tel')}
          style={p.hotlineRow}
        >
          <View style={p.hotlineBox}>
            <Text style={[p.hotlinePhone, { color: C.danger }]}>112</Text>
            <Text style={p.hotlineLabel}>Emergenza, 24/7</Text>
          </View>
        </PressableScale>
        <View style={p.hotlineDivider} />
        <PressableScale
          accessibilityRole="button"
          accessibilityLabel="Chiama Telefono Amico"
          onPress={() => safeOpen('tel:199284284', 'tel')}
          style={p.hotlineRow}
        >
          <View style={p.hotlineBox}>
            <Text style={[p.hotlinePhoneSm, { color: C.danger }]}>199 284 284</Text>
            <Text style={p.hotlineLabel}>Telefono Amico (ascolto umano)</Text>
          </View>
        </PressableScale>
      </View>

      {/* Inline city input — only when userStore.userCity is empty
          AND no live draft has been entered yet. */}
      {!userCity && !cityDraft && (
        <View style={[p.card, p.cardSage]}>
          <Text style={[p.cardKicker, { color: C.sage }]}>LA TUA CITTÀ</Text>
          <Text style={p.cardBody}>
            Per mostrarti i professionisti più vicini a te, dimmi in che città sei. La città viene salvata solo sul tuo dispositivo e non viene mai trasmessa.
          </Text>
          <TextInput
            style={p.input}
            placeholder="Es. Roma, Milano, Napoli\u2026"
            placeholderTextColor={C.textMuted}
            value={cityDraft}
            onChangeText={setCityDraft}
            returnKeyType="done"
            autoCapitalize="words"
          />
        </View>
      )}

      {/* Save city — when local draft is set but not yet saved. */}
      {!userCity && !!cityDraft && (
        <View style={[p.card, p.cardSage]}>
          <Text style={[p.cardKicker, { color: C.sage }]}>CONFERMA LA TUA CITTÀ</Text>
          <Text style={p.cardBody}>
            Stiamo mostrando professionisti per "<Text style={{ fontWeight: '800' }}>{cityDraft.trim()}</Text>". Puoi salvare questa scelta per le prossime volte.
          </Text>
          <View style={p.cityActionsRow}>
            <PressableScale
              accessibilityRole="button"
              accessibilityLabel={`Salva la città ${cityDraft}`}
              onPress={() => setUserCity(cityDraft)}
              style={p.cityBtnPrimary}
            >
              <Text style={p.cityBtnPrimaryText}>Salva "{cityDraft.trim()}"</Text>
            </PressableScale>
            <PressableScale
              accessibilityRole="button"
              accessibilityLabel="Correggi la città"
              onPress={() => setCityDraft('')}
              style={p.cityBtnGhost}
            >
              <Text style={p.cityBtnGhostText}>Correggi</Text>
            </PressableScale>
          </View>
        </View>
      )}

      {/* Directory list — for the resolved lookup. */}
      {lookup && lookup.match.length > 0 && (
        <View>
          <Text style={p.sectionTitle}>
            {lookup.kind === 'local'
              ? `Professionisti \u2014 ${lookup.city.charAt(0).toUpperCase() + lookup.city.slice(1)}`
              : 'Linee nazionali (la tua citt\u00e0 non \u00e8 ancora mappata)'}
          </Text>
          {lookup.match.map((psy, idx) => (
            <View key={idx} style={p.card}>
              <Text style={p.psyName}>{psy.name}</Text>
              <Text style={p.psySpec}>{psy.spec}</Text>
              {!!psy.address && <Text style={p.psyRow}>\ud83d\udccd {psy.address}</Text>}
              {!!psy.schedule && <Text style={p.psyRow}>\ud83d\udd50 {psy.schedule}</Text>}
              {!!psy.languages && <Text style={p.psyRow}>\ud83c\udf10 {psy.languages}</Text>}
              {!!psy.publicService && (
                <Text style={p.psyPublicBadge}>SERVIZIO PUBBLICO (SSN)</Text>
              )}
              <View style={p.psyActions}>
                {!!psy.phone && (
                  <PressableScale
                    accessibilityRole="button"
                    accessibilityLabel={`Chiama ${psy.name}`}
                    onPress={() => safeOpen(`tel:${String(psy.phone).replace(/\s/g, '')}`, 'tel')}
                    style={p.actionBtn}
                  >
                    <Text style={p.actionBtnText}>Chiama</Text>
                  </PressableScale>
                )}
                {!!psy.email && (
                  <PressableScale
                    accessibilityRole="button"
                    accessibilityLabel={`Email ${psy.name}`}
                    onPress={() => safeOpen(`mailto:${psy.email}`, 'mailto')}
                    style={p.actionBtn}
                  >
                    <Text style={p.actionBtnText}>Email</Text>
                  </PressableScale>
                )}
                {!!psy.website && (
                  <PressableScale
                    accessibilityRole="button"
                    accessibilityLabel={`Sito web di ${psy.name}`}
                    onPress={() => safeOpen(psy.website, 'web')}
                    style={p.actionBtn}
                  >
                    <Text style={p.actionBtnText}>Sito</Text>
                  </PressableScale>
                )}
              </View>
            </View>
          ))}
        </View>
      )}

      {/* Disclaimer — partner medico + privacy. */}
      <View style={p.disclaimerCard}>
        <Text style={p.disclaimerText}>
          *Directory dimostrativa.* Questi dati sono di esempio per sviluppo e anteprima. Prima di un rilascio in produzione, la directory va completata con dati reali e verificati (ASL regionali, Ordine degli Psicologi, CIPM). Il chatbot non garantisce la disponibilit\u00e0 dei professionisti elencati. La citt\u00e0 che inserisci resta solo sul tuo dispositivo.
        </Text>
      </View>

      {/* Back chip — same shape as ChatScreen's "← Home". */}
      {onNavigate && (
        <PressableScale
          accessibilityRole="button"
          accessibilityLabel="Torna alla home"
          onPress={() => onNavigate('home')}
          style={p.backChip}
        >
          <Text style={p.backChipText}>\u2190 Home</Text>
        </PressableScale>
      )}
    </ScrollView>
  );
}

const p = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg, maxWidth: 600, width: '100%', alignSelf: 'center' },
  scroll:    { paddingHorizontal: S.lg, paddingBottom: S.xl, paddingTop: S.md },

  cooldownCard: {
    backgroundColor: C.surface,
    borderRadius: R.xl,
    padding: S.lg,
    marginBottom: S.md,
    alignItems: 'center',
    borderWidth: 0,
    borderTopWidth: 4,
    borderTopColor: C.accent,
  },
  cooldownKicker: { ...T.micro, color: C.accent, marginBottom: S.sm },
  cooldownTime:   { color: C.text, fontSize: 50, fontWeight: '900', letterSpacing: -1.3, marginVertical: S.xs },
  cooldownSub:    { ...T.bodySm, color: C.textSec, textAlign: 'center' },
  cooldownReasonBox:  { marginTop: S.lg, paddingTop: S.md, borderTopWidth: 1, borderTopColor: C.border, width: '100%' },
  cooldownReasonLabel: { ...T.micro, color: C.textMuted, marginBottom: 4 },
  cooldownReason:      { ...T.bodySm, color: C.text, fontWeight: '700', lineHeight: 20 },

  card:       { backgroundColor: C.surface, borderRadius: R.xl, padding: S.lg, marginBottom: S.md, borderWidth: 0 },
  cardRed:    { backgroundColor: C.dangerLight, borderColor: C.danger, borderWidth: 1 },
  cardSage:   { backgroundColor: C.sageLight, borderColor: C.sage, borderWidth: 1 },
  cardKicker: { ...T.micro, color: C.primary, marginBottom: S.sm },
  cardBody:   { ...T.body, color: C.text, lineHeight: 22 },

  hotlineRow:     { paddingVertical: S.md },
  hotlineBox:     { alignItems: 'flex-start' },
  hotlinePhone:   { fontSize: 30, fontWeight: '900', letterSpacing: 1 },
  hotlinePhoneSm: { fontSize: 22, fontWeight: '800' },
  hotlineLabel:   { ...T.bodySm, color: C.text, marginTop: 4 },
  hotlineDivider: { height: 1, backgroundColor: C.border, opacity: 0.4, marginVertical: S.sm },

  input: {
    backgroundColor: C.card,
    color: C.text,
    borderRadius: R.pill,
    paddingHorizontal: S.lg,
    paddingVertical: S.md,
    fontSize: 16,
    marginTop: S.md,
    borderWidth: 0,
  },

  cityActionsRow:    { flexDirection: 'row', gap: S.sm, marginTop: S.md, flexWrap: 'wrap' },
  cityBtnPrimary:    { backgroundColor: C.primary, paddingVertical: 12, paddingHorizontal: S.lg, borderRadius: R.pill },
  cityBtnPrimaryText:{ color: C.primaryInk, fontWeight: '800', fontSize: 14 },
  cityBtnGhost:      { backgroundColor: C.surface, paddingVertical: 12, paddingHorizontal: S.lg, borderRadius: R.pill, borderWidth: 1, borderColor: C.border },
  cityBtnGhostText:  { color: C.text, fontWeight: '700', fontSize: 14 },

  sectionTitle: { ...T.h3, color: C.text, marginTop: S.md, marginBottom: S.md },

  psyName:        { ...T.bodyLg, color: C.text, fontWeight: '800', marginBottom: 4 },
  psySpec:        { ...T.bodySm, color: C.primary, marginBottom: S.sm, fontWeight: '700' },
  psyRow:         { ...T.bodySm, color: C.textSec, marginBottom: 4 },
  psyPublicBadge: { ...T.micro, color: C.sage, marginTop: S.sm, marginBottom: S.sm, fontWeight: '800' },
  psyActions:     { flexDirection: 'row', gap: S.sm, marginTop: S.md, flexWrap: 'wrap' },
  actionBtn:      { backgroundColor: C.surface2, paddingVertical: 10, paddingHorizontal: S.lg, borderRadius: R.pill, borderWidth: 1, borderColor: C.border },
  actionBtnText:  { color: C.text, fontWeight: '800', fontSize: 13 },

  disclaimerCard: { backgroundColor: C.surface, borderRadius: R.lg, padding: S.md, marginTop: S.lg, marginBottom: S.lg, borderWidth: 0 },
  disclaimerText: { ...T.caption, color: C.textMuted, lineHeight: 18, fontStyle: 'italic' },

  backChip:     { backgroundColor: C.surface, paddingVertical: 12, paddingHorizontal: S.lg, borderRadius: R.pill, alignItems: 'center', marginTop: S.md, marginBottom: S.xl, borderWidth: 0 },
  backChipText: { color: C.accent, fontWeight: '800', fontSize: 14 },
  // Top-of-scroll chip — small, self-aligned to the right, sits
  // above the cooldown card so it's the first thing the user sees
  // when the screen mounts.
  backChipTop:  { alignSelf: 'center', paddingVertical: 6, paddingHorizontal: 12, borderRadius: R.pill, backgroundColor: C.card, marginBottom: S.md, borderWidth: 1, borderColor: C.border },
});
