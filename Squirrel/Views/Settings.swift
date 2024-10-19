//
//  Settings.swift
//  Squirrel
//
//  Created by Bezaleel Ashefor on 2024-10-18.
//


import SwiftUI
import MessageUI

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("preserve_capture_settings") var preserveCaptureSettings : Bool = false
    @AppStorage("push_notifications") var pushNotifications : Bool = false
    @AppStorage("firstName") var firstName : String = ""
    @AppStorage("lastName") var lastName : String = ""
    @State var version : String = ""
    @State private var showingConfirmation = false
    let link = URL(string: "https://tryhermes.app")!
    @State private var linkWrapper: LinkWrapper?
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    let email = "loba@hey.com"
    @Environment(\.colorScheme) var colorScheme
    var gender : String = "male"
    @ObservedObject var healthKitManager : HealthKitManager
    
    
    
    var body: some View {
        VStack(spacing: 0){
            HStack(alignment: .center, spacing: 15){
                Button(action: {presentationMode.wrappedValue.dismiss()}){
                    HStack(alignment: .center){
                        Image(systemName: "multiply")
                            .font(.system(size: 20, weight: .medium))
                            .contentShape(Rectangle())
                        Text("Settings").font(.custom(FontsManager.fontRegular, size: 18))
                    }
                }
                Spacer()
            }.padding([.horizontal], 20).padding([.vertical], 16).padding([.top], 2)
            HStack{
                Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
            }
            ScrollView(showsIndicators: false){
                VStack{
                    VStack{
                        VStack(spacing: 11){
                            Button(action: {
                                healthKitManager.hasAskedForPermission = false
                            }){
                                HStack{
                                    Text("Reset HealthKit Permissions").padding(.bottom, 2)
                                    Spacer()
                                    Image(systemName: "heart.text.square")
                                }
                            }.foregroundColor(Color.primary)
                        }
                    }.padding(.horizontal, 5)
                }.padding([.horizontal], 20).padding([.vertical], 24).padding(.bottom, 20)
            }
            
        }.background(Color("MainBg").ignoresSafeArea()).onAppear{
            initValues()
        }.confirmationDialog("Delete Workouts", isPresented: $showingConfirmation) {
            Button("Delete", role: .destructive) {  }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete your account? You would lose all your domain tracking stats.")
        }.sheet(item: $linkWrapper, onDismiss: {
            
        }, content: { link in
            ActivityViewController(linkWrapper: link).edgesIgnoringSafeArea(.bottom)
        }).sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: self.$isShowingMailView, result: self.$result).edgesIgnoringSafeArea(.bottom)
        }.font(.custom(FontsManager.fontRegular, size: 16))
    }
    
    private func initValues(){
        let versionText = "v" + Bundle.main.releaseVersionNumberPretty + " (" + Bundle.main.buildVersionNumber! + ")"
        version = "Squirrel " + versionText
    }
    
}

#Preview {
    Settings(healthKitManager: HealthKitManager())
}


struct SettingsDivider: View{
    
    var body: some View {
        Divider().overlay(Color.white.opacity(0.6))
    }
    
}

struct LinkWrapper: Identifiable {
    let id = UUID()
    let link: URL
}

struct ActivityViewController: UIViewControllerRepresentable {
    let linkWrapper: LinkWrapper
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [linkWrapper.link], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

enum AppConfiguration {
    case Debug
    case TestFlight
    case AppStore
}

struct Config {
    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    // This can be used to add debug statements.
    static var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    static var appConfiguration: AppConfiguration {
        if isDebug {
            return .Debug
        } else if isTestFlight {
            return .TestFlight
        } else {
            return .AppStore
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    var trackingKey: String {
        switch (Config.appConfiguration) {
        case .Debug:
            return "Dev"
        case .TestFlight:
            return "Testflight"
        default:
            return "AppStore"
        }
    }
    let email = "loba@hey.com"
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result)
    }
    
    private func getEnvironmentDetails() -> String{
        let version = "<p>Version: " + Bundle.main.releaseVersionNumberPretty + " (" + Bundle.main.buildVersionNumber! + ")</p>"
        let device = "<p>Device: \(UIDevice.current.model)</p>"
        let system = "<p>OS: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)</p>"
        let timezone = "<p>Timezone: \(TimeZone.current.identifier)</p>"
        let env = "<p>Environment:\(trackingKey)</p>"
        let encode = Locale.current.language.languageCode?.identifier
        let language = "<p>Language: \(encode ?? "")</p>"
        let label = "<br/><br/><div><p>---</p>\(version)\(device)\(system)\(language)\(timezone)\(env)<p>---</p></div>"
        return label
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([email])
        vc.setSubject("Plomer iOS")
        vc.setMessageBody(getEnvironmentDetails(), isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        
    }
}
