import Foundation

extension String {
    enum Identification: String {
        case url = #"^(?:https?://)?(?:www\.)?(?:[\w-]+\.)+[a-z]{2,}(?:/[\w-./?%&=]*)?$"#
        case serialNumber = "^[A-Z]{3}[UJZ]\\d{7}$"
    }
    
    func validate(idCase: Identification) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", idCase.rawValue)
        return predicate.evaluate(with: self)
    }
}

extension String {
    
    func validateCheckDigit() -> Bool {
        guard self.count > 10 else { return false }
        
        var containerNumberForValidation = self
        let checkDigit = Int(String(containerNumberForValidation.removeLast()))
        
        let weights = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
        let m: [String: Int] = [
            "A": 10,
            "B": 12,
            "C": 13,
            "D": 14,
            "E": 15,
            "F": 16,
            "G": 17,
            "H": 18,
            "I": 19,
            "J": 20,
            "K": 21,
            "L": 23,
            "M": 24,
            "N": 25,
            "O": 26,
            "P": 27,
            "Q": 28,
            "R": 29,
            "S": 30,
            "T": 31,
            "U": 32,
            "V": 34,
            "W": 35,
            "X": 36,
            "Y": 37,
            "Z": 38,
        ]
        var sum = 0
        for i in 0..<10 {
            var digit = 0
            let index = containerNumberForValidation.index(self.startIndex, offsetBy: i)
            let char = containerNumberForValidation[index]
            if i < 4 {
                guard let val = m[String(char)] else { return false }
                digit = val
            } else {
                guard let val = Int(String(char)) else { return false }
                digit = val
            }
            sum += digit * weights[i]
        }
        
        var remainder = sum % 11
        remainder = remainder == 10 ? 0 : remainder
        
        return checkDigit == remainder
        
    }
}

