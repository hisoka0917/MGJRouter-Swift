//
//  ViewController.swift
//  MGJRouter-Swift
//
//  Created by hisoka0917 on 01/04/2019.
//  Copyright (c) 2019 hisoka0917. All rights reserved.
//

import UIKit
import MGJRouter_Swift

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.open(url: "mgj://userinfo?name=Tom", userInfo: nil) {
            self.label.text = "Callback of open url completion!"
            print("open url: 'mgj://userinfo' complete!")
        }
    }
}

