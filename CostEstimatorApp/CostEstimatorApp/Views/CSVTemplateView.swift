import SwiftUI
import UniformTypeIdentifiers

struct CSVTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let templateContent = """
Item Code,Item Name,Storing UOM,Purchasing Amount,Consuming UOM,Conversion Unit
CEM001,Portland Cement,Bag,25.00,Kg,50.00
STL001,Steel Rebar 12mm,Ton,2500.00,Kg,1000.00
BLK001,Concrete Block 200mm,Piece,3.50,Piece,1.00
SND001,Fine Sand,Cubic Meter,45.00,Cubic Meter,1.00
GRV001,Coarse Aggregate,Cubic Meter,55.00,Cubic Meter,1.00
PNT001,Emulsion Paint,Liter,15.00,Liter,1.00
TIL001,Ceramic Floor Tile,Square Meter,35.00,Square Meter,1.00
WIR001,Electrical Wire 2.5mm,Meter,2.50,Meter,1.00
PIP001,PVC Pipe 110mm,Meter,12.00,Meter,1.00
INS001,Thermal Insulation,Square Meter,8.50,Square Meter,1.00
"""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("CSV Template")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Download template for bulk material upload")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Template Information
                GroupBox("Template Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This template contains the required format for bulk uploading materials:")
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 6) {
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
                                    
                                    Text(columnDescription(for: column))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Important Notes:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("• Keep the header row as the first line")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("• Item codes must be unique")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("• Conversion unit represents how many consuming units equal one storing unit")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("• Use decimal numbers for amounts (e.g., 25.50)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Template Preview
                GroupBox("Template Preview") {
                    ScrollView {
                        Text(templateContent)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(6)
                    }
                    .frame(maxHeight: 200)
                }
                
                Spacer()
                
                // Download Button
                Button(action: downloadTemplate) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Download CSV Template")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("CSV Template")
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
        .alert("Download Status", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func columnDescription(for column: MaterialCSVColumn) -> String {
        switch column {
        case .itemCode:
            return "Unique identifier"
        case .itemName:
            return "Material description"
        case .storingUOM:
            return "Storage unit"
        case .purchasingAmount:
            return "Price per storing unit"
        case .consumingUOM:
            return "Usage unit"
        case .conversionUnit:
            return "Conversion factor"
        }
    }
    
    private func downloadTemplate() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.commaSeparatedText]
        panel.nameFieldStringValue = "materials_template.csv"
        panel.title = "Save CSV Template"
        
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            
            do {
                try templateContent.write(to: url, atomically: true, encoding: .utf8)
                alertMessage = "Template downloaded successfully to \(url.lastPathComponent)"
                showingAlert = true
            } catch {
                alertMessage = "Failed to save template: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}

#Preview {
    CSVTemplateView()
}