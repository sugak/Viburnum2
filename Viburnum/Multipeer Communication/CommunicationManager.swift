//
//  CommunicationManager.swift
//  Viburnum
//
//  Created by Maksim Sugak on 17/03/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class CommunicationManager: CommunicatorDelegate {

  // Making singleton:
  static let shared = CommunicationManager()
  var multiPeerCommunicator: MultiPeerCommunicator!
  // Delegate to talk to ViewController:
  weak var delegate: ManagerDelegate!

  private init() {
    //Setting up the instance of MultiPeerCommunicator
    self.multiPeerCommunicator = MultiPeerCommunicator()
    // Setting up the delegate
    self.multiPeerCommunicator.delegate = self
  }
  
  // List of conversations associated with their UserIDs:
  var listOfBlabbers: [String: Blabber] = [:]

  func didFoundUser(userID: String, userName: String?) {
    let saveContext = CoreDataStack.shared.saveContext
    saveContext.perform {
      guard let user = User.findOrInsertUser(id: userID, in: saveContext) else { return }
      let conversation = Conversation.findOrInsertConversationWith(id: userID, in: saveContext)
      user.name = userName
      conversation.isOnline = true
      conversation.user = user
      CoreDataStack.shared.performSave(context: saveContext, completion: nil)
    }
    DispatchQueue.main.async {
      self.delegate.userUpdate()
    }
  }

  func didLostUser(userID: String) {
    let saveContext = CoreDataStack.shared.saveContext
    saveContext.perform {
      let conversation = Conversation.findOrInsertConversationWith(id: userID, in: saveContext)
      conversation.isOnline = false
      CoreDataStack.shared.performSave(context: saveContext, completion: nil)
    }
    DispatchQueue.main.async {
      self.delegate.userUpdate()
    }
  }

  func failedToStartBrowsingForUsers(error: Error) {
    print(error.localizedDescription)
  }

  func failedToStartAdvertisingForUsers(error: Error) {
    print(error.localizedDescription)
  }

  func didReceiveMessage(text: String, fromUser: String, toUser: String) {
    let saveContext = CoreDataStack.shared.saveContext
    saveContext.perform {
      let message: Message
      if let conversation = Conversation.findConversationWith(id: fromUser, in: saveContext) {
        message = Message.insertNewMessage(in: saveContext)
        message.isIncome = true
        message.conversationId = conversation.conversationId
        message.text = text
        conversation.date = Date()
        message.date = Date()
        conversation.hasUnreadMessages = true
        conversation.addToMessages(message)
        conversation.lastMessage = message
      } else if let conversation = Conversation.findConversationWith(id: toUser, in: saveContext) {
        message = Message.insertNewMessage(in: saveContext)
        message.isIncome = false
        message.conversationId = conversation.conversationId
        message.text = text
        conversation.date = Date()
        message.date = Date()
        conversation.hasUnreadMessages = false
        conversation.addToMessages(message)
        conversation.lastMessage = message
      }
      CoreDataStack.shared.performSave(context: saveContext, completion: nil)
    }
    DispatchQueue.main.async {
      self.delegate.chatUpdate()
    }

  }
}
