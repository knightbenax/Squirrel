//
//  SleepData.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//

import Foundation

struct SleepData : Hashable {
    
    var start : Date?
    var end : Date?
    
    var remSleep: [SleepStage] = []
    var deepSleep: [SleepStage] = []
    var coreSleep: [SleepStage] = []
    var awake : [SleepStage] = []
    //this is the array containing all the stages
    var allSleep: [SleepStage] = []
    
    var totalSleepSeconds: TimeInterval = 0
}
