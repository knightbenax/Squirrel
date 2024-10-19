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
            VStack{
                GeometryReader { reader in
                    Chart(sleepData.allSleep) {
                            BarMark(
                                xStart: .value("Start Time", $0.start ?? Date()),
                                xEnd: .value("End Time", $0.end ?? Date()),
                                y: .value("Job", $0.type.rawValue)
                            )
                        }
                }.frame(height: sleepDataHeight)//.background(Color.red)
                HStack{
                    HStack(spacing: 4){
                        Image(systemName: "bed.double.fill").font(.system(size: 12)).offset(y: 1)
                        Text(dateHelper.formatDateToTime(thisDate: sleepData.start ?? Date())).font(.custom(FontsManager.fontRegular, size: 12)) + Text(dateHelper.formatDateToAMPM(thisDate: sleepData.start ?? Date())).font(.custom(FontsManager.fontRegular, size: 12))
                    }
                    Spacer()
                    HStack(spacing: 4){
                        Image(systemName: "sun.max.fill").font(.system(size: 12)).offset(y: 1)
                        Text(dateHelper.formatDateToTime(thisDate: sleepData.end ?? Date())).font(.custom(FontsManager.fontRegular, size: 12)) + Text(dateHelper.formatDateToAMPM(thisDate: sleepData.start ?? Date())).font(.custom(FontsManager.fontRegular, size: 12))
                    }
                }
            }
            
        }.padding(.horizontal, 22).padding(.bottom, 10)
    }
    
    private func normalizeSleepStageDateValueToGraph(endOrStateDate: Date, readerWidth: CGFloat) -> CGFloat {
        let value = endOrStateDate.timeIntervalSince(sleepData.start ?? Date())
        return (value/sleepData.totalSleepSeconds) * readerWidth
        
    }
}

#Preview {
    SleepPanel(sleepData: .constant(SleepData()))
}
