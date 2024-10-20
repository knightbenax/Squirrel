//
//  TopBar.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//


//
//  TopBar.swift
//  Gage
//
//  Created by Bezaleel Ashefor on 02/09/2024.
//

import SwiftUI

struct TopBar: View {
    @State var headerText = "Hiya"
    @Binding var showSettings : Bool
    var reloadSleepData : () -> () = {}
    
    var body: some View {
        HStack(alignment: .center, spacing: 20){
            Text("\(headerText)").contentShape(Rectangle()).font(.custom(FontsManager.fontBlack, size: 28))
            Spacer()
            Button(action: {
                reloadSleepData()
            }){
                Image(systemName: "arrow.clockwise").foregroundStyle(Color.primary)
            }
            Button(action: {
                showSettings.toggle()
            }){
                Image("me").resizable().scaledToFill()
                    .frame(width: 34, height: 34).clipShape(Circle())
            }
        }.padding(.horizontal, 22).padding(.top, 15).padding(.bottom, 10)
    }
}

#Preview {
    TopBar(showSettings: .constant(false))
}
