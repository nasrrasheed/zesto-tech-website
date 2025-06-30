import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settingsManager: SettingsManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.createdDate, ascending: false)],
        animation: .default)
    private var customers: FetchedResults<Customer>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.createdDate, ascending: false)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Quotation.createdDate, ascending: false)],
        animation: .default)
    private var quotations: FetchedResults<Quotation>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Material.createdDate, ascending: false)],
        animation: .default)
    private var materials: FetchedResults<Material>
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                // Statistics Cards
                StatCard(
                    title: "Total Customers",
                    value: "\(customers.count)",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Active Projects",
                    value: "\(activeProjectsCount)",
                    icon: "folder.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Quotations",
                    value: "\(quotations.count)",
                    icon: "doc.text.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Materials",
                    value: "\(materials.count)",
                    icon: "cube.box.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Recent Activity
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Activity")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    // Recent Projects
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.green)
                            Text("Recent Projects")
                                .font(.headline)
                            Spacer()
                        }
                        
                        if projects.isEmpty {
                            Text("No projects yet")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        } else {
                            ForEach(Array(projects.prefix(5)), id: \.id) { project in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(project.name ?? "Unnamed Project")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                        Text(project.customer?.name ?? "No Customer")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(project.status ?? "Unknown")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(statusColor(project.status ?? "Unknown"))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Recent Quotations
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.orange)
                            Text("Recent Quotations")
                                .font(.headline)
                            Spacer()
                        }
                        
                        if quotations.isEmpty {
                            Text("No quotations yet")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        } else {
                            ForEach(Array(quotations.prefix(5)), id: \.id) { quotation in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(quotation.quotationNumber ?? "No Number")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                        Text(quotation.project?.name ?? "No Project")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(settingsManager.formatCurrency(quotation.totalAmount))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            
            // Quick Actions
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Actions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    QuickActionButton(
                        title: "New Customer",
                        icon: "person.badge.plus",
                        color: .blue
                    ) {
                        // Handle new customer
                    }
                    
                    QuickActionButton(
                        title: "New Project",
                        icon: "folder.badge.plus",
                        color: .green
                    ) {
                        // Handle new project
                    }
                    
                    QuickActionButton(
                        title: "New Quotation",
                        icon: "doc.badge.plus",
                        color: .orange
                    ) {
                        // Handle new quotation
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .padding(.bottom, 40)
        }
        .navigationTitle("Dashboard")
    }
    
    private var activeProjectsCount: Int {
        projects.filter { $0.status?.lowercased() == "active" }.count
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active", "in progress":
            return .green
        case "completed":
            return .blue
        case "on hold":
            return .orange
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SettingsManager())
}