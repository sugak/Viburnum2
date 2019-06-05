//
//  UIButtonExtention.swift
//  Viburnum
//
//  Created by Maksim Sugak on 20/04/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
  func sendButtonAnimation () {
    UIView.animate(withDuration: 0.1, animations: { self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15) }, completion: { _ in
      self.transform = CGAffineTransform.identity
    })
  }
  
  func changeSendButton (for state: String) {
    UIView.animate(withDuration: 0.5) {
      if state == "inactive" {
        let image = UIImage(named: "sendButtonActive")
        self.setImage(image, for: .normal)
      } else if state == "active" {
        let image = UIImage(named: "sendButtonInactive")
        self.setImage(image, for: .normal)
      }
    }
  }
}

extension UILabel {
  func titleLabelIsOnline() {
    UIView.animate(withDuration: 1.0) {
      self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
      self.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    }
  }
  func titleLabelisOffline() {
    UIView.animate(withDuration: 1.0) {
      self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
      self.textColor = .black
    }
  }
}
