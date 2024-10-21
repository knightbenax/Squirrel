//
//  HealthKitManager.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//


//
//  HealthKitManager.swift
//  Gage
//
//  Created by Bezaleel Ashefor on 10/02/2024.
//

import Foundation
import HealthKit
import WidgetKit
import SwiftUI
import CoreLocation

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    var healthStore = HKHealthStore()
    
    @Published var weightInKilograms : Double = 0.0
    @Published var heightInMeters : Double = 0.0
    @Published var bodyMassIndex : Double = 0.0
    @PublishedAppStorage("hasAskedForPermission") var hasAskedForPermission = false
    @Published var sleepData = SleepData()
    @Published var sleepDataForLine = [SleepDataLine]()
    
    func requestAuthorization(completion: @escaping (Bool) -> ()){
        let reads = Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: reads, completion: { success, error in
            if (success){
                completion(true)
            } else {
                completion(false)
            }
            
        })
    }
    
    func isHealthKitAvaliable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func fetchSleepDataForDay(startDate: Date, endDate: Date, completion: @escaping (Bool) -> ()){
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let dateRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: dateRangePredicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { [self]_,results , error in
            if let error = error{
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let results = results as? [HKCategorySample] else {
                //return
                completion(false)
                return
            }
            
            if results.isEmpty {
                completion(false)
                return
            }
          
            DispatchQueue.main.async { [self] in
                sleepData.start = results.first?.startDate
                sleepData.end = results.last?.endDate
            }
            
            var totalSleepSeconds : TimeInterval = 0

            for sample in results {
                let value = sample.value
                let duration = sample.endDate.timeIntervalSince(sample.startDate)

                switch value {
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    totalSleepSeconds += duration
                    DispatchQueue.main.async { [self] in
                        sleepData.remSleep.append(SleepStage(type: .REM, color: .teal, duration: duration, start: sample.startDate, end: sample.endDate))
                    }
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    totalSleepSeconds += duration
                    DispatchQueue.main.async { [self] in
                        sleepData.coreSleep.append(SleepStage(type: .coreSleep, color: .blue, duration: duration, start: sample.startDate, end: sample.endDate))
                    }
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    totalSleepSeconds += duration
                    DispatchQueue.main.async { [self] in
                        sleepData.deepSleep.append(SleepStage(type: .deepSleep, color: .purple, duration: duration, start: sample.startDate, end: sample.endDate))
                    }
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    DispatchQueue.main.async { [self] in
                        sleepData.awake.append(SleepStage(type: .awake, color: .orange, duration: duration, start: sample.startDate, end: sample.endDate))
                    }
                    
                default:
                    break
                }
            }

            DispatchQueue.main.async { [self] in
                sleepData.allSleep.append(contentsOf: sleepData.awake)
                sleepData.allSleep.append(contentsOf: sleepData.remSleep)
                sleepData.allSleep.append(contentsOf: sleepData.coreSleep)
                sleepData.allSleep.append(contentsOf: sleepData.deepSleep)
                sleepData.totalSleepSeconds = totalSleepSeconds
            }
            
           
            completion(true)
        }
        
        healthStore.execute(query)
    }
    
    
}
