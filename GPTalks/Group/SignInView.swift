//
//  SignInView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/09/2024.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    private var tokenManager = TokenManager.shared
    @State private var authenticationSession: ASWebAuthenticationSession?
    @State private var isSignedIn = false
    
    var body: some View {
        VStack {
            if isSignedIn {
                HStack {
                    Text("Signed In")
                    Spacer()
                    Button("Sign Out") {
                        tokenManager.clearTokens()
                        isSignedIn = false
                    }
                    .foregroundStyle(.red)
                }
            } else {
                Button("Sign In With Google") {
                    signInWithGoogle()
                }
            }
        }
        .onAppear {
            isSignedIn = !tokenManager.accessToken.isEmpty
        }
    }
    
    // TODO: move this to a view model
    private func signInWithGoogle() {
        let authUrl = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=\(tokenManager.clientId)&redirect_uri=\(tokenManager.redirectUri)&response_type=code&scope=profile email https://www.googleapis.com/auth/cloud-platform openid")!
        let callbackUrlScheme = "com.zabir.GPTalksNew"
        
        authenticationSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: callbackUrlScheme) { callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else { return }
            
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            guard let code = queryItems?.first(where: { $0.name == "code" })?.value else { return }
            
            Task {
                do {
                    try await tokenManager.exchangeCodeForTokens(authCode: code)
                    isSignedIn = true
                } catch {
                    print("Error exchanging code for tokens: \(error)")
                }
            }
        }
        
        #if os(iOS)
        authenticationSession?.presentationContextProvider = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
        #elseif os(macOS)
        authenticationSession?.presentationContextProvider = NSApplication.shared.keyWindow
        #endif
        
        authenticationSession?.start()
    }
}
#if os(iOS)
extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
#elseif os(macOS)
extension NSWindow: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self
    }
}
#endif

