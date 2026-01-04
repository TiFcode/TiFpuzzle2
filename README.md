# TiFpuzzle for Kids

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

1. Clone the repository (https://github.com/TiFcode/TiFpuzzle2)
2. Add your puzzle image to Assets.xcassets with the name "puzzle"
3. Open TiFpuzzle2.xcodeproj in Xcode
4. Build and run on simulator or device


## Technical Details

- Built with SwiftUI for iOS
- Uses drag gesture recognition for piece manipulation
- Implements coordinate space conversions for accurate positioning
- Features smooth animations with spring physics
- Supports dynamic layout with GeometryReader

## Privacy

For information about how this app handles your data, please see our [Privacy Policy](https://tifcode.github.io/TiFpuzzle2/privacy-policy.html).

## License

The source code of the project "TiFpuzzle for Kids" located at [https://github.com/TiFcode/TiFpuzzle2](https://github.com/TiFcode/TiFpuzzle2) is licensed under the Apache License 2.0 - see the [https://tifcode.github.io/TiFpuzzle2/LICENSE.html](LICENSE.html) file for details.

### Attribution Requirements

If you use this code in your project, you **MUST**:
- ✅ Include the [https://tifcode.github.io/TiFpuzzle2/LICENSE.html](LICENSE.html) and [https://tifcode.github.io/TiFpuzzle2/NOTICE.html](NOTICE.html) files in your distribution
- ✅ Provide proper attribution mentioning "TiFpuzzle for Kids by Iulian-Florin Toma"
- ✅ Link back to this repository: https://github.com/TiFcode/TiFpuzzle2
- ✅ State any modifications you made to the original files

See the [https://tifcode.github.io/TiFpuzzle2/NOTICE.html](NOTICE.html) file for complete attribution requirements.