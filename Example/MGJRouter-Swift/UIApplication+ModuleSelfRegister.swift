//
//  UIApplication+ModuleSelfRegister.swift
//  MGJRouter-Swift
//
//  Created by hisoka0917 on 01/04/2019.
//  Copyright (c) 2019 hisoka0917. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    private static let runOnce: Void = {
        ModuleManagerBase.registerModules()
    }()
    
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}
