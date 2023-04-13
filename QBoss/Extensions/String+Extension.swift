import Foundation

extension String {
    enum Identification: String {
        case url = #"^(?:https?://)?(?:www\.)?(?:[\w-]+\.)+[a-z]{2,}(?:/[\w-./?%&=]*)?$"#
        //case serialNumber = "^[A-Z]{3}[UJZ]\\d{7}$"
        case digits = #"^\d+$"#
        case letters = #"^[A-Z]+$"#
        case groupCode = #"[UJZ]"#
    }
    
    func validate(idCase: Identification) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", idCase.rawValue)
        return predicate.evaluate(with: self)
    }
}
