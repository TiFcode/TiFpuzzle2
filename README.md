# TiFpuzzle

A fun and interactive puzzle game for iPhone and iPad

## Features

- **Switchable grid modes**: 3x3 (default) or 4x4 puzzle grid - tap the title to toggle
- **Camera support**: Take photos directly with the camera button to create instant puzzles
- **Custom photos**: Load any photo from your device using the photo picker
- **Smart piece placement**: Scattered pieces in the lower area (straight, not rotated)
- **Snap-to-grid**: Pieces automatically snap when dropped close to their correct position
- **Drag boundaries**: Pieces can't be dragged above the menu or below 1cm from bottom
- **Orientation handling**: Unplaced pieces shuffle when device is rotated
- **Secret combination**: Unlock Auto Solve button by tapping grid corners in sequence
- **Auto Solve**: Watch the puzzle solve itself with smooth animations (1.2s per piece)
- **Speed control**: Tap the title during auto-solve to accelerate to 0.3s per piece
- **Stop Auto Solve**: Red button to pause automatic solving at any time
- **Completion detection**: "Play Again" option when puzzle is completed

## How to Play

1. **Launch**: App starts with a 3x3 puzzle grid at the top and scattered pieces at the bottom
2. **Load photo** (optional):
   - Tap the camera icon to take a photo directly with your device camera
   - Or tap "Load photo" button to choose any image from your photo library
3. **Switch difficulty**: Tap the title (e.g., "TiFpuzzle 3x3") to toggle between 3x3 and 4x4 modes
4. **Drag pieces**: Drag puzzle pieces from the bottom area to their correct positions in the top grid
5. **Snap to grid**: When a piece is dropped close to its correct position, it automatically snaps into place
6. **Complete puzzle**: Solve all pieces to see the completion message
7. **Unlock Auto Solve**: Tap the grid corners in this order to reveal the Auto Solve button:
   - Upper-left corner → Lower-left corner → Lower-right corner → Upper-right corner
   - (Tap same sequence again to hide the button)
8. **Auto Solve**: Press the green "Auto Solve" button to watch the puzzle solve itself
9. **Speed up**: During auto-solve, tap the title to accelerate animation from 1.2s to 0.3s per piece
10. **Stop**: Press the red "Stop Auto Solve" button to pause automatic solving
11. **Play Again**: After completion, press "Play Again" to shuffle and start over

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Setup

