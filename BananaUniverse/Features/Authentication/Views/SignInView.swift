//
//  SignInView.swift
//  noname_banana
//
//  Created by AI Assistant on 14.10.2025.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = HybridAuthService.shared
    @StateObject private var creditManager = HybridCreditManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                    
                    Text("Sync your progress across devices")
                        .font(.system(size: 16))
                        .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                }
                .padding(.top, 40)
                
                // Value Proposition
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .foregroundColor(DesignTokens.Brand.primary(.light))
                        Text("Never lose your work")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                    }
                    
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(DesignTokens.Brand.primary(.light))
                        Text("Secure backup of your creations")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Sign In Form
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                    }
                    
                    TextField(isSignUp ? "Create Password" : "Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(DesignTokens.Semantic.error)
                            .padding(.horizontal, 20)
                    }
                    
                    // Sign In/Up Button
                    Button(action: {
                        Task {
                            await handleEmailAuth()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DesignTokens.Brand.primary(.light))
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .padding(.horizontal, 20)
                    
                    // Toggle Sign Up/Sign In
                    Button(action: {
                        isSignUp.toggle()
                        errorMessage = ""
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                            .underline()
                    }
                }
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(DesignTokens.Text.tertiary(themeManager.resolvedColorScheme))
                        .frame(height: 1)
                    Text("OR")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignTokens.Text.secondary(themeManager.resolvedColorScheme))
                        .padding(.horizontal, 16)
                    Rectangle()
                        .fill(DesignTokens.Text.tertiary(themeManager.resolvedColorScheme))
                        .frame(height: 1)
                }
                .padding(.horizontal, 20)
                
                // Apple Sign In
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        Task {
                            await handleAppleSignIn(result)
                        }
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignTokens.Text.tertiary(themeManager.resolvedColorScheme), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(DesignTokens.Background.primary(themeManager.resolvedColorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
                }
            }
        }
    }
    
    private func handleEmailAuth() async {
        isLoading = true
        errorMessage = ""
        
        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
            
            // Migration will happen automatically in HybridAuthService
            dismiss()
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Sign in failed"
        }
        
        isLoading = false
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = ""
        
        do {
            switch result {
            case .success(let authorization):
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                      let identityToken = appleIDCredential.identityToken,
                      let identityTokenString = String(data: identityToken, encoding: .utf8) else {
                    throw HybridAuthError.invalidAppleCredential
                }
                
                // Use the HybridAuthService's Apple Sign-In method directly
                try await authService.signInWithApple()
                
                dismiss()
            case .failure(let error):
                let appError = AppError.from(error)
                errorMessage = appError.errorDescription ?? "Sign in failed"
            }
        } catch {
            let appError = AppError.from(error)
            errorMessage = appError.errorDescription ?? "Sign in failed"
        }
        
        isLoading = false
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    @EnvironmentObject var themeManager: ThemeManager
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .foregroundColor(DesignTokens.Text.primary(themeManager.resolvedColorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DesignTokens.Text.tertiary(themeManager.resolvedColorScheme), lineWidth: 1)
            )
    }
}

#Preview {
    SignInView()
}
