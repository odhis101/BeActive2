//
//  Beactive2App.swift
//  Beactive2
//
//  Created by Joshua on 1/23/24.
//

// Beactive2App.swift

import SwiftUI

@main
struct Beactive2App: App {
    @StateObject var manager = HealthManager()

    var body: some Scene {
        WindowGroup {
            MyTabView()
                .environmentObject(manager)
                .onAppear {
                    // Call fetchTodaySteps when the app starts
                    manager.fetchTodaySteps()
                    manager.fetchTodayCalories()
                    //manager.fetchWeekRunningStatss()
                    manager.fetchSampleRunningDistance()
                    manager.fetchTodayDistanceWalkingRunning()
                    manager.fetchBloodPressureData()
                    manager.fetchHeartRateData()
                    
                    


                    
                }
            
            Text("hello world ")
        }
    }
}

