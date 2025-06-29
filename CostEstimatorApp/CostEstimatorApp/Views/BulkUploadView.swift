import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct BulkUploadView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedFileURL: URL?
    @State private var isProcessing = false
    @State private var uploadResults: UploadResults?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var previewData: [MaterialCSVRow] = []
    @State private var showingPreview = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Bulk Upload Materials")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Upload materials from a CSV file")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // File Selection
                VStack(spacing: 16) {
                    if let fileURL = selectedFileURL {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.green)
                            Text(fileURL.lastPathComponent)
                                .font(.subheadline)
                            Spacer()
                            Button("Remove") {
                                selectedFileURL = nil
                                previewData = []
                                showingPreview = false
                            }
                            .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Button(action: selectFile) {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.circle.dashed")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                
                                Text("Select CSV File")
                                    .font(.headline)
                                
                                Text("Choose a CSV file containing material data")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // CSV Format Information
                    GroupBox("CSV Format Requirements") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Required columns (in order):")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(MaterialCSVColumn.allCases, id: \.self) { column in
                                    HStack {
                                        Text("• \(column.displayName)")
                                            .font(.caption)
                                        if column.isRequired {
                                            Text("(Required)")
                                                .font(.caption2)
                                                .foregroundColor(.red)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            
                            Text("Note: First row should contain column headers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    // Preview Data
                    if showingPreview && !previewData.isEmpty {
                        GroupBox("Preview (\(previewData.count) rows)") {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 4) {
                                    ForEach(Array(previewData.prefix(10).enumerated()), id: \.offset) { index, row in
                                        HStack {
                                            Text("\(index + 1).")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .frame(width: 20, alignment: .leading)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("\(row.itemCode) - \(row.itemName)")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                
                                                Text("\(settingsManager.formatCurrency(row.purchasingAmount)) | \(row.storingUOM) → \(row.consumingUOM)")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 2)
                                    }
                                    
                                    if previewData.count > 10 {
                                        Text("... and \(previewData.count - 10) more rows")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                    
                    // Upload Results
                    if let results = uploadResults {
                        GroupBox("Upload Results") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Successfully imported: \(results.successCount)")
                                        .font(.subheadline)
                                }
                                
                                if results.errorCount > 0 {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text("Errors: \(results.errorCount)")
                                            .font(.subheadline)
                                    }
                                    
                                    if !results.errors.isEmpty {
                                        ScrollView {
                                            VStack(alignment: .leading, spacing: 2) {
                                                ForEach(Array(results.errors.enumerated()), id: \.offset) { index, error in
                                                    Text("Row \(error.row): \(error.message)")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                        .frame(maxHeight: 100)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 16) {
                    if selectedFileURL != nil && !showingPreview {
                        Button("Preview Data") {
                            previewCSVData()
                        }
                        .disabled(isProcessing)
                    }
                    
                    if showingPreview && !previewData.isEmpty {
                        Button("Upload Materials") {
                            uploadMaterials()
                        }
                        .disabled(isProcessing)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Bulk Upload")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 700)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .overlay {
            if isProcessing {
                Color.black.opacity(0.3)
                    .overlay {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Processing...")
                                .font(.headline)
                        }
                        .padding(30)
                        .background(Color(NSColor.windowBackgroundColor))
                        .cornerRadius(12)
                    }
            }
        }
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.commaSeparatedText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            selectedFileURL = panel.url
        }
    }
    
    private func previewCSVData() {
        guard let fileURL = selectedFileURL else { return }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let content = try String(contentsOf: fileURL)
                let rows = parseCSV(content: content)
                
                DispatchQueue.main.async {
                    self.previewData = rows
                    self.showingPreview = true
                    self.isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to read CSV file: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func uploadMaterials() {
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var successCount = 0
            var errors: [UploadError] = []
            
            for (index, row) in previewData.enumerated() {
                do {
                    try self.createMaterial(from: row)
                    successCount += 1
                } catch {
                    errors.append(UploadError(row: index + 2, message: error.localizedDescription)) // +2 for header and 1-based indexing
                }
            }
            
            DispatchQueue.main.async {
                self.uploadResults = UploadResults(
                    successCount: successCount,
                    errorCount: errors.count,
                    errors: errors
                )
                self.isProcessing = false
                
                // Save context
                do {
                    try self.viewContext.save()
                } catch {
                    self.alertMessage = "Failed to save materials: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func createMaterial(from row: MaterialCSVRow) throws {
        // Check if material with same item code already exists
        let fetchRequest: NSFetchRequest<Material> = Material.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemCode == %@", row.itemCode)
        
        let existingMaterials = try viewContext.fetch(fetchRequest)
        if !existingMaterials.isEmpty {
            throw MaterialUploadError.duplicateItemCode(row.itemCode)
        }
        
        let material = Material(context: viewContext)
        material.id = UUID()
        material.itemCode = row.itemCode
        material.itemName = row.itemName
        material.storingUOM = row.storingUOM
        material.purchasingAmount = row.purchasingAmount
        material.consumingUOM = row.consumingUOM
        material.conversionUnit = row.conversionUnit
        material.consumingRate = row.conversionUnit > 0 ? row.purchasingAmount / row.conversionUnit : 0
        material.createdDate = Date()
    }
    
    private func parseCSV(content: String) -> [MaterialCSVRow] {
        let lines = content.components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }
        
        var rows: [MaterialCSVRow] = []
        
        // Skip header row
        for line in lines.dropFirst() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }
            
            let columns = parseCSVLine(trimmedLine)
            guard columns.count >= 6 else { continue }
            
            let row = MaterialCSVRow(
                itemCode: columns[0].trimmingCharacters(in: .whitespacesAndNewlines),
                itemName: columns[1].trimmingCharacters(in: .whitespacesAndNewlines),
                storingUOM: columns[2].trimmingCharacters(in: .whitespacesAndNewlines),
                purchasingAmount: Double(columns[3].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0,
                consumingUOM: columns[4].trimmingCharacters(in: .whitespacesAndNewlines),
                conversionUnit: Double(columns[5].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1
            )
            
            rows.append(row)
        }
        
        return rows
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        
        columns.append(currentColumn)
        return columns
    }
}

struct MaterialCSVRow {
    let itemCode: String
    let itemName: String
    let storingUOM: String
    let purchasingAmount: Double
    let consumingUOM: String
    let conversionUnit: Double
}

enum MaterialCSVColumn: CaseIterable {
    case itemCode
    case itemName
    case storingUOM
    case purchasingAmount
    case consumingUOM
    case conversionUnit
    
    var displayName: String {
        switch self {
        case .itemCode: return "Item Code"
        case .itemName: return "Item Name"
        case .storingUOM: return "Storing UOM"
        case .purchasingAmount: return "Purchasing Amount"
        case .consumingUOM: return "Consuming UOM"
        case .conversionUnit: return "Conversion Unit"
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .itemCode, .itemName, .storingUOM, .purchasingAmount, .consumingUOM:
            return true
        case .conversionUnit:
            return false
        }
    }
}

struct UploadResults {
    let successCount: Int
    let errorCount: Int
    let errors: [UploadError]
}

struct UploadError {
    let row: Int
    let message: String
}

enum MaterialUploadError: LocalizedError {
    case duplicateItemCode(String)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .duplicateItemCode(let code):
            return "Material with item code '\(code)' already exists"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }
}

#Preview {
    BulkUploadView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SettingsManager())
}