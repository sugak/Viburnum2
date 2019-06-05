//
//  MultiPeerCommunicator.swift
//  Viburnum
//
//  Created by Maksim Sugak on 17/03/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultiPeerCommunicator: NSObject, Communicator {
  var online: Bool = false
 // var storageManager = StorageManager()

  // Initial creation of MultipeerConnectivity stuff:
  let myPeer: MCPeerID!
  let displayName = UserDefaults.standard.string(forKey: "profileName") ?? "Пользователь \(UIDevice.current.name)"
  let serviceBrowser: MCNearbyServiceBrowser!
  let advertiser: MCNearbyServiceAdvertiser!
  weak var delegate: CommunicatorDelegate?
  // Dictionary to save active sessions:
  var activeSessions: [String: MCSession] = [:]

  override init() {
    // Setting up my peer ID:
    myPeer = MCPeerID(displayName: displayName)
    // Setting up advertiser:
    advertiser = MCNearbyServiceAdvertiser(peer: myPeer, discoveryInfo: ["userName": displayName], serviceType: "tinkoff-chat")
    // Setting up browser:
    serviceBrowser = MCNearbyServiceBrowser(peer: myPeer, serviceType: "tinkoff-chat")
    super.init()
    // Settin up delegates:
    serviceBrowser.delegate = self
    advertiser.delegate = self
    // Let the magic begin:
    advertiser.startAdvertisingPeer()
    serviceBrowser.startBrowsingForPeers()
  }

  func manageSession(with peerID: MCPeerID) -> MCSession {
    // Checking if user is already on the list:
    guard activeSessions[peerID.displayName] == nil else { return activeSessions[peerID.displayName]! }
    // Create session for user:
    let session = MCSession(peer: myPeer, securityIdentity: nil, encryptionPreference: .none)
    session.delegate = self

    // Associate user with session:
    activeSessions[peerID.displayName] = session
    return activeSessions[peerID.displayName]!
  }

  // Send message function:
  func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> Void)?) {
    // Get user from array:
    guard let session = activeSessions[userID] else {return}

    // Prepare the message:
    let preparedMessageToSend = ["eventType": "TextMessage", "messageId": generateMessageId(), "text": string]

    // Prepare JSON:
    guard let data = try? JSONSerialization.data(withJSONObject: preparedMessageToSend, options: .prettyPrinted) else { return }

    // Try to send message or get error:
    do {
      try session.send(data, toPeers: session.connectedPeers, with: .reliable)

      // Work with sent message:
      delegate?.didReceiveMessage(text: string, fromUser: myPeer.displayName, toUser: userID)
      if let completion = completionHandler {
        completion(true, nil)
      }
    } catch let error {
      if let completion = completionHandler {
        completion(false, error)
      }
    }
  }

  // Required function for message ID:
  func generateMessageId() -> String {
    let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
    return string!
  }
}
