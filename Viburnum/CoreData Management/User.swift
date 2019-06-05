//
//  User.swift
//  Viburnum
//
//  Created by Maksim Sugak on 02/04/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import CoreData

extension User {
  // Insert User with:
  static func insertUserWith(id: String, in context: NSManagedObjectContext) -> User {
    guard let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User else {
      fatalError("Unable to insert User")
    }
    user.userId = id
    return user
  }
  // Find or insert User:
  static func findOrInsertUser(id: String, in context: NSManagedObjectContext) -> User? {
    let request = FetchRequestManager.shared.fetchUserWithID(id: id)
    do {
      let users = try context.fetch(request)
      assert(users.count < 2, "Users with id \(id) more than 1")
      if !users.isEmpty {
        return users.first!
      } else {
        return User.insertUserWith(id: id, in: context)
      }
    } catch {
      assertionFailure("Unable to fetch users")
      return nil
    }
  }
}
