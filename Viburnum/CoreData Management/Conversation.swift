//
//  Conversation.swift
//  Viburnum
//
//  Created by Maksim Sugak on 02/04/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import CoreData

extension Conversation {

  static func insertConversationWith(id: String, in context: NSManagedObjectContext) -> Conversation {
    guard let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation else {
      fatalError("Unable to insert Conversation")
    }
    conversation.conversationId = id
    return conversation
  }

  static func findConversationWith(id: String, in context: NSManagedObjectContext) -> Conversation? {
    let fetchConversationWithId = FetchRequestManager.shared.fetchConversationWith(id: id)
    do {
      let conversationsWithId = try context.fetch(fetchConversationWithId)
      assert(conversationsWithId.count < 2, "Conversations with id: \(id) more than 1")
      if !conversationsWithId.isEmpty {
        let conversation = conversationsWithId.first!
        return conversation
      } else {
        return nil
      }
    } catch {
      assertionFailure("Unable to fetch conversations")
      return nil
    }
  }

  // Find or insert Conversation:
  static func findOrInsertConversationWith(id: String, in context: NSManagedObjectContext) -> Conversation {
    guard let conversation = Conversation.findConversationWith(id: id, in: context) else {
      return Conversation.insertConversationWith(id: id, in: context)
    }
    return conversation
  }

}
