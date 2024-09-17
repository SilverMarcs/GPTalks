//
//  TokenManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/09/2024.
//

import SwiftUI
import AuthenticationServices

class TokenManager {
    static let shared = TokenManager()
    
    private(set) var accessToken: String = ""
    private var refreshToken: String = ""
    let clientId = "401645137849-5tlu6a5kai0oav5m498ntbhevm2lvgu1.apps.googleusercontent.com"
    let redirectUri = "com.zabir.GPTalksNew:/oauth2redirect"
    
    private init() {
        loadTokens()
    }
    
    private func loadTokens() {
        accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
    }
    
    private func saveTokens() {
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
    }
    
    func clearTokens() {
        accessToken = ""
        refreshToken = ""
        saveTokens()
    }
    
    private func refreshAccessToken() async throws -> String {
        guard !refreshToken.isEmpty else {
            throw NSError(domain: "TokenManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No refresh token available"])
        }
        
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "client_id": clientId,
            "client_secret": "",
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let jsonResult = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let newAccessToken = jsonResult["access_token"] as? String else {
            throw NSError(domain: "TokenManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        DispatchQueue.main.async {
            self.accessToken = newAccessToken
            self.saveTokens()
        }
        
        return newAccessToken
    }
    
    func exchangeCodeForTokens(authCode: String) async throws {
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "client_id": clientId,
            "client_secret": "",
            "code": authCode,
            "grant_type": "authorization_code",
            "redirect_uri": redirectUri,
            "scope": "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/cloud-platform openid"
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let jsonResult = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let accessToken = jsonResult["access_token"] as? String,
              let refreshToken = jsonResult["refresh_token"] as? String else {
            throw NSError(domain: "TokenManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        DispatchQueue.main.async {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.saveTokens()
        }
    }
    
    func getValidAccessToken() async throws -> String {
        if accessToken.isEmpty {
            throw NSError(domain: "TokenManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "No access token available"])
        }
        
        // Refresh the token every time to ensure it's always valid
        return try await refreshAccessToken()
    }
}
