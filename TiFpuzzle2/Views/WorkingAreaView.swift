//
//  WorkingAreaView.swift
//  TiFpuzzle2
//
//  Created by Florin on 12/15/25.
//

import SwiftUI

// MARK: - Working Area View

/// WorkingAreaView - Lower area with scattered, draggable puzzle pieces
struct WorkingAreaView: View {
    @Binding var pieces: [PuzzlePiece]
    let gridSize: Int
    let cellSize: CGFloat
    let puzzleImage: UIImage?
    let isAutoSolving: Bool
    let animationSpeed: Double
    let menuAreaMaxY: CGFloat
    let gridFrame: CGRect?
    let lowerAreaFrame: CGRect?
    let onLowerAreaFrameChange: (CGRect) -> Void
    let onDrop: (PuzzlePiece, CGPoint) -> Void

    var body: some View {
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
                                    onDrop(piece, value.location)
                                }
                        )
                        .disabled(isAutoSolving)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                onLowerAreaFrameChange(lowerGeo.frame(in: .global))
            }
            .onChange(of: lowerGeo.frame(in: .global)) { _, newFrame in
                onLowerAreaFrameChange(newFrame)
            }
        }
    }
}
