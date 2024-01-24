//
//  ActivityCard.swift
//  BeActive
//
//  Created by Joshua on 1/22/24.
//

import SwiftUI

struct Activity: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let image: String
    let amount: String
}

struct ActivityCard: View {
    @State var activity: Activity
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(20) // Adjust the corner radius to make it more rounded
            
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activity.title)
                            .font(.system(size: 16))
                        
                        Text(activity.subtitle)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundColor(.green)
                }
                
                Text(activity.amount)
                    .font(.system(size: 24))
            }
            .padding(15) // Add padding around the VStack
        }
        .padding(10) // Add additional padding around the entire ZStack
        .frame(maxWidth: .infinity, alignment: .top) // Ensure the card is at the top
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(title: "Your Title", subtitle: "Your Subtitle", image: "figure.walk", amount: "Your Amount"))
    }
}
