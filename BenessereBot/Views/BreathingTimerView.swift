import SwiftUI

struct BreathingTimerView: View {
    @ObservedObject var service: BreathingService

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "wind")
                    .font(.title2)
                    .foregroundStyle(.teal)
                    .symbolEffect(.pulse, isActive: service.isActive)

                VStack(alignment: .leading, spacing: 2) {
                    Text(service.phase)
                        .font(.subheadline.weight(.medium))
                    Text("\(service.secondsLeft)s")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    service.stop()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }

            ProgressView(value: service.progress)
                .tint(.teal)
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(radius: 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    BreathingTimerView(service: BreathingService())
}
