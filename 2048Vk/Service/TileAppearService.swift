//
//  TileAppearService.swift
//  2048Vk
//
//  Created by Максим Нурутдинов on 06.05.2023.
//

import Foundation
import UIKit

// внешний вид плитки
class TileAppearanceService {

    var board: Board
    private var tileViews = [TileView]()
    private let moveSpeed = 0.2 // скорость движения

    init(board: Board) {
        self.board = board
    }

    func reset() {
        for view in tileViews {
            view.removeFromSuperview()
        }
        tileViews.removeAll()
    }

}

extension TileAppearanceService: TileAppearanceServiceDelegate {
    func moveOnSameTile(from: Tile, to: Tile, completion: @escaping () -> Void) {
        let fromTileView = tileViews.filter({ tileView in
            tileView.tileModel?.position == from.position
        }).first!

        let toTileView = tileViews.filter({ tileView in
            tileView.tileModel?.position == to.position
        }).first!

        board.bringSubviewToFront(fromTileView) // на передний план

        UIView.animate(
                withDuration: moveSpeed,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    fromTileView.center = toTileView.center
                    fromTileView.tileModel = to

                    toTileView.alpha = 0
                }
        ){ finished in

            UIView.animate(
                    withDuration: self.moveSpeed,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 7,
                    options: .curveEaseOut,
                    animations: {
                        fromTileView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    },
                    completion: { _ in
                        fromTileView.transform = .identity
                    }
            )

            toTileView.alpha = 0
            toTileView.removeFromSuperview()

            if let index = self.tileViews.firstIndex(of: toTileView) {
                self.tileViews.remove(at: index)
            }
            completion()
        }
    }

    func moveOnEmptyTile(from: Tile, to: Tile, completion: @escaping () -> Void) {

        let tileView = tileViews.filter({
            tileView in
            tileView.tileModel?.position == from.position
        }).first!

        UIView.animate(
                withDuration: moveSpeed,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    tileView.frame.origin = self.board.positionRect(position: to.position).origin
                    tileView.tileModel = to
                }
        ) { _ in
            completion()
        }
    }

    // созд клетки
    func addTile(tile: Tile?) {

        guard let tile = tile else { return }

        let scale: CGFloat = 0.2
        let tileView = TileView(tileModel: tile, frame: board.positionRect(position: tile.position))
        tileView.transform = CGAffineTransform(scaleX: scale, y: scale)
        tileView.alpha = 0
        tileViews.append(tileView)

        board.addSubview(tileView)
        board.bringSubviewToFront(tileView)

        UIView.animate(
                withDuration: self.moveSpeed * 2,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 8,
                options: .curveEaseOut,
                animations: {
                    tileView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    tileView.alpha = 1.0
                }
        )
    }
}
