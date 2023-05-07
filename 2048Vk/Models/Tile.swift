//
//  Tile.swift
//  2048Vk
//
//  Created by Максим Нурутдинов on 06.05.2023.
//

import Foundation
import UIKit

class Tile {
    var number: Int? {
        didSet {
            tileColor = AppearanceService.tileColorOfNumber(number: number)
            textColor = AppearanceService.textColorOfNumber(number: number)
        }
    }

    var tileColor = UIColor.TILE_EMPTY
    var textColor = UIColor.black

    var position: CGPoint

    weak var up: Tile?
    weak var down: Tile?
    weak var left: Tile?
    weak var right: Tile?

    init(position: CGPoint, number: Int? = nil) {
        self.position = position
        self.number = number

        setupColors()
    }

    private func setupColors(){
        tileColor = AppearanceService.tileColorOfNumber(number: number)
        textColor = AppearanceService.textColorOfNumber(number: number)
    }

}
