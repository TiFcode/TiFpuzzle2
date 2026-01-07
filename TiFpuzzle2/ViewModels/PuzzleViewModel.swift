//
//  PuzzleViewModel.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//

import SwiftUI
import PhotosUI

// MARK: - Puzzle View Model

/// PuzzleViewModel - Manages puzzle state and business logic
class PuzzleViewModel: ObservableObject {

    // MARK: - Published State

    @Published var pieces: [PuzzlePiece] = []
    @Published var puzzleCompleted = false
    @Published var gridSize = AppConstants.defaultGridSize
    @Published var puzzleImage: UIImage?
    @Published var isAutoSolving = false
    @Published var animationSpeed: Double = AppConstants.defaultAnimationSpeed
    @Published var gridFrame: CGRect?
    @Published var lowerAreaFrame: CGRect?
    @Published var menuAreaMaxY: CGFloat = 0
    @Published var secretTaps: [Int] = []
    @Published var showAutoSolveButton = false
    @Published var selectedImage: PhotosPickerItem?
    @Published var showCamera = false

    var previousSize: CGSize = .zero

    // MARK: - Computed Properties

    var secretSequence: [Int] {
        gridSize == AppConstants.maxGridSize ? AppConstants.secretSequence4x4 : AppConstants.secretSequence3x3
    }

    // MARK: - Puzzle Management

