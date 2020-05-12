//
//  MultiBalanceModel.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import SwiftyJSON

class MultiBalanceModel: NSObject {
    
    var account: String = ""
    
    var balance: String = ""
    
    var name: String = ""
    
    init(json:JSON) {
        super.init()
        account = json["account"].stringValue
        balance = json["balance"].stringValue
    }
}
