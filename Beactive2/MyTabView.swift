//
//  MyTabView.swift
//  BeActive
//
//  Created by Joshua on 1/22/24.
//

import SwiftUI

struct MyTabView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedTab = "Home"
    var body: some View {
        TabView(selection: $selectedTab){
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                }            
            ContentView()
                .tag("Content")
                .tabItem {
                    Image(systemName: "person")
                }
        }
    }
}

struct MyTabView_Previews: PreviewProvider {
    static var previews: some View {
        MyTabView()
          
    }
}
