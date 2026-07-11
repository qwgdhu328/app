// Static content used by the chat protocol.
// Centralized here so they can be reviewed, edited and unit-tested in one place.

// Italian red-flag phrases that trigger a safety response.
export const RED_FLAGS = [
  'uccidermi', 'impiccarmi', 'buttarmi', 'sgozzarmi', 'tagliarmi',
  'overdose', 'suicidio', 'ammazzarmi', 'morte', 'non voglio più vivere',
  'farla finita', 'lacci', 'corda', 'veleno', 'lame',
];

// Keyword buckets used for emotion detection on user input.
export const EMOTION_KEYWORDS = {
  rabbia: ['rabbia', 'arrabbiato', 'furioso', 'irritato', 'fastidio', 'odio'],
  tristezza: ['triste', 'tristezza', 'deluso', 'malinconico', 'lutto', 'disperazione', 'piango'],
  paura: ['paura', 'preoccupato', 'ansia', 'terrore', 'panico', 'dubbio', 'spaventato'],
  gioia: ['felice', 'contento', 'gioia', 'euforia', 'bene'],
  sorpresa: ['sorpreso', 'stupore', 'shock', 'inaspettato'],
  disgusto: ['disgusto', 'antipatia', 'repulsione', 'schifo'],
};

// Therapeutic techniques the bot can offer during a chat.
// Each entry has a title and a multi-paragraph exercise description.
export const TECNICHE = {
  grounding: {
    titolo: 'Grounding 5-4-3-2-1',
    descrizione: `Ora voglio portarti lontano dalla tua mente e riportarti in questa stanza. Guardati intorno.

**5 cose che vedi:** Nomina ad alta voce 5 oggetti che ti circondano. Anche il più piccolo dettaglio.
**4 cose che puoi toccare:** Appoggia le mani su queste 4 superfici. Senti la consistenza.
**3 cose che senti:** Ascolta. Il rumore del frigo? La tua stessa voce? Il traffico lontano?
**2 cose che annusi:** Porta un oggetto al naso o semplicemente annusa l'aria. Che odore ha?
**1 cosa che assapori:** Fai un sorso d'acqua o nota il sapore che hai in bocca.

Fatto? Ora muovi le dita dei piedi. Sei qui. La crisi è un'onda, e tu sei la roccia.`,
  },
  respirazione: {
    titolo: 'Respirazione diaframmatica',
    descrizione: `Sincronizziamoci. Il mio testo scorrerà al ritmo del tuo respiro.

*Preparati...*

**Inspira** (1, 2, 3, 4) – riempi prima la pancia, poi il petto.
**Trattieni** (1, 2, 3, 4) – mantieni la calma.
**Espira** (1, 2, 3, 4, 5, 6) – lascia uscire tutta l'aria, come se stessi spegnendo una candela lontana.

Ripeti questo ciclo 5 volte. Non cercare di controllare, lascia che il respiro ti controlli.`,
  },
  defusione: {
    titolo: 'Defusione cognitiva (ACT)',
    descrizione: `La tua mente ti sta raccontando una storia molto triste. Ma tu non sei quella storia. Proviamo un esperimento: aggiungi davanti al tuo pensiero le parole **"In questo momento, ho il pensiero che..."**

Per esempio: "In questo momento, ho il pensiero di essere un fallito".

Riesci a sentire come quel pensiero perde un po' di potenza? Diventa un oggetto, come una nuvola che passa. Puoi osservarlo passare senza doverlo inseguire.`,
  },
  ristrutturazione: {
    titolo: 'Ristrutturazione cognitiva (CBT)',
    descrizione: `Noto che la tua mente prevede un futuro terribile. È un meccanismo di protezione, ma spesso sbaglia. Ti faccio tre domande:

1. Qual è la prova **concreta** che questo evento negativo accadrà?
2. Se accadesse, quali risorse hai già per affrontarlo?
3. Cosa diresti a un tuo caro amico se fosse nei tuoi panni?

Le risposte che darai saranno molto più gentili di quelle che dai a te stesso.`,
  },
  scrittura: {
    titolo: 'Scrittura espressiva',
    descrizione: `Se ti va, prendi un foglio virtuale e scrivi per 3 minuti senza fermarti. Inizia così:

**"Oggi il mio corpo mi sta dicendo..."**

Non preoccuparti della grammatica. Metti parole sul caos. Se senti che le parole si fermano, scrivi "non so cosa scrivere" fino a che qualcosa non esce. Io aspetto.`,
  },
  visualizzazione: {
    titolo: 'Visualizzazione guidata',
    descrizione: `Chiudi gli occhi se puoi. Immagina di essere in un luogo che ti ha sempre trasmesso pace. Un bosco, una spiaggia, una stanza accogliente. Nota i colori, le temperature, i suoni.

Ora, immagina di mettere il tuo problema in un contenitore, come un baule o una scatola. Lo chiudi con un lucchetto. Lo metti da parte, in un angolo di questo luogo sicuro.

Il problema è ancora lì, ma per ora, non devi occupartene.`,
  },
};
