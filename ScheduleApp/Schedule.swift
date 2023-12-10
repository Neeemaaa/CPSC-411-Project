import Foundation

class ScheduleManager: ObservableObject {
    @Published var schedules: [Schedule] = []

    init() {
        schedules.append(Schedule(person: "Neema", dT: "12/18/2023 [14:00 - 15:00]"))
        schedules.append(Schedule(person: "Sahar", dT: "12/18/2023 [14:30 - 15:00]"))
    }
    
    func findCommonTimeForTwoSchedules() -> String? {
        guard schedules.count == 2 else {
            print("Incorrect number of schedules")
            return nil // Only two schedules should be compared
        }

        if let commonTime = findCommonTime(scheduleA: schedules[0], scheduleB: schedules[1]) {
            print("Common Time Found: \(commonTime)")
            return commonTime
        }

        print("No common time found")
        return nil // No common time found
    }


    func findCommonTime(scheduleA: Schedule, scheduleB: Schedule) -> String? {
        guard let startA = extractTime(from: scheduleA.dT),
              let startB = extractTime(from: scheduleB.dT) else {
            print("Error extracting time")
            return nil
        }
        
        print("Start A: \(startA)")
        print("Start B: \(startB)")
        
        let commonStart = max(startA.start, startB.start)
        let commonEnd = min(startA.end, startB.end)
        
        print("Common Start: \(commonStart)")
        print("Common End: \(commonEnd)")
        
        if commonStart < commonEnd {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            let commonDate = dateFormatter.string(from: commonStart)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            
            let startTime = timeFormatter.string(from: commonStart)
            let endTime = timeFormatter.string(from: commonEnd)
            
            let commonTimeString = "\(commonDate) [\(startTime) - \(endTime)]"
            print("Common Time String: \(commonTimeString)")
            return commonTimeString
        }
        
        print("No common time found")
        return nil
    }


    func extractTime(from schedule: String) -> (start: Date, end: Date)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy '[HH:mm - HH:mm]'"
        
        // Separate the date and time components using '[' and ']' as delimiters
        let components = schedule.components(separatedBy: " [")
        guard components.count == 2 else {
            print("Error: Unexpected number of components")
            return nil
        }
        
        let dateString = components[0]
        let timeString = components[1].replacingOccurrences(of: "]", with: "")
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        guard let date = dateFormatter.date(from: dateString) else {
            print("Error: Unable to convert date string to Date")
            return nil
        }
        
        dateFormatter.dateFormat = "HH:mm"
        let timeComponents = timeString.components(separatedBy: " - ")
        
        guard timeComponents.count == 2,
              let startTime = dateFormatter.date(from: timeComponents[0]),
              let endTime = dateFormatter.date(from: timeComponents[1]) else {
            print("Error: Unable to convert time strings to dates")
            return nil
        }
        
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                  minute: calendar.component(.minute, from: startTime),
                                  second: 0,
                                  of: date)!
        let end = calendar.date(bySettingHour: calendar.component(.hour, from: endTime),
                                minute: calendar.component(.minute, from: endTime),
                                second: 0,
                                of: date)!
        
        return (start, end)
    }


    func isEarlierCommonTime(_ time1: String, than time2: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy '[HH:mm - HH:mm]'"
        
        if let date1 = dateFormatter.date(from: time1),
           let date2 = dateFormatter.date(from: time2) {
            return date1 < date2
        }
        
        return false
    }
}

struct Schedule: Identifiable {
    var id = UUID()
    var person: String
    var dT: String
}
