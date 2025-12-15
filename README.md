# TiFpuzzle2

A fun and interactive puzzle game for iOS 15.0+ built with SwiftUI.

## Features

✅ 4x4 puzzle grid in the upper area
✅ Scattered pieces in the lower area (straight, not rotated)
✅ Drag and drop with snap-to-grid when pieces are dropped close to their correct position
✅ Auto Solve button with smooth animations (0.3s per piece)
✅ Stop Auto Solve functionality (button turns red and stops the animation)
✅ Puzzle completion detection with "Play Again" option

## How to Play

1. Launch the app to see the puzzle grid at the top and scattered pieces at the bottom
2. Drag puzzle pieces from the bottom area to their correct positions in the top grid
3. When a piece is dropped close to its correct position, it will automatically snap into place
4. Complete the entire puzzle to see a completion message
5. Use the "Auto Solve" button to watch the puzzle solve itself with smooth animations
6. Press "Stop Auto Solve" (red button) to pause the automatic solving at any time
7. After completing the puzzle, press "Play Again" to shuffle and start over

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
