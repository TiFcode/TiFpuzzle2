//
//  PuzzleGridView.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//

import SwiftUI

// MARK: - Puzzle Grid View

/// PuzzleGridView - Upper grid area where pieces snap into correct positions
struct PuzzleGridView: View {
    let pieces: [PuzzlePiece]
    let gridSize: Int
    let squareSize: CGFloat
    let cellSize: CGFloat
    let puzzleImage: UIImage?
    let onGridFrameChange: (CGRect) -> Void
    let onSecretTap: (Int, Int) -> Void

    var body: some View {
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
                                    onSecretTap(row, col)
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
                        onGridFrameChange(gridGeo.frame(in: .global))
                    }
                    .onChange(of: gridGeo.frame(in: .global)) { _, newFrame in
                        onGridFrameChange(newFrame)
                    }
            }
        )
        .cornerRadius(AppConstants.gridCornerRadius)
        .shadow(radius: AppConstants.gridShadowRadius)
    }
}
