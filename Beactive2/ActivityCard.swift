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
                .cornerRadius(20)
            VStack(spacing:10) {
                HStack (alignment : .top) {
                    VStack(alignment: .leading, spacing: 10) {
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
            .padding()

        }
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(title: "Your Title", subtitle: "Your Subtitle", image: "figure.walk", amount: "Your Amount"))
    }
}
