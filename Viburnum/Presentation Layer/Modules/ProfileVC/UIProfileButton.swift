//
//  StyleForProfileButton.swift
//  Viburnum
//
//  Created by Maksim Sugak on 11/03/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import UIKit

class UIProfileButton: UIButton {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    self.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    self.layer.borderWidth = 1.0
    self.layer.cornerRadius = 8
    self.clipsToBounds = true
  }
}
