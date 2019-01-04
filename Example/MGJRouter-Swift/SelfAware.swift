//
//  SelfAware.swift
//  MGJRouter-Swift
//
//  Created by hisoka0917 on 01/04/2019.
//  Copyright (c) 2019 hisoka0917. All rights reserved.
//

import Foundation

protocol SelfAware: class {
    static func awake()
}

class ModuleManagerBase {
    static func registerModules() {
        let startTime = NSDate.timeIntervalSinceReferenceDate
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount {
            (types[index] as? SelfAware.Type)?.awake()
        }
        types.deallocate()
        let endTime = NSDate.timeIntervalSinceReferenceDate
        print("Register modules spend \(endTime - startTime)s")
    }
}
