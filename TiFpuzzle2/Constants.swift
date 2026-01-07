//
//  Constants.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//
//  CONSTANTS OVERVIEW:
//  ==================
//  Centralized configuration values for the TiFpuzzle application.
//  Modify these values to customize app behavior and appearance.
//

import Foundation
import CoreGraphics

struct AppConstants {

    // ========================================================================
    // URLs
    // ========================================================================

    /// README documentation URL
    static let readmeURL = "https://tifcode.github.io/TiFpuzzle2"

    /// Privacy policy URL
    static let privacyPolicyURL = "https://tifcode.github.io/TiFpuzzle2/privacy-policy.html"

    // ========================================================================
    // Grid Configuration
    // ========================================================================

    /// Default grid size on app launch
    static let defaultGridSize = 3

    /// Minimum grid size (3x3)
    static let minGridSize = 3

    /// Maximum grid size (4x4)
    static let maxGridSize = 4

    // ========================================================================
    // Layout Dimensions
    // ========================================================================

    /// Grid height multiplier relative to screen height (45% of screen height)
    static let gridHeightMultiplier: CGFloat = 0.45

    /// Grid size reduction padding (subtracted from calculated square size)
    static let gridSizePadding: CGFloat = 32

    /// Cell size multiplier for boundary calculations (90% of container)
    static let cellSizeMultiplier: CGFloat = 0.9

    /// Lower area height multiplier relative to screen height (50% of screen height)
    static let lowerAreaHeightMultiplier: CGFloat = 0.5

    // ========================================================================
    // Boundary Enforcement
    // ========================================================================

    /// Bottom margin in points (1 cm ≈ 37.8 points at standard DPI)
    /// Pieces cannot be dragged below this margin from the bottom edge
    static let bottomMargin: CGFloat = 37.8

    // ========================================================================
    // Snap Behavior
    // ========================================================================

    /// Distance threshold in points for snapping pieces to grid cells
    /// Pieces within this distance from cell center will snap into place
    static let snapThreshold: CGFloat = 30.0

    // ========================================================================
    // Animation
    // ========================================================================

    /// Default animation speed in seconds per piece for auto-solve
    static let defaultAnimationSpeed: Double = 1.2

    /// Fast animation speed in seconds per piece (triggered by tapping title)
    static let fastAnimationSpeed: Double = 0.3

    /// Spring animation response time for piece snapping
    static let snapSpringResponse: Double = 0.3

    /// Spring animation damping fraction for piece snapping
    static let snapSpringDamping: Double = 0.6

    /// Delay in seconds before showing puzzle completion alert
    static let completionAlertDelay: Double = 0.5

    // ========================================================================
    // Visual Styling
    // ========================================================================

    /// Puzzle piece border width in points
    static let pieceBorderWidth: CGFloat = 2

    /// Shadow radius for unplaced pieces
    static let pieceShadowRadius: CGFloat = 3

    /// Grid border line width
    static let gridBorderWidth: CGFloat = 1

    /// Grid border opacity
    static let gridBorderOpacity: Double = 0.5

    /// Grid corner radius
    static let gridCornerRadius: CGFloat = 12

    /// Grid shadow radius
    static let gridShadowRadius: CGFloat = 4

    /// Button corner radius
    static let buttonCornerRadius: CGFloat = 8

    /// Button padding
    static let buttonPadding: CGFloat = 6

    /// Button background opacity
    static let buttonBackgroundOpacity: Double = 0.1

    /// Auto solve button horizontal padding
    static let autoSolveButtonHorizontalPadding: CGFloat = 16

    /// Auto solve button vertical padding
    static let autoSolveButtonVerticalPadding: CGFloat = 8

    // ========================================================================
    // Secret Features
    // ========================================================================

    /// Secret tap sequence for 3x3 grid (corners: top-left, bottom-left, bottom-right, top-right)
    static let secretSequence3x3 = [0, 6, 8, 2]

    /// Secret tap sequence for 4x4 grid (corners: top-left, bottom-left, bottom-right, top-right)
    static let secretSequence4x4 = [0, 12, 15, 3]

    /// Number of taps to track for secret sequence detection
    static let secretSequenceLength = 4

    // ========================================================================
    // Assets
    // ========================================================================

    /// Default puzzle image name in Assets.xcassets
    static let defaultPuzzleImageName = "puzzle"

    // ========================================================================
    // UI Spacing
    // ========================================================================

    /// Vertical spacing between upper and lower zones
    static let zoneSpacing: CGFloat = 16

    /// Menu bar bottom padding
    static let menuBarBottomPadding: CGFloat = 8

    /// Load button icon-text spacing
    static let loadButtonIconSpacing: CGFloat = 4
}
