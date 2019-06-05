//
//  ThemesViewController.swift
//  Viburnum
//
//  Created by Maksim Sugak on 05/03/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {

  let model = Themes()
  let themesQueue = DispatchQueue(label: "com.MaksimSugak", qos: .background)
  var themeProtocol: ((UIColor) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

      // Setting current theme color to the view background:
      guard let currentTheme = UserDefaults.standard.colorForKey(key: "currentTheme") else {return}
      self.view.backgroundColor = currentTheme
    }

  // Function for all updates on buttons tap:
  func applyTheme(with color: UIColor) {
    self.view.backgroundColor = color
    UINavigationBar.appearance().barTintColor = color
    themesQueue.async {
      UserDefaults.standard.setColor(value: color, forKey: "currentTheme")
    }

    // All views update:
    let windows = UIApplication.shared.windows
    for window in windows {
      for view in window.subviews {
        view.removeFromSuperview()
        window.addSubview(view)
      }
    }
    themeProtocol?(color)
  }

  // Actions:
  @IBAction func backButton(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func themeButtonTap(_ sender: Any) {
    if let button = sender as? UIButton {
      switch button.tag {
      case 1:
        applyTheme(with: model.theme1)
      case 2:
        applyTheme(with: model.theme2)
      case 3:
        applyTheme(with: model.theme3)
      default:
        break
      }
    }
  }
}
