//
//  LoginView.swift
//  noname_banana
//
//  Created by AI Assistant on 13.10.2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpMode = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Text(isSignUpMode ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button(action: handleAuth) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isSignUpMode ? "Sign Up" : "Sign In")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
            
            Button(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                isSignUpMode.toggle()
                clearForm()
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
        .alert("Authentication Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: authService.errorMessage) { errorMessage in
            if let errorMessage = errorMessage {
                alertMessage = errorMessage
                showingAlert = true
                authService.clearError()
            }
        }
    }
    
    private func handleAuth() {
        Task {
            do {
                if isSignUpMode {
                    try await authService.signUp(email: email, password: password)
                } else {
                    try await authService.signIn(email: email, password: password)
                }
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        authService.clearError()
    }
}

#Preview {
    LoginView()
}
