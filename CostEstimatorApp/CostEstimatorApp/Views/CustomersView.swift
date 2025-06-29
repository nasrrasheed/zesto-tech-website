import SwiftUI
import CoreData

struct CustomersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.name, ascending: true)],
        animation: .default)
    private var customers: FetchedResults<Customer>
    
    @State private var showingAddCustomer = false
    @State private var selectedCustomer: Customer?
    @State private var searchText = ""
    
    var filteredCustomers: [Customer] {
        if searchText.isEmpty {
            return Array(customers)
        } else {
            return customers.filter { customer in
                (customer.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (customer.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (customer.phone?.localizedCaseInsensitiveContains(searchText) ?? false)
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
                    TextField("Search customers...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Customer List
                List(filteredCustomers, id: \.id, selection: $selectedCustomer) { customer in
                    CustomerRowView(customer: customer)
                        .tag(customer)
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Customers (\(customers.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddCustomer = true }) {
                        Image(systemName: "plus")
                    }
                    .disabled(!authManager.hasPermission(.editCustomers))
                    .help("Add Customer")
                }
            }
        } detail: {
            if let customer = selectedCustomer {
                CustomerDetailView(customer: customer)
            } else {
                ContentUnavailableView(
                    "Select a Customer",
                    systemImage: "person.2",
                    description: Text("Choose a customer from the list to view details")
                )
            }
        }
        .sheet(isPresented: $showingAddCustomer) {
            AddEditCustomerView()
        }
    }
}

struct CustomerRowView: View {
    let customer: Customer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(customer.name ?? "Unnamed Customer")
                .font(.headline)
                .lineLimit(1)
            
            if let email = customer.email, !email.isEmpty {
                Text(email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if let phone = customer.phone, !phone.isEmpty {
                Text(phone)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                Text("\(customer.projects?.count ?? 0) projects")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                if let date = customer.createdDate {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct CustomerDetailView: View {
    let customer: Customer
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingEditCustomer = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(customer.name ?? "Unnamed Customer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if authManager.hasPermission(.editCustomers) {
                            Menu {
                                Button("Edit Customer") {
                                    showingEditCustomer = true
                                }
                                
                                Divider()
                                
                                Button("Delete Customer", role: .destructive) {
                                    showingDeleteAlert = true
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                            }
                        }
                    }
                    
                    if let date = customer.createdDate {
                        Text("Customer since \(date, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Contact Information
                GroupBox("Contact Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        if let email = customer.email, !email.isEmpty {
                            InfoRow(label: "Email", value: email, icon: "envelope")
                        }
                        
                        if let phone = customer.phone, !phone.isEmpty {
                            InfoRow(label: "Phone", value: phone, icon: "phone")
                        }
                        
                        if let address = customer.address, !address.isEmpty {
                            InfoRow(label: "Address", value: address, icon: "location")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Projects
                GroupBox("Projects (\(customer.projects?.count ?? 0))") {
                    if let projects = customer.projects?.allObjects as? [Project], !projects.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(projects.sorted(by: { ($0.createdDate ?? Date()) > ($1.createdDate ?? Date()) }), id: \.id) { project in
                                ProjectRowInCustomer(project: project)
                            }
                        }
                    } else {
                        Text("No projects yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Customer Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditCustomer) {
            AddEditCustomerView(customer: customer)
        }
        .alert("Delete Customer", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCustomer()
            }
        } message: {
            Text("Are you sure you want to delete this customer? This action cannot be undone and will also delete all associated projects and quotations.")
        }
    }
    
    private func deleteCustomer() {
        withAnimation {
            viewContext.delete(customer)
            
            do {
                try viewContext.save()
            } catch {
                // Handle error
                print("Error deleting customer: \(error)")
            }
        }
    }
}

struct ProjectRowInCustomer: View {
    let project: Project
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name ?? "Unnamed Project")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let description = project.projectDescription, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(project.status ?? "Unknown")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor(project.status ?? "Unknown"))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                if let date = project.createdDate {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
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

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

#Preview {
    CustomersView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AuthenticationManager())
}