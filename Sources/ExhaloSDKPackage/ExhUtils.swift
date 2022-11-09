import Foundation

public func exhLog(_ message: String) {
    guard ExhDataManager.shared.showDebug else { return }
    print(message)
}

func buildISO8601String(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    let posix = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = posix as Locale
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
    let dateString = dateFormatter.string(from: date)
    
    return dateString
}

func buildUTCDateString(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    let posix = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = posix as Locale
    let date = dateFormatter.string(from: date);
    return date;
}

func buildISO8601Date(from strDate: String) -> Date? {
    let dateFormatter = DateFormatter()
    let posix = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = posix as Locale
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
    let date = dateFormatter.date(from: strDate)
    return date;
}

func buildUTCDate(from date: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    let posix = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = posix as Locale
    let date = dateFormatter.date(from: date);
    return date;
}


func isSameDay(date1: Date, date2: Date) -> Bool {
    var c = Calendar.current
    c.timeZone = TimeZone(identifier: "UTC")!
    
    let isSame = c.isDate(date1, equalTo: date2, toGranularity: .day)

    return isSame
}


extension Double {
    func truncate(places : Int) -> Double {
          return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
      }
}
