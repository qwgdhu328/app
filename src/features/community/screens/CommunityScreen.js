// CommunityScreen — "Spazio" stories + listener row + benessereBot CTA +
// shared rules + disclaimer. Extracted from the monolithic App.js as
// part of Phase 0.C.
//
// This screen is intentionally self-contained: every bit of state it owns
// (the static stories seed, the local story-likes map, the randomised
// "persone online" + "ascoltatori" counts) lives in component-local
// useState. No store reads, no store writes. That's deliberate — these
// figures are demo-only reads that the user explicitly opted into ("Le
// storie sono statiche per questa build demo" comment in the prior App.js
// version is preserved verbatim).

import React, { useState } from 'react';
import { StyleSheet, Text, View, ScrollView } from 'react-native';
import { C, R, S, sh } from '../../../constants/theme';
import MoodIcon from '../../../components/MoodIcon';
import PressableScale from '../../../components/PressableScale';
import { ShieldIcon, HeartIcon } from '../../../../icons';

export default function CommunityScreen({ onNavigate }) {
  const [stories] = useState([
    { id: 1, iconName: 'sprout',         testo: 'Oggi ho fatto pace con una parte di me che evitavo da anni. Piano piano.', reazioni: 24 },
    { id: 2, iconName: 'sun',            testo: 'Questa settimana sono riuscito a fare 3 passeggiate. Per me \u00e8 una vittoria enorme.', reazioni: 18 },
    { id: 3, iconName: 'bolt',           testo: 'Ho chiesto aiuto per la prima volta. Spaventoso, ma liberatorio.', reazioni: 37 },
    { id: 4, iconName: 'pen_alt',        testo: 'Scrivere i miei pensieri ogni sera mi ha aiutato a dormire meglio.', reazioni: 31 },
    { id: 5, iconName: 'smile_concern',  testo: 'Oggi ho ascoltato un amico senza giudicare. Mi sono sentito bene anche io.', reazioni: 42 },
  ]);
  const [personeOnline] = useState(() => 12 + Math.floor(Math.random() * 8));
  const [ascoltatori]   = useState(() => 4  + Math.floor(Math.random() * 3));
  const [likedStories, setLikedStories] = useState({});

  const handleLike = (id) => {
    if (likedStories[id]) return;
    setLikedStories((prev) => ({ ...prev, [id]: true }));
    // The story counts are static for this demo build — saved replies
    // would be wired in via a backend later.
  };

  return (
    <ScrollView style={co.container} contentContainerStyle={co.scroll} showsVerticalScrollIndicator={false}>
      <View style={co.hero}>
        <View style={co.heroBlob} />
        <View style={co.heroBlob2} />
        {/* "← Home" back chip — replaces the bottom TabBar (Phase 1.x). */}
        {onNavigate && (
          <PressableScale
            onPress={() => onNavigate('home')}
            style={co.backChip}
            accessibilityRole="button"
            accessibilityLabel="Torna alla home"
          >
            <Text style={co.backChipText}>← Home</Text>
          </PressableScale>
        )}
        <Text style={co.heroKicker}>SPAZIO</Text>
        <Text style={co.heroTitle}>Uno spazio sicuro</Text>
        <Text style={co.heroSub}>Qui non sei solə. Persone come te si incontrano, si ascoltano, si capiscono.</Text>
      </View>

      <View style={co.line}>
        <View style={co.onlineDot} />
        <Text style={co.lineText}><Text style={{ fontWeight: '900', color: C.primary }}>{personeOnline}</Text> persone online ora</Text>
      </View>
      <View style={co.line}>
        <View style={[co.onlineDot, { backgroundColor: C.accent }]} />
        <Text style={co.lineText}><Text style={{ fontWeight: '900', color: C.accent }}>{ascoltatori}</Text> ascoltatori disponibili</Text>
      </View>

      <View style={co.guidePill}>
        <View style={co.guidePillIcon}><ShieldIcon size={13} color={C.primary} /></View>
        <Text style={co.guidePillText}>Moderato · Niente giudizi · Solo supporto</Text>
      </View>

      <Text style={co.sectionTitle}>Parla con qualcuno</Text>
      <View style={co.listenersRow}>
        {['Sofia', 'Marco', 'Elena', 'Alessio'].slice(0, ascoltatori).map((nome, i) => (
          <PressableScale key={i} onPress={() => onNavigate('chat')} style={co.listenerBtn}>
            <View style={[co.listenerAvatar, i % 2 === 0 ? { backgroundColor: C.primaryLight } : { backgroundColor: C.accentLight }]}>
              <Text adjustsFontSizeToFit numberOfLines={1} style={[co.listenerAvatarText, { color: i % 2 === 0 ? C.primary : C.accent }]}>{nome[0]}</Text>
            </View>
            <Text style={co.listenerName}>{nome}</Text>
            <Text style={co.listenerRole}>Ascoltatore</Text>
          </PressableScale>
        ))}
      </View>

      <PressableScale onPress={() => onNavigate('chat')} style={co.chatCta}>
        <View style={[co.chatCtaIcon, { backgroundColor: C.primaryLight }]}>
          <Text adjustsFontSizeToFit numberOfLines={1} style={[co.chatCtaIconText, { color: C.primary }]}>+</Text>
        </View>
        <View style={{ flex: 1 }}>
          <Text style={co.chatCtaTitle}>Parla in privato con BenessereBot</Text>
          <Text style={co.chatCtaDesc}>Sempre disponibile, senza giudizio</Text>
        </View>
        <Text style={co.chatCtaArrow}>→</Text>
      </PressableScale>

      <Text style={co.sectionTitle}>Storie</Text>
      {stories.map((st) => (
        <View key={st.id} style={co.storyCard}>
          <View style={co.storyHeader}>
            <View style={co.storyEmoji}><MoodIcon name={st.iconName} color={C.sage} size={26} /></View>
            <View style={co.storyBadge}><Text style={co.storyBadgeText}>Anonimo</Text></View>
          </View>
          <Text style={co.storyText}>{st.testo}</Text>
          <View style={co.storyFooter}>
            <PressableScale
              onPress={() => handleLike(st.id)}
              style={co.storyLike}
              accessibilityLabel={likedStories[st.id] ? 'Hai gi\u00e0 messo cuore' : 'Metti cuore'}
            >
              <HeartIcon size={18} color={likedStories[st.id] ? C.danger : C.textMuted} filled={!!likedStories[st.id]} />
              <Text style={[co.storyLikeNum, likedStories[st.id] && { color: C.danger }]}>{st.reazioni + (likedStories[st.id] ? 1 : 0)}</Text>
            </PressableScale>
            <PressableScale onPress={() => onNavigate('chat')} style={co.storyShare}>
              <Text style={co.storyShareText}>Rispondi →</Text>
            </PressableScale>
          </View>
        </View>
      ))}

      <PressableScale
        activeOpacity={0.85}
        style={co.shareCta}
        accessibilityRole="button"
      >
        <Text style={co.shareCtaText}>Condividi la tua storia</Text>
        <Text style={co.shareCtaSub}>Anonima. Nessun giudizio. Solo supporto.</Text>
      </PressableScale>

      <View style={co.rulesCard}>
        <Text style={co.rulesTitle}>Le regole dello Spazio</Text>
        {['Sii rispettos\u0259', 'Niente giudizi', 'Niente consigli non richiesti', 'Tutto \u00e8 confidenziale'].map((r, i) => (
          <View key={i} style={co.ruleRow}>
            <View style={[co.ruleDot, i % 2 === 0 ? { backgroundColor: C.primary } : { backgroundColor: C.accent }]} />
            <Text style={co.ruleText}>{r}</Text>
          </View>
        ))}
      </View>

      <View style={co.disclaimer}>
        <Text style={co.disclaimerText}>Le storie sono anonime e moderate. In emergenza: 112.</Text>
      </View>
    </ScrollView>
  );
}

