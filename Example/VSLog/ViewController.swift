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
    /// 配网组件命名空间
    struct AddDevice: LogProtocol { }
    /// 网络库命名空间
    struct VSNetwork: LogProtocol { }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        VSLogManager.sharedInstance().addBusinessAllowListMember([Log.AddDevice])
//        VSLogManager.sharedInstance().addCategoryAllowListMember([.ble])
//        VSLogManager.sharedInstance().updateAllowList([.business, .category], state: true)
        
        VSLogManager.sharedInstance().addCategoryDenyListMember([.custom("other")])
        VSLogManager.sharedInstance().addBusinessDenyListMember([Log.VSNetwork.nameSpace()])
        VSLogManager.sharedInstance().updateDenyList([.category, .business], state: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    @IBAction func path() {
        print(NSHomeDirectory().appending("/Documents/VSLogger"))
    }
    @IBAction func debug() {
        Log.Default.debug(category: .custom("Stephen"), "1")
    }
    @IBAction func info() {
        Log.AddDevice.info(category: .ble, "来了老弟")
    }
    @IBAction func warning() {
        Log.VSNetwork.warning(category: .netWork, "再见走好")
    }
    @IBAction func error() {
        Log.Default.warning("来了老弟")
    }
    
}

