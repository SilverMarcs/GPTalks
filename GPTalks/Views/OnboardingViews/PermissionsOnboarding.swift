//
//  PermissionsOnboarding.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/12/2024.
//

import SwiftUI
import AVFoundation
import Photos

struct PermissionsOnboarding: View {
    @State private var isCameraAllowed = false
    @State private var isPhotoLibraryAllowed = false

    var body: some View {
        GenericOnboardingView(
            icon: "lock.shield",
            iconColor: .orange,
            title: "App Permissions",
            content: {
                Form {
                    Section {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.accent)
                            
                            VStack(alignment: .leading) {
                                Text("Camera")
                                    .font(.headline)
                                
                                Text("Add images for LLM vision chat.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(isCameraAllowed ? "Allowed" : "Allow") {
                                requestCameraPermission()
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .disabled(isCameraAllowed)
                        }
//                        .padding()
                        
                        HStack {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                                .foregroundStyle(.accent)
                            
                            VStack(alignment: .leading) {
                                Text("Photos Library")
                                    .font(.headline)
                                
                                Text("Upload pictures from gallery.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(isPhotoLibraryAllowed ? "Allowed" : "Allow") {
                                requestPhotoLibraryPermission()
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .disabled(isPhotoLibraryAllowed)
                        }
//                        .padding()
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                }
                .padding(.horizontal, -10)
            }
            ,
            footerText: "Enable permissions to use all features"
        )
        .onAppear {
            checkInitialPermissions()
        }
    }
    
    private func checkInitialPermissions() {
        isCameraAllowed = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        let photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
        isPhotoLibraryAllowed = photoLibraryStatus == .authorized || photoLibraryStatus == .limited
    }

    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera permission already granted")
            isCameraAllowed = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    isCameraAllowed = granted
                }
            }
        case .denied, .restricted:
            print("Camera permission denied or restricted")
        @unknown default:
            break
        }
    }
    
    private func requestPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            print("Photo library permission already granted")
            isPhotoLibraryAllowed = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    isPhotoLibraryAllowed = status == .authorized || status == .limited
                }
            }
        case .denied, .restricted:
            print("Photo library permission denied or restricted")
        @unknown default:
            break
        }
    }
}

#Preview {
    PermissionsOnboarding()
}
