//
//  messageViewCell.swift
//  Viburnum
//
//  Created by Maksim Sugak on 24/02/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell, messageCellConfiguration {

  override func layoutSubviews() {
    super .layoutSubviews()

    //Styling chat bubbles:
    self.selectionStyle = .none
    messageView.layer.cornerRadius = 14.0
    messageView.clipsToBounds = true
  }

  // Confirming to protocol:
  var textMess: String? {
    didSet {
      messageText.text = textMess
    }
  }

  var textDate: Date? {
    didSet {
      // Checking date and time for date format:
      if textDate != nil {
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(textDate!) {
          dateFormatter.dateFormat = "HH:mm"
        } else {
          dateFormatter.dateFormat = "dd MMM"
        }
        messageDate.text = dateFormatter.string(from: textDate!)
      } else {
        messageDate.text = ""
      }
    }
  }

  // Outlets:
  @IBOutlet var messageView: UIView! // View for bubble background
  @IBOutlet var messageText: UILabel!
  @IBOutlet var messageDate: UILabel! // Message date field
}
