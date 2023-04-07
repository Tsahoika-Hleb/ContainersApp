import UIKit
import CoreImage

final class ImageToTextProcessor {
    private let imageTextRecognizer: ImageTextRecognizer = .init()

    func process(image: UIImage, isVertical: Bool = true) async throws -> (UIImage?, String) {
        let outputImage = await processImageInBackground(image: image, isVertical: isVertical)
        let recognizedText = try await imageTextRecognizer.recognizeText(from: outputImage)
        return (outputImage, recognizedText)
    }

    func process(images: [UIImage], isVertical: Bool = true) async throws -> (UIImage?, String) {
        let outputImage = await processImagesInBackground(images: images, isVertical: isVertical)
        let recognizedText = try await imageTextRecognizer.recognizeText(from: outputImage)
        return (outputImage, recognizedText)
    }

    private func processImageInBackground(image: UIImage, isVertical: Bool) async -> UIImage {
        return await withCheckedContinuation({ continuation in
            let outputImage = OpenCVWrapper.processImage(image, isVertical: isVertical)
            continuation.resume(returning: outputImage)
        })
    }

    private func processImagesInBackground(images: [UIImage], isVertical: Bool) async -> UIImage {
        return await withCheckedContinuation({ continuation in
            let outputImage = OpenCVWrapper.processImages(images, isVertical: isVertical)
            continuation.resume(returning: outputImage)
        })
    }
}
