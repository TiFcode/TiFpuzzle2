//
//  ContentView.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//

import SwiftUI
import PhotosUI

struct PuzzlePiece: Identifiable {
    let id: Int
    let row: Int
    let col: Int
    var position: CGPoint
    var rotation: Double
    var isPlaced: Bool = false
    var zIndex: Double = 0
}

struct ContentView: View {
    @State private var pieces: [PuzzlePiece] = []
    @State private var puzzleCompleted = false
    @State private var draggedPiece: PuzzlePiece?
    @State private var isAutoSolving = false
    @State private var gridFrame: CGRect?
    @State private var lowerAreaFrame: CGRect?
    @State private var secretTaps: [Int] = []
    @State private var showAutoSolveButton = false
    @State private var animationSpeed: Double = 1.2
    @State private var selectedImage: PhotosPickerItem?
    @State private var puzzleImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var menuAreaMaxY: CGFloat = 0
    @State private var lastOrientation: UIDeviceOrientation = UIDevice.current.orientation

    let gridSize = 4
    let snapThreshold: CGFloat = 30.0
    let secretSequence = [0, 12, 15, 3] // upper-left, lower-left, lower-right, upper-right

    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height
            let availableWidth = geometry.size.width
            let squareSize = min(availableWidth, availableHeight * 0.45) - 32
            let cellSize = squareSize / CGFloat(gridSize)

