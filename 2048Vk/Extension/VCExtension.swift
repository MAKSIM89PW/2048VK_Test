//
//  VCExtension.swift
//  2048Vk
//
//  Created by Максим Нурутдинов on 06.05.2023.
//

import Foundation
import UIKit

extension ViewController {

    func removeGestures() {
        self.view.gestureRecognizers?.removeAll()
    }
    
    func setupGestures(){
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        left.direction = .left
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        right.direction = .right
        let up = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        up.direction = .up
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        down.direction = .down

        self.view.addGestureRecognizer(left)
        self.view.addGestureRecognizer(right)
        self.view.addGestureRecognizer(up)
        self.view.addGestureRecognizer(down)
    }

    @objc func swipedLeft() {
        gameLogicService.move(direction: .left)
    }

    @objc func swipedRight() {
        gameLogicService.move(direction: .right)
    }

    @objc func swipedUp() {
        gameLogicService.move(direction: .up)
    }

    @objc func swipedDown() {
        gameLogicService.move(direction: .down)
    }

}
