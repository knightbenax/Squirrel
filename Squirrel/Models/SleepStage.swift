//
//  SleepStage.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-19.
//
import Foundation

enum SleepStageType : String, Codable {
    case awake = "Awake"
    case coreSleep = "Core"
    case deepSleep = "Deep"
    case REM = "REM"
}

struct SleepStage : Hashable, Identifiable {
    
    var id = UUID().uuidString
    var type : SleepStageType = .awake
    var duration : TimeInterval = 0
    var start : Date?
    var end : Date?
    
}

