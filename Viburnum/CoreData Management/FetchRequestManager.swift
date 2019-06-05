//
//  FetchRequestManager.swift
//  Viburnum
//
//  Created by Maksim Sugak on 02/04/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import CoreData

class FetchRequestManager {

  // Connector:
  static let shared = FetchRequestManager()

  // Online users:
  func fetchOnlineUsers() -> NSFetchRequest<User> {
    let request: NSFetchRequest<User> = User.fetchRequest()
    request.predicate = NSPredicate(format: "isOnline == YES")
    return request
  }

  // User with ID:
  func fetchUserWithID(id: String) -> NSFetchRequest<User> {
    let request: NSFetchRequest<User> = User.fetchRequest()
    request.predicate = NSPredicate(format: "userId == %@", id)
    return request
  }

  // Conversations:
  func fetchConversations() -> NSFetchRequest<Conversation> {
    let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
    let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    let onlineSortDescriptor = NSSortDescriptor(key: "isOnline", ascending: false)
    request.sortDescriptors = [onlineSortDescriptor, dateSortDescriptor]
    return request
  }

  // Online conversations:
  func fetchOnlineConversations() -> NSFetchRequest<Conversation> {
    let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
    request.predicate = NSPredicate(format: "isOnline == YES")
    return request
  }

  // Exact conversation:
  func fetchConversationWith(id: String) -> NSFetchRequest<Conversation> {
    let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
    request.predicate = NSPredicate(format: "conversationId == %@", id)
    return request
  }

  // User's messages:
  func fetchMessagesFrom(conversationID: String) -> NSFetchRequest<Message> {
    let request: NSFetchRequest<Message> = Message.fetchRequest()
    request.predicate = NSPredicate(format: "conversationId == %@", conversationID)
    let sort = NSSortDescriptor(key: "date", ascending: true)
    request.sortDescriptors = [sort]
    return request
  }
}
