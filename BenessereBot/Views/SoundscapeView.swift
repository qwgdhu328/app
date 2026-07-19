import SwiftUI
import AVFoundation
import AudioToolbox

struct SoundscapeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedScene: String?
    @State private var playing = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioEngine: AVAudioEngine?
    @State private var progress: Double = 0
    @State private var timer: Timer?

    private let scenes = [
        ("forest.fill", "Foresta", "Foglie e uccelli", Color(red: 0.25, green: 0.70, blue: 0.35)),
        ("water.waves", "Oceano", "Onde e brezza", Color(red: 0.25, green: 0.45, blue: 0.85)),
        ("cloud.rain.fill", "Pioggia", "Gocce e tuoni", Color(red: 0.45, green: 0.50, blue: 0.70)),
        ("sparkles", "Stelle", "Campane celesti", Color(red: 0.55, green: 0.35, blue: 0.90)),
        ("flame.fill", "Camino", "Fuoco e crepitio", Color(red: 0.90, green: 0.50, blue: 0.25)),
        ("moon.stars.fill", "Notte", "Silenzio cosmico", Color(red: 0.30, green: 0.20, blue: 0.50)),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Scegli un paesaggio sonoro")
                            .font(.headline).foregroundStyle(Theme.text)
                        Text("Ogni ambiente genera un'atmosfera unica per il tuo momento di calma.")
                            .font(.subheadline).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(scenes, id: \.1) { scene in
                                Button {
                                    withAnimation(.spring) {
                                        if selectedScene == scene.1 {
                                            playing.toggle()
                                            playing ? play(scene: scene.1) : stop()
                                        } else {
                                            stop()
                                            selectedScene = scene.1
                                            playing = true
                                            play(scene: scene.1)
                                        }
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    VStack(spacing: 10) {
                                        ZStack {
                                            Circle().fill(scene.3.opacity(0.15)).frame(width: 56, height: 56)
                                            Image(systemName: selectedScene == scene.1 && playing ? "pause.circle.fill" : scene.0)
                                                .font(.title2).foregroundStyle(scene.3)
                                                .symbolEffect(.pulse, isActive: selectedScene == scene.1 && playing)
                                        }
                                        Text(scene.1).font(.callout.weight(.semibold)).foregroundStyle(Theme.text)
                                        Text(scene.2).font(.caption2).foregroundStyle(Theme.muted)
                                    }
                                    .frame(maxWidth: .infinity).padding(16)
                                    .background(Theme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(
                                        selectedScene == scene.1 && playing ? scene.3.opacity(0.4) : Theme.cardBorder, lineWidth: 1))
                                }
                            }
                        }

                        if playing, let sceneName = selectedScene, let scene = scenes.first(where: { $0.1 == sceneName }) {
                            VStack(spacing: 10) {
                                Text("In ascolto: \(scene.1)")
                                    .font(.subheadline.weight(.medium)).foregroundStyle(scene.3)
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Theme.cardBorder).frame(height: 4)
                                    Capsule().fill(scene.3).frame(width: 120, height: 4)
                                }
                                Button("Stop") {
                                    withAnimation { stop() }
                                }
                                .font(.caption.weight(.semibold)).foregroundStyle(Theme.muted)
                                .padding(.horizontal, 20).padding(.vertical, 8)
                                .background(Theme.surface)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.cardBorder, lineWidth: 1))
                            }
                            .padding(16)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Soundscape")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }

    private func play(scene: String) {
        if let url = Bundle.main.url(forResource: scene, withExtension: "mp3") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            startProgress()
        } else {
            playGeneratedTone(for: scene)
        }
    }

    private func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioEngine?.stop()
        audioEngine = nil
        timer?.invalidate()
        timer = nil
        playing = false
        progress = 0
    }

    private func startProgress() {
        progress = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.linear(duration: 0.3)) {
                progress = Double.random(in: 0.2...0.9)
            }
        }
    }

    private func playGeneratedTone(for scene: String) {
        let frequencies: [String: Float] = [
            "Foresta": 220, "Oceano": 180, "Pioggia": 300,
            "Stelle": 440, "Camino": 160, "Notte": 100
        ]
        guard let freq = frequencies[scene] else { return }

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100) else { return }
        buffer.frameLength = 44100
        let channels = UnsafeMutableBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength))

        for i in 0..<Int(buffer.frameLength) {
            let t = Float(i) / 44100.0
            let envelope = exp(-t * 0.5)
            let wave = sin(2 * .pi * freq * t) * 0.06
            let noise = Float.random(in: -0.02...0.02)
            channels[i] = (wave + noise) * envelope
        }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? engine.start()

        player.scheduleBuffer(buffer, at: nil, options: .loops)
        player.play()

        audioEngine = engine
        startProgress()
    }
}
