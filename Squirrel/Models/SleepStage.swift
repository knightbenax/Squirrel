//
//  SleepStage.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//

import Foundation

enum SLEEPSTAGEVALUE : Int {
    
    case inBed = 0
    case asleepUnspecified = 1
    case awake = 2
    case asleepCore = 3
    case asleepDeep = 4
    case asleepREM = 5
    
}

struct SleepStage : Hashable {
    var duration : Double
    var start : Date
    var end : Date
    var value : SLEEPSTAGEVALUE
}
