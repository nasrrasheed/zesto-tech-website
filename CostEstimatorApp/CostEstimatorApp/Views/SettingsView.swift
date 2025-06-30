import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        NavigationView {
            Form {
                Section("Currency Settings") {
                    Picker("Default Currency", selection: $settingsManager.selectedCurrency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            HStack {
                                Text(currency.symbol)
                                    .frame(width: 30, alignment: .leading)
                                Text("\(currency.rawValue) - \(currency.name)")
                            }
                            .tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Company Information") {
                    TextField("Company Name", text: $settingsManager.companyName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Address", text: $settingsManager.companyAddress, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                    
                    TextField("Phone", text: $settingsManager.companyPhone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $settingsManager.companyEmail)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section("Default Values") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Profit Margin (%)")
                            .font(.headline)
                        
                        HStack {
                            Slider(value: $settingsManager.defaultProfitMargin, in: 0...50, step: 0.5)
                            Text("\(String(format: "%.1f", settingsManager.defaultProfitMargin))%")
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Overhead Percentage (%)")
                            .font(.headline)
                        
                        HStack {
                            Slider(value: $settingsManager.defaultOverheadPercentage, in: 0...30, step: 0.5)
                            Text("\(String(format: "%.1f", settingsManager.defaultOverheadPercentage))%")
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tax Percentage (%)")
                            .font(.headline)
                        
                        HStack {
                            Slider(value: $settingsManager.taxPercentage, in: 0...20, step: 0.5)
                            Text("\(String(format: "%.1f", settingsManager.taxPercentage))%")
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                }
                
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency Format Preview")
                            .font(.headline)
                        
                        HStack {
                            Text("Sample Amount:")
                            Spacer()
                            Text(settingsManager.formatCurrency(1234.56))
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        settingsManager.saveSettings()
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
}