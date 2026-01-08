# CLAUDE.md - TiFpuzzle2 Project Guide

## Project Overview

**TiFpuzzle2** is a SwiftUI-based iOS jigsaw-style puzzle game where users drag and drop randomly scattered photo pieces into a grid. Users can create puzzles from photos taken with their camera or selected from their photo library. The app features a clean MVVM architecture with zone-based layout design.

### Key Features
- **Customizable Puzzles**: 3x3 or 4x4 grid sizes
- **Photo Integration**: Use device camera or photo library
- **Interactive Gameplay**: Drag randomly scattered pieces from working area and drop them into the correct grid positions
- **Snap-to-Grid Mechanics**: Pieces automatically snap when placed close to their correct position
- **Secret Feature**: Auto-solve mode unlocked via corner tap sequence
- **Orientation Support**: Adapts to portrait and landscape modes, reshuffling unplaced pieces
- **Boundary Enforcement**: Pieces stay within playable areas (can't go above menu bar or below bottom margin)

## Architecture

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

## File Structure

```
TiFpuzzle2/
├── Models/
│   └── PuzzlePiece.swift          # 23 lines - Data model
├── ViewModels/
│   └── PuzzleViewModel.swift      # 235 lines - State & logic
├── Views/
│   ├── MenuBarView.swift          # 124 lines - Menu controls
│   ├── PuzzleGridView.swift       # 73 lines - Upper grid
│   ├── WorkingAreaView.swift      # 83 lines - Lower area
│   ├── PuzzlePieceView.swift      # 56 lines - Piece rendering
│   └── ImagePicker.swift          # 53 lines - Camera/photo
├── ContentView.swift              # 187 lines - Coordinator
├── Constants.swift                # 155 lines - Configuration
├── TiFpuzzle2App.swift            # Entry point
└── Assets.xcassets/               # Images & resources
```

## Key Components

### 1. PuzzlePiece Model
```swift
struct PuzzlePiece: Identifiable {
    let id: Int              // Unique identifier
    let row: Int             // Correct row position
    let col: Int             // Correct column position
    var position: CGPoint    // Current position in working area
    var rotation: Double     // Rotation angle (always 0)
    var isPlaced: Bool       // Whether in correct grid position
    var zIndex: Double       // Layering order
}
```

### 2. PuzzleViewModel
Manages all puzzle state and business logic:
- **Published State**: Pieces, grid size, images, frames, animation
- **Puzzle Management**: Initialize, reset, shuffle, toggle size
- **Drop Detection**: Coordinate conversion (lower area → global → grid)
- **Secret Features**: Tap tracking, auto-solve animation

### 3. Coordinate Systems
Three coordinate spaces are used:
- **Global Coordinates**: Absolute screen positions
- **Grid Coordinates**: Relative to upper grid zone
- **Lower Area Coordinates**: Relative to working zone

**Conversion Flow**:
```
Lower Area (drag location)
    ↓ + lowerAreaFrame.minX/minY
Global Coordinates
    ↓ - gridFrame.minX/minY
Grid Coordinates
    ↓ / cellSize
Cell Index (row, col)
```

### 4. Boundary Enforcement
```swift
// Top boundary: piece doesn't go above menu
minLocalY = menuAreaMaxY - lowerAreaFrame.minY + (cellSize / 2)

// Bottom boundary: piece doesn't go below 1cm margin
maxLocalY = lowerAreaFrame.height - bottomMargin - (cellSize / 2)

// Clamp position
clampedY = min(max(location.y, minLocalY), maxLocalY)
```

### 5. Snap Detection
Pieces snap to grid when:
1. Dropped within grid bounds
2. In correct cell (targetRow == piece.row && targetCol == piece.col)
3. Distance from cell center ≤ 30 points

## Configuration

All app constants are centralized in `Constants.swift`:

### Key Constants
```swift
// Grid
defaultGridSize = 3          // 3x3 on launch
minGridSize = 3, maxGridSize = 4

// Layout
gridHeightMultiplier = 0.45  // 45% of screen height
bottomMargin = 37.8          // 1cm in points

// Snap Behavior
snapThreshold = 30.0         // pixels from center

// Animation
defaultAnimationSpeed = 1.2  // seconds per piece
fastAnimationSpeed = 0.3     // fast mode

// Secret Sequences
secretSequence3x3 = [0, 6, 8, 2]    // corners
secretSequence4x4 = [0, 12, 15, 3]  // corners
```

## Features

### Secret Feature: Auto-Solve
**Unlock Sequence**:
- 3x3 grid: Tap corners [0, 6, 8, 2] (top-left, bottom-left, bottom-right, top-right)
- 4x4 grid: Tap corners [0, 12, 15, 3]
- Toggles auto-solve button visibility

**Fast Mode**:
- Tap "TiFpuzzle" title during auto-solve to speed up (0.3s per piece)

### Orientation Handling
- Detects portrait ↔ landscape transitions
- Preserves placed pieces in grid
- Shuffles unplaced pieces to new random positions

## Code Navigation

All files use `// MARK:` comments for Xcode navigation:

**Main Sections**:
- `// MARK: - Main View` - Top-level view structures
- `// MARK: - Published State` - Observable properties
- `// MARK: - Puzzle Management` - Core puzzle functions
- `// MARK: - Drop Detection & Coordinate Conversion` - Snap logic
- `// MARK: - Secret Features` - Auto-solve implementation

**Constants Sections**:
- `// MARK: URLs` - External links
- `// MARK: Grid Configuration` - Size settings
- `// MARK: Layout Dimensions` - Screen ratios
- `// MARK: Boundary Enforcement` - Margin values
- `// MARK: Snap Behavior` - Threshold values
- `// MARK: Animation` - Timing parameters
- `// MARK: Visual Styling` - UI appearance
- `// MARK: Secret Features` - Unlock sequences
- `// MARK: Assets` - Image names
- `// MARK: UI Spacing` - Padding values

## Development Guidelines

### Adding a New Feature

1. **Model Changes**: Update `PuzzlePiece.swift` if data structure changes
2. **Business Logic**: Add to `PuzzleViewModel.swift`
3. **UI Updates**: Modify appropriate view file
4. **Constants**: Add configuration values to `Constants.swift`
5. **Navigation**: Use `// MARK:` comments for new sections

### Modifying Layout

- **Grid Size**: Adjust `gridHeightMultiplier` in Constants
- **Margins**: Update `bottomMargin`, `gridSizePadding`
- **Snap Sensitivity**: Modify `snapThreshold`
- **Animation Speed**: Change `defaultAnimationSpeed`

### Best Practices

1. **Single Responsibility**: Each file has one clear purpose
2. **MARK Comments**: Use for Xcode navigation
3. **Inline Comments**: Keep comments concise and inline where possible
4. **Constants**: Never hardcode values; use `AppConstants`
5. **Coordinate Clarity**: Document coordinate space conversions
6. **State Management**: All state in ViewModel, not in Views

## Testing

### Manual Testing Checklist

- [ ] Load puzzle from photo library
- [ ] Take photo with camera
- [ ] Drag pieces within boundaries
- [ ] Pieces snap to correct positions
- [ ] Grid size toggle (3x3 ↔ 4x4)
- [ ] Orientation change preserves placed pieces
- [ ] Secret sequence unlocks auto-solve
- [ ] Auto-solve completes puzzle
- [ ] Fast mode during auto-solve
- [ ] Completion alert triggers
- [ ] Play again resets puzzle

### Edge Cases

- Orientation change during auto-solve
- Multiple rapid grid size toggles
- Dragging piece during snap animation
- Camera permission denied
- Photo library permission denied

## Common Tasks

### Change Default Grid Size
```swift
// Constants.swift
static let defaultGridSize = 4  // Change from 3 to 4
```

### Adjust Snap Sensitivity
```swift
// Constants.swift
static let snapThreshold: CGFloat = 50.0  // More forgiving
```

### Modify Secret Sequence
```swift
// Constants.swift
static let secretSequence3x3 = [0, 2, 6, 8]  // Different pattern
```

### Change Animation Speed
```swift
// Constants.swift
static let defaultAnimationSpeed: Double = 0.5  // Faster
```

## Troubleshooting

### Pieces Not Snapping
- Check `snapThreshold` value
- Verify coordinate conversion in `handleDrop()`
- Ensure `gridFrame` and `lowerAreaFrame` are set

### Boundary Issues
- Verify `menuAreaMaxY` is tracking correctly
- Check `bottomMargin` calculation
- Review `lowerAreaFrame` geometry updates

### Auto-Solve Not Working
- Confirm secret sequence is correct
- Verify `gridFrame` and `lowerAreaFrame` are available
- Check `isAutoSolving` state updates

## URLs & Resources

- **README**: https://tifcode.github.io/TiFpuzzle2/
- **Privacy Policy**: https://tifcode.github.io/TiFpuzzle2/privacy-policy.html
- **Repository**: https://github.com/TiFcode/TiFpuzzle2

## Dependencies

- **SwiftUI**: UI framework
- **PhotosUI**: Photo picker integration
- **UIKit**: Camera integration via `UIImagePickerController`
- **Foundation**: Core utilities
- **CoreGraphics**: Geometry types

## iOS Requirements

- **Minimum iOS Version**: iOS 17.0+
- **Capabilities**: Camera access, Photo library access
- **Orientation Support**: Portrait and Landscape

## License

See https://tifcode.github.io/TiFpuzzle2/LICENSE.html file for details.

---

**Last Updated**: January 2026
**iOS Target**: 17.0+
**Architecture**: MVVM with SwiftUI
