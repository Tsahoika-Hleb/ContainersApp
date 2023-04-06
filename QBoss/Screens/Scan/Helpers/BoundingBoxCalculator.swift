import UIKit

final class BoundingBoxCalculator {
    
    private let edgeOffset: CGFloat = 8.0
    
    func createBoundingBox(convertedRect: CGRect, viewBounds: CGRect) -> CGRect {
        
        var resultRect = convertedRect
        if resultRect.origin.x < 0 {
            resultRect.origin.x = edgeOffset
        }
        if resultRect.origin.y < 0 {
            resultRect.origin.y = edgeOffset
        }
        if resultRect.maxY > viewBounds.maxY {
            resultRect.size.height =
            viewBounds.maxY - resultRect.origin.y - edgeOffset
        }
        if resultRect.maxX > viewBounds.maxX {
            resultRect.size.width =
            viewBounds.maxX - resultRect.origin.x - edgeOffset
        }
        return resultRect
    }
    
    /**
     This function crops an input image based on a specified rectangular area of interest (cropRect) and view bounds (viewBoundsRect).
     The resulting cropped image is returned
     */
    func getBoundingBoxImage(cropRect: CGRect, viewBoundsRect: CGRect, pixelBuffer: CVPixelBuffer) -> UIImage? {
        // Convert pixelBuffer to CIImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))) else { return nil }
        
        let inputImage = UIImage(cgImage: cgImage)
        
        let scaleX = inputImage.size.width / viewBoundsRect.width
        let scaleY = inputImage.size.height / viewBoundsRect.height
        
        let cropZone = CGRect(x: cropRect.origin.x * scaleX,
                              y: cropRect.origin.y * scaleY,
                              width: cropRect.size.width * scaleX + edgeOffset * 2,
                              height: cropRect.size.height * scaleY + edgeOffset * 2)
        
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone) else { return nil }
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}
