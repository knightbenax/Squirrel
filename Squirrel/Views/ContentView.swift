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
    @ObservedObject var healthKitManager : HealthKitManager
    @State var loadingSleepData = false
    
    var body: some View {
        VStack(spacing: 20){
            if (!healthKitManager.hasAskedForPermission){
                HStack(alignment: .center){
                    Text("Hey, what's the rush? 😄")
                }.padding(.top, 40).ignoresSafeArea()
            } else {
                TopBar(showSettings: $showSettings, reloadSleepData: loadSleepData)
                if (!loadingSleepData) {
                    SleepPanel(sleepData: $healthKitManager.sleepData)
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            Spacer()
        }.sheet(isPresented: $healthKitManager.hasAskedForPermission.not){
            PermissionScreen(healthKitManager: healthKitManager, requestHealthPermissionsAndLoadData: requestHealthPermissionsAndLoadData)
                .interactiveDismissDisabled()
        }.sheet(isPresented: $showSettings){
            Settings(healthKitManager: healthKitManager)
        }
        .font(.custom(FontsManager.fontRegular, size: 16))
            .onAppear(perform: {
                if (healthKitManager.hasAskedForPermission){
                    loadSleepData()
                }
        })
    }
    
    private func requestHealthPermissionsAndLoadData(){
        healthKitManager.requestAuthorization(completion: { value in
            if (value) {
                DispatchQueue.main.async {
                    healthKitManager.hasAskedForPermission = true
                }
                loadSleepData()
            }
        })
    }
    
    private func loadSleepData(){
        loadingSleepData = true
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: endDate)!
        healthKitManager.fetchSleepDataForDay(startDate: startDate, endDate: endDate, completion: { result in
            loadingSleepData = false
        })
        
    }
}

#Preview {
    ContentView(healthKitManager: HealthKitManager()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
