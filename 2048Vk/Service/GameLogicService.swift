//
//  GameLogicService.swift
//  2048Vk
//
//  Created by Максим Нурутдинов on 06.05.2023.
//

import Foundation
import UIKit

protocol GameLogicServiceDelegate: AnyObject {
    func showVictory()
    func showDefeat()
}

protocol TileAppearanceServiceDelegate: AnyObject {
    func addTile(tile: Tile?)
    func moveOnSameTile(from: Tile, to: Tile, completion: @escaping () -> Void)
    func moveOnEmptyTile(from: Tile, to: Tile, completion: @escaping () -> Void)
}

class GameLogicService {

    weak var gameLogicDelegate: GameLogicServiceDelegate?
    weak var tileAppearanceDelegate: TileAppearanceServiceDelegate?

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var isMoving = false
    private var dimension: Int = GameConfiguration.dimension
    private var winTileValue: Int = GameConfiguration.maxValue
    private var nextMoves = [Move]()
    private var tiles = [Tile]() {
        didSet {
            refreshNeighborTiles()
        }
    }

    init() {
        tiles = appDelegate.getTiles()
        refreshNeighborTiles()
    }

    private func getNewTileValue() -> Int {
        let rndTileValue = Int.random(in: 0...9)
        return rndTileValue < 5 ? 2 : 4
    }

    private func resetGame() {
        
        nextMoves.removeAll()
        tiles.removeAll()
        for x in 0..<dimension {
            for y in 0..<dimension {
                tiles.append(Tile(position: CGPoint(x: x, y: y) ))
            }
        }
        refreshNeighborTiles()
    }

    func start() {
        guard tiles.filter({
            tile in
            tile.number != nil
        }).count != 0 else {
            startNewGame()
            return
        }
        
        for tile in tiles.filter({
            filterTile in
            filterTile.number != nil
        }) {
            
            if checkVictory(number: tile.number!) {
                return
            }
            
            tileAppearanceDelegate?.addTile(tile: tile)
            appDelegate.setTiles(tiles: tiles)
        }
        
        if checkDefeat() {
            return
        }
    }

    func startNewGame() {
        resetGame()
        tileAppearanceDelegate?.addTile(tile: createRandomTile())
        tileAppearanceDelegate?.addTile(tile: createRandomTile())
        appDelegate.setTiles(tiles: tiles)
    }

    private func createRandomTile() -> Tile? {
        if let position = getRandomPosition(),
           let tile = tiles.filter({
               tile in
               tile.position == position
           }).first {
            tile.number = getNewTileValue()
            return tile
        }
        return nil
    }

    private func checkDefeat() -> Bool{

        var defeat = true

        if tiles.filter({$0.number == nil}).count != 0 {
            defeat = false
            return defeat
        }
        for tile in tiles {
            let v = tile.number!
            let neighbours = [tile.up, tile.right, tile.down, tile.left].filter { $0?.number == v }
            if neighbours.count != 0 {
                defeat = false
                return defeat
            }
        }

        if defeat {
            UserDefaults.standard.set(true, forKey: "defeat")
            gameLogicDelegate?.showDefeat()
            return defeat
        }
    }

    private func checkVictory(number: Int) -> Bool {
        if number == winTileValue{
            UserDefaults.standard.set(true, forKey: "victory")
            gameLogicDelegate?.showVictory()
            return true
        } else {
            return false
        }
    }

    private func getRandomPosition() -> CGPoint? {
        let emptyTiles = tiles.filter({
            tile in
            tile.number == nil
        })
        return emptyTiles[ Int.random(in: 0 ..< emptyTiles.count) ].position
    }

    private func refreshNeighborTiles() {
        for tile in tiles {
            let up = CGPoint(x: Int(tile.position.x) , y: Int(tile.position.y - 1))
            tile.up = tiles.filter({ $0.position == up }).first

            let down = CGPoint(x: Int(tile.position.x) , y: Int(tile.position.y + 1))
            tile.down = tiles.filter({ $0.position == down }).first

            let left = CGPoint(x: Int(tile.position.x - 1) , y: Int(tile.position.y))
            tile.left = tiles.filter({ $0.position == left }).first

            let right = CGPoint(x: Int(tile.position.x + 1), y: Int(tile.position.y))
            tile.right = tiles.filter({ $0.position == right }).first
        }
        
        appDelegate.setTiles(tiles: tiles)
    }


    func move(direction: Move) {
        if isMoving {
            nextMoves.append(direction)
            return
        }

        isMoving = true
        var waitForSignalToContinue = false
        var performedShift = false

        for side in 0..<dimension {
            var tilesToCheck = tiles.filter {
                return ((direction == .right || direction == .left) ? Int($0.position.x) : Int($0.position.y)) == side
            }
            if direction == .right || direction == .down {
                tilesToCheck = tilesToCheck.reversed()
            }

            var tileIndex = 0

            while tileIndex < tilesToCheck.count {
                let currentTile = tilesToCheck[tileIndex]

                if let otherTile = tilesToCheck.filter({ tile in
                    
                    guard tile.number != nil else { return false }

                    var position: Bool {
                        switch direction {
                            case .up:
                                return tile.position.x > currentTile.position.x
                            case .right:
                                return tile.position.y < currentTile.position.y
                            case .down:
                                return tile.position.x < currentTile.position.x
                            case .left:
                                return tile.position.y > currentTile.position.y
                        }
                    }
                    return position

                }).first {
                    if otherTile.number == currentTile.number {

                        waitForSignalToContinue = true
                        moveOnSameTile(from: otherTile, to: currentTile)

                        if checkVictory(number: currentTile.number!) {
                            return
                        }

                        performedShift = true

                    } else if currentTile.number == nil {

                        waitForSignalToContinue = true
                        moveOnEmptyTile(from: otherTile, to: currentTile)
                        tileIndex -= 1
                        performedShift = true

                    }
                }
                tileIndex += 1
            }
        }

        if performedShift {
            tileAppearanceDelegate?.addTile(tile: createRandomTile())
        }

        if checkDefeat() {
            return
        }

        if !waitForSignalToContinue {
            isMoving = false
            guard let direction = nextMoves.first else {
                return
            }
            move(direction: direction)
            nextMoves.removeFirst()
        }
    }

    private func moveOnSameTile(from: Tile, to: Tile) {
        to.number! *= 2
        from.number = nil
        tileAppearanceDelegate?.moveOnSameTile(from: from, to: to, completion: {
            self.isMoving = false
            self.appDelegate.setTiles(tiles: self.tiles)
        })
    }

    private func moveOnEmptyTile(from: Tile, to: Tile) {
        to.number = from.number
        from.number = nil
        tileAppearanceDelegate?.moveOnEmptyTile(from: from, to: to, completion: {
            self.isMoving = false
            self.appDelegate.setTiles(tiles: self.tiles)
        })
    }
    
    func removeTiles() {
        tiles.removeAll()
        appDelegate.setTiles(tiles: tiles)
    }
    
}
