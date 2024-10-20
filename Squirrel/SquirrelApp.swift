//
//  SquirrelApp.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//

import SwiftUI

@main
struct SquirrelApp: App {
    let persistenceController = PersistenceController.shared
    @State var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(healthKitManager: healthKitManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
