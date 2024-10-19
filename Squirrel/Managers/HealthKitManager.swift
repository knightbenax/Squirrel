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
                sleepData.start = startDate
                sleepData.end = endDate
            }
            
            var totalSleepSeconds : TimeInterval = 0

            for sample in results {
                let value = sample.value
                let duration = sample.endDate.timeIntervalSince(sample.startDate)

                switch value {
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    totalSleepSeconds += duration
                    DispatchQueue.main.async { [self] in
                        sleepData.remSleep.append(SleepStage(type: .REM, duration: duration, start: sample.startDate, end: sample.endDate))
                    }
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    totalSleepSeconds += duration
                    DispatchQueue.main.async { [self] in
                        sleepData.coreSleep.append(SleepStage(type: .coreSleep, duration: duration, start: sample.startDate, end: sample.endDate))
                    }
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    totalSleepSeconds += duration
                    DispatchQueue.main.async { [self] in
                        sleepData.deepSleep.append(SleepStage(type: .deepSleep, duration: duration, start: sample.startDate, end: sample.endDate))
                    }
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    //sleepData.awakeningsCount += 1
                    DispatchQueue.main.async { [self] in
                        sleepData.awake.append(SleepStage(type: .awake, duration: duration, start: sample.startDate, end: sample.endDate))
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
    
    //https://stackoverflow.com/questions/63599928/duration-of-array-of-dateintevals-that-excludes-overlapping-times/63600255#63600255
    //used to decouple interval timing for inBed analysis
    func calculateSpentTime(for intervals: [DateInterval]) -> TimeInterval {
        guard intervals.count > 1 else {
            return intervals.first?.duration ?? 0
        }
        
        let sorted = intervals.sorted { $0.start < $1.start }
        
        var total: TimeInterval = 0
        var start = sorted[0].start
        var end = sorted[0].end
        
        for i in 1..<sorted.count {
            
            if sorted[i].start > end {
                total += end.timeIntervalSince(start)
                start = sorted[i].start
                end = sorted[i].end
            } else if sorted[i].end > end {
                end = sorted[i].end
            }
        }
        
        total += end.timeIntervalSince(start)
        return total
    }
    
    
}
