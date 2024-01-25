//
//  HomeView.swift
//  BeActive
//
//  Created by Joshua on 1/22/24.
//

// HomeView.swift

// HomeView.swift

import SwiftUI

// Update HomeView.swift

// Update HomeView.swift

struct HomeView: View {
    @EnvironmentObject var manager: HealthManager
    let dummyActivities: [Activity] = [
        Activity(title: "Daily Steps", subtitle: "Goal: 10,000", image: "figure.walk", amount: "6,450"),
        Activity(title: "Calories Burned", subtitle: "Goal: 2,000", image: "flame.fill", amount: "300 kcal"),
        Activity(title: "Weeks running", subtitle: "Goal: 2,000", image: "flame.walk", amount: "350 kcal"),
        
    ]
    let welcomeArray = ["Welcome", "Bienvenido", "Karibu"]

    @State private var currentWelcomeIndex = 0

    var body: some View {
        VStack(alignment: .leading) {
            Text(welcomeArray[currentWelcomeIndex])
                .foregroundColor(.gray)
                .font(.largeTitle)
                .padding()
                .foregroundColor(.secondary)
                .transition(.opacity)
                .multilineTextAlignment(.center)
                .animation(.easeOut(duration: 0.5))
                
                .onAppear {
                    startWelcomeTimer()
                }
            
            /*
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ForEach(dummyActivities, id: \.title) { activity in
                    ActivityCard(activity: activity)
                }
                
            }
             */
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ForEach(Array(manager.activities.values), id: \.title) { activity in
                    ActivityCard(activity: activity)
                }
            }

            
            Spacer()

        }
        .alignmentGuide(.top) { d in d[.top] }
    }

    func startWelcomeTimer() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            // Update the current welcome index cyclically
            self.currentWelcomeIndex = (self.currentWelcomeIndex + 1) % self.welcomeArray.count
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
