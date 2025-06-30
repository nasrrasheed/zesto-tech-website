import Foundation
import SwiftUI

enum Currency: String, CaseIterable, Codable {
    case aed = "AED"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case inr = "INR"
    case sar = "SAR"
    
    var symbol: String {
        switch self {
        case .aed: return "د.إ"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .inr: return "₹"
        case .sar: return "ر.س"
        }
    }
    
    var name: String {
        switch self {
        case .aed: return "UAE Dirham"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .inr: return "Indian Rupee"
        case .sar: return "Saudi Riyal"
        }
    }
}

class SettingsManager: ObservableObject {
    @Published var selectedCurrency: Currency = .aed
    @Published var companyName: String = "Zesto Tech"
    @Published var companyAddress: String = ""
    @Published var companyPhone: String = ""
    @Published var companyEmail: String = ""
    @Published var defaultProfitMargin: Double = 15.0
    @Published var defaultOverheadPercentage: Double = 10.0
    @Published var taxPercentage: Double = 5.0
    
    private let settingsKey = "CostEstimator_Settings"
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        let settings: [String: Any] = [
            "selectedCurrency": selectedCurrency.rawValue,
            "companyName": companyName,
            "companyAddress": companyAddress,
            "companyPhone": companyPhone,
            "companyEmail": companyEmail,
            "defaultProfitMargin": defaultProfitMargin,
            "defaultOverheadPercentage": defaultOverheadPercentage,
            "taxPercentage": taxPercentage
        ]
        
        UserDefaults.standard.set(settings, forKey: settingsKey)
    }
    
    private func loadSettings() {
        guard let settings = UserDefaults.standard.dictionary(forKey: settingsKey) else { return }
        
        if let currencyRaw = settings["selectedCurrency"] as? String,
           let currency = Currency(rawValue: currencyRaw) {
            selectedCurrency = currency
        }
        
        companyName = settings["companyName"] as? String ?? "Zesto Tech"
        companyAddress = settings["companyAddress"] as? String ?? ""
        companyPhone = settings["companyPhone"] as? String ?? ""
        companyEmail = settings["companyEmail"] as? String ?? ""
        defaultProfitMargin = settings["defaultProfitMargin"] as? Double ?? 15.0
        defaultOverheadPercentage = settings["defaultOverheadPercentage"] as? Double ?? 10.0
        taxPercentage = settings["taxPercentage"] as? Double ?? 5.0
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.rawValue
        formatter.currencySymbol = selectedCurrency.symbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(selectedCurrency.symbol) \(String(format: "%.2f", amount))"
    }
}