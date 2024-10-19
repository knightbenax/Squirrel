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
    var sleepQuality : Int
    var avgHeartRate : Int
    var allStages : [SleepStage]
    var sleepStages : [SleepStage]
    var totalInBedDuration : Double
    var awakeDuration : Double
    var aSleepDuration : Double
}
