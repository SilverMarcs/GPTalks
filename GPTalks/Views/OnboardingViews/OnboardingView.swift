//
//  OnboardingView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/11/2024.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @ObservedObject var config = AppConfig.shared
    
    @Namespace private var skipButtonSpace
    
    @State private var currentPage = OnboardingPage.welcome
    @State private var navigationDirection = NavigationDirection.forward
    
    @Query var providerDefaults: [ProviderDefaults]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                pageContent
                
                Spacer()
                
                navigationControls
            }
            
            if currentPage != .welcome && currentPage != .ready {
                Button("Skip") {
                    config.hasCompletedOnboarding = true
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .matchedGeometryEffect(id: "skipButton", in: skipButtonSpace)
            }
        }
        .padding()
        #if os(macOS)
        .frame(width: 500, height: 500)
        #else
        .interactiveDismissDisabled(!config.hasCompletedOnboarding)
        #endif
    }
    
    @ViewBuilder
    private var pageContent: some View {
        Group {
            switch currentPage {
            case .welcome:
                WelcomeOnboarding()
            case .apiKey:
                APIKeyOnboarding(providerDefault: providerDefaults.first!)
            case .plugins:
                PluginsOnboarding()
            #if os(macOS)
            case .quickPanel:
                QuickPanelOnboarding(provider: providerDefaults.first!.quickProvider)
            #else
            case .permissions:
                PermissionsOnboarding()
            #endif
            case .imageGen:
                ImageGenOnboarding(provider: providerDefaults.first!.imageProvider)
            case .ready:
                ReadyPageView()
            }
        }
        .transition(.asymmetric(
            insertion: navigationDirection == .forward ?
                .move(edge: .trailing) : .move(edge: .leading),
            removal: navigationDirection == .forward ?
                .move(edge: .leading) : .move(edge: .trailing)
        ))
    }
    
    private var navigationControls: some View {
        ZStack {
            HStack(spacing: 20) {
                if currentPage != .welcome {
                    Button("Previous") {
                        #if os(iOS)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        #endif
                        
                        navigationDirection = .backward
                        withAnimation {
                            currentPage = OnboardingPage(rawValue: currentPage.rawValue - 1) ?? .welcome
                        }
                    }
                }
                
                if currentPage == .welcome {
                    Button("Skip") {
                        config.hasCompletedOnboarding = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .matchedGeometryEffect(id: "skipButton", in: skipButtonSpace)
                }
                
                Spacer()
                
                Button(currentPage != .ready ? "Next" : "Get Started") {
                    if currentPage != .ready {
                        #if os(iOS)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        #endif
                        
                        navigationDirection = .forward
                        withAnimation {
                            currentPage = OnboardingPage(rawValue: currentPage.rawValue + 1) ?? .ready
                        }
                    } else {
                        config.hasCompletedOnboarding = true
                    }
                }
                .keyboardShortcut(currentPage == .ready ? .defaultAction : nil)
            }
            
            PageDots(current: currentPage.rawValue, total: OnboardingPage.allCases.count)
        }
    }
}