    /// Initialize Puzzle - Creates all puzzle pieces with random positions within boundaries.
    func initializePuzzle(containerWidth: CGFloat, containerHeight: CGFloat) {
        pieces = []

        let cellSize = min(containerWidth, containerHeight * AppConstants.cellSizeMultiplier) / CGFloat(gridSize)

        // Calculate valid placement ranges (account for piece size)
        let minX = cellSize / 2
        let maxX = containerWidth - cellSize / 2
        let minY = cellSize / 2
        let maxY = containerHeight - AppConstants.bottomMargin - (cellSize / 2)

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let randomX = CGFloat.random(in: minX...maxX)
                let randomY = CGFloat.random(in: minY...maxY)

                let piece = PuzzlePiece(
                    id: row * gridSize + col,
                    row: row,
                    col: col,
                    position: CGPoint(x: randomX, y: randomY),
                    rotation: 0,
                    isPlaced: false
                )
                pieces.append(piece)
            }
        }
    }

    /// Reset Puzzle - Clears completion state and reinitializes all pieces
    func resetPuzzle(containerWidth: CGFloat, containerHeight: CGFloat) {
        puzzleCompleted = false
        showAutoSolveButton = false
        secretTaps = []
        initializePuzzle(containerWidth: containerWidth, containerHeight: containerHeight)
    }

    /// Shuffle Unplaced Pieces - Repositions unplaced pieces to new random positions.
    func shuffleUnplacedPieces(containerWidth: CGFloat, containerHeight: CGFloat) {
        guard let lowerAreaFrame = lowerAreaFrame else { return }

        let cellSize = min(containerWidth, containerHeight * AppConstants.cellSizeMultiplier) / CGFloat(gridSize)

        // Calculate valid Y range (lower area starts at y=0 locally)
        let minY = cellSize / 2
        let maxY = lowerAreaFrame.height - AppConstants.bottomMargin - (cellSize / 2)

        for index in pieces.indices {
            if !pieces[index].isPlaced {
                let randomX = CGFloat.random(in: (cellSize / 2)...(containerWidth - cellSize / 2))
                let randomY = CGFloat.random(in: minY...maxY)
                pieces[index].position = CGPoint(x: randomX, y: randomY)
            }
        }
    }

    /// Toggle Grid Size - Switches between 3x3 and 4x4 grid modes
    func toggleGridSize(containerWidth: CGFloat, containerHeight: CGFloat) {
        gridSize = gridSize == AppConstants.maxGridSize ? AppConstants.minGridSize : AppConstants.maxGridSize
        resetPuzzle(containerWidth: containerWidth, containerHeight: containerHeight)
    }

    // MARK: - Drop Detection & Coordinate Conversion

    /// Handle Drop - Processes piece drop and checks for correct placement.
    func handleDrop(piece: PuzzlePiece, location: CGPoint, cellSize: CGFloat) {
        guard let index = pieces.firstIndex(where: { $0.id == piece.id }),
              let gridFrame = gridFrame,
              let lowerAreaFrame = lowerAreaFrame else { return }

        // Convert location from lower area coordinates to global coordinates
        let globalX = location.x + lowerAreaFrame.minX
        let globalY = location.y + lowerAreaFrame.minY

        // Convert global coordinates to grid coordinates
        let gridX = globalX - gridFrame.minX
        let gridY = globalY - gridFrame.minY

        // Check if dropped within the grid area
        if gridX >= 0 && gridX <= gridFrame.width && gridY >= 0 && gridY <= gridFrame.height {
            let targetCol = Int(gridX / cellSize)
            let targetRow = Int(gridY / cellSize)

            // Check if it's the correct cell
            if targetRow == piece.row && targetCol == piece.col {
                // Calculate center of correct cell and snap distance
                let cellCenterX = CGFloat(targetCol) * cellSize + cellSize / 2
                let cellCenterY = CGFloat(targetRow) * cellSize + cellSize / 2

                let distance = sqrt(pow(gridX - cellCenterX, 2) + pow(gridY - cellCenterY, 2))

                // Snap if within threshold
                if distance <= AppConstants.snapThreshold {
                    withAnimation(.spring(response: AppConstants.snapSpringResponse, dampingFraction: AppConstants.snapSpringDamping)) {
                        pieces[index].isPlaced = true
                        pieces[index].rotation = 0
                    }

                    checkPuzzleCompletion()
                }
            }
        }
    }

    /// Check Puzzle Completion - Triggers completion alert if all pieces are placed
    func checkPuzzleCompletion() {
        if pieces.allSatisfy({ $0.isPlaced }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.completionAlertDelay) {
                self.puzzleCompleted = true
            }
        }
    }

    // MARK: - Secret Features

    /// Stop Auto Solve - Halts the automatic solving animation
    func stopAutoSolve() {
        isAutoSolving = false
    }

    /// Handle Secret Tap - Tracks grid cell taps for secret unlock sequence.
    func handleSecretTap(row: Int, col: Int) {
        let cellIndex = row * gridSize + col
        secretTaps.append(cellIndex)

        if secretTaps.count > AppConstants.secretSequenceLength {
            secretTaps.removeFirst()
        }

        if secretTaps == secretSequence {
            withAnimation {
                showAutoSolveButton.toggle()
            }
        }
    }

    /// Auto Solve Puzzle - Automatically solves the puzzle with smooth animations.
    func autoSolvePuzzle(cellSize: CGFloat) {
        guard let gridFrame = gridFrame, let lowerAreaFrame = lowerAreaFrame else { return }

        isAutoSolving = true
        animationSpeed = AppConstants.defaultAnimationSpeed

        let unplacedPieces = pieces.filter { !$0.isPlaced }

        // Recursive function to solve pieces one by one
        func solvePiece(at index: Int) {
            guard index < unplacedPieces.count else {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.animationSpeed) {
                    self.isAutoSolving = false
                    self.checkPuzzleCompletion()
                }
                return
            }

            guard self.isAutoSolving else { return }

            let piece = unplacedPieces[index]

            if let idx = self.pieces.firstIndex(where: { $0.id == piece.id }) {
                // Calculate target position: grid → global → lower area coordinates
                let cellX = CGFloat(piece.col) * cellSize + cellSize / 2
                let cellY = CGFloat(piece.row) * cellSize + cellSize / 2
                let targetGlobalX = gridFrame.minX + cellX
                let targetGlobalY = gridFrame.minY + cellY
                let targetLocalX = targetGlobalX - lowerAreaFrame.minX
                let targetLocalY = targetGlobalY - lowerAreaFrame.minY

                self.pieces[idx].position = CGPoint(x: targetLocalX, y: targetLocalY)
                self.pieces[idx].rotation = 0

                DispatchQueue.main.asyncAfter(deadline: .now() + self.animationSpeed) {
                    guard self.isAutoSolving else { return }
                    self.pieces[idx].isPlaced = true

                    solvePiece(at: index + 1)
                }
            }
        }

        solvePiece(at: 0)
    }
}
