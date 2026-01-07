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

// ============================================================================
// Main View
// ============================================================================

struct ContentView: View {

    // ========================================================================
    // State Management
    // ========================================================================

    // Puzzle State:
    @State private var pieces: [PuzzlePiece] = []  // Array of all puzzle pieces
    @State private var puzzleCompleted = false     // Completion alert trigger
    @State private var gridSize = AppConstants.defaultGridSize  // Current grid dimension (3 or 4)
    @State private var puzzleImage: UIImage?       // Current puzzle image (custom or default)
    @State private var draggedPiece: PuzzlePiece?  // Currently dragged piece (unused but kept for compatibility)

    // Animation State:
    @State private var isAutoSolving = false       // Auto-solve animation state
    @State private var animationSpeed: Double = AppConstants.defaultAnimationSpeed  // Duration per piece in auto-solve (1.2s or 0.3s)

    // Geometry Tracking:
    @State private var gridFrame: CGRect?          // Grid frame geometry tracking (upper grid zone)
    @State private var lowerAreaFrame: CGRect?     // Lower area geometry tracking (working zone)
    @State private var menuAreaMaxY: CGFloat = 0   // Menu area geometry tracking (bottom Y coordinate)
    @State private var previousSize: CGSize = .zero  // Geometry size tracking for orientation changes

    // Secret Feature State:
    @State private var secretTaps: [Int] = []      // Last 4 grid cell taps for secret sequence
    @State private var showAutoSolveButton = false // Auto-solve button visibility

    // Image Selection State:
    @State private var selectedImage: PhotosPickerItem?  // Selected image tracking from photo picker
    @State private var showPhotoPicker = false     // Photo picker presentation state
    @State private var showCamera = false          // Camera presentation state

    // ========================================================================
    // Computed Properties
    // ========================================================================

    /// Secret Feature: Auto Solve Unlock Sequence
    /// 3x3 grid: tap cells [0, 6, 8, 2] (corners: top-left, bottom-left, bottom-right, top-right)
    /// 4x4 grid: tap cells [0, 12, 15, 3] (same corner pattern)
    var secretSequence: [Int] {
        gridSize == AppConstants.maxGridSize ? AppConstants.secretSequence4x4 : AppConstants.secretSequence3x3
    }

    // ========================================================================
    // Body
    // ========================================================================

