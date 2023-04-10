import UIKit
import Vision

final class ImageTextRecognizer {
    private var textRecognitionRequest: VNRecognizeTextRequest?

    init() { createTextRecognitionRequest() }

    // MARK: - actions
    
    func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageTextRecognizer",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage from UIImage."])
        }

        return try await performRecognitionRequest(on: cgImage)
    }

    private func createTextRecognitionRequest() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
        textRecognitionRequest?.recognitionLevel = .accurate
    }

    private func performRecognitionRequest(on image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            guard let textRecognitionRequest = textRecognitionRequest else {
                continuation.resume(throwing: NSError(domain: "ImageTextRecognizer",
                                                      code: 2,
                                                      userInfo: [NSLocalizedDescriptionKey: "Text recognition request not created."]))
                return
            }

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([textRecognitionRequest])

                guard let observations = textRecognitionRequest.results else {
                    continuation.resume(throwing: NSError(domain: "ImageTextRecognizer",
                                                          code: 3,
                                                          userInfo: [NSLocalizedDescriptionKey: "Failed to get text observations."]))
                    return
                }

                let text = observations.compactMap({ $0.topCandidates(1).first?.string }).joined()
                continuation.resume(returning: text)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
