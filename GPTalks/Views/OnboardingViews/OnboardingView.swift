//
//  OnboardingView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/11/2024.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @State private var currentPage = OnboardingPage.welcome
    @Query var providerDefaults: [ProviderDefaults]
    @ObservedObject var config = AppConfig.shared
    @Namespace private var skipButtonSpace // Add namespace for matched geometry effect
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                pageContent
                
                Spacer()
                
                navigationControls
            }
            
            // Show skip button at top-left only for middle pages
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
        .frame(width: 500, height: 500)
    }
    
    @ViewBuilder
    private var pageContent: some View {
        switch currentPage {
        case .welcome:
            WelcomeOnboarding()
        case .apiKey:
            APIKeyOnboarding(providerDefault: providerDefaults.first!)
        case .plugins:
            PluginsOnboarding()
        case .quickPanel:
            QuickPanelOnboarding(provider: providerDefaults.first!.quickProvider)
        case .imageGen:
            ImageGenOnboarding(provider: providerDefaults.first!.imageProvider)
        case .ready:
            ReadyPageView()
        }
    }
    
    private var navigationControls: some View {
        ZStack {
            HStack(spacing: 20) {
                if currentPage != .welcome {
                    Button("Previous") {
                        withAnimation {
                            currentPage = OnboardingPage(rawValue: currentPage.rawValue - 1) ?? .welcome
                        }
                    }
                }
                
                // Show skip button in navigation controls only for welcome page
                if currentPage == .welcome {
                    Button("Skip") {
                        config.hasCompletedOnboarding = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .matchedGeometryEffect(id: "skipButton", in: skipButtonSpace)
                }
                
                Spacer()
                
                if currentPage != .ready {
                    Button("Next") {
                        withAnimation {
                            currentPage = OnboardingPage(rawValue: currentPage.rawValue + 1) ?? .ready
                        }
                    }
                } else {
                    Button("Get Started") {
                        config.hasCompletedOnboarding = true
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            
            PageDots(current: currentPage.rawValue, total: OnboardingPage.allCases.count)
        }
    }
}
