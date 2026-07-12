import SwiftUI

enum AIPersona: String, CaseIterable {
    case therapist = "Terapeuta"
    case coach = "Coach"
    case friend = "Amico"

    var icon: String {
        switch self { case .therapist: return "brain.head.profile"; case .coach: return "figure.run"; case .friend: return "heart.fill" }
    }

    var systemPrompt: String {
        switch self {
        case .therapist: return "Sei uno psicoterapeuta empatico e professionista. Rispondi con calore, ascolto attivo e tecniche di psicologia cognitivo-comportamentale. Fai domande aperte. Non dai diagnosi ma supporto emotivo."
        case .coach: return "Sei un life coach motivazionale. Aiuti a fissare obiettivi, superare blocchi e mantenere la motivazione. Sei diretto, energico e propositivo. Dai consigli pratici e azionabili."
        case .friend: return "Sei un amico vicino e affettuoso. Parli in modo informale, condividi esperienze e supporti senza giudicare. Usa un linguaggio quotidiano, a volte anche umoristico."
        }
    }
}

struct PersonaPickerView: View {
    @Binding var selected: AIPersona

    var body: some View {
        Picker("Stile", selection: $selected) {
            ForEach(AIPersona.allCases, id: \.self) { p in
                Label(p.rawValue, systemImage: p.icon).tag(p)
            }
        }
        .pickerStyle(.segmented)
    }
}
