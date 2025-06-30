import SwiftUI
import CoreData

struct AddEditMaterialView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    
    let material: Material?
    
    @State private var itemCode = ""
    @State private var itemName = ""
    @State private var storingUOM = ""
    @State private var purchasingAmount = ""
    @State private var consumingUOM = ""
    @State private var conversionUnit = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(material: Material? = nil) {
        self.material = material
        if let material = material {
            _itemCode = State(initialValue: material.itemCode ?? "")
            _itemName = State(initialValue: material.itemName ?? "")
            _storingUOM = State(initialValue: material.storingUOM ?? "")
            _purchasingAmount = State(initialValue: String(format: "%.2f", material.purchasingAmount))
            _consumingUOM = State(initialValue: material.consumingUOM ?? "")
            _conversionUnit = State(initialValue: String(format: "%.2f", material.conversionUnit))
        }
    }
    
    var isEditing: Bool {
        material != nil
    }
    
    var consumingRate: Double {
        let amount = Double(purchasingAmount) ?? 0
        let conversion = Double(conversionUnit) ?? 1
        return conversion > 0 ? amount / conversion : 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Material Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item Code *")
                            .font(.headline)
                        TextField("Enter item code", text: $itemCode)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item Name *")
                            .font(.headline)
                        TextField("Enter item name", text: $itemName)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section("Unit Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Storing UOM *")
                            .font(.headline)
                        TextField("e.g., Bag, Ton, Piece", text: $storingUOM)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Consuming UOM *")
                            .font(.headline)
                        TextField("e.g., Kg, Meter, Piece", text: $consumingUOM)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Conversion Unit")
                            .font(.headline)
                        TextField("How many consuming units per storing unit", text: $conversionUnit)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        
                        Text("Example: 1 Bag = 50 Kg, enter 50")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Pricing") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Purchasing Amount *")
                            .font(.headline)
                        TextField("Enter amount in \(settingsManager.selectedCurrency.rawValue)", text: $purchasingAmount)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        
                        Text("Price per \(storingUOM.isEmpty ? "storing unit" : storingUOM)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !conversionUnit.isEmpty && Double(conversionUnit) ?? 0 > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calculated Consuming Rate")
                                .font(.headline)
                            
                            HStack {
                                Text(settingsManager.formatCurrency(consumingRate))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text("per \(consumingUOM.isEmpty ? "consuming unit" : consumingUOM)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if isEditing, let material = material {
                    Section("Information") {
                        HStack {
                            Text("Created")
                            Spacer()
                            Text(material.createdDate ?? Date(), style: .date)
                                .foregroundColor(.secondary)
                        }
                        
                        if let updatedDate = material.updatedDate {
                            HStack {
                                Text("Last Updated")
                                Spacer()
                                Text(updatedDate, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let itemMaterials = material.itemMaterials {
                            HStack {
                                Text("Used in Items")
                                Spacer()
                                Text("\(itemMaterials.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Material" : "New Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMaterial()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .frame(width: 500, height: 700)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !itemCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !storingUOM.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !consumingUOM.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !purchasingAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(purchasingAmount) != nil &&
        Double(purchasingAmount) ?? 0 > 0
    }
    
    private func saveMaterial() {
        let trimmedItemCode = itemCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedItemName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStoringUOM = storingUOM.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConsumingUOM = consumingUOM.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let amount = Double(purchasingAmount), amount > 0 else {
            alertMessage = "Please enter a valid purchasing amount."
            showingAlert = true
            return
        }
        
        let conversion = Double(conversionUnit) ?? 1.0
        guard conversion > 0 else {
            alertMessage = "Conversion unit must be greater than 0."
            showingAlert = true
            return
        }
        
        // Check for duplicate item code (only for new materials or if code changed)
        if material == nil || material?.itemCode != trimmedItemCode {
            let fetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "itemCode == %@", trimmedItemCode)
            
            do {
                let existingMaterials = try viewContext.fetch(fetchRequest)
                if !existingMaterials.isEmpty {
                    alertMessage = "A material with item code '\(trimmedItemCode)' already exists."
                    showingAlert = true
                    return
                }
            } catch {
                alertMessage = "Error checking for duplicate item code: \(error.localizedDescription)"
                showingAlert = true
                return
            }
        }
        
        withAnimation {
            let materialToSave: Material
            
            if let existingMaterial = material {
                materialToSave = existingMaterial
                materialToSave.updatedDate = Date()
            } else {
                materialToSave = Material(context: viewContext)
                materialToSave.id = UUID()
                materialToSave.createdDate = Date()
            }
            
            materialToSave.itemCode = trimmedItemCode
            materialToSave.itemName = trimmedItemName
            materialToSave.storingUOM = trimmedStoringUOM
            materialToSave.consumingUOM = trimmedConsumingUOM
            materialToSave.purchasingAmount = amount
            materialToSave.conversionUnit = conversion
            materialToSave.consumingRate = amount / conversion
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                alertMessage = "Failed to save material: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}

#Preview {
    AddEditMaterialView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SettingsManager())
}