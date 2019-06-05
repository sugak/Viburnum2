//
//  AppUser extention.swift
//  Viburnum
//
//  Created by Maksim Sugak on 26/03/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension AppUser {

  // Insert function:
  static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
    if let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser {
      return appUser
    }
    return nil
  }

  // Fetch request:
  static func fetchRequestAppUser(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
    let templateName = "AppUser"
    guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
      assert(false, "No template with name \(templateName)!")
      return nil
    }
    return fetchRequest
  }

  // Find or insert func:
  static func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {

    guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
      print("Model is not available in context!")
      assert(false)
      return nil
    }
    var appUser: AppUser?
    guard let fetchRequest = AppUser.fetchRequestAppUser(model: model) else {
      return nil
    }

    context.performAndWait {
          do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUsers found!")
            if let foundUser = results.first {
              appUser = foundUser
            }
          } catch {
            print("Failed to fetch AppUser: \(error)")
          }

          if appUser == nil {
            appUser = AppUser.insertAppUser(in: context)
          }
    }

    return appUser
  }
}
