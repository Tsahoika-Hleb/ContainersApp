extension Date {
    
    func dateToString() -> String {
        let dateFormater = DateFormatter()
        dateFormater.timeStyle = .long
        dateFormater.dateStyle = .full
        return dateFormater.string(from: self)
    }
}
