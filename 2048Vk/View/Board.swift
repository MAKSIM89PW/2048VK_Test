//
//  Board.swift
//  2048Vk
//
//  Created by Максим Нурутдинов on 06.05.2023.
//

import Foundation
import UIKit

class Board: UIView {

    let dimension: Int = GameConfiguration.dimension
    let padding: CGFloat = GameConfiguration.padding

    let tileSize: CGSize
    var tileRects = [CGRect]()

    init(boardSize: CGSize) {
        let sideLength = (Double(boardSize.width) - Double(padding) * Double(self.dimension + 1)) / Double(self.dimension)
        tileSize = CGSize(width: sideLength, height: sideLength)
        super.init(frame: CGRect(origin: CGPoint.zero, size: boardSize))

        setup()
    }

    fileprivate func setup(){
        var point = CGPoint(x: padding, y: padding)

        for x in 0..<dimension {
            point.x = self.padding

            for y in 0..<dimension {

                let tileModel = Tile(position: CGPoint(x: x, y: y))
                let backgroundTile = TileView(tileModel: tileModel, frame: CGRect(origin: point, size: tileSize))
                self.addSubview(backgroundTile)
                tileRects.append(backgroundTile.frame)

                point.x += padding + tileSize.width
            }
            point.y += padding + tileSize.width
        }

    }

    func positionRect(position: CGPoint) -> CGRect {
        return tileRects[Int(position.x) * dimension + Int(position.y)]
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}
