import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct MaterialsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Material.itemCode, ascending: true)],
        animation: .default)
    private var materials: FetchedResults<Material>
    
    @State private var showingAddMaterial = false
    @State private var showingBulkUpload = false
    @State private var showingCSVTemplate = false
    @State private var selectedMaterial: Material?
    @State private var searchText = ""
    
    var filteredMaterials: [Material] {
        if searchText.isEmpty {
            return Array(materials)
        } else {
            return materials.filter { material in
                (material.itemCode?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (material.itemName?.localizedCaseInsensitiveContains(searchText) ?? false)
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
                    TextField("Search materials...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Materials List
                List(filteredMaterials, id: \.id, selection: $selectedMaterial) { material in
                    MaterialRowView(material: material)
                        .tag(material)
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Materials (\(materials.count))")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        Button("Add Material") {
                            showingAddMaterial = true
                        }
                        .disabled(!authManager.hasPermission(.editMaterials))
                        
                        Divider()
                        
                        Button("Bulk Upload") {
                            showingBulkUpload = true
                        }
                        .disabled(!authManager.hasPermission(.bulkUpload))
                        
                        Button("Download CSV Template") {
                            showingCSVTemplate = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help("Material Actions")
                }
            }
        } detail: {
            if let material = selectedMaterial {
                MaterialDetailView(material: material)
            } else {
                ContentUnavailableView(
                    "Select a Material",
                    systemImage: "cube.box",
                    description: Text("Choose a material from the list to view details")
                )
            }
        }
        .sheet(isPresented: $showingAddMaterial) {
            AddEditMaterialView()
        }
        .sheet(isPresented: $showingBulkUpload) {
            BulkUploadView()
        }
        .sheet(isPresented: $showingCSVTemplate) {
            CSVTemplateView()
        }
    }
}

struct MaterialRowView: View {
    let material: Material
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(material.itemCode ?? "No Code")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(settingsManager.formatCurrency(material.purchasingAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            Text(material.itemName ?? "Unnamed Material")
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            HStack {
                Text("Store: \(material.storingUOM ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Consume: \(material.consumingUOM ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if material.conversionUnit > 0 {
                    Text("1:\(String(format: "%.2f", material.conversionUnit))")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(3)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct MaterialDetailView: View {
    let material: Material
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingEditMaterial = false
    @State private var showingDeleteAlert = false
    
    var consumingRate: Double {
        guard material.conversionUnit > 0 else { return 0 }
        return material.purchasingAmount / material.conversionUnit
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(material.itemCode ?? "No Code")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(material.itemName ?? "Unnamed Material")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if authManager.hasPermission(.editMaterials) {
                            Menu {
                                Button("Edit Material") {
                                    showingEditMaterial = true
                                }
                                
                                Divider()
                                
                                Button("Delete Material", role: .destructive) {
                                    showingDeleteAlert = true
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                            }
                        }
                    }
                    
                    if let date = material.createdDate {
                        Text("Added on \(date, style: .date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Pricing Information
                GroupBox("Pricing Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Purchasing Amount")
                                .font(.headline)
                            Spacer()
                            Text(settingsManager.formatCurrency(material.purchasingAmount))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Consuming Rate")
                                .font(.headline)
                            Spacer()
                            Text(settingsManager.formatCurrency(consumingRate))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        if material.conversionUnit > 0 {
                            HStack {
                                Text("Conversion Ratio")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("1 \(material.storingUOM ?? "unit") = \(String(format: "%.2f", material.conversionUnit)) \(material.consumingUOM ?? "units")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Unit Information
                GroupBox("Unit Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Storing UOM")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(material.storingUOM ?? "Not specified")
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Consuming UOM")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(material.consumingUOM ?? "Not specified")
                                    .font(.body)
                            }
                        }
                        
                        if material.conversionUnit > 0 {
                            HStack {
                                Text("Conversion Unit")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.2f", material.conversionUnit))
                                    .font(.body)
                            }
                        }
                    }
                }
                
                // Usage Information
                if let itemMaterials = material.itemMaterials, !itemMaterials.isEmpty {
                    GroupBox("Usage in Projects") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("This material is used in \(itemMaterials.count) estimation items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Show recent usage
                            ForEach(Array(itemMaterials.prefix(5)), id: \.self) { itemMaterial in
                                if let estimationItem = itemMaterial as? ItemMaterial,
                                   let item = estimationItem.estimationItem {
                                    HStack {
                                        Text(item.name ?? "Unnamed Item")
                                            .font(.caption)
                                        Spacer()
                                        Text("\(String(format: "%.2f", estimationItem.consumedQuantity)) \(estimationItem.consumedUOM ?? "")")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Material Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditMaterial) {
            AddEditMaterialView(material: material)
        }
        .alert("Delete Material", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteMaterial()
            }
        } message: {
            Text("Are you sure you want to delete this material? This action cannot be undone.")
        }
    }
    
    private func deleteMaterial() {
        withAnimation {
            viewContext.delete(material)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting material: \(error)")
            }
        }
    }
}

#Preview {
    MaterialsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AuthenticationManager())
        .environmentObject(SettingsManager())
}