import SwiftUI

struct UsersView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingAddUser = false
    @State private var selectedUser: User?
    @State private var searchText = ""
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return authManager.users
        } else {
            return authManager.users.filter { user in
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText) ||
                user.role.rawValue.localizedCaseInsensitiveContains(searchText)
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
                    TextField("Search users...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Users List
                List(filteredUsers, id: \.id, selection: $selectedUser) { user in
                    UserRowView(user: user)
                        .tag(user)
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Users (\(authManager.users.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "plus")
                    }
                    .help("Add User")
                }
            }
        } detail: {
            if let user = selectedUser {
                UserDetailView(user: user)
            } else {
                ContentUnavailableView(
                    "Select a User",
                    systemImage: "person.3",
                    description: Text("Choose a user from the list to view details")
                )
            }
        }
        .sheet(isPresented: $showingAddUser) {
            AddEditUserView()
        }
    }
}

struct UserRowView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(user.username)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                if !user.isActive {
                    Text("Inactive")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            
            Text(user.email)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack {
                Text(user.role.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(roleColor(user.role))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Spacer()
                
                if let lastLogin = user.lastLoginDate {
                    Text("Last: \(lastLogin, style: .date)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("Never logged in")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func roleColor(_ role: UserRole) -> Color {
        switch role {
        case .admin: return .red
        case .manager: return .blue
        case .estimator: return .green
        case .viewer: return .gray
        }
    }
}

struct UserDetailView: View {
    let user: User
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingEditUser = false
    @State private var showingDeleteAlert = false
    @State private var showingChangePassword = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.username)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(user.email)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button("Edit User") {
                                showingEditUser = true
                            }
                            
                            Button("Change Password") {
                                showingChangePassword = true
                            }
                            
                            Divider()
                            
                            if user.id != authManager.currentUser?.id {
                                Button("Delete User", role: .destructive) {
                                    showingDeleteAlert = true
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                        }
                    }
                    
                    HStack {
                        Text(user.role.rawValue)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(roleColor(user.role))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        if !user.isActive {
                            Text("Inactive")
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                
                // User Information
                GroupBox("User Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Username", value: user.username, icon: "person")
                        InfoRow(label: "Email", value: user.email, icon: "envelope")
                        InfoRow(label: "Role", value: user.role.rawValue, icon: "person.badge.key")
                        InfoRow(label: "Status", value: user.isActive ? "Active" : "Inactive", icon: "circle.fill")
                    }
                }
                
                // Permissions
                GroupBox("Permissions") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(user.role.permissions, id: \.self) { permission in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(permission.rawValue)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                }
                
                // Activity Information
                GroupBox("Activity") {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(
                            label: "Created",
                            value: user.createdDate.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar"
                        )
                        
                        if let lastLogin = user.lastLoginDate {
                            InfoRow(
                                label: "Last Login",
                                value: lastLogin.formatted(date: .abbreviated, time: .shortened),
                                icon: "clock"
                            )
                        } else {
                            InfoRow(
                                label: "Last Login",
                                value: "Never",
                                icon: "clock"
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("User Details")
        .sheet(isPresented: $showingEditUser) {
            AddEditUserView(user: user)
        }
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordView(user: user)
        }
        .alert("Delete User", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                authManager.deleteUser(user)
            }
        } message: {
            Text("Are you sure you want to delete this user? This action cannot be undone.")
        }
    }
    
    private func roleColor(_ role: UserRole) -> Color {
        switch role {
        case .admin: return .red
        case .manager: return .blue
        case .estimator: return .green
        case .viewer: return .gray
        }
    }
}

struct AddEditUserView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    let user: User?
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .viewer
    @State private var isActive = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(user: User? = nil) {
        self.user = user
        if let user = user {
            _username = State(initialValue: user.username)
            _email = State(initialValue: user.email)
            _selectedRole = State(initialValue: user.role)
            _isActive = State(initialValue: user.isActive)
        }
    }
    
    var isEditing: Bool {
        user != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("User Information") {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Picker("Role", selection: $selectedRole) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    
                    Toggle("Active", isOn: $isActive)
                }
                
                if !isEditing {
                    Section("Password") {
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit User" : "New User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveUser()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .frame(width: 400, height: 500)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (isEditing || (!password.isEmpty && password == confirmPassword))
    }
    
    private func saveUser() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isEditing, let existingUser = user {
            var updatedUser = existingUser
            updatedUser.username = trimmedUsername
            updatedUser.email = trimmedEmail
            updatedUser.role = selectedRole
            updatedUser.isActive = isActive
            
            authManager.updateUser(updatedUser)
            dismiss()
        } else {
            if authManager.createUser(username: trimmedUsername, email: trimmedEmail, password: password, role: selectedRole) {
                var newUser = authManager.users.last!
                newUser.isActive = isActive
                authManager.updateUser(newUser)
                dismiss()
            } else {
                alertMessage = "Failed to create user. Username or email may already exist."
                showingAlert = true
            }
        }
    }
}

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    let user: User
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Change Password for \(user.username)") {
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("Change Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        changePassword()
                    }
                    .disabled(newPassword.isEmpty || newPassword != confirmPassword)
                }
            }
        }
        .frame(width: 400, height: 300)
        .alert("Password Change", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func changePassword() {
        if authManager.changePassword(for: user.username, newPassword: newPassword) {
            alertMessage = "Password changed successfully."
        } else {
            alertMessage = "Failed to change password."
        }
        showingAlert = true
    }
}

#Preview {
    UsersView()
        .environmentObject(AuthenticationManager())
}