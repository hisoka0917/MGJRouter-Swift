//
//  UIViewController+Routable.swift
//  MGJRouter-Swift
//
//  Created by hisoka0917 on 01/04/2019.
//  Copyright (c) 2019 hisoka0917. All rights reserved.
//

import Foundation
import UIKit
import MGJRouter_Swift

protocol Routable {
//    func open(url: String)
    func open(url: String, userInfo: [String: Any]?, completion: (() -> Void)?)
}

extension UIViewController: Routable {
//    func open(url: String) {
//        MGJRouter.open(url: url)
//    }

    func open(url: String, userInfo: [String: Any]?, completion: (() -> Void)?) {
        MGJRouter.open(url: url, userInfo: userInfo, completion: completion)
    }
}
