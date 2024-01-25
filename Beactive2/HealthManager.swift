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
        let types: Set = [
               HKQuantityType.quantityType(forIdentifier: .stepCount)!,
               HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
               HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
               HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!,
               HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
               HKQuantityType.quantityType(forIdentifier: .bodyMass)!
           ]
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
            let newActivity = Activity(title: "Calories Burned", subtitle: "Goal: 2,000", image: "flame.fill", amount: "\(Int(caloriesBurned)) kcal")

            DispatchQueue.main.async {
                self.activities["todayCalories"] = newActivity
            }
        }

        healthStore.execute(query)
    }
    
     func fetchTodayDistanceWalkingRunning() {
         guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
             print("Distance Walking or Running data is not available.")
             return
         }

         let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
         let query = HKStatisticsQuery(
             quantityType: distanceType,
             quantitySamplePredicate: predicate,
             options: .cumulativeSum
         ) { query, result, error in
             guard let result = result, let sum = result.sumQuantity() else {
                 print("Error fetching distance walking or running data: \(error?.localizedDescription ?? "Unknown error")")
                 return
             }

             let distance = sum.doubleValue(for: HKUnit.meter())
             print("Today's Distance Walking or Running: \(distance) meters")
             let newActivity = Activity(title: "Distance Walking or Running", subtitle: "Goal: Custom Goal", image: "walk", amount: "\(Int(distance)) meters")

             DispatchQueue.main.async {
                 self.activities["todayDistanceWalkingRunning"] = newActivity
             }
         }

         healthStore.execute(query)
     }

    
    func fetchSampleRunningDistance() {
         // Simulate fetching sample running distance data
         let runningDistance = 3000 // Simulated running distance in meters
        print("This week's running distance fake: 2000 meters")

        DispatchQueue.main.async {
         let newActivity = Activity(title: "Sample Running Distance", subtitle: "Goal: 5000", image: "figure.walk", amount: "\(runningDistance) meters")
         self.activities["sampleRunningDistance"] = newActivity
            
        }
        
        
     }
    
    func fetchBloodPressureData() {
        print("we have hit this function")
        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            print("Blood pressure data is not available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKCorrelationQuery(
            type: HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!,
            predicate: predicate,
            samplePredicates: nil
        ) { query, samples, error in
            guard error == nil else {
                print("Error fetching blood pressure data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Process blood pressure data
            guard let samples = samples else {
                print("No blood pressure data available.")
                return
            }

            for sample in samples {
                if let systolic = sample.objects(for: systolicType).first as? HKQuantitySample,
                   let diastolic = sample.objects(for: diastolicType).first as? HKQuantitySample {
                    let systolicValue = systolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                    let diastolicValue = diastolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                    print("Systolic: \(systolicValue), Diastolic: \(diastolicValue)")

                    // Create an Activity object with the blood pressure data
                    let newActivity = Activity(title: "Blood Pressure", subtitle: "Systolic: \(systolicValue), Diastolic: \(diastolicValue)", image: "heart.fill", amount: "\(Int(systolicValue))/\(Int(diastolicValue)) mmHg")

                    DispatchQueue.main.async {
                        self.activities["bloodPressure"] = newActivity
                    }
                }
            }
        }

        healthStore.execute(query)
    }

    func fetchHeartRateData() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate data is not available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { query, result, error in
            guard let result = result, let average = result.averageQuantity() else {
                print("Error fetching heart rate data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let heartRate = average.doubleValue(for: HKUnit.init(from: "count/min"))
            print("Average Heart Rate: \(heartRate) bpm")

            let newActivity = Activity(title: "Heart Rate", subtitle: "Average: \(Int(heartRate)) bpm", image: "heart.fill", amount: "\(Int(heartRate)) bpm")

            DispatchQueue.main.async {
                self.activities["heartRate"] = newActivity
            }
        }

        healthStore.execute(query)
    }

    func fetchSleepAnalysisData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep analysis data is not available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { query, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep analysis data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Process sleep analysis data
            for sample in samples {
                let sleepCategoryValue = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "In Bed" : "Asleep"
                print("Sleep Category: \(sleepCategoryValue)")

                let newActivity = Activity(title: "Sleep Analysis", subtitle: "\(sleepCategoryValue)", image: "moon.stars.fill", amount: "\(sleepCategoryValue)")

                DispatchQueue.main.async {
                    self.activities["sleepAnalysis"] = newActivity
                }
            }
        }

        healthStore.execute(query)
    }

    func fetchBMIData() {
        guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass),
              let heightType = HKQuantityType.quantityType(forIdentifier: .height) else {
            print("Body mass or height data is not available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: bodyMassType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { query, result, error in
            guard let result = result, let average = result.averageQuantity() else {
                print("Error fetching body mass data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let bodyMass = average.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            print("Average Body Mass: \(bodyMass) kg")

            let heightQuery = HKStatisticsQuery(
                quantityType: heightType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { heightQuery, heightResult, heightError in
                guard let heightResult = heightResult, let heightAverage = heightResult.averageQuantity() else {
                    print("Error fetching height data: \(heightError?.localizedDescription ?? "Unknown error")")
                    return
                }

                let height = heightAverage.doubleValue(for: HKUnit.meter())
                print("Average Height: \(height) meters")

                let bmiValue = bodyMass / (height * height)
                print("Average BMI: \(bmiValue)")

                let newActivity = Activity(title: "Body Mass Index", subtitle: "Average: \(bmiValue)", image: "person.fill", amount: "\(bmiValue)")

                DispatchQueue.main.async {
                    self.activities["bmi"] = newActivity
                }
            }

            self.healthStore.execute(heightQuery)
        }

        healthStore.execute(query)
    }
    func fetchDietaryEnergyData() {
        guard let dietaryEnergyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            print("Dietary energy data is not available.")
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: dietaryEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching dietary energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let energyValue = sum.doubleValue(for: HKUnit.kilocalorie())
            print("Dietary Energy Consumption: \(energyValue) kcal")

            let newActivity = Activity(title: "Dietary Energy", subtitle: "Consumption: \(energyValue) kcal", image: "leaf.fill", amount: "\(Int(energyValue)) kcal")

            DispatchQueue.main.async {
                self.activities["dietaryEnergy"] = newActivity
            }
        }

        healthStore.execute(query)
    }

    
    

 
}
