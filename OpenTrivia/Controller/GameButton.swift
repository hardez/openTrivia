//
//  GameButton.swift
//  OpenTrivia
//
//  Created by Marco Eckhardt on 25.10.18.
//  Copyright © 2018 Marco Eckhardt. All rights reserved.
//

import UIKit

class GameButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }

}
