# TiFpuzzle2

A fun and interactive puzzle game for iOS 15.0+ built with SwiftUI.

## Features

- 4x4 puzzle grid in the upper area
- Load any photo from your device using the photo picker
- Scattered pieces in the lower area (straight, not rotated)
- Drag and drop with snap-to-grid when pieces are dropped close to their correct position
- Secret combination to unlock Auto Solve button
- Auto Solve button with smooth animations (1.2s per piece)
- Tap "TiFpuzzle2" during auto-solve to accelerate to 0.3s per piece
- Stop Auto Solve functionality (button turns red and stops the animation)
- Puzzle completion detection with "Play Again" option

## How to Play

1. Launch the app to see the puzzle grid at the top and scattered pieces at the bottom
2. Tap the photo icon to load any image from your device (optional - defaults to built-in "puzzle" image)
3. Drag puzzle pieces from the bottom area to their correct positions in the top grid
4. When a piece is dropped close to its correct position, it will automatically snap into place
5. Complete the entire puzzle to see a completion message
6. To unlock the Auto Solve button, tap the grid corners in this order:
   - Upper-left corner → Lower-left corner → Lower-right corner → Upper-right corner
7. Use the "Auto Solve" button to watch the puzzle solve itself with smooth animations
8. During auto-solve, tap "TiFpuzzle2" to speed up the animation
9. Press "Stop Auto Solve" (red button) to pause the automatic solving at any time
10. After completing the puzzle, press "Play Again" to shuffle and start over

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Setup

1. Clone the repository
2. Add your puzzle image to Assets.xcassets with the name "puzzle"
3. Open TiFpuzzle2.xcodeproj in Xcode
4. Build and run on simulator or device


## Technical Details

- Built with SwiftUI for iOS
- Uses drag gesture recognition for piece manipulation
- Implements coordinate space conversions for accurate positioning
- Features smooth animations with spring physics
- Supports dynamic layout with GeometryReader
