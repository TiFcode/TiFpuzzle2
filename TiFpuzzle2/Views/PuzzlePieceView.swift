//
//  PuzzlePieceView.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//

import SwiftUI

/// PuzzlePieceView - Renders individual puzzle pieces by cropping the full image.
/// Uses offset-based image slicing, applies white border, and shadow for unplaced pieces.
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
                    Image(uiImage: uiImage)  // Custom image from camera or photo picker
                        .resizable()
                        .scaledToFill()
                        .frame(width: totalSize, height: totalSize)
                        .clipped()
                        .offset(
                            x: -CGFloat(piece.col) * cellSize,
                            y: -CGFloat(piece.row) * cellSize
                        )
                } else {
                    Image(AppConstants.defaultPuzzleImageName)  // Default puzzle image from assets
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
                .strokeBorder(Color.white, lineWidth: AppConstants.pieceBorderWidth)
        )
        .shadow(radius: piece.isPlaced ? 0 : AppConstants.pieceShadowRadius)
    }
}
