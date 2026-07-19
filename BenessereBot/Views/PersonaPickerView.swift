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
        HStack(spacing: 0) {
            ForEach(AIPersona.allCases, id: \.self) { p in
                Button {
                    withAnimation(.spring) { selected = p }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: p.icon)
                            .font(.system(size: 14))
                        Text(p.rawValue)
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(selected == p ? Theme.accent : Theme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selected == p ? Theme.accent.opacity(0.12) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(4)
        .background(Theme.bgTop.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
