import SwiftUI
import CoreData

struct ReportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedReportType: ReportType = .customer
    @State private var dateRange: DateRange = .lastMonth
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Reports & Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Generate comprehensive reports for your business")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Report Type Selection
            GroupBox("Report Type") {
                Picker("Report Type", selection: $selectedReportType) {
                    ForEach(ReportType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            // Date Range Selection
            GroupBox("Date Range") {
                VStack(spacing: 12) {
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if dateRange == .custom {
                        HStack {
                            DatePicker("From", selection: $customStartDate, displayedComponents: .date)
                            DatePicker("To", selection: $customEndDate, displayedComponents: .date)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Report Content
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedReportType {
                    case .customer:
                        CustomerReportView(dateRange: effectiveDateRange)
                    case .project:
                        ProjectReportView(dateRange: effectiveDateRange)
                    case .estimation:
                        EstimationReportView(dateRange: effectiveDateRange)
                    case .material:
                        MaterialReportView(dateRange: effectiveDateRange)
                    case .financial:
                        FinancialReportView(dateRange: effectiveDateRange)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationTitle("Reports")
    }
    
    private var effectiveDateRange: ClosedRange<Date> {
        switch dateRange {
        case .lastWeek:
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: endDate) ?? endDate
            return startDate...endDate
        case .lastMonth:
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate) ?? endDate
            return startDate...endDate
        case .lastQuarter:
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate) ?? endDate
            return startDate...endDate
        case .lastYear:
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate) ?? endDate
            return startDate...endDate
        case .custom:
            return customStartDate...customEndDate
        }
    }
}

enum ReportType: CaseIterable {
    case customer
    case project
    case estimation
    case material
    case financial
    
    var displayName: String {
        switch self {
        case .customer: return "Customer"
        case .project: return "Project"
        case .estimation: return "Estimation"
        case .material: return "Material"
        case .financial: return "Financial"
        }
    }
}

enum DateRange: CaseIterable {
    case lastWeek
    case lastMonth
    case lastQuarter
    case lastYear
    case custom
    
    var displayName: String {
        switch self {
        case .lastWeek: return "Last Week"
        case .lastMonth: return "Last Month"
        case .lastQuarter: return "Last Quarter"
        case .lastYear: return "Last Year"
        case .custom: return "Custom Range"
        }
    }
}

struct CustomerReportView: View {
    let dateRange: ClosedRange<Date>
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.createdDate, ascending: false)],
        animation: .default)
    private var customers: FetchedResults<Customer>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customer Report")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ReportCard(
                    title: "Total Customers",
                    value: "\(customers.count)",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                ReportCard(
                    title: "New Customers",
                    value: "\(newCustomersCount)",
                    icon: "person.badge.plus",
                    color: .green
                )
                
                ReportCard(
                    title: "Active Customers",
                    value: "\(activeCustomersCount)",
                    icon: "person.fill.checkmark",
                    color: .orange
                )
            }
            
            Text("Customer report details will be implemented here")
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private var newCustomersCount: Int {
        customers.filter { customer in
            guard let createdDate = customer.createdDate else { return false }
            return dateRange.contains(createdDate)
        }.count
    }
    
    private var activeCustomersCount: Int {
        customers.filter { customer in
            guard let projects = customer.projects?.allObjects as? [Project] else { return false }
            return projects.contains { project in
                project.status?.lowercased() == "active"
            }
        }.count
    }
}

struct ProjectReportView: View {
    let dateRange: ClosedRange<Date>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Project Report")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Project report details will be implemented here")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

struct EstimationReportView: View {
    let dateRange: ClosedRange<Date>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estimation Report")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Estimation report details will be implemented here")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

struct MaterialReportView: View {
    let dateRange: ClosedRange<Date>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Material Report")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Material report details will be implemented here")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

struct FinancialReportView: View {
    let dateRange: ClosedRange<Date>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Report")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Financial report details will be implemented here")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

struct ReportCard: View {
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

#Preview {
    ReportsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SettingsManager())
}