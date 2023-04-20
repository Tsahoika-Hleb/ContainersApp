import Foundation
import TensorFlowLiteTaskVision

protocol TFManagerDelegateProtocol: AnyObject {
    func drawAfterPerformingCalculations(onDetections detections: [Detection],
                                         withImageSize imageSize: CGSize,
                                         pixelBuffer: CVPixelBuffer)
}

final class TFManager {
    
    // MARK: - Properties
    weak var delegate: TFManagerDelegateProtocol?
    
    // Holds the results at any time
    private var result: Result?
    private var isInferenceQueueBusy = false
    
    private var objectDetectionHelper: ObjectDetectionHelper? = ObjectDetectionHelper(
        modelFileInfo: FileInfo("containerDetection", "tflite"),
        scoreThreshold: 0.4,
        maxResults: 12
    )
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    func detect(pixelBuffer: CVPixelBuffer) {
        result = self.objectDetectionHelper?.detect(frame: pixelBuffer)
        
        guard let displayResult = result else {
            return
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        DispatchQueue.main.async {
            self.delegate?.drawAfterPerformingCalculations(
                onDetections: displayResult.detections,
                withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)), pixelBuffer: pixelBuffer)
        }
    }
}