const co = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg, maxWidth: 600, width: '100%', alignSelf: 'center' },
  scroll:    { paddingBottom: S.xl },
  hero:      { paddingHorizontal: S.lg, paddingTop: S.xl, paddingBottom: S.lg, position: 'relative', overflow: 'hidden' },
  backChip:  { alignSelf: 'flex-start', paddingVertical: 6, paddingHorizontal: 12, borderRadius: R.pill, backgroundColor: C.card, marginBottom: S.md, borderWidth: 1, borderColor: C.border },
  backChipText: { color: C.accent, fontSize: 12, fontWeight: '800' },
  heroBlob:  { position: 'absolute', top: -20, right: -30, width: 140, height: 140, borderRadius: 70, backgroundColor: C.primaryLight },
  heroBlob2: { position: 'absolute', bottom: -10, left: -20, width: 80,  height: 80,  borderRadius: 40, backgroundColor: C.accentLight },
  heroKicker:{ color: C.primary, fontSize: 11, fontWeight: '900', letterSpacing: 2, marginBottom: S.xs },
  heroTitle: { color: C.text,    fontSize: 26, fontWeight: '900', letterSpacing: -0.6, marginBottom: S.sm },
  heroSub:   { color: C.textSec, fontSize: 14, lineHeight: 22 },

  line:      { flexDirection: 'row', alignItems: 'center', paddingHorizontal: S.xl, marginBottom: S.xs },
  onlineDot: { width: 8, height: 8, borderRadius: 4, backgroundColor: C.primary, marginRight: S.sm },
  lineText:  { color: C.textSec, fontSize: 13, fontWeight: '600' },

  guidePill: { flexDirection: 'row', alignItems: 'center', alignSelf: 'center', backgroundColor: C.card, paddingVertical: 8, paddingHorizontal: 16, borderRadius: R.pill, marginTop: S.md, marginBottom: S.xs, borderWidth: 1, borderColor: C.border },
  guidePillIcon:  { fontSize: 13, marginRight: 6 },
  guidePillText:  { color: C.textSec, fontSize: 11, fontWeight: '800', letterSpacing: 0.5, textTransform: 'uppercase' },

  sectionTitle: { color: C.text, fontSize: 17, fontWeight: '900', paddingHorizontal: S.lg, marginBottom: S.md, marginTop: S.lg, letterSpacing: -0.3 },
  listenersRow:  { paddingHorizontal: S.lg, flexDirection: 'row', gap: S.sm, marginBottom: S.sm },
  listenerBtn:  { alignItems: 'center', backgroundColor: C.surface, borderRadius: R.xl, padding: S.lg, flex: 1, borderWidth: 0 },

  // Accessibility: circle must grow with Dynamic Type so the initial-letter
  // glyph inside doesn’t overflow. minWidth/minHeight preserves the base 44pt.
  listenerAvatar:{ minWidth: 44, minHeight: 44, borderRadius: 22, aspectRatio: 1, justifyContent: 'center', alignItems: 'center', marginBottom: S.xs },
  listenerAvatarText:{ fontSize: 17, fontWeight: '900' },
  listenerName: { color: C.text, fontSize: 12, fontWeight: '800', marginBottom: 2 },
  listenerRole: { color: C.textSec, fontSize: 9, fontWeight: '700', letterSpacing: 0.5, textTransform: 'uppercase' },

  chatCta:       { flexDirection: 'row', alignItems: 'center', backgroundColor: C.surface, borderRadius: R.xl, padding: S.lg, marginHorizontal: S.lg, marginTop: S.md, borderWidth: 0 },
  chatCtaIcon:   { minWidth: 44, minHeight: 44, borderRadius: 22, aspectRatio: 1, justifyContent: 'center', alignItems: 'center', marginRight: S.md },
  chatCtaIconText:{ fontSize: 24, fontWeight: '900' },
  chatCtaTitle:  { color: C.text, fontSize: 15, fontWeight: '800', marginBottom: 2 },
  chatCtaDesc:   { color: C.textSec, fontSize: 12 },
  chatCtaArrow:  { color: C.textMuted, fontSize: 20, fontWeight: '900' },

  storyCard:    { backgroundColor: C.surface, borderRadius: R.xl, padding: S.lg, marginHorizontal: S.lg, marginBottom: S.md, borderWidth: 0 },
  storyHeader:  { flexDirection: 'row', alignItems: 'center', marginBottom: S.sm },
  storyEmoji:   { fontSize: 24, marginRight: S.sm },
  storyBadge:   { backgroundColor: C.primaryLight, paddingHorizontal: 10, paddingVertical: 3, borderRadius: R.pill },
  storyBadgeText:{ color: C.primary, fontSize: 10, fontWeight: '900', letterSpacing: 0.5, textTransform: 'uppercase' },
  storyText:    { color: C.text, fontSize: 15, lineHeight: 23 },
  storyFooter:  { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: S.md },
  storyLike:    { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 10, paddingVertical: 6, borderRadius: R.pill },
  storyLikeNum: { color: C.textSec, fontSize: 13, fontWeight: '700' },
  storyShare:   { backgroundColor: C.cardAlt, paddingHorizontal: 14, paddingVertical: 6, borderRadius: R.pill },
  storyShareText:{ color: C.primary, fontSize: 12, fontWeight: '800' },

  shareCta:    { alignItems: 'center', paddingVertical: S.lg, marginHorizontal: S.lg, marginBottom: S.md, backgroundColor: C.card, borderRadius: R.lg, borderWidth: 1.5, borderColor: C.primaryLight, borderStyle: 'dashed' },
  shareCtaText:{ color: C.primary, fontSize: 16, fontWeight: '900' },
  shareCtaSub: { color: C.textSec, fontSize: 12, marginTop: 4 },

  rulesCard: { backgroundColor: C.surface, borderRadius: R.xl, padding: S.lg, marginHorizontal: S.lg, marginTop: S.md, marginBottom: S.xs, borderWidth: 0 },
  rulesTitle:{ color: C.text, fontSize: 15, fontWeight: '900', marginBottom: S.md },
  ruleRow:   { flexDirection: 'row', alignItems: 'center', marginBottom: S.sm },
  ruleDot:   { width: 6, height: 6, borderRadius: 3, marginRight: S.sm },
  ruleText:  { color: C.textSec, fontSize: 13 },
  disclaimer:{ paddingHorizontal: S.xl, paddingVertical: S.lg },
  disclaimerText:{ color: C.textMuted, fontSize: 12, textAlign: 'center', lineHeight: 20 },
});
