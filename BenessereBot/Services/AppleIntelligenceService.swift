import Foundation
import NaturalLanguage

@MainActor
class AppleIntelligenceService {
    static let shared = AppleIntelligenceService()

    enum AnalysisResult {
        case needsCloud
        case localReply(String)
    }

    private let supportivePhrases = [
        "Ti ascolto. Cosa ti passa per la mente in questo momento?",
        "Grazie per aver condiviso questo con me. Come posso supportarti meglio?",
        "Capisco come ti senti. A volte parlare dei nostri sentimenti è il primo passo per stare meglio.",
        "È normale sentirsi così. Ti va di approfondire cosa ha scatenato questa emozione?",
        "Sei coraggioso ad affrontare queste sensazioni. Ricorda che non sei solo.",
        "Ogni emozione ha un messaggio per noi. Cosa pensi che questa sensazione stia cercando di dirti?",
        "La consapevolezza è il primo passo verso il cambiamento. Sei già sulla strada giusta.",
        "Prenditi un momento. Respira. Non c'è fretta di risolvere tutto ora.",
    ]

    private let greetingResponses: [String: String] = [
        "ciao": "Ciao! Come stai oggi? Sono qui per ascoltarti.",
        "buongiorno": "Buongiorno! Come è iniziata la tua giornata?",
        "buonasera": "Buonasera! Come è stata la tua giornata?",
        "grazie": "Di niente! Sono qui per te. C'è altro di cui vuoi parlare?",
        "sto bene": "Sono felice di sapere che stai bene! C'è qualcosa di particolare che vuoi condividere?",
        "non so": "Va bene non sapere. A volte basta iniziare a parlare e le cose diventano più chiare.",
        "aiuto": "Sono qui per te. Cosa ti sta preoccupando in questo momento?",
        "tutto bene": "Mi fa piacere! Ricorda che puoi sempre parlare con me di qualsiasi cosa.",
    ]

    func analyze(_ text: String) -> AnalysisResult {
        let lower = text.lowercased().trimmingCharacters(in: .whitespaces)

        for (key, reply) in greetingResponses {
            if lower == key || lower.hasPrefix(key) || lower.hasSuffix(key) {
                return .localReply(reply)
            }
        }

        if lower.count < 15 {
            return .localReply(supportivePhrases.randomElement()!)
        }

        let sentiment = detectSentiment(text)
        let containsCrisis = detectCrisisKeywords(text)

        if containsCrisis {
            return .needsCloud
        }

        if abs(sentiment) < 0.3 && lower.count > 30 {
            return .needsCloud
        }

        if lower.count > 100 {
            return .needsCloud
        }

        return .localReply(supportivePhrases.randomElement()!)
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
        let lower = text.lowercased()
        return crisisTerms.contains { lower.contains($0) }
    }
}
