import SwiftUI

struct SoundscapeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedScene: String?
    @State private var playing = false

    private let scenes = [
        ("forest.fill", "Foresta", "Foglie e uccelli", Color(red: 0.2, green: 0.7, blue: 0.3)),
        ("water.waves", "Oceano", "Onde e brezza", Color(red: 0.2, green: 0.4, blue: 0.9)),
        ("cloud.rain.fill", "Pioggia", "Gocce e tuoni", Color(red: 0.4, green: 0.5, blue: 0.7)),
        ("sparkles", "Stelle", "Campane celesti", Color(red: 0.5, green: 0.3, blue: 1.0)),
        ("flame.fill", "Camino", "Fuoco e crepitio", Color(red: 1.0, green: 0.5, blue: 0.2)),
        ("moon.stars.fill", "Notte", "Silenzio cosmico", Color(red: 0.2, green: 0.1, blue: 0.4)),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Scegli un paesaggio sonoro").font(.headline).foregroundStyle(Theme.text)
                        Text("Ogni ambiente genera un'atmosfera unica per il tuo momento di calma.")
                            .font(.subheadline).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(scenes, id: \.1) { scene in
                                Button {
                                    withAnimation(.spring) {
                                        if selectedScene == scene.1 { playing.toggle() }
                                        else { selectedScene = scene.1; playing = true }
                                    }
                                } label: {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle().fill(scene.3.opacity(0.2)).frame(width: 64, height: 64)
                                            Image(systemName: selectedScene == scene.1 && playing ? "pause.circle.fill" : scene.0)
                                                .font(.title).foregroundStyle(scene.3)
                                                .symbolEffect(.pulse, isActive: selectedScene == scene.1 && playing)
                                        }
                                        Text(scene.1).font(.callout.weight(.semibold)).foregroundStyle(Theme.text)
                                        Text(scene.2).font(.caption2).foregroundStyle(Theme.muted)
                                    }
                                    .frame(maxWidth: .infinity).padding(16)
                                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                                    .overlay(alignment: .topTrailing) {
                                        if selectedScene == scene.1 && playing {
                                            Circle().fill(scene.3).frame(width: 8, height: 8).padding(8)
                                        }
                                    }
                                }
                            }
                        }
                        if playing, let sceneName = selectedScene, let scene = scenes.first(where: { $0.1 == sceneName }) {
                            VStack(spacing: 12) {
                                Text("🎵 In ascolto: \(scene.1)").font(.subheadline.weight(.medium)).foregroundStyle(scene.3)
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Theme.cardBorder).frame(height: 4)
                                    Capsule().fill(scene.3).frame(width: 120, height: 4)
                                }
                                Button("Stop") { withAnimation { playing = false } }
                                    .font(.caption.weight(.semibold)).foregroundStyle(Theme.muted)
                            }
                            .padding(16)
                            .glassEffect(.regular, in: .rect(cornerRadius: 20))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Soundscape")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Chiudi") { dismiss() } }
            }
        }
    }
}
