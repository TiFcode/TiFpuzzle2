//
//  MenuBarView.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//

import SwiftUI
import PhotosUI

// MARK: - Menu Bar View

/// MenuBarView - Top control strip with buttons and title
struct MenuBarView: View {
    @Binding var showCamera: Bool
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var showAutoSolveButton: Bool
    @Binding var isAutoSolving: Bool
    @Binding var animationSpeed: Double

    let gridFrame: CGRect?
    let lowerAreaFrame: CGRect?
    let cellSize: CGFloat
    let onToggleGridSize: () -> Void
    let onAutoSolve: () -> Void
    let onStopAutoSolve: () -> Void

    var body: some View {
        HStack {
            // Camera button (left) - launches device camera
            Button(action: {
                showCamera = true
            }) {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(AppConstants.buttonPadding)
                    .background(Color.blue.opacity(AppConstants.buttonBackgroundOpacity))
                    .cornerRadius(AppConstants.buttonCornerRadius)
            }

            // Load button - opens photo picker
            PhotosPicker(selection: $selectedImage, matching: .images) {
                HStack(spacing: AppConstants.loadButtonIconSpacing) {
                    Image(systemName: "photo")
                        .font(.title2)
                    Text("Load")
                        .font(.body)
                }
                .padding(AppConstants.buttonPadding)
                .background(Color.blue.opacity(AppConstants.buttonBackgroundOpacity))
                .foregroundColor(.blue)
                .cornerRadius(AppConstants.buttonCornerRadius)
            }

            // Title display - "TiFpuzzle" (tap to toggle grid size or speed up auto-solve)
            Text("TiFpuzzle")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.regular)
                .onTapGesture {
                    if isAutoSolving {
                        animationSpeed = AppConstants.fastAnimationSpeed
                    } else {
                        onToggleGridSize()
                    }
                }

            Spacer()

            // Auto Solve button (conditional) - appears after secret sequence
            if showAutoSolveButton {
                Button(action: {
                    if isAutoSolving {
                        onStopAutoSolve()
                    } else {
                        onAutoSolve()
                    }
                }) {
                    Text(isAutoSolving ? "Stop Auto Solve" : "Auto Solve")
                        .font(.body)
                        .padding(.horizontal, AppConstants.autoSolveButtonHorizontalPadding)
                        .padding(.vertical, AppConstants.autoSolveButtonVerticalPadding)
                        .background(isAutoSolving ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(AppConstants.buttonCornerRadius)
                }
            }

            // Question mark button - opens README documentation
            Button(action: {
                if let url = URL(string: AppConstants.readmeURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(AppConstants.buttonPadding)
                    .background(Color.blue.opacity(AppConstants.buttonBackgroundOpacity))
                    .cornerRadius(AppConstants.buttonCornerRadius)
            }

            // Info button (right) - opens privacy policy
            Button(action: {
                if let url = URL(string: AppConstants.privacyPolicyURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(AppConstants.buttonPadding)
                    .background(Color.blue.opacity(AppConstants.buttonBackgroundOpacity))
                    .cornerRadius(AppConstants.buttonCornerRadius)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, AppConstants.menuBarBottomPadding)
    }
}
