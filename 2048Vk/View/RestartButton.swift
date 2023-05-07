//
//  RestartButton.swift
//  2048Vk
//
//  Created by Максим Нурутдинов on 06.05.2023.
//

import UIKit

class RestartButton: UIButton {
    required init() {
        super.init(frame: .zero)
            
        let normalTitleAttributedString = NSAttributedString(
            string: "Попробовать ещё раз",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.black
            ])
        
        self.setAttributedTitle(normalTitleAttributedString, for: .normal)
        self.backgroundColor = .white
        
        self.contentEdgeInsets = UIEdgeInsets(top: 10,left: 15,bottom: 10,right: 15)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.BUTTON_SHADOW.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 8.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}
