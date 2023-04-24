import UIKit
import TensorFlowLiteTaskVision

final class DetectionProcessorHelper {
    
    private let colors = [
        UIColor.red,
        UIColor(displayP3Red: 90.0 / 255.0, green: 200.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0),
        UIColor.green,
        UIColor.orange,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.brown,
    ]
    
    func processDetections(_ detections: [Detection], imageSize: CGSize, viewBoundsRect: CGRect) -> [ObjectOverlay] {
        
        var objectOverlays: [ObjectOverlay] = []
        
        for detection in detections {
            
            guard let category = detection.categories.first else { continue }
            
            let calculator = BoundingBoxCalculator()
            let rect = calculator
                .createBoundingBox(convertedRect: detection.boundingBox.applying(
                    CGAffineTransform( scaleX: viewBoundsRect.size.width / imageSize.width,
                                       y: viewBoundsRect.size.height / imageSize.height)),
                                   viewBounds: viewBoundsRect)
            
            let objectDescription = String(
                format: "\(category.label ?? "Unknown") (%.2f)",
                category.score)
            
            let displayColor = colors[category.index % colors.count]
            
            let size = objectDescription.size(withAttributes: [.font: UIFont.displayFont])
            
            let objectOverlay = ObjectOverlay(
                name: objectDescription, borderRect: rect, nameStringSize: size,
                color: displayColor,
                font: UIFont.displayFont)
            
            objectOverlays.append(objectOverlay)
        }
        
        return objectOverlays
    }
}
