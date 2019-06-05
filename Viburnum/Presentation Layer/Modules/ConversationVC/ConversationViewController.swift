//
//  ConversationViewController.swift
//  Viburnum
//
//  Created by Maksim Sugak on 24/02/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import UIKit
import CoreData

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ManagerDelegate, UITextFieldDelegate {
  // -----
  let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
  // User for data transfer:
  
  var blabberChat: Conversation! {
    didSet {
      setupTitleLabelAnimation()
    }
  }

  // FetchResultsController:
  var fetchResultsController: NSFetchedResultsController<Message>!
  
  //Keyboard observers:
  var observerShow: AnyObject?
  var observerHide: AnyObject?

  // Outlets:
  @IBOutlet var tableView: UITableView!
  @IBOutlet var sendButton: UIButton!
  @IBOutlet var messageInputField: UITextField!
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var customView: UIView!

  // Actions:
  @IBAction func messageInputFieldChanged(_ sender: Any) {
    if (messageInputField.text != "") && (blabberChat.isOnline) && (!(messageInputField.text?.hasPrefix(" "))!) {
      if !sendButton.isEnabled {
      sendButton.changeSendButton(for: "inactive")
      sendButton.sendButtonAnimation()
      }
      sendButton.isEnabled = true
      
    } else {
      if sendButton.isEnabled {
        sendButton.changeSendButton(for: "active")
        sendButton.sendButtonAnimation()
      }
      sendButton.isEnabled = false
    }
  }

  // Send message:
  @IBAction func sendMessageButton(_ sender: UIButton) {
    let messageToSend = messageInputField.text
    let conversationId = blabberChat.conversationId
    messageInputField.resignFirstResponder()

    CommunicationManager.shared.multiPeerCommunicator.sendMessage(string: messageToSend!, to: conversationId!) { success, error in
      if success {
        self.messageInputField.text = ""
        self.sendButton.isEnabled = false
        self.sendButton.sendButtonAnimation()
      }
      if let error = error {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Ошибка при отправке сообщения: \(error.localizedDescription)", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: Constants.animated, completion: nil)
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self
    self.tableView.delegate = self

    // Remove separator:
    self.tableView.separatorStyle = .none

    // Making large navbar title:
    navigationController?.navigationBar.prefersLargeTitles = true

    // Tuning row height:
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44

    // Tuning message input field:
    messageInputField.clipsToBounds = true

    //TextField delegate:
    messageInputField.delegate = self

    // Initial messages fetching:
    initialMessagesFetching()
    
    // Initial setup of title label:
    setupTitleLabel(with: titleLabel)
    
    //Animation for title label:
    setupTitleLabelAnimation()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.customView.superview?.setNeedsLayout()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(Constants.animated)
    CommunicationManager.shared.delegate = self
    blabberChat.hasUnreadMessages = false
    scrollChatDown()
    
    // Tuning keyboard:
    keyBoardSettings()

    // Initial sendButton state:
    sendButton.isEnabled = false
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    // Removing keyboard observers
    removeObservers()
  }
  
  func setupTitleLabel (with label: UILabel) {
    navigationItem.titleView = label
    
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
    //label.lineBreakMode = NSLineBreakMode.byWordWrapping
    
    label.text = blabberChat.user?.name
  }
  
  func setupTitleLabelAnimation () {
    if blabberChat.isOnline {
      titleLabel.titleLabelIsOnline()
    } else {
      titleLabel.titleLabelisOffline()
    }
  }
  
  private func initialMessagesFetching() {
    guard let conversationId = blabberChat.conversationId else { return }
    fetchResultsController = NSFetchedResultsController(fetchRequest: FetchRequestManager.shared.fetchMessagesFrom(conversationID: conversationId), managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchResultsController.delegate = self
    do {
      try fetchResultsController.performFetch()
    } catch {
    }
  }

  // Delegate funcntion:
  func chatUpdate() {
    blabberChat.hasUnreadMessages = false
    tableView.reloadData()
    
    // Scroll down to the last message:
    scrollChatDown()
  }
  
  func userUpdate() {
    blabberChat.isOnline = !blabberChat.isOnline
    setupTitleLabelAnimation()
    print("CONVERSATION")
  }
  
  // Scroll down to the last message:
  func scrollChatDown() {
    guard let fetchedObjects = fetchResultsController.fetchedObjects else { return }
    if !fetchedObjects.isEmpty {
      let indexPath = IndexPath(row: fetchedObjects.count - 1, section: 0)
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
  }

  // Tableview functions:
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = fetchResultsController.fetchedObjects?.count {
      return count
    } else {
        return 0
      }
    }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Choosing between cell prototype:
    let message = fetchResultsController.object(at: indexPath)
    var cellID = ""
    if message.isIncome {
      cellID = "incomeCell"
    } else {
      cellID = "outcomeCell"
    }
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MessageViewCell else {
      return MessageViewCell()
    }
    cell.textMess = message.text
    cell.textDate = message.date
    return cell
  }
  
  // Keyboard notifications:
  func keyBoardSettings() {
   observerShow = NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillShowNotification, object: nil, queue: nil) { (_) in
      self.view.frame.origin.y = -270
      // Scroll down to the last message:
      self.scrollChatDown()
    }
    observerHide = NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillShowNotification, object: nil, queue: nil) { (_) in
      self.view.frame.origin.y = 0.0
      // Scroll down to the last message:
      self.scrollChatDown()
    }
  }
  
  private func removeObservers() {
    if let observer = observerShow {
      NotificationCenter.default.removeObserver(observer)
    }
    if let observer = observerHide {
      NotificationCenter.default.removeObserver(observer)
    }

  }

  // Hide keyboard on textView Return tap:
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if string == "\n" {
      sendMessageButton(sendButton)
      messageInputField.resignFirstResponder()
      // Scroll down to the last message:
      scrollChatDown()
      return true
    }
    return true
  }
}

// FetchResultController extention:
extension ConversationViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
    scrollChatDown()
  }
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any, at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .none)
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .none)
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .none)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .none)
      tableView.insertRows(at: [newIndexPath!], with: .none)
    }
  }
}
