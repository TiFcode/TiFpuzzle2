//
//  ContentView.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//
//  ARCHITECTURE OVERVIEW:
//  =====================
//  This app uses a zone-based layout with three main areas:
//  1. Menu Bar - Top control strip with buttons and title
//  2. Upper Zone - Puzzle Grid Area where pieces snap into correct positions
//  3. Lower Zone - Working Area with scattered, draggable puzzle pieces
//
//  COORDINATE SYSTEMS:
//  - Global Coordinates: Absolute screen positions tracked via GeometryReader.frame(in: .global)
//  - Grid Coordinates: Relative positions within the upper grid zone
//  - Lower Area Coordinates: Relative positions within the lower working zone
//
//  BOUNDARY ENFORCEMENT:
//  - Top: Pieces cannot go above menu bar (menuAreaMaxY tracking)
//  - Bottom: Pieces cannot go below 1cm (37.8 points) from bottom edge
//  - Sides: Pieces stay within container width
//

import SwiftUI
import PhotosUI

// MARK: - Main View

struct ContentView: View {

    @StateObject private var viewModel = PuzzleViewModel()

    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height
            let availableWidth = geometry.size.width
            let squareSize = min(availableWidth, availableHeight * AppConstants.gridHeightMultiplier) - AppConstants.gridSizePadding
            let cellSize = squareSize / CGFloat(viewModel.gridSize)

            VStack(spacing: AppConstants.zoneSpacing) {

                // ====================================================================
                // Upper Zone - Puzzle Grid Area
                // ====================================================================

                VStack(spacing: 0) {

                    MenuBarView(
                        showCamera: $viewModel.showCamera,
                        selectedImage: $viewModel.selectedImage,
                        showAutoSolveButton: $viewModel.showAutoSolveButton,
                        isAutoSolving: $viewModel.isAutoSolving,
                        animationSpeed: $viewModel.animationSpeed,
                        gridFrame: viewModel.gridFrame,
                        lowerAreaFrame: viewModel.lowerAreaFrame,
                        cellSize: cellSize,
                        onToggleGridSize: {
                            viewModel.toggleGridSize(
                                containerWidth: availableWidth,
                                containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier
                            )
                        },
                        onAutoSolve: {
                            viewModel.autoSolvePuzzle(cellSize: cellSize)
                        },
                        onStopAutoSolve: {
                            viewModel.stopAutoSolve()
                        }
                    )
                    .background(
                        // Menu area geometry tracking - tracks bottom Y coordinate for boundary enforcement
                        GeometryReader { menuGeo in
                            Color.clear
                                .onAppear {
                                    viewModel.menuAreaMaxY = menuGeo.frame(in: .global).maxY
                                }
                                .onChange(of: menuGeo.frame(in: .global)) { _, newFrame in
                                    viewModel.menuAreaMaxY = newFrame.maxY
                                }
                        }
                    )

                    PuzzleGridView(
                        pieces: viewModel.pieces,
                        gridSize: viewModel.gridSize,
                        squareSize: squareSize,
                        cellSize: cellSize,
                        puzzleImage: viewModel.puzzleImage,
                        onGridFrameChange: { frame in
                            viewModel.gridFrame = frame
                        },
                        onSecretTap: { row, col in
                            viewModel.handleSecretTap(row: row, col: col)
                        }
                    )
                }
                .padding()

                // ====================================================================
                // Lower Zone - Working Area
                // ====================================================================
                // Scattered puzzle pieces area where unplaced pieces are randomly distributed.

                WorkingAreaView(
                    pieces: $viewModel.pieces,
                    gridSize: viewModel.gridSize,
                    cellSize: cellSize,
                    puzzleImage: viewModel.puzzleImage,
                    isAutoSolving: viewModel.isAutoSolving,
                    animationSpeed: viewModel.animationSpeed,
                    menuAreaMaxY: viewModel.menuAreaMaxY,
                    gridFrame: viewModel.gridFrame,
                    lowerAreaFrame: viewModel.lowerAreaFrame,
                    onLowerAreaFrameChange: { frame in
                        viewModel.lowerAreaFrame = frame
                    },
                    onDrop: { piece, location in
                        viewModel.handleDrop(piece: piece, location: location, cellSize: cellSize)
                    }
                )
            }
            .onAppear {
                viewModel.initializePuzzle(
                    containerWidth: availableWidth,
                    containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier
                )
                viewModel.previousSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newSize in
                // Detect orientation changes and shuffle unplaced pieces
                if viewModel.previousSize != .zero {
                    let wasPortrait = viewModel.previousSize.height > viewModel.previousSize.width
                    let isPortrait = newSize.height > newSize.width

                    if wasPortrait != isPortrait {
                        viewModel.shuffleUnplacedPieces(
                            containerWidth: newSize.width,
                            containerHeight: newSize.height * AppConstants.lowerAreaHeightMultiplier
                        )
                    }
                }
                viewModel.previousSize = newSize
            }
            .onChange(of: viewModel.selectedImage) { _, newItem in
                // Load selected image from photo picker asynchronously
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.puzzleImage = image
                        viewModel.resetPuzzle(
                            containerWidth: availableWidth,
                            containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier
                        )
                    }
                }
            }
            .alert("Puzzle Completed!", isPresented: $viewModel.puzzleCompleted) {
                Button("Play Again") {
                    viewModel.resetPuzzle(
                        containerWidth: availableWidth,
                        containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier
                    )
                }
            } message: {
                Text("Great job! You solved the puzzle!")
            }
            .sheet(isPresented: $viewModel.showCamera) {
                ImagePicker(image: $viewModel.puzzleImage, sourceType: .camera) { image in
                    if image != nil {
                        viewModel.resetPuzzle(
                            containerWidth: availableWidth,
                            containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
