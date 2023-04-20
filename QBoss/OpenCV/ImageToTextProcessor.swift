import UIKit
import CoreImage

typealias ProcessedImageResult = (UIImage, String)

final class ImageToTextProcessor {
    
    private let imageTextRecognizer: ImageTextRecognizer = .init()
    
    func process(image: UIImage) async -> ProcessedImageResult? {
        guard let outputImage = await processImageInBackground(image: image),
              let recognizedText = await imageTextRecognizer.recognizeText(from: outputImage) else { return nil }
        return (outputImage, recognizedText)
    }
    
    func process(images: [UIImage], isVertical: Bool) async -> ProcessedImageResult? {
        guard let outputImage = await processImagesInBackground(images: images, isVertical: isVertical),
              let recognizedText = await imageTextRecognizer.recognizeText(from: outputImage) else { return nil }
        return (outputImage, recognizedText)
    }
    
    private func processImageInBackground(image: UIImage) async -> UIImage? {
        return await withCheckedContinuation({ continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let outputImage = OpenCVWrapper.processImage(image)
                continuation.resume(returning: outputImage)
            }
        })
    }
    
    private func processImagesInBackground(images: [UIImage], isVertical: Bool) async -> UIImage? {
        return await withCheckedContinuation({ continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let outputImage = OpenCVWrapper.processImages(images, isVerticalText: isVertical)
                continuation.resume(returning: outputImage)
            }
        })
    }
}
