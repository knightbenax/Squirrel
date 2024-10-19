//
//  SleepPanel.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-19.
//

import SwiftUI
import Charts

struct SleepPanel: View {
    @Binding var sleepData : SleepData
    var dateHelper = DateHelper()
    var sleepDataHeight : CGFloat = 200
    
    var body: some View {
        VStack{
            VStack(spacing: 6){
                HStack(alignment: .center, spacing: 5){
                    Image(systemName: "bed.double.fill").font(.system(size: 16)).offset(y: 0.5)
                    Text("Average Time Asleep").font(.custom(FontsManager.fontMedium, size: 14))
                    Spacer()
                }.opacity(0.8)
                HStack(alignment: .center, spacing: 5){
                    Text(dateHelper.getIntervalInHoursMinsFromSeconds(duration: sleepData.totalSleepSeconds)).font(.custom(FontsManager.fontBold, size: 24))
                    Spacer()
                }
            }
            VStack(spacing: 16){
                GeometryReader { reader in
                    Chart(sleepData.allSleep) {
                        BarMark(
                            xStart: .value("Start Time", $0.start ?? Date()),
                            xEnd: .value("End Time", $0.end ?? Date()),
                            y: .value("Job", $0.type.rawValue)
                        )
                        //.foregroundStyle(by: .value($0.type.rawValue, $0.type))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }.chartXScale(domain: [getDomainStart(), getDomainEnd()])
                        .chartXAxis {
                            //make the axis for only even hours spaced at 2hrs apart
                            AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                                if let date = value.as(Date.self) {
                                    let hour = Calendar.current.component(.hour, from: date)
                                    if hour % 2 == 0 {
                                        AxisValueLabel(format: .dateTime.hour())
                                        AxisGridLine()
                                        AxisTick()
                                        let _ = print(hour)
                                    } else {
                                        AxisValueLabel(format: .dateTime.hour())
                                        AxisGridLine()
                                        AxisTick()
                                    }
                                }
                            }
                        }
                }.frame(height: sleepDataHeight)
                HStack{
                    HStack(spacing: 4){
                        Image(systemName: "bed.double.fill").font(.system(size: 12)).offset(y: 1)
                        Text(dateHelper.formatDateToTime(thisDate: sleepData.start ?? Date())).font(.custom(FontsManager.fontRegular, size: 12)) + Text(dateHelper.formatDateToAMPM(thisDate: sleepData.start ?? Date())).font(.custom(FontsManager.fontRegular, size: 12))
                    }
                    Spacer()
                    HStack(spacing: 4){
                        Image(systemName: "sun.max.fill").font(.system(size: 12)).offset(y: 1)
                        Text(dateHelper.formatDateToTime(thisDate: sleepData.end ?? Date())).font(.custom(FontsManager.fontRegular, size: 12)) + Text(dateHelper.formatDateToAMPM(thisDate: sleepData.end ?? Date())).font(.custom(FontsManager.fontRegular, size: 12))
                    }
                }
            }
            
        }.padding(.horizontal, 22).padding(.bottom, 10)
    }
    
    private func getDomainStart() -> Date {
        return Calendar.current.date(byAdding: .minute, value: -100, to: sleepData.start ?? Date()) ?? Date()
    }
    
    private func getDomainEnd() -> Date {
        return Calendar.current.date(byAdding: .hour, value: 1, to: sleepData.end ?? Date()) ?? Date()
    }
}

#Preview {
    SleepPanel(sleepData: .constant(SleepData()))
}
