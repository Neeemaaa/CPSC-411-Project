import SwiftUI

struct AvailableTimes: View {
    @EnvironmentObject var manager: ScheduleManager
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()

    var body: some View {
        VStack {
            if manager.schedules.isEmpty {
                Text("There are no schedules available.").multilineTextAlignment(.center)
            } else if manager.schedules.count == 1 {
                Text("There is only one schedule available, cannot compare to anything.").multilineTextAlignment(.center)
            } else if manager.schedules.count >= 3 {
                Text("This application can only compare 2 schedules, please remove \(manager.schedules.count-2) of the schedules.")
                .multilineTextAlignment(.center)
            } else {
                if let commonTime = manager.findCommonTimeForTwoSchedules() {
                    let components = commonTime.components(separatedBy: " ")
                    VStack(alignment: .center, spacing: 8) {
                        Text("Common Time:")
                            .font(.headline)
                            .padding(.bottom, 4)
                        let people = manager.schedules.map { $0.person }.joined(separator: " and ")
                                            Text("\(people) are both available at")
                                                .font(.headline)
                                                .padding(.bottom, 4)
                        Text("\(formattedDate(from: components[0]))") // Date
                            .font(.system(size: 18, weight: .bold))
                            .padding(.bottom, 4)
                        
                        Text("\(components[1]) \(components[2]) \(components[3])") // Time Range
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding()
                } else {
                    Text("No common time found")
                        .padding()
                }
            }
        }
    }
    func formattedDate(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy"

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "*MMMM dd, yyyy*"
            return outputFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
}


struct EditableSchedulesList: View {
    @EnvironmentObject var manager: ScheduleManager
    @State private var isShowingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(manager.schedules) { schedule in
                        VStack(alignment: .leading) {
                            Text(schedule.person)
                                .font(.largeTitle)
                                .onTapGesture {
                                    if !isShowingAlert {
                                        isShowingAlert.toggle()
                                    }
                                }
                            Text(schedule.dT)
                                .font(.caption)
                        }
                    }
                    .onDelete { indices in
                        manager.schedules.remove(atOffsets: indices)
                    }
                    .onMove { indices, newOffset in
                        manager.schedules.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .navigationBarTitle("Schedules")
                .navigationBarItems(trailing:
                    Button(action: {
                        isShowingAlert.toggle()
                    }) {
                        Text("Edit")
                    }
                )
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("Editing Feature To Be Added Later, Swipe Name To The Left To Delete"))
                }
                
                Text("Current Schedule Count: \(manager.schedules.count)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
                    .padding(.bottom, 20)
            }
        }
    }
}


struct AddDateTime: View {
    @EnvironmentObject var manager: ScheduleManager
    @State private var userName = ""
    @State private var timeAddedMessage = "" // State variable to control the message visibility
    @State private var startTime = Date()
    @State private var endTime = Date() // Default value for endTime
    @State private var shouldClearFields = false
    
    func formatDate() -> String {
        let calendar = Calendar.current
        let sComponents = calendar.dateComponents([.hour, .minute, .day, .month, .year], from: startTime)
        let eComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        guard let sHour = sComponents.hour,
              let sMinute = sComponents.minute,
              let eHour = eComponents.hour,
              let eMinute = eComponents.minute,
              let sDay = sComponents.day,
              let sMonth = sComponents.month,
              let sYear = sComponents.year else {
            return "Invalid time"
        }
        
        let isValidTime = calendar.compare(startTime, to: endTime, toGranularity: .minute) == .orderedAscending
        
        if isValidTime {
            let formattedStartTime = String(format: "%02d:%02d", sHour, sMinute)
            let formattedEndTime = String(format: "%02d:%02d", eHour, eMinute)
            
            if formattedStartTime == formattedEndTime {
                return "Start and end time cannot be the same"
            } else {
                return "\(sMonth)/\(sDay)/\(sYear) [\(formattedStartTime) - \(formattedEndTime)]"
            }
        } else {
            return "Invalid time"
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Enter your name", text: $userName)
            }
            
            Section(header: Text("Please Enter Your Availability")) {}
            
            Section(header: Text("Start Time")) {
                DatePicker("Pick a date/time: ", selection: $startTime)
            }
            
            Section(header: Text("End Time")) {
                DatePicker("Pick a time: ", selection: $endTime, displayedComponents: .hourAndMinute)
                    .onChange(of: endTime, perform: { value in
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute], from: value)
                        if let hour = components.hour, let minute = components.minute {
                            let newEndTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: startTime)
                            endTime = newEndTime ?? value
                        }
                    })
            }
            
            Section(header: Text("Result")) {
                Text(formatDate())
            }
            
            Button("Done") {
                let formattedTime = formatDate()
                if !formattedTime.contains("Invalid time") && !userName.isEmpty {
                    let sameTime = startTime == endTime
                    
                    if sameTime {
                        timeAddedMessage = "Start and end times cannot be the same."
                    } else {
                        let newSchedule = Schedule(person: userName, dT: formattedTime)
                        manager.schedules.append(newSchedule)
                        timeAddedMessage = "Time added!"
                        shouldClearFields = true
                        print("Time added!")
                    }
                } else {
                    timeAddedMessage = "Please enter a valid name and time."
                }
            }
        }
        .onChange(of: startTime) { newValue in
            endTime = Calendar.current.date(byAdding: .minute, value: 1, to: newValue) ?? Date()
        }
        .alert(isPresented: Binding<Bool>(
            get: { !timeAddedMessage.isEmpty },
            set: { _ in }
        )) {
            Alert(title: Text(timeAddedMessage), dismissButton: .default(Text("Okay")) {
                if shouldClearFields {
                    userName = ""
                    startTime = Date()
                    endTime = Date()
                    shouldClearFields = false
                }
                timeAddedMessage = ""
            })
        }
    }
}
