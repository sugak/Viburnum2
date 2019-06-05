//
//  ConversationListViewController.swift
//  Viburnum
//
//  Created by Maksim Sugak on 22/02/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import UIKit
import CoreData

class ConversationListViewController: UITableViewController, ManagerDelegate {

  // Creating empty array of existing blabbers (users)
  var blabbers: [Blabber] = []

  //fetchResultsController instance:
  var fetchResultsController: NSFetchedResultsController<Conversation>!

  // Outlet for funny placeholder when on chat users:
  @IBOutlet var tablePlaceHolder: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self

    // Remove separator + large navbar title:
    self.tableView.separatorStyle = .none
    navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationController!.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

    //Themes: calling update function for current theme:
    updateForCurrentTheme()

    //Prepare for tableview placeholder:
    tableView.backgroundView = tablePlaceHolder
    tableView.backgroundView?.isHidden = true

    // Initial conversations fetch:
    initialConversationFetching()
  }
  override func viewWillAppear(_ animated: Bool) {
    super .viewWillAppear(Constants.animated)
    // Initilize Communication manager:
    CommunicationManager.shared.delegate = self
    chatUpdate()
  }

  // Initial dialogs fetching:
  func initialConversationFetching() {
    let request = FetchRequestManager.shared.fetchConversations()
    request.fetchBatchSize = 20
    fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchResultsController.delegate = self
    do {
      try fetchResultsController.performFetch()
    } catch let error {
      print("fetchConversations() method:   \(error)")
    }
  }
  
  //Delegate functions:
  func chatUpdate() {
    initialConversationFetching()
    tableView.reloadData()
  }
  
  func userUpdate() {
    tableView.reloadData()
      print("CONVERSATION LIST")
  }
  
  // Tableview functions:
  override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     return "Диалоги"
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if fetchResultsController.fetchedObjects?.count ?? 0 > 0 {
      tableView.backgroundView?.isHidden = true
    } else {
      tableView.backgroundView?.isHidden = false
    }
    return fetchResultsController.fetchedObjects?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "conversationСell", for: indexPath) as? ConversationListTableViewCell else {
      return UITableViewCell()
    }

    let conversation = fetchResultsController.object(at: indexPath)
    cell.name = conversation.user?.name
    cell.avatarSymbols = conversation.user?.name ?? "XX"
    cell.message = conversation.lastMessage?.text
    cell.date = conversation.date
    cell.online = conversation.isOnline
    cell.hasUnreadMessages = conversation.hasUnreadMessages
    return cell
  }

  // Segue to chat:
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showConversation" {
      if let indexPath = tableView.indexPathForSelectedRow {
        guard let destinationController = segue.destination as?
          ConversationViewController else {
            return
        }

        let conversation = fetchResultsController.object(at: indexPath)
        destinationController.blabberChat = conversation

        // Transfer name into navbar:
//        guard let cell = tableView.cellForRow(at: indexPath) as? ConversationListTableViewCell else {
//          return
//        }
//        destinationController.navigationItem.title = cell.name
      }
    }

    //Themes: segue to ThemeViewController:
    if segue.identifier == "themeMenu" {
      guard let navController = segue.destination as? UINavigationController else {
        return
      }
      guard let destination = navController.topViewController as? ThemesViewController else {
        return
      }

      // Themes class protocol:
      destination.themeProtocol = { [weak self] (selectedTheme: UIColor) in
      self?.logThemeChanging(selectedTheme: selectedTheme) }
    }
  }

  // Function for ThemesView delegate and closure:
  func logThemeChanging(selectedTheme: UIColor) {
    print(selectedTheme)
  }

  //Themes: update function for current theme with User Defaults:
  func updateForCurrentTheme () {
    if let currentTheme = UserDefaults.standard.colorForKey(key: "currentTheme") {
       UINavigationBar.appearance().barTintColor = currentTheme
    } else {
      UserDefaults.standard.setColor(value: UIColor.white, forKey: "currentTheme")
      updateForCurrentTheme()
    }

    // Views updating:
    let windows = UIApplication.shared.windows
    for window in windows {
      for view in window.subviews {
        view.removeFromSuperview()
        window.addSubview(view)
      }
    }
  }
}

//Themes: extention for passing and reading UIColor in User Defaults:
extension UserDefaults {
  func setColor(value: UIColor?, forKey: String) {
    guard let value = value else {
      set(nil, forKey: forKey)
      return
    }
    set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: forKey)
  }
  func colorForKey(key: String) -> UIColor? {
    guard let data = data(forKey: key), let color = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
      else { return nil }
    return color
  }
}

// FetchResultController extention:
extension ConversationListViewController: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .update:
      tableView.reloadRows(at: [newIndexPath!], with: .none)
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .none)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .none)
    case.move:
      tableView.deleteRows(at: [indexPath!], with: .none)
      tableView.insertRows(at: [newIndexPath!], with: .none)
    }
  }
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}
