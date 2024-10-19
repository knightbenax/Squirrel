//
//  ContentView.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var showSettings = false
    @State var healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack{
            if (!healthKitManager.hasAskedForPermission){
                HStack(alignment: .center){
                    Text("Hey, what's the rush? 😄")
                }.padding(.top, 40).ignoresSafeArea()
            } else {
                TopBar(showSettings: $showSettings)
            }
            Spacer()
        }.sheet(isPresented: $healthKitManager.hasAskedForPermission.not){
            PermissionScreen(healthKitManager: healthKitManager, requestHealthPermissionsAndLoadData: requestHealthPermissionsAndLoadData)
                .interactiveDismissDisabled()
        }.sheet(isPresented: $showSettings){
            Settings(healthKitManager: healthKitManager)
        }.font(.custom(FontsManager.fontRegular, size: 16))
    }
    
    func requestHealthPermissionsAndLoadData(){
        healthKitManager.requestAuthorization(completion: {_ in
            let calendar = Calendar.current
            let endDate = Date()
            let startDate = calendar.date(byAdding: .day, value: -1, to: endDate)!
            healthKitManager.fetchSleepDataForDay(startDate: startDate, endDate: endDate)
        })
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
