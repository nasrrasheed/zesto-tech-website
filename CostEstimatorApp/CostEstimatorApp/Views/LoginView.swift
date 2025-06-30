import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Cost Estimator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Professional Construction Estimation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
            
            // Login Form
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    SecureField("Enter password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                }
                
                Button(action: login) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(username.isEmpty || password.isEmpty || isLoading)
                .opacity(username.isEmpty || password.isEmpty || isLoading ? 0.6 : 1.0)
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: 400)
            
            Spacer()
            
            // Footer
            VStack(spacing: 8) {
                Text("Default Login:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Username: admin | Password: admin123")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Login Failed", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onSubmit {
            if !username.isEmpty && !password.isEmpty {
                login()
            }
        }
    }
    
    private func login() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if authManager.login(username: username, password: password) {
                // Login successful - handled by app state
            } else {
                alertMessage = "Invalid username or password. Please try again."
                showingAlert = true
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}