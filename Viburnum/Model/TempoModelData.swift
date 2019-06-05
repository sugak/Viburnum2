//
//  TempoModelData.swift
//  Viburnum
//
//  Created by Maksim Sugak on 23/02/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation

// Data storage for Communication Homework:
class Blabber: NSObject {
  var id: String
  var name: String?
  var online: Bool
  var message: [String]
  var messageDate: [Date]
  var messageType: [MessageType]
  var hasUnreadMessages: Bool

  init(id: String, name: String?) {
    self.id = id
    self.name = name
    self.online = false
    self.message = []
    self.messageDate = []
    self.messageType = []
    self.hasUnreadMessages = false
  }
}

enum MessageType {
  case income
  case outcome
}
