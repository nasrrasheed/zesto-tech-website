import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTab: SidebarItem = .dashboard
    @State private var showingSettings = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .customers:
                    CustomersView()
                case .projects:
                    ProjectsView()
                case .quotations:
                    QuotationsView()
                case .materials:
                    MaterialsView()
                case .reports:
                    ReportsView()
                case .users:
                    UsersView()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                    .help("Settings")
                    
                    Menu {
                        Text("Logged in as: \(authManager.currentUser?.username ?? "")")
                        Text("Role: \(authManager.currentUser?.role.rawValue ?? "")")
                        Divider()
                        Button("Logout") {
                            authManager.logout()
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                    .help("User Menu")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settingsManager)
        }
    }
}

enum SidebarItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case customers = "Customers"
    case projects = "Projects"
    case quotations = "Quotations"
    case materials = "Materials"
    case reports = "Reports"
    case users = "Users"
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.pie.fill"
        case .customers: return "person.2.fill"
        case .projects: return "folder.fill"
        case .quotations: return "doc.text.fill"
        case .materials: return "cube.box.fill"
        case .reports: return "chart.bar.fill"
        case .users: return "person.3.fill"
        }
    }
    
    func isAccessible(for user: User?) -> Bool {
        guard let user = user else { return false }
        
        switch self {
        case .dashboard:
            return true
        case .customers:
            return user.role.permissions.contains(.viewCustomers)
        case .projects:
            return user.role.permissions.contains(.viewProjects)
        case .quotations:
            return user.role.permissions.contains(.viewQuotations)
        case .materials:
            return user.role.permissions.contains(.viewMaterials)
        case .reports:
            return user.role.permissions.contains(.viewReports)
        case .users:
            return user.role.permissions.contains(.userManagement)
        }
    }
}

struct SidebarView: View {
    @Binding var selectedTab: SidebarItem
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        List(selection: $selectedTab) {
            Section("Navigation") {
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    if item.isAccessible(for: authManager.currentUser) {
                        NavigationLink(value: item) {
                            Label(item.rawValue, systemImage: item.icon)
                        }
                    }
                }
            }
        }
        .navigationTitle("Cost Estimator")
        .listStyle(.sidebar)
    }
}

#Preview {
    MainContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(SettingsManager())
}