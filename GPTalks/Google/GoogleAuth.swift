//
//  GoogleAuth.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/09/2024.
//


import SwiftUI
import GoogleSignIn

@Observable class GoogleAuth {
    var name: String = ""
    var email: String = ""
    var profilePicUrl: String = ""
    var isLoggedIn: Bool = false
    var errorMessage: String = ""
    
    init(){
        check()
    }
    
    func checkStatus(){
        if(GIDSignIn.sharedInstance.currentUser != nil){
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            name = user.profile?.name ?? "No Name"
            email = user.profile?.email ?? "No Email"
            let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
            self.profilePicUrl = profilePicUrl
            self.isLoggedIn = true
        }else{
            self.isLoggedIn = false
            self.name = "Not Logged In"
            self.profilePicUrl =  ""
        }
    }
    
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
    
    func signIn(){
        #if os(macOS)
        guard let presentingWindow = NSApplication.shared.windows.first else {
          print("There is no presenting window!")
          return
        }
        
        GIDSignIn.sharedInstance.signIn(
          withPresenting: presentingWindow,
          hint: "Accessing VertexAI",
          additionalScopes: ["https://www.googleapis.com/auth/cloud-platform"]
        ) { signInResult, error in
          guard let signInResult = signInResult else {
            print("Error! \(String(describing: error))")
            return
          }
          
        }

        #else
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
          print("There is no root view controller!")
          return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
          guard let signInResult = signInResult else {
            print("Error! \(String(describing: error))")
            return
          }
          self.authViewModel.state = .signedIn(signInResult.user)
        }
        #endif
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
}
