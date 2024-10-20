//
//  DateHelper.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-19.
//


import Foundation

enum DATEFORMATTYPES {
    case YEAR
    case DAY
    case MONTH
    case PRETTY
    case PRETTY_STATUS
}

enum TIMEFORMATTYPES {
    case LABEL
    case TWENTYFOUR
}

class DateHelper {
    
    func formatDateToBeauty(thisDate: Date, type: DATEFORMATTYPES = .DAY) -> String{
        switch type {
        case .YEAR:
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy"
            return dateFormatterPrint.string(from: thisDate)
        case .DAY:
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "d MMMM"
            return dateFormatterPrint.string(from: thisDate)
        case .MONTH:
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM"
            return dateFormatterPrint.string(from: thisDate)
        case .PRETTY:
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "EEE, dd MMM YYYY"
            return dateFormatterPrint.string(from: thisDate)
        case .PRETTY_STATUS:
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "EEE, dd MMM YYYY"
            return dateFormatterPrint.string(from: thisDate) + getWhatDayIsDate(thisDate: thisDate)
        }
    }
    
    func getWhatDayIsDate(thisDate: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(thisDate) {
            return " - Today"
        } else if calendar.isDateInTomorrow(thisDate) {
            return " - Tomorrow"
        } else if calendar.isDateInYesterday(thisDate) {
            return " - Yesterday"
        } else {
            return ""
        }
    }
    
    
    func addMonth(_ date: Date, value: Int = 1) -> Date
    {
        return Calendar.current.date(byAdding: .month, value: value, to: date)!
    }
    
    func minusMonth(_ date: Date, value: Int = -1) -> Date
    {
        return Calendar.current.date(byAdding: .month, value: value, to: date)!
    }
    
    func daysInMonth(_ date: Date) -> Int
    {
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    //https://stackoverflow.com/questions/44416831/list-of-dates-for-given-day-of-the-week-swift
    func getDaysInWeek(dateInWeek: Date) -> [Date]{
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: dateInWeek)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: dateInWeek)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: dateInWeek) }
        return days
    }
    
    func getDayOfWeekFromDate(thisDate: Date) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterGet.dateFormat = "EEEE"
        return dateFormatterGet.string(from: thisDate)
    }
    
    func getMonthDayFromDate(thisDate: Date) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterGet.dateFormat = "dd MMMM YYYY"
        return dateFormatterGet.string(from: thisDate)
    }
    
    func getDayFromDate(thisDate: Date) -> String{
        let dateFormatterPrint = DateFormatter()
        //dateFormatterPrint.locale = Locale.current
        dateFormatterPrint.timeStyle = .none
        dateFormatterPrint.dateStyle = .full
        dateFormatterPrint.timeZone = TimeZone.current
        dateFormatterPrint.dateFormat = "d"
        //let _ = print("Balls X \(thisDate)")
        let runs = dateFormatterPrint.string(from: thisDate)
        //let _ = print("Balls X \(runs)")
        return dateFormatterPrint.string(from: thisDate)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func getIntervalInHoursMins(startDate: Date, endDate : Date, type : TIMEFORMATTYPES = .LABEL) -> String{
        let interval = endDate.timeIntervalSince(startDate)
        let (h, m, s) = secondsToHoursMinutesSeconds(Int(interval))
        if (type == .LABEL){
            return "\(h)hrs \(m)mins" //, \(s) Seconds
        } else {
            var hr = ""
            var mr = ""
            var sr = ""
            
            if (h < 10){
                hr = "0"
            }
            
            if (m < 10){
                mr = "0"
            }
            
            if (s < 10){
                sr = "0"
            }
            
            return "\(hr)\(h):\(mr)\(m):\(sr)\(s)"
        }
    }
    
    func getIntervalInHoursMinsFromSeconds(duration: TimeInterval, type : TIMEFORMATTYPES = .LABEL) -> String{
        let (h, m, s) = secondsToHoursMinutesSeconds(Int(duration))
        if (type == .LABEL){
            return "\(h) hr \(m) mins" //, \(s) Seconds
        } else {
            return "\(h):\(m):\(s)"
        }
    }
    
        func formatDateToTime(thisDate: Date) -> String {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
            dateFormatterGet.dateFormat = "hh:mm "
            dateFormatterGet.amSymbol = "AM"
            dateFormatterGet.pmSymbol = "PM"
            return dateFormatterGet.string(from: thisDate)
        }
    
    func formatDateToAMPM(thisDate: Date) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterGet.dateFormat = "a"
        dateFormatterGet.amSymbol = "AM"
        dateFormatterGet.pmSymbol = "PM"
        return dateFormatterGet.string(from: thisDate)
    }
    
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func dayOfWeek() -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: self).capitalized
        }
}