            VStack(spacing: 16) {
                // Upper part - Solved puzzle grid
                VStack(spacing: 0) {
                    HStack {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            HStack {
                                Image(systemName: "photo")
                                    .font(.body)
                                Text("Load photo")
                                    .font(.body)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }

                        Text("TiFpuzzle")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.regular)
                            .onTapGesture {
                                if isAutoSolving {
                                    animationSpeed = 0.3
                                }
                            }

                        Spacer()

                        if showAutoSolveButton {
                            Button(action: {
                                if isAutoSolving {
                                    stopAutoSolve()
                                } else {
                                    if let gridFrame = gridFrame, let lowerAreaFrame = lowerAreaFrame {
                                        autoSolvePuzzle(
                                            gridFrame: gridFrame,
                                            lowerAreaFrame: lowerAreaFrame,
                                            cellSize: cellSize
                                        )
                                    }
                                }
                            }) {
                                Text(isAutoSolving ? "Stop Auto Solve" : "Auto Solve")
                                    .font(.body)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(isAutoSolving ? Color.red : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(
                        GeometryReader { menuGeo in
                            Color.clear
                                .onAppear {
                                    menuAreaMaxY = menuGeo.frame(in: .global).maxY
                                }
                                .onChange(of: menuGeo.frame(in: .global)) { newFrame in
                                    menuAreaMaxY = newFrame.maxY
                                }
                        }
                    )

                    ZStack {
                        // Grid overlay with tap detection
                        VStack(spacing: 0) {
                            ForEach(0..<gridSize, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<gridSize, id: \.self) { col in
                                        Rectangle()
                                            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                                            .frame(width: cellSize, height: cellSize)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                handleSecretTap(row: row, col: col)
                                            }
                                    }
                                }
                            }
                        }
                        .frame(width: squareSize, height: squareSize)

                        // Placed pieces
                        ForEach(pieces.filter { $0.isPlaced }) { piece in
                            let x = CGFloat(piece.col) * cellSize + cellSize / 2
                            let y = CGFloat(piece.row) * cellSize + cellSize / 2

                            PuzzlePieceView(
                                piece: piece,
                                cellSize: cellSize,
                                gridSize: gridSize,
                                image: puzzleImage
                            )
                            .position(x: x, y: y)
                            .allowsHitTesting(false)
                        }
                    }
                    .frame(width: squareSize, height: squareSize)
                    .background(
                        GeometryReader { gridGeo in
                            Color.white
                                .onAppear {
                                    gridFrame = gridGeo.frame(in: .global)
                                }
                                .onChange(of: gridGeo.frame(in: .global)) { newFrame in
                                    gridFrame = newFrame
                                }
                        }
                    )
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding()

                // Lower part - Scattered puzzle pieces
                GeometryReader { lowerGeo in
                    ZStack {
                        ForEach(pieces) { piece in
                            if !piece.isPlaced {
                                PuzzlePieceView(
                                    piece: piece,
                                    cellSize: cellSize,
                                    gridSize: gridSize,
                                    image: puzzleImage
                                )
                                .contentShape(Rectangle())
                                .position(piece.position)
                                .rotationEffect(.degrees(piece.rotation))
                                .zIndex(piece.zIndex)
                                .animation(isAutoSolving ? .easeInOut(duration: animationSpeed) : nil, value: piece.position)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
                                                // Bring to front when dragging
                                                let maxZ = pieces.map { $0.zIndex }.max() ?? 0
                                                pieces[index].zIndex = maxZ + 1

                                                // Calculate minimum Y position so the top of the piece doesn't go above menu
                                                // Position is at center of piece, so we need to add half the cellSize
                                                let minLocalY = menuAreaMaxY - lowerAreaFrame!.minY + (cellSize / 2)

                                                // Calculate maximum Y position (1 cm = ~37.8 points from bottom)
                                                // Bottom of piece shouldn't go below lowerArea height - 37.8 points
                                                let bottomMargin: CGFloat = 37.8
                                                let maxLocalY = lowerAreaFrame!.height - bottomMargin - (cellSize / 2)

                                                // Clamp the position to prevent the piece from going above menu or below bottom margin
                                                let clampedLocalY = min(max(value.location.y, minLocalY), maxLocalY)

                                                pieces[index].position = CGPoint(
                                                    x: value.location.x,
                                                    y: clampedLocalY
                                                )
                                            }
                                        }
                                        .onEnded { value in
                                            if let gridFrame = gridFrame, let lowerAreaFrame = lowerAreaFrame {
                                                handleDrop(
                                                    piece: piece,
                                                    location: value.location,
                                                    gridFrame: gridFrame,
                                                    lowerAreaFrame: lowerAreaFrame,
                                                    cellSize: cellSize
                                                )
                                            }
                                        }
                                )
                                .disabled(isAutoSolving)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .onAppear {
                        lowerAreaFrame = lowerGeo.frame(in: .global)
                    }
                    .onChange(of: lowerGeo.frame(in: .global)) { newFrame in
                        lowerAreaFrame = newFrame
                    }
                }
            }
            .onAppear {
                initializePuzzle(containerWidth: availableWidth, containerHeight: availableHeight * 0.5)
                lastOrientation = UIDevice.current.orientation
            }
            .onChange(of: geometry.size) { newSize in
                let currentOrientation = UIDevice.current.orientation

                // Check if orientation changed from portrait to landscape or vice versa
                let wasPortrait = lastOrientation.isPortrait
                let wasLandscape = lastOrientation.isLandscape
                let isPortrait = currentOrientation.isPortrait
                let isLandscape = currentOrientation.isLandscape

                if (wasPortrait && isLandscape) || (wasLandscape && isPortrait) {
                    shuffleUnplacedPieces(containerWidth: newSize.width, containerHeight: newSize.height * 0.5)
                    lastOrientation = currentOrientation
                }
            }
            .onChange(of: selectedImage) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        puzzleImage = image
                        resetPuzzle(containerWidth: availableWidth, containerHeight: availableHeight * 0.5)
                    }
                }
            }
            .alert("Puzzle Completed!", isPresented: $puzzleCompleted) {
                Button("Play Again") {
                    resetPuzzle(containerWidth: availableWidth, containerHeight: availableHeight * 0.5)
                }
            } message: {
                Text("Great job! You solved the puzzle!")
            }
        }
    }

    func initializePuzzle(containerWidth: CGFloat, containerHeight: CGFloat) {
        pieces = []

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let randomX = CGFloat.random(in: 50...(containerWidth - 50))
                let randomY = CGFloat.random(in: 50...(containerHeight - 50))

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

    func resetPuzzle(containerWidth: CGFloat, containerHeight: CGFloat) {
        puzzleCompleted = false
        showAutoSolveButton = false
        secretTaps = []
        initializePuzzle(containerWidth: containerWidth, containerHeight: containerHeight)
    }

    func shuffleUnplacedPieces(containerWidth: CGFloat, containerHeight: CGFloat) {
        for index in pieces.indices {
            if !pieces[index].isPlaced {
                let randomX = CGFloat.random(in: 50...(containerWidth - 50))
                let randomY = CGFloat.random(in: 50...(containerHeight - 50))
                pieces[index].position = CGPoint(x: randomX, y: randomY)
            }
        }
    }

    func handleDrop(piece: PuzzlePiece, location: CGPoint, gridFrame: CGRect, lowerAreaFrame: CGRect, cellSize: CGFloat) {
        guard let index = pieces.firstIndex(where: { $0.id == piece.id }) else { return }

        // Convert location from lower area coordinates to global coordinates
        let globalX = location.x + lowerAreaFrame.minX
        let globalY = location.y + lowerAreaFrame.minY

        // Convert global coordinates to grid coordinates
        let gridX = globalX - gridFrame.minX
        let gridY = globalY - gridFrame.minY

        // Check if dropped within the grid area
        if gridX >= 0 && gridX <= gridFrame.width && gridY >= 0 && gridY <= gridFrame.height {
            // Calculate which cell was targeted
            let targetCol = Int(gridX / cellSize)
            let targetRow = Int(gridY / cellSize)

            // Check if it's the correct cell
            if targetRow == piece.row && targetCol == piece.col {
                // Calculate center of correct cell
                let cellCenterX = CGFloat(targetCol) * cellSize + cellSize / 2
                let cellCenterY = CGFloat(targetRow) * cellSize + cellSize / 2

                let dropX = gridX
                let dropY = gridY

                // Check if within snap threshold
                let distance = sqrt(pow(dropX - cellCenterX, 2) + pow(dropY - cellCenterY, 2))

                if distance <= snapThreshold {
                    // Snap to correct position with animation
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        pieces[index].isPlaced = true
                        pieces[index].rotation = 0
                    }

                    // Check if puzzle is completed
                    checkPuzzleCompletion()
                }
            }
        }
    }

    func checkPuzzleCompletion() {
        if pieces.allSatisfy({ $0.isPlaced }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                puzzleCompleted = true
            }
        }
    }

    func stopAutoSolve() {
        isAutoSolving = false
    }

    func handleSecretTap(row: Int, col: Int) {
        let cellIndex = row * gridSize + col
        secretTaps.append(cellIndex)

        // Keep only the last 4 taps
        if secretTaps.count > 4 {
            secretTaps.removeFirst()
        }

        // Check if the sequence matches
        if secretTaps == secretSequence {
            withAnimation {
                showAutoSolveButton.toggle()
            }
        }
    }

    func autoSolvePuzzle(gridFrame: CGRect, lowerAreaFrame: CGRect, cellSize: CGFloat) {
        isAutoSolving = true
        animationSpeed = 1.2

        // Get only pieces that are not yet placed
        let unplacedPieces = pieces.filter { !$0.isPlaced }

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
                // Calculate target position in grid coordinates (global)
                let cellX = CGFloat(piece.col) * cellSize + cellSize / 2
                let cellY = CGFloat(piece.row) * cellSize + cellSize / 2
                let targetGlobalX = gridFrame.minX + cellX
                let targetGlobalY = gridFrame.minY + cellY

                // Convert to lower area coordinates (relative to lower ZStack)
                let targetLocalX = targetGlobalX - lowerAreaFrame.minX
                let targetLocalY = targetGlobalY - lowerAreaFrame.minY

                // Update position (animation handled by .animation modifier on view)
                self.pieces[idx].position = CGPoint(x: targetLocalX, y: targetLocalY)
                self.pieces[idx].rotation = 0

                // Mark as placed after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + self.animationSpeed) {
                    guard self.isAutoSolving else { return }
                    self.pieces[idx].isPlaced = true

                    // Solve next piece
                    solvePiece(at: index + 1)
                }
            }
        }

        solvePiece(at: 0)
    }
}

struct PuzzlePieceView: View {
    let piece: PuzzlePiece
    let cellSize: CGFloat
    let gridSize: Int
    let image: UIImage?

    var body: some View {
        GeometryReader { geometry in
            let totalSize = cellSize * CGFloat(gridSize)

            Group {
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: totalSize, height: totalSize)
                        .clipped()
                        .offset(
                            x: -CGFloat(piece.col) * cellSize,
                            y: -CGFloat(piece.row) * cellSize
                        )
                } else {
                    Image("puzzle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: totalSize, height: totalSize)
                        .clipped()
                        .offset(
                            x: -CGFloat(piece.col) * cellSize,
                            y: -CGFloat(piece.row) * cellSize
                        )
                }
            }
        }
        .frame(width: cellSize, height: cellSize)
        .clipped()
        .overlay(
            Rectangle()
                .strokeBorder(Color.white, lineWidth: 2)
        )
        .shadow(radius: piece.isPlaced ? 0 : 3)
    }
}

#Preview {
    ContentView()
}
