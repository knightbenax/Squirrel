//
//  HealthKitLinkButton.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//

import SwiftUI

struct HealthKitLinkButton: View {
    var action: () -> () = {}
    
    var body: some View {
        Button(action: {
            DispatchQueue.main.async {
                action()
            }
        }){
            HStack{
                Image(systemName: "waveform.path.ecg")
                Text("Connect HealthKit")
            }.padding(.vertical, 15).frame(maxWidth: .infinity).foregroundStyle(Color.white)
        }.background(Color("HealthKitBg")).clipShape(RoundedRectangle(cornerRadius: 10)).font(.custom(FontsManager.fontMedium, size: 16)).padding(.horizontal, 18)
    }
}

#Preview {
    HealthKitLinkButton()
}
