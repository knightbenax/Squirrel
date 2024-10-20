//
//  SleepDataLine.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-19.
//
import Foundation

struct SleepDataLine : Hashable, Identifiable {
    
    let id = UUID()
    let time: Date
    let stage: String
    let stageValue: Double
    
    // Convert sleep stages to numeric values for plotting
    // Awake = 1, Core = 2, Deep = 3, REM = 4
    static func stageToValue(_ stage: String) -> Double {
        switch stage {
        case "Awake": return 4
        case "Core": return 3
        case "Deep": return 2
        case "REM": return 1
        default: return -1
        }
    }
}

