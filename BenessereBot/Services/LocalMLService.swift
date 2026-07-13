import Foundation
import CoreML
import NaturalLanguage

@MainActor
class LocalMLService {
    static let shared = LocalMLService()

    private var model: MLModel?
    private let tokenizer = NLTokenizer(unit: .word)

    var isAvailable: Bool { model != nil }

    func loadModel(named name: String = "openelm-270m") {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mlpackage") else { return }
        guard let compiled = try? MLModel.compileModel(at: url) else { return }
        model = try? MLModel(contentsOf: compiled)
    }

    func generateReply(for text: String) async -> String? {
        guard let model = model else { return nil }

        let prompt = "Utente: \(text)\nBenessereBot:"
        tokenizer.string = prompt
        let tokens = Array(tokenizer.tokens(for: prompt.startIndex..<prompt.endIndex))

        do {
            let input = try MLMultiArray(shape: [1, NSNumber(value: tokens.count)], dataType: .float32)
            for (i, token) in tokens.enumerated() {
                input[i] = NSNumber(value: Float(token.hashValue) / 1000.0)
            }

            let feature = try MLDictionaryFeatureProvider(dictionary: ["input_ids": input])
            let output = try model.prediction(from: feature)

            if let tokenIds = output.featureValue(for: "logits")?.multiArrayValue {
                return "[OpenELM 270M] \(tokenIds.debugDescription.prefix(200))"
            }
        } catch {
            print("[LocalML] Error: \(error)")
        }
        return nil
    }
}
