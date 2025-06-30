import SwiftUI
import CoreData

struct AddEditCustomerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let customer: Customer?
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(customer: Customer? = nil) {
        self.customer = customer
        if let customer = customer {
            _name = State(initialValue: customer.name ?? "")
            _email = State(initialValue: customer.email ?? "")
            _phone = State(initialValue: customer.phone ?? "")
            _address = State(initialValue: customer.address ?? "")
        }
    }
    
    var isEditing: Bool {
        customer != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Customer Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name *")
                            .font(.headline)
                        TextField("Enter customer name", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        TextField("Enter email address", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone")
                            .font(.headline)
                        TextField("Enter phone number", text: $phone)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.phonePad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.headline)
                        TextField("Enter address", text: $address, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                }
                
                if isEditing, let customer = customer {
                    Section("Information") {
                        HStack {
                            Text("Created")
                            Spacer()
                            Text(customer.createdDate ?? Date(), style: .date)
                                .foregroundColor(.secondary)
                        }
                        
                        if let updatedDate = customer.updatedDate {
                            HStack {
                                Text("Last Updated")
                                Spacer()
                                Text(updatedDate, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Projects")
                            Spacer()
                            Text("\(customer.projects?.count ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Customer" : "New Customer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCustomer()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(width: 500, height: 600)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveCustomer() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            alertMessage = "Customer name is required."
            showingAlert = true
            return
        }
        
        // Validate email if provided
        if !email.isEmpty && !isValidEmail(email) {
            alertMessage = "Please enter a valid email address."
            showingAlert = true
            return
        }
        
        withAnimation {
            let customerToSave: Customer
            
            if let existingCustomer = customer {
                customerToSave = existingCustomer
                customerToSave.updatedDate = Date()
            } else {
                customerToSave = Customer(context: viewContext)
                customerToSave.id = UUID()
                customerToSave.createdDate = Date()
            }
            
            customerToSave.name = trimmedName
            customerToSave.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
            customerToSave.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
            customerToSave.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                alertMessage = "Failed to save customer: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    AddEditCustomerView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}