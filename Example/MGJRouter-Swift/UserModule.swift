//
//  UserModule.swift
//  MGJRouter-Swift
//
//  Created by hisoka0917 on 01/04/2019.
//  Copyright (c) 2019 hisoka0917. All rights reserved.
//

import Foundation
import MGJRouter_Swift

class UserModule: SelfAware {
    static func awake() {
        MGJRouter.register(url: "http://") { params in
            print("匹配到了url，以下是相关信息")
            print("parameters: \(params)")
        }
        MGJRouter.register(url: "mgj://search/:keyword") { params in
            print("匹配到了url，以下是相关信息")
            print("parameters: \(params)")
            if let completion = params[MGJRouterParameterCompletion] as? () -> Void {
                completion()
            }
        }
        MGJRouter.register(url: "mgj://userinfo") { params in
            print("匹配到了url，以下是相关信息")
            print("parameters: \(params)")
            if let completion = params[MGJRouterParameterCompletion] as? () -> Void {
                completion()
            }
        }
    }
}
