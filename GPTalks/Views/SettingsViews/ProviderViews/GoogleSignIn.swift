//
//  GoogleSignIn.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/09/2024.
//

import SwiftUI

struct GoogleSignIn: View {
    private var tokenManager = GoogleAuth.shared
    
    @State private var isSigningIn = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if tokenManager.isSignedIn {
                HStack {
                    Text("Signed In")
                    Spacer()
                    Button("Sign Out", role: .destructive) {
                        tokenManager.clearTokens()
                    }
                }
            } else {
                Button("Sign In With Google") {
                    signInWithGoogle()
                }
                .disabled(isSigningIn)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
    
    private func signInWithGoogle() {
        isSigningIn = true
        errorMessage = nil
        
        Task {
            do {
                try await tokenManager.signIn()
                isSigningIn = false
            } catch {
                isSigningIn = false
                errorMessage = "Sign-in failed: \(error.localizedDescription)"
            }
        }
    }
}

