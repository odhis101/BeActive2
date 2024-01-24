//
//  HealthManager.swift
//  BeActive
//
//  Created by Joshua on 1/22/24.
//

// HealthManager.swift

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var activities: [String: Activity] = [:]

    init() {
        let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.activeEnergyBurned)]

        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: types)
            } catch {
                print("Error fetching health data: \(error)")
            }
        }
    }

    func fetchTodaySteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step Count is not available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching steps data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let stepCount = sum.doubleValue(for: HKUnit.count())
            print("Today's Steps: \(stepCount)")
            let newActivity = Activity(title: "Daily Steps", subtitle: "Goal: 10,000", image: "figure.walk", amount: "\(Int(stepCount))")

            DispatchQueue.main.async {
                self.activities["todaySteps"] = newActivity
            }
        }

        healthStore.execute(query)
    }

    func fetchTodayCalories() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Active Energy Burned is not available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: caloriesType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching calories data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            print("Today's Calories Burned: \(caloriesBurned)")
            let newActivity = Activity(title: "Calories Burned", subtitle: "Goal: Custom Goal", image: "flame.fill", amount: "\(Int(caloriesBurned)) kcal")

            DispatchQueue.main.async {
                self.activities["todayCalories"] = newActivity
            }
        }

        healthStore.execute(query)
    }
    func fetchWeekRunningStats() {
            guard let runningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                print("Running data is not available.")
                return
            }

            let calendar = Calendar.current
            let now = Date()
            guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: now) else {
                print("Error calculating seven days ago.")
                return
            }

            let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: now, options: .strictStartDate)
            let query = HKStatisticsQuery(
                quantityType: runningType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { query, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("Error fetching running data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                let runningDistance = sum.doubleValue(for: HKUnit.meter())
                print("Weekly Running Distance: \(runningDistance) meters")
                
                let newActivity = Activity(title: "Weekly Running", subtitle: "Goal: Custom Goal", image: "figure.walk", amount: "\(Int(runningDistance)) meters")

                DispatchQueue.main.async {
                    self.activities["weeklyRunning"] = newActivity
                }
            }

            healthStore.execute(query)
        }
    
    func fetchWeekRunningStats(completion: @escaping (Double?) -> Void) {
        guard let runningType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            print("Running distance is not available.")
            completion(nil)
            return
        }

        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: endOfWeek, options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: runningType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching running data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            let runningDistance = sum.doubleValue(for: HKUnit.meter())
            print("This week's running distance: \(runningDistance) meters")
            completion(runningDistance)
        }

        healthStore.execute(query)
    }

}
