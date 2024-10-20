//
//  Okoye.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-19.
//

import SwiftUI

struct Okoye: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

import Charts

struct SleepStageX: Identifiable {
    let id = UUID()
    let time: Date
    let stage: String
    let stageValue: Double
    
    // Convert sleep stages to numeric values for plotting
    // Wake = 4, REM = 3, N1 = 2, N2 = 1, N3 = 0
    static func stageToValue(_ stage: String) -> Double {
        switch stage {
            case "Wake": return 4
            case "REM": return 3
            case "Core": return 2
            case "Deep": return 1
            case "N3": return 0
            default: return -1
        }
    }
}

struct Hypnogram: View {
    let sleepData: [SleepStageX]
    
    init() {
        // Sample sleep data for one night
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: Date())
        
        // Create sample sleep stages
        let stages = [
            ("Wake", 15), ("Core", 10), ("Deep", 30), ("N3", 45),
            ("Deep", 30), ("REM", 25), ("Deep", 30), ("N3", 40),
            ("Deep", 25), ("REM", 30), ("Deep", 20), ("Core", 15)
            ,("Wake", 10)
        ]
        
        // Convert stages into SleepStage objects with timestamps
        var currentTime = startTime
        var data: [SleepStageX] = []
        
        for (stage, duration) in stages {
            let stageValue = SleepStageX.stageToValue(stage)
            data.append(SleepStageX(time: currentTime, stage: stage, stageValue: stageValue))
            currentTime = calendar.date(byAdding: .minute, value: duration, to: currentTime)!
        }
        
        self.sleepData = data
    }
    
    var body: some View {
        VStack {
            Text("Sleep Hypnogram")
                .font(.title)
                .padding()
            
            Chart(sleepData) { stage in
                LineMark(
                    x: .value("Time", stage.time),
                    y: .value("Stage", stage.stageValue)
                )
                .interpolationMethod(.stepStart)
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4]) { value in
                    AxisValueLabel {
                        switch value.index {
                            case 0: Text("N3")
                            case 1: Text("Deep")
                            case 2: Text("Core")
                            case 3: Text("REM")
                            case 4: Text("Wake")
                            default: Text("")
                        }
                    }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 300)
            .padding()
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        Hypnogram()
//    }
//}

#Preview {
    Hypnogram()
}