    var body: some View {
        GeometryReader { geometry in
            // Calculate dimensions for grid and cells
            let availableHeight = geometry.size.height
            let availableWidth = geometry.size.width
            let squareSize = min(availableWidth, availableHeight * AppConstants.gridHeightMultiplier) - AppConstants.gridSizePadding  // Fixed square for grid
            let cellSize = squareSize / CGFloat(gridSize)  // Size of each puzzle piece

            VStack(spacing: AppConstants.zoneSpacing) {

                // ====================================================================
                // Upper Zone - Puzzle Grid Area
                // ====================================================================

                VStack(spacing: 0) {

                    // Menu Bar - Fixed height control strip with buttons and title
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
                                    // Animation Speed Control: Fast mode
                                    animationSpeed = AppConstants.fastAnimationSpeed
                                } else {
                                    // Toggle between 3x3 and 4x4 grid
                                    toggleGridSize(containerWidth: availableWidth, containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier)
                                }
                            }

                        Spacer()

                        // Auto Solve button (conditional) - appears after secret sequence
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
                    .background(
                        // Menu area geometry tracking - tracks bottom Y coordinate for boundary enforcement
                        GeometryReader { menuGeo in
                            Color.clear
                                .onAppear {
                                    menuAreaMaxY = menuGeo.frame(in: .global).maxY
                                }
                                .onChange(of: menuGeo.frame(in: .global)) { _, newFrame in
                                    menuAreaMaxY = newFrame.maxY
                                }
                        }
                    )

                    // Puzzle Grid - Contains solved puzzle grid where pieces snap into correct positions
                    ZStack {
                        // Grid overlay with tap detection for secret sequence on corners
                        VStack(spacing: 0) {
                            ForEach(0..<gridSize, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<gridSize, id: \.self) { col in
                                        Rectangle()
                                            .strokeBorder(Color.gray.opacity(AppConstants.gridBorderOpacity), lineWidth: AppConstants.gridBorderWidth)
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

                        // Placed pieces - displayed with white borders and no shadow
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
                        // Grid frame geometry tracking - uses global coordinate frame for accurate drop detection
                        GeometryReader { gridGeo in
                            Color.white
                                .onAppear {
                                    gridFrame = gridGeo.frame(in: .global)
                                }
                                .onChange(of: gridGeo.frame(in: .global)) { _, newFrame in
                                    gridFrame = newFrame
                                }
                        }
                    )
                    .cornerRadius(AppConstants.gridCornerRadius)
                    .shadow(radius: AppConstants.gridShadowRadius)
                }
                .padding()

                // ====================================================================
                // Lower Zone - Working Area
                // ====================================================================
                // Scattered puzzle pieces area where unplaced pieces are randomly distributed.
                // Pieces maintain correct orientation (no rotation).
                // Supports drag gestures with real-time position updates.
                GeometryReader { lowerGeo in
                    ZStack {
                        // Unplaced pieces with drag support, Z-index management, and shadow effect for depth perception
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
                                                // Bring piece to front when dragging
                                                let maxZ = pieces.map { $0.zIndex }.max() ?? 0
                                                pieces[index].zIndex = maxZ + 1

                                                // Top boundary: calculate minimum Y so piece doesn't go above menu
                                                let minLocalY = menuAreaMaxY - lowerAreaFrame!.minY + (cellSize / 2)

                                                // Bottom boundary: calculate maximum Y so piece doesn't go below bottom margin
                                                let maxLocalY = lowerAreaFrame!.height - AppConstants.bottomMargin - (cellSize / 2)

                                                // Clamp position to enforce boundaries
                                                let clampedLocalY = min(max(value.location.y, minLocalY), maxLocalY)

                                                pieces[index].position = CGPoint(
                                                    x: value.location.x,
                                                    y: clampedLocalY
                                                )
                                            }
                                        }
                                        .onEnded { value in
                                            // Check if piece should snap to grid when drag ends
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
                    .onAppear {
                        lowerAreaFrame = lowerGeo.frame(in: .global)
                    }
                    .onChange(of: lowerGeo.frame(in: .global)) { _, newFrame in
                        lowerAreaFrame = newFrame  // Track lower area geometry
                    }
                }
            }
            .onAppear {
                initializePuzzle(containerWidth: availableWidth, containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier)
                previousSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newSize in
                // Detect orientation changes and shuffle unplaced pieces
                if previousSize != .zero {
                    let wasPortrait = previousSize.height > previousSize.width  // Portrait: height > width
                    let isPortrait = newSize.height > newSize.width

                    if wasPortrait != isPortrait {  // Orientation changed
                        shuffleUnplacedPieces(containerWidth: newSize.width, containerHeight: newSize.height * AppConstants.lowerAreaHeightMultiplier)
                    }
                }
                previousSize = newSize
            }
            .onChange(of: selectedImage) { _, newItem in
                // Load selected image from photo picker asynchronously
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        puzzleImage = image
                        resetPuzzle(containerWidth: availableWidth, containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier)
                    }
                }
            }
            .alert("Puzzle Completed!", isPresented: $puzzleCompleted) {
                Button("Play Again") {
                    resetPuzzle(containerWidth: availableWidth, containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier)
                }
            } message: {
                Text("Great job! You solved the puzzle!")
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $puzzleImage, sourceType: .camera) { image in
                    if image != nil {
                        resetPuzzle(containerWidth: availableWidth, containerHeight: availableHeight * AppConstants.lowerAreaHeightMultiplier)
                    }
                }
            }
        }
    }

    // ============================================================================
    // Puzzle Management Functions
    // ============================================================================

    /// Initialize Puzzle - Creates all puzzle pieces with random positions within boundaries.
    /// Triggered on: app launch, photo load, grid size change.
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
                    rotation: 0,  // No rotation
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
    /// Called during orientation changes.
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

    // ============================================================================
    // Drop Detection & Coordinate Conversion
    // ============================================================================

    /// Handle Drop - Processes piece drop and checks for correct placement.
    /// Coordinate conversion: lower area → global → grid. Snaps if within threshold.
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
            let targetCol = Int(gridX / cellSize)
            let targetRow = Int(gridY / cellSize)

            // Check if it's the correct cell
            if targetRow == piece.row && targetCol == piece.col {
                // Calculate center of correct cell and snap distance
                let cellCenterX = CGFloat(targetCol) * cellSize + cellSize / 2
                let cellCenterY = CGFloat(targetRow) * cellSize + cellSize / 2

                let dropX = gridX
                let dropY = gridY

                let distance = sqrt(pow(dropX - cellCenterX, 2) + pow(dropY - cellCenterY, 2))

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
                puzzleCompleted = true
            }
        }
    }

    // ============================================================================
    // Secret Features
    // ============================================================================

    /// Stop Auto Solve - Halts the automatic solving animation
    func stopAutoSolve() {
        isAutoSolving = false
    }

    /// Handle Secret Tap - Tracks grid cell taps for secret unlock sequence.
    /// 3x3 grid: [0, 6, 8, 2] (corners). 4x4 grid: [0, 12, 15, 3]. Toggle button visibility.
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
    /// Uses recursive function to solve pieces sequentially. Fast mode available.
    func autoSolvePuzzle(gridFrame: CGRect, lowerAreaFrame: CGRect, cellSize: CGFloat) {
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

                    // Solve next piece
                    solvePiece(at: index + 1)
                }
            }
        }

        solvePiece(at: 0)
    }
}

#Preview {
    ContentView()
}
