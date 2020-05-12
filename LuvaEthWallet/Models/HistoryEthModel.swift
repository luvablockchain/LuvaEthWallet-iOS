//
//  HistoryEthModel.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import SwiftyJSON

class HistoryEthModel: NSObject {
    
    var blockNumber: String = ""
    var timeStamp: Date?
    var hashTransaction: String = ""
    var blockHash: String = ""
    var fromAddress: String = ""
    var toAddress: String = ""
    var amount: String = ""
    var gas: String = ""
    var gasPrice: String = ""
    var isError: Int = 0
    var cumulativeGasUsed: String = ""
    var gasUsed: String = ""
    var confirmations:String = ""
    var contractAddress:String = ""
    var input: String = ""
    
    override init() {
        super.init()
    }
    
    init(json:JSON) {
        super.init()
        self.input = json["input"].stringValue
        self.blockNumber = json["blockNumber"].stringValue
        if(json["timeStamp"].intValue != 0) {
            timeStamp = json["timeStamp"].intValue.dateFromTimeInterval
        }
        self.contractAddress = json["contractAddress"].stringValue
        self.hashTransaction = json["hash"].stringValue
        self.blockHash = json["blockHash"].stringValue
        self.fromAddress = json["from"].stringValue
        self.toAddress = json["to"].stringValue
        self.amount = json["value"].stringValue
        self.gas = json["gas"].stringValue
        self.gasPrice = json["gasPrice"].stringValue
        self.isError = json["isError"].intValue
        self.cumulativeGasUsed = json["cumulativeGasUsed"].stringValue
        self.gasUsed = json["gasUsed"].stringValue
        self.confirmations = json["confirmations"].stringValue
    }

}
