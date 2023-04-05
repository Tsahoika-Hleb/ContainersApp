import UIKit

final class BoundingBoxCalculator {
    
    private let edgeOffset: CGFloat = 2.0
    
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
    
    func getBoundingBoxImage(cropRect: CGRect, viewBoundsRect: CGRect, pixelBuffer: CVPixelBuffer) -> UIImage? {
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))) else { return nil }
        let inputImage = UIImage(cgImage: cgImage)
    
        let imageViewScale = max(inputImage.size.width / viewBoundsRect.width,
                                 inputImage.size.height / viewBoundsRect.height)
        print(viewBoundsRect)
        print(cropRect)
//        print("ImageViewScale: \(imageViewScale)")
        let cropZone = CGRect(x: cropRect.origin.x * imageViewScale,
                              y: cropRect.origin.y * imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)
//        print("Crop Zone: \(cropZone)")
//        print("-----------------------------------------")
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone) else { return nil }
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
}
