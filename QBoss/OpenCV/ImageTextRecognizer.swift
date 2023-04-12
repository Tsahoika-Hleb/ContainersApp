import UIKit
import Vision

final class ImageTextRecognizer {
    
    private var textRecognitionRequest: VNRecognizeTextRequest?
    
    init() { createTextRecognitionRequest() }
    
    // MARK: - actions
    func recognizeText(from image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }
        return await performRecognitionRequest(on: cgImage)
    }
    
    private func createTextRecognitionRequest() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
        textRecognitionRequest?.recognitionLevel = .accurate
        textRecognitionRequest?.usesCPUOnly = false
    }
    
    private func performRecognitionRequest(on image: CGImage) async -> String? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let textRecognitionRequest = self.textRecognitionRequest else {
                    continuation.resume(returning: nil)
                    return
                }
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                try? handler.perform([textRecognitionRequest])
                
                guard let observations = textRecognitionRequest.results else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let text = observations.compactMap({ $0.topCandidates(1).first?.string }).joined()
                continuation.resume(returning: text)
            }
        }
    }
}
