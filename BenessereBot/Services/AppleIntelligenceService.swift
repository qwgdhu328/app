import Foundation
import NaturalLanguage

@MainActor
class AppleIntelligenceService {
    static let shared = AppleIntelligenceService()

    enum AnalysisResult {
        case needsCloud
        case localReply(String)
    }

    private let embedding: NLEmbedding? = NLEmbedding.wordEmbedding(for: .italian)
    private let sentenceEmbedding: NLEmbedding? = NLEmbedding.sentenceEmbedding(for: .italian)

    private let responses: [(query: String, reply: String)] = [
        ("ciao come stai", "Ciao! Come stai oggi? Sono qui per ascoltarti."),
        ("buongiorno", "Buongiorno! Come è iniziata la tua giornata?"),
        ("buonasera", "Buonasera! Come è stata la tua giornata?"),
        ("grazie", "Di niente! Sono qui per te. C'è altro di cui vuoi parlare?"),
        ("sto bene", "Sono felice di sapere che stai bene! Cosa ti passa per la mente oggi?"),
        ("non so", "Va bene non sapere. A volte basta iniziare a parlare e le cose diventano più chiare."),
        ("aiuto", "Sono qui per te. Cosa ti sta preoccupando in questo momento?"),
        ("tutto bene", "Mi fa piacere! Se mai vorrai parlare di qualcosa, io sono qui."),
        ("triste", "Mi dispiace che tu ti senta così. Vuoi parlare di cosa ti ha reso triste?"),
        ("ansia", "L'ansia può essere molto pesante. Facciamo un respiro insieme. Cosa senti in questo momento?"),
        ("arrabbiato", "La rabbia è un'emozione valida. Cosa ha scatenato questa sensazione?"),
        ("stress", "Lo stress può accumularsi. Ti va di fare un esercizio di respirazione insieme?"),
        ("felice", "Che bello sentirti felice! Cosa ha reso speciale la tua giornata?"),
        ("stanco", "La stanchezza è importante da ascoltare. Stai dormendo abbastanza?"),
        ("paura", "La paura è un'emozione potente. Cosa ti spaventa in questo momento?"),
        ("piangere", "Va bene piangere. Le lacrime aiutano a rilasciare le emozioni. Sono qui con te."),
        ("fidanzato", "Le relazioni possono essere complesse. Vuoi parlarne?"),
        ("lavoro", "Il lavoro occupa gran parte della nostra vita. Cosa ti preoccupa?"),
        ("famiglia", "La famiglia è importante. Vuoi condividere cosa stai vivendo?"),
        ("amici", "Le amicizie arricchiscono la vita. Com'è la tua situazione sociale?"),
        ("futuro", "Il futuro può sembrare incerto. Cosa sogni per te stesso?"),
        ("amore", "L'amore è un viaggio meraviglioso e complicato. Cosa succede?"),
        ("sofferenza", "La sofferenza merita di essere ascoltata. Sono qui, prenditi tutto il tempo che ti serve."),
    ]

    private let supportivePhrases: [(sentiment: ClosedRange<Double>, phrase: String)] = [
        ((-1.0)...(-0.4), "Ti ascolto. Il dolore che senti è reale e importante. Non devi affrontarlo da solo."),
        ((-0.4)...(-0.1), "Capisco che questo momento è difficile. A volte parlare dei nostri sentimenti è il primo passo per stare meglio."),
        ((-1.0)...(-0.4), "Quello che provi è valido. Prenditi un momento per respirare, un passo alla volta."),
        ((-0.1)...(0.1), "Ti ascolto. Cosa ti passa per la mente in questo momento?"),
        ((-0.1)...(0.1), "Grazie per aver condiviso questo con me. Come posso supportarti meglio?"),
        ((0.1)...(0.4), "Mi fa piacere sentire che le cose vanno meglio. Cosa ha contribuito a questo cambiamento?"),
        ((0.4)...(1.0), "Sono contento per te! Continuare a coltivare queste emozioni positive fa bene."),
    ]

    func analyze(_ text: String) -> AnalysisResult {
        let lower = text.lowercased().trimmingCharacters(in: .whitespaces)

        if detectCrisisKeywords(lower) {
            return .localReply("Sono molto preoccupato per quello che stai dicendo. Ricorda che non sei solo — il Telefono Amico è disponibile 24/7 al 199 284 284. Se sei in pericolo immediato, chiama il 112. Io sono qui con te, ma queste risorse possono darti l'aiuto immediato di cui hai bisogno.")
        }

        if let reply = matchSemantically(lower) {
            return .localReply(reply)
        }

        let sentiment = detectSentiment(text)
        let phrase = supportivePhrases.first { $0.sentiment.contains(sentiment) }?.phrase ?? supportivePhrases[3].phrase
        return .localReply(phrase)
    }

    private func matchSemantically(_ text: String) -> String? {
        let cleaned = text.lowercased()
            .replacingOccurrences(of: "[?.,!]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)

        if cleaned.count < 3 { return nil }

        if let sentenceEmbedding = sentenceEmbedding {
            var bestMatch: (index: Int, distance: NLDistance)?
            for (i, pair) in responses.enumerated() {
                let dist = sentenceEmbedding.distance(between: cleaned, and: pair.query)
                if dist < 0.5 {
                    if bestMatch == nil || dist < bestMatch!.distance {
                        bestMatch = (i, dist)
                    }
                }
            }
            if let match = bestMatch {
                return responses[match.index].reply
            }
        }

        if let _ = embedding {
            var bestScore: Float = 0
            var bestReply: String?
            for pair in responses {
                let words = pair.query.split(separator: " ")
                var score: Float = 0
                for word in words {
                    if let _ = embedding?.neighbors(for: String(word), maximumCount: 5) {
                        let neighbors = embedding?.neighbors(for: String(word), maximumCount: 10) ?? []
                        for (neighbor, _) in neighbors {
                            if cleaned.contains(neighbor) {
                                score += 1
                            }
                        }
                    }
                }
                if score > bestScore {
                    bestScore = score
                    bestReply = pair.reply
                }
            }
            if bestScore > 0 {
                return bestReply
            }
        }

        for pair in responses {
            if cleaned.contains(pair.query) {
                return pair.reply
            }
        }

        return nil
    }

    private func detectSentiment(_ text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let sentiment = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let sentimentTag = sentiment.0,
           let score = Double(sentimentTag.rawValue) {
            return score
        }
        return 0
    }

    func extractKeywords(_ text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = text
        var keywords: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if tag == .personalName || tag == .placeName || tag == .organizationName {
                keywords.append(String(text[range]))
            }
            return true
        }
        return keywords
    }

    func detectLanguage(_ text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        if let lang = recognizer.dominantLanguage {
            return lang.rawValue
        }
        return "it"
    }

    private func detectCrisisKeywords(_ text: String) -> Bool {
        let crisisTerms = ["suicidio", "uccidermi", "morire", "non voglio vivere", "farla finita",
                           "autolesionismo", "tagliarmi", "fammi del male", "non ce la faccio più",
                           "voglio scomparire", "non voglio più svegliarmi"]
        return crisisTerms.contains { text.contains($0) }
    }
}
