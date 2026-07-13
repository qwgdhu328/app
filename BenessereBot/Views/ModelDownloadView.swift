import SwiftUI

struct ModelDownloadView: View {
    let onComplete: () -> Void
    @State private var status = "Preparazione download..."
    @State private var progress: Float = 0
    @State private var error: String?
    @State private var hasStarted = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "cpu.and.arrow.down")
                .font(.system(size: 60))
                .foregroundStyle(Theme.accent)

            Text("Installazione modello AI")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.text)

            Text("Sto scaricando Mistral 7B (4.1 GB)\nla prima conversazione partirà automaticamente.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
                .padding(.horizontal, 32)

            if let error = error {
                VStack(spacing: 12) {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Button("Riprova") {
                        self.error = nil
                        progress = 0
                        status = "Preparazione download..."
                        hasStarted = false
                        start()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(Theme.accent)
                    .padding(.horizontal, 32)

                Text(status)
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }

            Spacer()
        }
        .background(Theme.bg)
        .onAppear { start() }
    }

    private func start() {
        guard !hasStarted else { return }
        hasStarted = true
        status = "Avvio download..."
        LocalLLMService.shared.downloadProgress = 0

        Task {
            let ok = await LocalLLMService.shared.startDownload()
            guard ok else { return }

            while LocalLLMService.shared.isDownloading {
                progress = LocalLLMService.shared.downloadProgress
                status = "Download: \(Int(progress * 100))%"
                try? await Task.sleep(nanoseconds: 500_000_000)
            }

            if let err = LocalLLMService.shared.downloadError {
                error = err
                return
            }

            progress = 1
            status = "Caricamento modello..."
            _ = await LocalLLMService.shared.prepare()

            if LocalLLMService.shared.isReady {
                withAnimation { onComplete() }
            } else {
                error = "Errore caricamento modello"
            }
        }
    }
}
