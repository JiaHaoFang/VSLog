//
//  ViewController.swift
//  VSLog
//
//  Created by JiaHaoFang on 03/24/2022.
//  Copyright (c) 2022 JiaHaoFang. All rights reserved.
//

import UIKit
import VSLog

extension Log {
    struct AddDevice: LogProtocol {
        
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        VSLogManager.sharedInstance().addBusinessAllowListMember([Log.AddDevice.nameSpace()])
        VSLogManager.sharedInstance().addCategoryAllowListMember([.ble])
        VSLogManager.sharedInstance().updateAllowList([.business, .category], state: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    @IBAction func path() {
        print(NSHomeDirectory().appending("/Documents/VSLogger"))
    }
    @IBAction func debug() {
        Log.Default.debug("1")
    }
    @IBAction func info() {
        Log.AddDevice.info(category: .ble, "来了老弟")
    }
    @IBAction func warning() {
        Log.AddDevice.warning("来了老弟")
    }
    @IBAction func error() {
        Log.AddDevice.warning("来了老弟")
    }
    
}

