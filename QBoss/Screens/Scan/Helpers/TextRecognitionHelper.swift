//import Foundation
//import MLImage
//import MLKit
//
//
//actor TextRecognitionHelper {
//    
//    func recognizeText(in image: UIImage) async -> String? {
//        await withCheckedContinuation { continuation in
//            let visionImage = VisionImage(image: image)
//            //        let orientation = UIUtilities.imageOrientation(fromDevicePosition: .back)
//            //        visionImage.orientation = orientation
//
//            let recognizedText: Text? = try? TextRecognizer.textRecognizer().results(in: visionImage)
//            continuation.resume(returning: recognizedText?.blocks
//                .flatMap { $0.lines.flatMap { $0.elements.flatMap { $0.text } } }
//                .map { String($0)}
//                .joined(separator: " "))
//        }
//    }
//}
