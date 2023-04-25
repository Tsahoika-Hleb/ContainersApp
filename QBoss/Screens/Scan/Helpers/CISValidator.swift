import Foundation

final class CISValidator {

    enum NumberPart {
        case code
        case digits
    }

    func handleResults(mainNumber: ProcessedImageResult?, partialNumber: ProcessedImageResult?) -> (UIImage, String, Bool)? {
        if let mainPair = mainNumber, let mainResult = getValidatedNumber(serialNumber: mainPair.1), mainResult.1 {
            return (mainPair.0, mainResult.0, mainResult.1)
        } else if let partrialPair = partialNumber, let partialResult = getValidatedNumber(serialNumber: partrialPair.1), partialResult.1 {
            return (partrialPair.0, partialResult.0, partialResult.1)
        } else if let mainPair = mainNumber, let mainResult = getValidatedNumber(serialNumber: mainPair.1) {
            return (mainPair.0, mainResult.0, mainResult.1)
        } else if let partrialPair = partialNumber, let partialResult = getValidatedNumber(serialNumber: partrialPair.1) {
            return (partrialPair.0, partialResult.0, partialResult.1)
        } else {
            return nil
        }
    }

    private func getValidatedNumber(serialNumber: String, isPartial: Bool = false) -> (String, Bool)? {
        var tempString = serialNumber.filter({ $0.isLetter || $0.isNumber && !$0.isWhitespace })
        guard tempString.count >= 10 else { return nil }

        let hasTypeCode = tempString.count >= 15

        let (isValid, codePart, digitsPart, checkDigitChar) = validateSerialNumberParts(tempString: tempString)
        guard isValid else { return nil }

        let typeCode = processTypeCode(tempString: tempString, hasTypeCode: hasTypeCode)
        tempString = codePart + digitsPart + checkDigitChar

        if tempString.count == 10, let checkDigit = countCheckDigit(serialNumber: tempString), isPartial {
            tempString += String(checkDigit)
        }

        guard tempString.count > 10 else { return nil }
        let isCheckDigitValid = validateCheckDigit(serialNumber: tempString)
        tempString += typeCode

        return (tempString, isCheckDigitValid)
    }

    private func validateSerialNumberParts(tempString: String) -> (Bool, String, String, String) {
        let hasCheckDigit = tempString.count != 10
        let codePart = processCodePart(tempString: tempString)
        let digitsPart = processDigitsPart(tempString: tempString)
        let checkDigitChar = hasCheckDigit ? processCheckDigit(tempString: tempString) : ""

        let isValid = codePart.validate(idCase: .letters)
        && digitsPart.validate(idCase: .digits)
        && (checkDigitChar.validate(idCase: .digits)
            || !hasCheckDigit)

        return (isValid, codePart, digitsPart, checkDigitChar)
    }

    private func processCodePart(tempString: String) -> String {
        var codePart = String(tempString.prefix(4))
        codePart = charReplace(inputString: codePart, part: .code)
        if let last = codePart.last, !["U", "J", "Z"].contains(last) {
            codePart.removeLast()
            codePart += "U"
        }

        return codePart
    }

    private func processDigitsPart(tempString: String) -> String {
        let digitsPart = String(tempString.dropFirst(4).prefix(6))
        return charReplace(inputString: digitsPart, part: .digits)
    }

    private func processCheckDigit(tempString: String) -> String {
        let checkDigitChar = String(tempString.dropFirst(10).first ?? Character(""))
        return charReplace(inputString: checkDigitChar, part: .digits)
    }

    private func processTypeCode(tempString: String, hasTypeCode: Bool) -> String {
        guard hasTypeCode else { return "" }
        let typeCode = String(tempString.dropFirst(11).prefix(2)) + "G1"
        return typeCode
    }

    private func charReplace(inputString: String, part: NumberPart) -> String {
        let lettersToDigits = ["O": "0", "S":"5", "Z": "2", "I": "1", "G": "6"]
        let digitsToLetters = Dictionary(uniqueKeysWithValues: lettersToDigits.map { ($1, $0) })
        var outputString = ""
        for char in inputString {
            let value = (part == .code) ? digitsToLetters[String(char)] : lettersToDigits[String(char)]
            outputString += value ?? String(char)
        }

        return outputString
    }

    private func validateCheckDigit(serialNumber: String) -> Bool {
        var containerNumberForValidation = serialNumber
        let checkDigit = Int(String(containerNumberForValidation.removeLast()))

        return checkDigit == countCheckDigit(serialNumber: containerNumberForValidation)
    }
    private func countCheckDigit(serialNumber: String) -> Int? {
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
            let index = serialNumber.index(serialNumber.startIndex, offsetBy: i)
            let char = serialNumber[index]
            if i < 4 {
                guard let val = m[String(char)] else { return nil }
                digit = val
            } else {
                guard let val = Int(String(char)) else { return nil }
                digit = val
            }
            sum += digit * weights[i]
        }

        var remainder = sum % 11
        remainder = remainder == 10 ? 0 : remainder

        return remainder
    }
}