1. Clone the repository [https://github.com/TiFcode/TiFpuzzle2](https://github.com/TiFcode/TiFpuzzle2)
2. Add your puzzle image to Assets.xcassets with the name "puzzle"
3. Open TiFpuzzle2.xcodeproj in Xcode
4. Build and run on simulator or device


## Technical Details

### Design Pattern: MVVM (Model-View-ViewModel)

The app follows a strict separation of concerns:

```
┌─────────────────────────────────────────┐
│ Models/                                  │
│ - PuzzlePiece.swift (Data model)        │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│ ViewModels/                              │
│ - PuzzleViewModel.swift (Business logic) │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│ Views/                                   │
│ - ContentView.swift (Coordinator)        │
│ - MenuBarView.swift                      │
│ - PuzzleGridView.swift                   │
│ - WorkingAreaView.swift                  │
│ - PuzzlePieceView.swift                  │
│ - ImagePicker.swift                      │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│ Constants.swift (Configuration)          │
└─────────────────────────────────────────┘
```

### Application Structure

TiFpuzzle is built using SwiftUI with a clean, zone-based layout that separates different functional areas:
### Zone-Based Layout

The UI is divided into three main zones:

1. **Menu Bar** (Top)
   - Camera button
   - Photo picker button
   - Title (tap to toggle grid size)
   - Auto-solve button (conditional)
   - Help/Privacy buttons

2. **Upper Zone - Puzzle Grid Area**
   - Fixed-size grid where pieces snap into correct positions
   - Tap detection for secret sequence
   - White background with shadow

3. **Lower Zone - Working Area**
   - Randomly scattered puzzle pieces (initial placement)
   - All pieces are draggable within boundaries
   - Pieces can be dragged up to the grid and dropped
   - Boundary enforcement (top: menu bar, bottom: 1cm margin)


#### Details For Each Zone

**Upper Zone - Puzzle Grid Area**
- Contains the solved puzzle grid where pieces snap into their correct positions
- Fixed square dimensions calculated as `min(width, height * 0.45) - 32`
- Grid cells are evenly divided based on grid size (3x3 or 4x4)
- Displays placed pieces with white borders and no shadow
- Interactive grid overlay detects secret tap sequence on corners
- Uses global coordinate frame tracking for accurate drop detection

**Lower Zone - Working Area**
- Scattered puzzle pieces area where unplaced pieces are randomly distributed
- Pieces maintain their correct orientation (no rotation)
- Supports drag gestures with real-time position updates
- Implements boundary enforcement:
  - Top boundary: pieces cannot go above the menu bar
  - Bottom boundary: pieces cannot go below 1cm (37.8 points) from bottom edge
  - Side boundaries: pieces stay within container width
- Unplaced pieces have shadow effect for depth perception
- Z-index management brings dragged pieces to front

**Menu Bar**
- Fixed height control strip at the top containing:
  - Camera button (left) - launches device camera
  - Load button - opens photo picker
  - Title display - "TiFpuzzle" (tap to toggle grid size)
  - Auto Solve button (conditional) - appears after secret sequence
  - Question mark button - opens README documentation
  - Info button (right) - opens privacy policy

### Core Components

**PuzzlePiece Model**
```swift
struct PuzzlePiece: Identifiable {
    let id: Int              // Unique identifier
    let row: Int             // Correct row position (0-based)
    let col: Int             // Correct column position (0-based)
    var position: CGPoint    // Current position in working area
    var rotation: Double     // Rotation angle (always 0 in current version)
    var isPlaced: Bool       // Whether piece is in correct grid position
    var zIndex: Double       // Layering order for overlapping pieces
}
```

**PuzzlePieceView**
- Renders individual puzzle pieces by cropping the full image
- Uses offset-based image slicing to show correct portion
- Applies 2-point white border for piece separation
- Conditionally applies shadow (only on unplaced pieces)
- Scales to cell size while maintaining aspect ratio

**ImagePicker (UIViewControllerRepresentable)**
- Wraps UIKit's UIImagePickerController for SwiftUI integration
- Supports both camera and photo library sources
- Handles image selection and dismissal callbacks
- Triggers puzzle reset with newly selected image

### State Management

The app uses SwiftUI's `@State` property wrappers for reactive state:

**Puzzle State:**
- `pieces: [PuzzlePiece]` - Array of all puzzle pieces
- `puzzleCompleted: Bool` - Completion alert trigger
- `gridSize: Int` - Current grid dimension (3 or 4)
- `puzzleImage: UIImage?` - Current puzzle image (custom or default)

**Animation State:**
- `isAutoSolving: Bool` - Auto-solve animation state
- `animationSpeed: Double` - Duration per piece in auto-solve (1.2s or 0.3s)

**Geometry Tracking:**
- `gridFrame: CGRect?` - Grid frame geometry tracking (upper grid zone)
- `lowerAreaFrame: CGRect?` - Lower area geometry tracking (working zone)
- `menuAreaMaxY: CGFloat` - Menu area geometry tracking (bottom Y coordinate)
- `previousSize: CGSize` - Geometry size tracking for orientation changes

**Secret Feature State:**
- `secretTaps: [Int]` - Last 4 grid cell taps for secret sequence
- `showAutoSolveButton: Bool` - Auto-solve button visibility

**Image Selection State:**
- `selectedImage: PhotosPickerItem?` - Selected image tracking from photo picker
- `showPhotoPicker: Bool` - Photo picker presentation state
- `showCamera: Bool` - Camera presentation state

### Coordinate Space Management

The app uses three coordinate systems:

1. **Global Coordinates** - Absolute screen positions tracked via `GeometryReader.frame(in: .global)`
2. **Grid Coordinates** - Relative positions within the upper grid zone
3. **Lower Area Coordinates** - Relative positions within the lower working zone

**Drop Detection Flow:**
1. Drag gesture provides location in lower area coordinates
2. Convert to global: `globalY = localY + lowerAreaFrame.minY`
3. Convert to grid: `gridY = globalY - gridFrame.minY`
4. Calculate target cell: `targetRow = Int(gridY / cellSize)`
5. Check correctness: `targetRow == piece.row && targetCol == piece.col`
6. Calculate snap distance from cell center
7. If distance ≤ 30 points, snap piece into place

### Boundary Enforcement

**Drag Constraints:**
- Top: `minY = menuAreaMaxY - lowerAreaFrame.minY + (cellSize / 2)`
- Bottom: `maxY = lowerAreaFrame.height - 37.8 - (cellSize / 2)`
- Left: `minX = cellSize / 2`
- Right: `maxX = containerWidth - (cellSize / 2)`

**Initialization & Shuffle:**
- Uses same boundary calculations for consistent behavior
- Random placement within valid ranges
- Triggered on app launch, photo load, grid size change, and orientation change

### Secret Features

**Auto Solve Unlock Sequence:**
- 3x3 grid: tap cells [0, 6, 8, 2] (corners: top-left, bottom-left, bottom-right, top-right)
- 4x4 grid: tap cells [0, 12, 15, 3] (same corner pattern)
- Toggle button visibility by repeating sequence

**Animation Speed Control:**
- Default: 1.2 seconds per piece
- Fast mode: 0.3 seconds per piece (activated by tapping title during auto-solve)

### Orientation Handling

- Monitors `geometry.size` changes via `onChange`
- Detects portrait ↔ landscape transitions
- Preserves placed pieces in grid
- Shuffles unplaced pieces to new random positions within bounds
- Maintains grid size and completion state

## Technical Details

- Built with SwiftUI for iOS
- Uses drag gesture recognition for piece manipulation
- Implements coordinate space conversions for accurate positioning
- Features smooth animations with spring physics
- Supports dynamic layout with GeometryReader
- UIViewControllerRepresentable for camera integration
- PhotosPicker for modern photo library access
- Task-based async image loading

## Privacy

For information about how this app handles your data, please see our [Privacy Policy](https://tifcode.github.io/TiFpuzzle2/privacy-policy.html).

## License

The source code of the project "TiFpuzzle" located at [https://github.com/TiFcode/TiFpuzzle2](https://github.com/TiFcode/TiFpuzzle2) is licensed under the Apache License 2.0 - see the [https://tifcode.github.io/TiFpuzzle2/LICENSE.html](LICENSE.html) file for details.

### Attribution Requirements

If you use this code in your project, you **MUST**:
- ✅ Include the [LICENSE.html](https://tifcode.github.io/TiFpuzzle2/LICENSE.html) and [NOTICE.html](https://tifcode.github.io/TiFpuzzle2/NOTICE.html) files in your distribution
- ✅ Provide proper attribution mentioning "TiFpuzzle by Iulian-Florin Toma"
- ✅ Link back to this repository: [https://github.com/TiFcode/TiFpuzzle2](https://github.com/TiFcode/TiFpuzzle2)
- ✅ State any modifications you made to the original files

See the [NOTICE.html](https://tifcode.github.io/TiFpuzzle2/NOTICE.html) file for complete attribution requirements.