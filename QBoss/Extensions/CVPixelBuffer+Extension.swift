import UIKit
import CoreVideo

extension CVPixelBuffer {
    func getImage() -> UIImage? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        guard let context = CGContext(data: baseAddress,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue),
              let cgImage = context.makeImage() else { return nil }

        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        CVPixelBufferUnlockBaseAddress(self, .readOnly)

        return image
    }
}
