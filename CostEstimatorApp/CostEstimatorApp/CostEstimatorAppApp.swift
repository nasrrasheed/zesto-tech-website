import SwiftUI

@main
struct CostEstimatorAppApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var settingsManager = SettingsManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authManager)
                    .environmentObject(settingsManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Customer") {
                    // Handle new customer
                }
                .keyboardShortcut("n", modifiers: [.command])
                
                Button("New Project") {
                    // Handle new project
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
    }
}