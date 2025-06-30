import SwiftUI
import CoreData

struct QuotationsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Quotation.createdDate, ascending: false)],
        animation: .default)
    private var quotations: FetchedResults<Quotation>
    
    @State private var selectedQuotation: Quotation?
    @State private var searchText = ""
    
    var filteredQuotations: [Quotation] {
        if searchText.isEmpty {
            return Array(quotations)
        } else {
            return quotations.filter { quotation in
                (quotation.quotationNumber?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (quotation.project?.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (quotation.project?.customer?.name?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search quotations...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Quotations List
                List(filteredQuotations, id: \.id, selection: $selectedQuotation) { quotation in
                    QuotationRowView(quotation: quotation)
                        .tag(quotation)
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Quotations (\(quotations.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { /* Add new quotation */ }) {
                        Image(systemName: "plus")
                    }
                    .disabled(!authManager.hasPermission(.editQuotations))
                    .help("Add Quotation")
                }
            }
        } detail: {
            if let quotation = selectedQuotation {
                QuotationDetailView(quotation: quotation)
            } else {
                ContentUnavailableView(
                    "Select a Quotation",
                    systemImage: "doc.text",
                    description: Text("Choose a quotation from the list to view details")
                )
            }
        }
    }
}

struct QuotationRowView: View {
    let quotation: Quotation
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(quotation.quotationNumber ?? "No Number")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(settingsManager.formatCurrency(quotation.totalAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            if let project = quotation.project?.name {
                Text(project)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if let customer = quotation.project?.customer?.name {
                Text(customer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                Text(quotation.status ?? "Draft")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor(quotation.status ?? "Draft"))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Spacer()
                
                if let date = quotation.createdDate {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "approved", "accepted":
            return .green
        case "pending", "sent":
            return .orange
        case "draft":
            return .blue
        case "rejected", "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

struct QuotationDetailView: View {
    let quotation: Quotation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(quotation.quotationNumber ?? "No Number")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Quotation details will be implemented here")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Quotation Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    QuotationsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AuthenticationManager())
        .environmentObject(SettingsManager())
}