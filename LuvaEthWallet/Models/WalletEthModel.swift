//
//  WalletEthModel.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import LKDBHelper
import SwiftyJSON

public enum NetworkType: Int {
    case main = 1, test = 2
}


class WalletEthModel: NSObject {
            
    @objc var address: String = ""
    
    @objc var name: String = ""
    
    @objc var isHD: Bool = false
    
    @objc var data: Data?
    
    @objc var createDate = Date()
    
    @objc var useDate = Date()
    
    @objc var isPending = false
    
    @objc var listRecents:[String] = []
    
    override init() {
        super.init()
    }
    
    override static func getPrimaryKey() -> String {
        return "address"
    }
    
    override static func getTableName() -> String {
        return "WalletEthTable"
    }
    
    public static func getListWalletEthFromDB(completionHandler: @escaping (_ result: [WalletEthModel]) -> ()) {
        
        if let mutableArray = WalletEthModel.search(withWhere: nil, orderBy: nil, offset: 0, count: 10000) {
            let array: [WalletEthModel] = mutableArray.compactMap {
                if let model = $0 as? WalletEthModel {
                    if model.address != "" {
                        return model
                    }
                }
                return nil
            }
            completionHandler(array)
        } else {
            completionHandler([])
        }
    }
    
    public static let sharedInstance : WalletEthModel = {
        let instance = WalletEthModel()
        instance.saveToDB()
        return instance
    }()
    
    public func saveConfigToDB() {
        self.saveToDB()
    }
}
