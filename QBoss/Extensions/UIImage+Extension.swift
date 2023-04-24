import UIKit

extension UIImage {
    
    func getData() -> Data? {
        self.jpegData(compressionQuality: 0.5)
    }
}
