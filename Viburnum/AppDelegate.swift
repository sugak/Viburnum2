//
//  AppDelegate.swift
//  Viburnum
//
//  Created by Maksim Sugak on 07/02/2019.
//  Copyright © 2019 Maksim Sugak. All rights reserved.
//
//// --------------------------------------------------//
////                                                   //
////                    Viburnum                       //
////    Вайбёрнум - это:                               //
////        - калина (ягода), как раз в рамках         //
////         современных тенденций нэйминга            //
////        - слово, удачно созвучное с Viber.         //
////        - Было легко подобрать хорошую иконку      //
////                                                   //
//// --------------------------------------------------//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

  // MARK: - ShowLog()
    func showLog (from: String, to: String, caller: String = #function) {
        #if SHOWLOGS
        print("\n App moved from \(from) to \(to) with: \(caller)")
        #endif
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      showLog(from: "Not running", to: "Foreground Inactive")
      
      // SOA Assembly:
//      self.window = UIWindow(frame: UIScreen.main.bounds)
//      let controller = rootAssembly.presentationAssembly.demoViewCotnroller()
//      window?.rootViewController = controller
//      window?.makeKeyAndVisible()
      
      return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
      showLog(from: "Active", to: "Inactive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
      showLog(from: "Inactive", to: "Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
      showLog(from: "Background", to: "Inactive Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      showLog(from: "Inactive Foreground", to: "Active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
      showLog(from: "Background", to: "Suspended")
    }

}
