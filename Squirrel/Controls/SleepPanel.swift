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
    @Binding var sleepDataForLine : [SleepDataLine]
    var dateHelper = DateHelper()
    var sleepDataHeight : CGFloat = 210
    
    var body: some View {
        VStack(spacing: 16){
            VStack(spacing: 6){
                HStack(alignment: .center, spacing: 5){
                    Image(systemName: "bed.double.fill").font(.system(size: 16)).offset(y: 0.5)
                    Text("Average Time Asleep").font(.custom(FontsManager.fontMedium, size: 14))
                    Spacer()
                }.opacity(0.8)
                VStack(spacing: 1){
                    HStack(alignment: .center, spacing: 5){
                        Text(dateHelper.getIntervalInHoursMinsFromSeconds(duration: sleepData.totalSleepSeconds)).font(.custom(FontsManager.fontBold, size: 24))
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 5){
                        Text(dateHelper.formatDateToBeauty(thisDate: sleepData.start ?? Date(), type: .PRETTY_STATUS)).font(.custom(FontsManager.fontRegular, size: 13))
                        Spacer()
                    }
                }
            }
            VStack(spacing: 16){
                GeometryReader { reader in
                    ZStack{
                        Chart(sleepData.allSleep) {
                            BarMark(
                                xStart: .value("", $0.start ?? Date()),
                                xEnd: .value("", $0.end ?? Date()),
                                y: .value("", $0.type.rawValue),
                                height: 26
                            )
                            .foregroundStyle($0.color)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            
//                            if ($0.type != .deepSleep && $0.type != .awake){
//                                RectangleMark(
//                                    xStart: .value("", ($0.start ?? Date()).addingTimeInterval(-25)),
//                                    xEnd: .value("", ($0.start ?? Date()).addingTimeInterval(15)),
//                                    y: .value("", $0.type.rawValue),
//                                    height: 60
//                                )
//                                .foregroundStyle(.red)
//                                
//                                RectangleMark(
//                                    xStart: .value("", ($0.end ?? Date()).addingTimeInterval(-15)),
//                                    xEnd: .value("", ($0.end ?? Date()).addingTimeInterval(35)),
//                                    y: .value("", $0.type.rawValue),
//                                    height: 60
//                                )
//                                .foregroundStyle(.red)
//                            }
                
                        }.chartXScale(domain: [getDomainStart(), getDomainEnd()])
                            .chartXAxis {
                                //make the axis for only even hours spaced at 2hrs apart
                                AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                                    if let date = value.as(Date.self) {
                                        let hour = Calendar.current.component(.hour, from: date)
                                        if hour % 2 == 0 {
                                            AxisValueLabel(format: .dateTime.hour())
                                            AxisGridLine()
                                            AxisTick()
                                        }
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
        let value = Calendar.current.date(byAdding: .minute, value: -90, to: sleepData.start ?? Date()) ?? Date()
        return value
    }
    
    private func getDomainEnd() -> Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: sleepData.end ?? Date()) ?? Date()
    }
}

#Preview {
    SleepPanel(sleepData: .constant(SleepData()), sleepDataForLine: .constant([]))
}


extension View {
    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
            self.mask(
                ZStack {
                    Rectangle()

                    mask()
                        .blendMode(.destinationOut)
                }
            )
        }
}
