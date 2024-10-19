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
    @Published var sleepData : SleepData?
    @PublishedAppStorage("hasAskedForPermission") var hasAskedForPermission = false
    @Published var permissionGranted = false
    
    
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
    
    func fetchSleepDataForDay(startDate: Date, endDate: Date){
        DispatchQueue.main.async {
            self.sleepData = nil
        }
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let dateRangePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        // Predicate for all asleep samples (unspecified, core, deep, REM)
        let allAsleepPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(equalTo: HKCategoryValueSleepAnalysis.allAsleepValues)
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        //let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dateRangePredicate, allAsleepPredicate])
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: dateRangePredicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { [self]_,results , error in
            if let error = error{
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let results = results as? [HKCategorySample] else {
                return
            }
            
            if results.isEmpty {
                return
            }
//            
//                        print("Start Date: \(startDate), End Date: \(endDate)")
//                        print("Fetched \(results.count) sleep analysis samples.")
//                        print("Duration \(results.first?.startDate) - \(results.last?.endDate)")
            
            var totalInBedTime: TimeInterval = 0
            var totalASleepTime: TimeInterval = 0
            var totalAwakeTime: TimeInterval = 0
            DispatchQueue.main.async { [self] in
                sleepData = SleepData(start: results.first?.startDate, end: results.last?.endDate, sleepQuality: 0, avgHeartRate: 0, allStages: [SleepStage](), sleepStages: [SleepStage](), totalInBedDuration: 0, awakeDuration: 0,  aSleepDuration: 0)
            }
            
            var allStages = [SleepStage]()
            var sleepStages = [SleepStage]()
            var inbedTimeIntervals = [DateInterval]()
            for result in results {
                //                if let type = HKCategoryValueSleepAnalysis(rawValue: result.value) {
                //                    if HKCategoryValueSleepAnalysis.allAsleepValues.contains(type) {
                //                        let sleepDuration = result.endDate.timeIntervalSince(result.startDate)
                //                        sleepStage.append(SleepStage(duration: sleepDuration,
                //                                                     start: result.startDate,
                //                                                     end: result.endDate,
                //                                                     value: SLEEPSTAGEVALUE(rawValue: result.value) ?? .asleepUnspecified))
                //                        totalSleepTime += sleepDuration
                //                    }
                //                }
                let sleepDuration = result.endDate.timeIntervalSince(result.startDate)
                allStages.append(SleepStage(duration: sleepDuration,
                                            start: result.startDate,
                                            end: result.endDate,
                                            value: SLEEPSTAGEVALUE(rawValue: result.value) ?? .asleepUnspecified))
                
                if (result.value == SLEEPSTAGEVALUE.asleepCore.rawValue || result.value == SLEEPSTAGEVALUE.asleepDeep.rawValue || result.value == SLEEPSTAGEVALUE.asleepREM.rawValue || result.value == SLEEPSTAGEVALUE.asleepUnspecified.rawValue
                    || result.value == SLEEPSTAGEVALUE.awake.rawValue) {
                    let sleepDuration = result.endDate.timeIntervalSince(result.startDate)
                    totalASleepTime += sleepDuration
                    
                    if (result.value == SLEEPSTAGEVALUE.awake.rawValue){
                        totalAwakeTime += sleepDuration
                    }
                    sleepStages.append(SleepStage(duration: sleepDuration,
                                                  start: result.startDate,
                                                  end: result.endDate,
                                                  value: SLEEPSTAGEVALUE(rawValue: result.value) ?? .asleepUnspecified))
                    inbedTimeIntervals.append(DateInterval(start: result.startDate, end: result.endDate))
                }
                
                if (result.value == SLEEPSTAGEVALUE.inBed.rawValue){
                    inbedTimeIntervals.append(DateInterval(start: result.startDate, end: result.endDate))
                }
                
            }
            
           
            totalInBedTime = calculateSpentTime(for: inbedTimeIntervals)
            let percent = totalASleepTime - totalAwakeTime
            let sleepQuality = (percent/totalInBedTime) * 100
            DispatchQueue.main.async { [self] in
                sleepData?.allStages = allStages
                sleepData?.sleepStages = sleepStages
                sleepData?.totalInBedDuration = totalInBedTime
                sleepData?.aSleepDuration = totalASleepTime
                sleepData?.awakeDuration = totalAwakeTime
                sleepData?.sleepQuality = Int(sleepQuality)
            }
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
