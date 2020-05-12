//
//  LuvaServiceData.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BoltsSwift

protocol LuvaEthWalletNotificationDelegate: class {
    func notifySendEthSuccess(balance: String)
    func notifyTransactionPending()
}

class LuvaServiceData: NSObject {
    
    public var hostAPIDApp = "https://dappapi.luvapay.com"

    public var hostAPIRinkeby = "https://api-rinkeby.etherscan.io/api"
    
    public var hostAPIMainNet = "https://api.etherscan.io/api"
    
    private let apiKey = "89AU5UZ71BIQ11XM2Q3EXXWGH597859WRJ"
    
    private let getEtherFromLuva = "/wallet_api/wallets/faucet"
    
    private let getAllContract = "/contract_api/types/all"
    
    private let getAllPublicContract = "/contract_api/contracts/public"
    
    var isEdit = false

    public static let sharedInstance : LuvaServiceData = {
        let instance = LuvaServiceData()
        return instance
    }()
    
    public func taskGetBalanceFromRinkeby(address: String, action: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let parameter = ["module":"account","action": action,"address":address,"tag":"latest","apikey":apiKey] as [String: Any]
        Alamofire.SessionManager.default.request(hostAPIRinkeby, method: .get,parameters: parameter).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                if let result = response.result.value {
                    if action == "balance" {
                        let json = JSON(result)
                        let balance = json["result"].stringValue
                        taskCompletionSource.set(result: balance as AnyObject)
                    } else {
                        let json = JSON(result)
                        let data = json.dictionaryValue["result"]!
                        var listAccount:[MultiBalanceModel] = []
                        for account in data.array! {
                            let model = MultiBalanceModel(json: account)
                            listAccount.append(model)
                        }
                        taskCompletionSource.set(result: listAccount as AnyObject)
                    }
                }
            }

            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetBalanceFromMainnet(address: String, action: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let parameter = ["module":"account","action": action,"address":address,"tag":"latest","apikey":apiKey] as [String: Any]
        Alamofire.SessionManager.default.request(hostAPIMainNet, method: .get,parameters: parameter).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                if let result = response.result.value {
                    if action == "balance" {
                        let json = JSON(result)
                        let balance = json["result"].stringValue
                        taskCompletionSource.set(result: balance as AnyObject)
                    } else {
                        let json = JSON(result)
                        let data = json.dictionaryValue["result"]!
                        var listAccount:[MultiBalanceModel] = []
                        for account in data.array! {
                            let model = MultiBalanceModel(json: account)
                            listAccount.append(model)
                        }
                        taskCompletionSource.set(result: listAccount as AnyObject)
                    }
                }
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetHistoryFromRinkeby(address: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let parameter = ["module":"account","action":"txlist","address":address,"startblock":"0","endblock":"99999999","sort":"asc","apikey":apiKey] as [String: Any]
        Alamofire.SessionManager.default.request(hostAPIRinkeby, method: .get,parameters: parameter).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                if let result = response.result.value {
                    let json = JSON(result)
                    let data = json.dictionaryValue["result"]!
                    var listHistory:[HistoryEthModel] = []
                    for history in data.array! {
                        let model = HistoryEthModel(json: history)
                        listHistory.append(model)
                    }
                    taskCompletionSource.set(result: listHistory as AnyObject)
                }
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetHistoryFromMainnet(address: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let parameter = ["module":"account","action":"txlist","address":address,"startblock":"0","endblock":"99999999","sort":"asc","apikey":apiKey] as [String: Any]
        Alamofire.SessionManager.default.request(hostAPIMainNet, method: .get,parameters: parameter).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                if let result = response.result.value {
                    let json = JSON(result)
                    let data = json.dictionaryValue["result"]!
                    var listHistory:[HistoryEthModel] = []
                    for history in data.array! {
                        let model = HistoryEthModel(json: history)
                        listHistory.append(model)
                    }
                    taskCompletionSource.set(result: listHistory as AnyObject)
                }
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetEtherFromLuva(address: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPIDApp, getEtherFromLuva)
        let parameter = ["address":address] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter,encoding:JSONEncoding.default).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                if let result = response.result.value {
                    let json = JSON(result)
                    let balance = json["data"]["ether"].stringValue
                    taskCompletionSource.set(result: balance as AnyObject)
                }
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }

}
