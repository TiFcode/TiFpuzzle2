//
//  PuzzlePiece.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//

import Foundation
import CoreGraphics

// MARK: - Puzzle Piece Model

/// Core Component: PuzzlePiece Model
/// Represents a single puzzle piece with its position and state
struct PuzzlePiece: Identifiable {
    let id: Int              // Unique identifier
    let row: Int             // Correct row position (0-based)
    let col: Int             // Correct column position (0-based)
    var position: CGPoint    // Current position in working area
    var rotation: Double     // Rotation angle (always 0 in current version)
    var isPlaced: Bool = false  // Whether piece is in correct grid position
    var zIndex: Double = 0   // Layering order for overlapping pieces
}
