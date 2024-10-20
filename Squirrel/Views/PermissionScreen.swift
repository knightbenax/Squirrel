//
//  PermissionScreen.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//

import SwiftUI

struct PermissionScreen: View {
    @ObservedObject var healthKitManager: HealthKitManager
    var requestHealthPermissionsAndLoadData : () -> () = {}
    
    var body: some View {
        VStack{
            Spacer()
            Image("Logo").resizable().scaledToFit().frame(width: 220)
            Spacer().frame(height: 20)
            Text("Squirrel needs your permission to access your health data.")
                .multilineTextAlignment(.center).padding(.horizontal, 50)
            Spacer().frame(height: 40)
            HealthKitLinkButton(action: {
                healthKitManager.requestAuthorization(completion: { result in
                    requestHealthPermissionsAndLoadData()
                })
            })
        }.padding(.bottom, 50).padding(.top, 20)
    }
}

#Preview {
    PermissionScreen(healthKitManager: HealthKitManager())
}
