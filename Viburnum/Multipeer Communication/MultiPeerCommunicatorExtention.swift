//
//  MultiPeerCommunicatorExtention.swift
//  Viburnum
//
//  Created by Maksim Sugak on 17/03/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension MultiPeerCommunicator: MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {

  // Invitation from peer:
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    print(#function)

    let session = manageSession(with: peerID)
    if session.connectedPeers.contains(peerID) {
      invitationHandler(false, nil)
    } else {
          invitationHandler(true, session)
    }
  }

  // Found and lost peer:
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    guard let recievedInfo = info else { return } // Safely getting recieved info
    guard let blabberName = recievedInfo["userName"] else { return }  // Safely getting blabber name from dictionary

    let session: MCSession = manageSession(with: peerID)
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    delegate?.didFoundUser(userID: peerID.displayName, userName: blabberName)
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    activeSessions.removeValue(forKey: peerID.displayName)
    delegate?.didLostUser(userID: peerID.displayName)
  }

  // Session:
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case .notConnected:
      print("\(peerID.displayName) is not connected")
    case .connecting:
      print("\(peerID.displayName) is connecting")
    case .connected:
      print("\(peerID.displayName) is connected")
    }
  }

  // Received message:
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    let json = JSONDecoder()
    guard let info = try? json.decode([String: String].self, from: data), info["eventType"] == "TextMessage" else { return }
    delegate?.didReceiveMessage(text: info["text"]!, fromUser: peerID.displayName, toUser: myPeer.displayName)
  }

  // Fails functions:
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    delegate?.failedToStartBrowsingForUsers(error: error)
  }
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    delegate?.failedToStartAdvertisingForUsers(error: error)
  }

  // UNUSEFUL. Stream and sourse:
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    print(#function)
  }

  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    print(#function)
  }

  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    print(#function)
  }
}
