import Foundation
import SwiftUI
import CryptoKit

enum UserRole: String, CaseIterable, Codable {
    case admin = "Admin"
    case manager = "Manager"
    case estimator = "Estimator"
    case viewer = "Viewer"
    
    var permissions: [Permission] {
        switch self {
        case .admin:
            return Permission.allCases
        case .manager:
            return [.viewCustomers, .editCustomers, .viewProjects, .editProjects, .viewQuotations, .editQuotations, .viewReports, .viewMaterials, .editMaterials, .bulkUpload]
        case .estimator:
            return [.viewCustomers, .viewProjects, .editProjects, .viewQuotations, .editQuotations, .viewReports, .viewMaterials]
        case .viewer:
            return [.viewCustomers, .viewProjects, .viewQuotations, .viewReports, .viewMaterials]
        }
    }
}

enum Permission: String, CaseIterable, Codable {
    case viewCustomers = "View Customers"
    case editCustomers = "Edit Customers"
    case viewProjects = "View Projects"
    case editProjects = "Edit Projects"
    case viewQuotations = "View Quotations"
    case editQuotations = "Edit Quotations"
    case viewReports = "View Reports"
    case viewMaterials = "View Materials"
    case editMaterials = "Edit Materials"
    case bulkUpload = "Bulk Upload"
    case userManagement = "User Management"
}

struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String
    var role: UserRole
    var isActive: Bool
    var createdDate: Date
    var lastLoginDate: Date?
    
    init(username: String, email: String, role: UserRole) {
        self.id = UUID()
        self.username = username
        self.email = email
        self.role = role
        self.isActive = true
        self.createdDate = Date()
    }
}

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var users: [User] = []
    
    private let usersKey = "CostEstimator_Users"
    private let currentUserKey = "CostEstimator_CurrentUser"
    private let passwordsKey = "CostEstimator_Passwords"
    
    init() {
        loadUsers()
        loadCurrentUser()
        
        // Create default admin user if no users exist
        if users.isEmpty {
            createDefaultAdmin()
        }
    }
    
    func login(username: String, password: String) -> Bool {
        guard let user = users.first(where: { $0.username == username && $0.isActive }),
              verifyPassword(password, for: username) else {
            return false
        }
        
        var updatedUser = user
        updatedUser.lastLoginDate = Date()
        updateUser(updatedUser)
        
        currentUser = updatedUser
        isAuthenticated = true
        saveCurrentUser()
        return true
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    func hasPermission(_ permission: Permission) -> Bool {
        guard let user = currentUser else { return false }
        return user.role.permissions.contains(permission)
    }
    
    func createUser(username: String, email: String, password: String, role: UserRole) -> Bool {
        guard !users.contains(where: { $0.username == username || $0.email == email }) else {
            return false
        }
        
        let user = User(username: username, email: email, role: role)
        users.append(user)
        savePassword(password, for: username)
        saveUsers()
        return true
    }
    
    func updateUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveUsers()
            
            if currentUser?.id == user.id {
                currentUser = user
                saveCurrentUser()
            }
        }
    }
    
    func deleteUser(_ user: User) {
        users.removeAll { $0.id == user.id }
        removePassword(for: user.username)
        saveUsers()
    }
    
    func changePassword(for username: String, newPassword: String) -> Bool {
        guard users.contains(where: { $0.username == username }) else { return false }
        savePassword(newPassword, for: username)
        return true
    }
    
    private func createDefaultAdmin() {
        let admin = User(username: "admin", email: "admin@zestotech.com", role: .admin)
        users.append(admin)
        savePassword("admin123", for: "admin")
        saveUsers()
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func savePassword(_ password: String, for username: String) {
        var passwords = UserDefaults.standard.dictionary(forKey: passwordsKey) as? [String: String] ?? [:]
        passwords[username] = hashPassword(password)
        UserDefaults.standard.set(passwords, forKey: passwordsKey)
    }
    
    private func verifyPassword(_ password: String, for username: String) -> Bool {
        guard let passwords = UserDefaults.standard.dictionary(forKey: passwordsKey) as? [String: String],
              let storedHash = passwords[username] else {
            return false
        }
        return storedHash == hashPassword(password)
    }
    
    private func removePassword(for username: String) {
        var passwords = UserDefaults.standard.dictionary(forKey: passwordsKey) as? [String: String] ?? [:]
        passwords.removeValue(forKey: username)
        UserDefaults.standard.set(passwords, forKey: passwordsKey)
    }
    
    private func saveUsers() {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    
    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let users = try? JSONDecoder().decode([User].self, from: data) {
            self.users = users
        }
    }
    
    private func saveCurrentUser() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: currentUserKey)
        }
    }
    
    private func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isAuthenticated = true
        }
    }
}