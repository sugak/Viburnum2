//
//  UIPhotoButton.swift
//  Viburnum
//
//  Created by Maksim Sugak on 17/02/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

/*
Custom class for photo selecting button
 */

import UIKit

class PhotoButton: UIButton {

  // Init
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    let buttonImage = UIImage(named: "slr-camera-2-xxl")
    self.setImage(buttonImage, for: .normal) // Image set
    self.backgroundColor = UIColor(red: 0.25, green: 0.47, blue: 0.94, alpha: 1.0) // Setting background color
    self.imageEdgeInsets = UIEdgeInsets(top: Constants.imageInset, left: Constants.imageInset, bottom: Constants.imageInset, right: Constants.imageInset) // reduсing camera image inside the button
    self.layer.cornerRadius = Constants.cornerRadius // Setting the radius
    self.clipsToBounds = true
    self.isHidden = true
  }

  // Photo button animation
  func buttonAnimation () {
    UIView.animate(withDuration: 0.1, animations: { self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) }, completion: { _ in
      self.transform = CGAffineTransform.identity
    })
  }

}
