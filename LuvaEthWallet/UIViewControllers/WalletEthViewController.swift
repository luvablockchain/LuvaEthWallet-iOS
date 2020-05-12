//
//  WalletEthViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import web3swift
import BigInt
import EZAlertController
import SwiftyJSON
import SwiftKeychainWrapper

class WalletEthViewController: BaseViewController {
    
    @IBOutlet weak var lblHistory: UILabel!
    
    @IBOutlet weak var lblTitleSend: UILabel!
    
    @IBOutlet weak var lblTitleDeposit: UILabel!
    
    @IBOutlet weak var viewSendEth: UIView!
    
    @IBOutlet weak var viewDeposit: UIView!
    
    @IBOutlet weak var imgCircle: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var viewType: UIView!
    
    @IBOutlet weak var lblPublicKey: UILabel!
    
    @IBOutlet weak var btnRemove: UIButton!
    
    @IBOutlet weak var imgCopy: UIImageView!
    
    @IBOutlet weak var viewPublicKey: UIView!
    
    @IBOutlet weak var lblSend: UILabel!
    
    @IBOutlet weak var lblDeposit: UILabel!
    
    @IBOutlet weak var lblEth: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var btnRight: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var walletEth: WalletEthModel!
    
    var listHistory: [HistoryEthModel] = []
    
    var listWallet: [WalletEthModel] = []
    
    var multiAddress = ""
    
    var address = ""
    
    var listAccount: [MultiBalanceModel] = []
    
    var socketProvider: InfuraWebsocketProvider? = nil
    
    var shouldShowLockScreen = true
    
    var timeBackGround:Date?
    
    var web3 = Web3.InfuraRinkebyWeb3()
    
    var balance = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SettingApp.sharedInstance.enablePassCode == .on &&         SettingApp.sharedInstance.accountType == .normal{
            presentToLockScreenViewController(delegate: self)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification
            , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification
            , object: nil)
        Broadcaster.register(LuvaEthWalletNotificationDelegate.self, observer: self)
        lblTitleSend.text = "Send".localizedString()
        lblHistory.text = "Transaction History".localizedString()
        lblTitleDeposit.text = "Deposit".localizedString()
        WalletEthModel.getListWalletEthFromDB{ (result) in
            let listSorted = result.sorted(by: { (first, second) -> Bool in
                return second.useDate.isEarly(first.useDate)
            })
            self.address = listSorted[0].address
            self.listWallet = listSorted
            if let model = WalletEthModel.search(withWhere: ["address": self.address])?.firstObject as? WalletEthModel {
                model.useDate = Date()
                model.saveToDB()
                self.walletEth = model
            }
        }
        let url = getDocumentsDirectory()
        print(url)
        btnMore.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        imgCopy.image = UIImage(named: "ic_copy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgCopy.tintColor = BaseViewController.MainColor
        viewPublicKey.layer.cornerRadius = 5
        viewType.layer.cornerRadius = viewType.frame.size.height/2
        viewType.layer.borderWidth = 1
        viewType.layer.borderColor = UIColor.lightGray.cgColor
        imgCircle.image = UIImage(named: "ic_circle-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.imgCircle.tintColor = UIColor.init(rgb: 0x00bfbf)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        btnRemove.isHidden = true
        viewDeposit.layer.cornerRadius = 5
        viewDeposit.layer.borderWidth = 1
        viewDeposit.layer.borderColor = UIColor.lightGray.cgColor
        viewSendEth.layer.cornerRadius = 5
        viewSendEth.layer.borderWidth = 1
        viewSendEth.layer.borderColor = UIColor.lightGray.cgColor
        let endString = walletEth.address.suffix(8)
        let beginString = walletEth.address.prefix(8)
        lblPublicKey.text = beginString + "...." + endString
        lblName.text = walletEth.name
        self.lblEth.text = "0 ETH"
        WalletEthModel.getListWalletEthFromDB { (result) in
            self.multiAddress = self.walletEth.address
            if result.count > 1 {
                for address in result {
                    if address.address != self.walletEth.address {
                        self.multiAddress = self.multiAddress + "," + address.address
                    }
                }
            }
        }
        print(multiAddress)
        if SettingApp.sharedInstance.typeNetwork == .main {
            self.lblTitle.text = "Main Ethereum Network".localizedString()
            self.imgCircle.image = UIImage(named: "ic_circle-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.imgCircle.tintColor = UIColor.init(rgb: 0x00bfbf)
            LuvaServiceData.sharedInstance.taskGetBalanceFromMainnet(address: walletEth.address,action: "balance").continueOnSuccessWith(continuation: { task in
                let balance = task as! String
                if balance == "0" {
                    self.lblEth.text = "0 ETH"
                    self.balance = "0"
                } else {
                    let myFloat = (balance as NSString).floatValue
                    let newBalance = myFloat/1000000000000000000.0
                    self.lblEth.text = String(newBalance) + " ETH"
                    self.balance = String(newBalance)
                }
            }).continueOnErrorWith(continuation: { error in
                print(error)
            })
            DispatchQueue.main.async {
                LuvaServiceData.sharedInstance.taskGetHistoryFromMainnet(address: self.walletEth.address).continueOnSuccessWith(continuation: { task in
                    let result = task as! [HistoryEthModel]
                    self.listHistory = result.sorted(by: { (first, second) -> Bool in
                        return second.timeStamp!.isEarly(first.timeStamp!)
                    })
                    self.tableView.reloadData()
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
                LuvaServiceData.sharedInstance.taskGetBalanceFromMainnet(address: self.multiAddress,action: "balancemulti").continueOnSuccessWith(continuation: { task in
                    self.listAccount = task as! [MultiBalanceModel]
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
            }
            
        } else {
            self.lblTitle.text = "Rinkeby Test Network".localizedString()
            self.imgCircle.image = UIImage(named: "ic_circle-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.imgCircle.tintColor = UIColor.init(rgb: 0x7f007f)
            LuvaServiceData.sharedInstance.taskGetBalanceFromRinkeby(address: walletEth.address,action: "balance").continueOnSuccessWith(continuation: { task in
                let balance = task as! String
                if balance == "0" {
                    self.lblEth.text = "0 ETH"
                    self.balance = "0"
                } else {
                    let myFloat = (balance as NSString).floatValue
                    let newBalance = myFloat/1000000000000000000.0
                    self.lblEth.text = String(newBalance) + " ETH"
                    self.balance = String(newBalance)
                }
            }).continueOnErrorWith(continuation: { error in
                print(error)
            })
            DispatchQueue.main.async {
                LuvaServiceData.sharedInstance.taskGetHistoryFromRinkeby(address: self.walletEth.address).continueOnSuccessWith(continuation: { task in
                    let result = task as! [HistoryEthModel]
                    self.listHistory = result.sorted(by: { (first, second) -> Bool in
                        return second.timeStamp!.isEarly(first.timeStamp!)
                    })
                    self.tableView.reloadData()
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
                LuvaServiceData.sharedInstance.taskGetBalanceFromRinkeby(address: self.multiAddress,action: "balancemulti").continueOnSuccessWith(continuation: { task in
                    self.listAccount = task as! [MultiBalanceModel]
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
                
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if LuvaServiceData.sharedInstance.isEdit == true {
            if let model = WalletEthModel.search(withWhere: ["address": walletEth.address])?.firstObject as? WalletEthModel {
                lblName.text = model.name
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func presentLockScreen() {
        if let topViewController = UIApplication.topViewController() {
            topViewController.presentToLockScreenViewController(delegate: self)
        }
    }
    
    @objc func willEnterForeground() {
        let currentDate = Date()
        if let time = timeBackGround {
            let timeInterval  =  currentDate.timeIntervalSince1970 - time.timeIntervalSince1970
            if Int(timeInterval) < SettingApp.sharedInstance.configType.second {
                shouldShowLockScreen = false
            }
        }
    }
    
    @objc func didEnterBackground() {
        if SettingApp.sharedInstance.enablePassCode == .on {
            SettingApp.sharedInstance.accountType = .normal
            SettingApp.sharedInstance.saveSettingAppToDB()
            self.timeBackGround = Date()
            let second = SettingApp.sharedInstance.configType.second
            shouldShowLockScreen = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
                if self.shouldShowLockScreen {
                    self.presentLockScreen()
                }
            }
        }
    }
    
    
    @IBAction func tappedCopyAddressEth(_ sender: Any) {
        UIPasteboard.general.string = walletEth.address
        HUD.flash(.success, delay: 1.0)
    }
    
    @IBAction func tappedRemoveMenuWalletEth(_ sender: Any) {
        MenuWalletEthView.removeMenuWalletEthView(parent: self.view)
        btnRemove.isHidden = true
        btnRight.isSelected = false
    }
    
    @IBAction func tappedOpenRightMenu(_ sender: Any) {
        btnRight.isSelected = !btnRight.isSelected
        if btnRight.isSelected {
            MenuWalletEthView.initMenuWalletEthView(parent: self.view,button: self.btnRight,delegate: self,address: self.walletEth.address,listAccount: self.listAccount)
            btnRemove.isHidden = false
        } else {
            MenuWalletEthView.removeMenuWalletEthView(parent: self.view)
            btnRemove.isHidden = true
        }
    }
    
    @IBAction func tappedChangeNetwork(_ sender: Any) {
        FTPopOverMenuConfiguration.default().menuWidth = 220
        FTPopOverMenuConfiguration.default().menuRowHeight = 45
        FTPopOverMenuConfiguration.default().tintColor = UIColor.black.withAlphaComponent(0.8)
        FTPopOverMenuConfiguration.default().borderWidth = 0.0
        FTPopOverMenuConfiguration.default()?.textColor = .white
        FTPopOverMenuConfiguration.default()?.selectedTextColor = .red
        FTPopOverMenuConfiguration.default().textFont = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        FTPopOverMenuConfiguration.default().ignoreImageOriginalColor = false
        FTPopOverMenuConfiguration.default().selectedCellBackgroundColor = UIColor.init(rgb: 0xFFD700)
        
        FTPopOverMenu.show(forSender: sender as? UIView, withMenuArray: ["Main Ethereum Network","Rinkeby Test Network"], imageArray: ["ic_main","ic_test"], doneBlock: { (index) in
            if index == 0 {
                if SettingApp.sharedInstance.typeNetwork == .test {
                    self.lblTitle.text = "Main Ethereum Network"
                    self.imgCircle.image = UIImage(named: "ic_circle-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                    self.imgCircle.tintColor = UIColor.init(rgb: 0x00bfbf)
                    SettingApp.sharedInstance.typeNetwork = .main
                    SettingApp.sharedInstance.saveSettingAppToDB()
                    LuvaServiceData.sharedInstance.taskGetBalanceFromMainnet(address: self.walletEth.address, action: "balance").continueOnSuccessWith(continuation: { task in
                        let balance = task as! String
                        if balance == "0" {
                            self.lblEth.text = "0 ETH"
                            self.balance = "0"
                            
                        } else {
                            let myFloat = (balance as NSString).floatValue
                            let newBalance = myFloat/1000000000000000000.0
                            self.lblEth.text = String(newBalance) + " ETH"
                            self.balance = String(newBalance)
                        }
                    }).continueOnErrorWith(continuation: { error in
                        print(error)
                    })
                    DispatchQueue.main.async {
                        LuvaServiceData.sharedInstance.taskGetHistoryFromMainnet(address: self.walletEth.address).continueOnSuccessWith(continuation: { task in
                            let result = task as! [HistoryEthModel]
                            self.listHistory = result.sorted(by: { (first, second) -> Bool in
                                return second.timeStamp!.isEarly(first.timeStamp!)
                            })
                            self.tableView.reloadData()
                        }).continueOnErrorWith(continuation: { error in
                            print(error)
                        })
                        LuvaServiceData.sharedInstance.taskGetBalanceFromMainnet(address: self.multiAddress,action: "balancemulti").continueOnSuccessWith(continuation: { task in
                            self.listAccount = task as! [MultiBalanceModel]
                        }).continueOnErrorWith(continuation: { error in
                            print(error)
                        })
                    }
                }
            } else {
                if SettingApp.sharedInstance.typeNetwork == .main {
                    self.lblTitle.text = "Rinkeby Test Network"
                    self.imgCircle.image = UIImage(named: "ic_circle-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                    self.imgCircle.tintColor = UIColor.init(rgb: 0x7f007f)
                    SettingApp.sharedInstance.typeNetwork = .test
                    SettingApp.sharedInstance.saveSettingAppToDB()
                    LuvaServiceData.sharedInstance.taskGetBalanceFromRinkeby(address: self.walletEth.address, action: "balance").continueOnSuccessWith(continuation: { task in
                        let balance = task as! String
                        if balance == "0" {
                            self.lblEth.text = "0 ETH"
                            self.balance = "0"
                        } else {
                            let myFloat = (balance as NSString).floatValue
                            let newBalance = myFloat/1000000000000000000.0
                            self.lblEth.text = String(newBalance) + " ETH"
                            self.balance = String(newBalance)
                        }
                    }).continueOnErrorWith(continuation: { error in
                        print(error)
                    })
                    DispatchQueue.main.async {
                        LuvaServiceData.sharedInstance.taskGetHistoryFromRinkeby(address: self.walletEth.address).continueOnSuccessWith(continuation: { task in
                            let result = task as! [HistoryEthModel]
                            self.listHistory = result.sorted(by: { (first, second) -> Bool in
                                return second.timeStamp!.isEarly(first.timeStamp!)
                            })
                            self.tableView.reloadData()
                        }).continueOnErrorWith(continuation: { error in
                            print(error)
                        })
                        LuvaServiceData.sharedInstance.taskGetBalanceFromRinkeby(address: self.multiAddress,action: "balancemulti").continueOnSuccessWith(continuation: { task in
                            self.listAccount = task as! [MultiBalanceModel]
                        }).continueOnErrorWith(continuation: { error in
                            print(error)
                        })
                        
                    }
                }
            }
        }) {
            print("")
        }
        
    }
    
    @IBAction func tappedDepositButton(_ sender: Any) {
        self.pushDetailsWalletEthViewController(wallet: self.walletEth,isDeposit: true,delegate: self)
    }
    
    @IBAction func tappedSendEthereum(_ sender: Any) {
         pushAddRecipientViewController(listWallet: self.listWallet, model: walletEth, balance: balance)
    }
    
    @IBAction func tappedMoreButton(_ sender: Any) {
        FTPopOverMenuConfiguration.default().menuWidth = 180
        FTPopOverMenuConfiguration.default().menuRowHeight = 45
        FTPopOverMenuConfiguration.default().tintColor = UIColor.black.withAlphaComponent(0.8)
        FTPopOverMenuConfiguration.default().borderWidth = 0.0
        FTPopOverMenuConfiguration.default()?.textColor = .white
        FTPopOverMenuConfiguration.default().textFont = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        FTPopOverMenuConfiguration.default().ignoreImageOriginalColor = true
        FTPopOverMenuConfiguration.default().selectedCellBackgroundColor = UIColor.init(rgb: 0xFFD700)
        FTPopOverMenu.show(forSender: sender as? UIView, withMenuArray: ["View on Etherscan".localizedString(),"Account Details".localizedString(),"Add Custom Token".localizedString()], imageArray: ["ic_expand","ic_infoeth","ic_circleplus"], doneBlock: { (index) in
            if(index == 0) {
                if SettingApp.sharedInstance.typeNetwork == .main {
                    let webVC = SwiftWebVC(urlString: "https://etherscan.io/address/" + self.walletEth.address)
                    webVC.delegate = self
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    webVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(webVC, animated: true)
                } else {
                    let webVC = SwiftWebVC(urlString: "https://rinkeby.etherscan.io/address/" + self.walletEth.address)
                    webVC.delegate = self
                    webVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
            } else if(index == 1) {
                self.pushDetailsWalletEthViewController(wallet: self.walletEth)
            } else if(index == 2) {
                self.pushInfoTokenViewController()
            }
        }) {
            print("")
        }
        
    }
}
extension WalletEthViewController: MenuWalletEthViewDelegate {
    func didSelectWallet(wallet: WalletEthModel,balance: String) {
        if wallet.address == walletEth.address {
            MenuWalletEthView.removeMenuWalletEthView(parent: self.view)
            btnRemove.isHidden = true
            btnRight.isSelected = false
            walletEth = wallet
        } else {
            let endString = wallet.address.suffix(8)
            let beginString = wallet.address.prefix(8)
            lblPublicKey.text = beginString + "...." + endString
            lblName.text = wallet.name
            walletEth = wallet
            if SettingApp.sharedInstance.typeNetwork == .main {
                self.lblTitle.text = "Main Ethereum Network"
                self.imgCircle.image = UIImage(named: "ic_circle-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.imgCircle.tintColor = UIColor.init(rgb: 0x00bfbf)
                if balance == "0" {
                    self.lblEth.text = "0 ETH"
                    self.balance = "0"
                } else {
                    let myFloat = (balance as NSString).floatValue
                    let newBalance = myFloat/1000000000000000000.0
                    self.lblEth.text = String(newBalance) + " ETH"
                    self.balance = String(newBalance)
                }
                LuvaServiceData.sharedInstance.taskGetHistoryFromMainnet(address: wallet.address).continueOnSuccessWith(continuation: { task in
                    let result = task as! [HistoryEthModel]
                    self.listHistory = result.sorted(by: { (first, second) -> Bool in
                        return second.timeStamp!.isEarly(first.timeStamp!)
                    })
                    self.tableView.reloadData()
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
                
            } else {
                self.lblTitle.text = "Rinkeby Test Network"
                self.imgCircle.image = UIImage(named: "ic_circle-1")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.imgCircle.tintColor = UIColor.init(rgb: 0x7f007f)
                if balance == "0" {
                    self.lblEth.text = "0 ETH"
                    self.balance = "0"
                } else {
                    let myFloat = (balance as NSString).floatValue
                    let newBalance = myFloat/1000000000000000000.0
                    self.lblEth.text = String(newBalance) + " ETH"
                    self.balance = String(newBalance)
                }
                LuvaServiceData.sharedInstance.taskGetHistoryFromRinkeby(address: wallet.address).continueOnSuccessWith(continuation: { task in
                    let result = task as! [HistoryEthModel]
                    self.listHistory = result.sorted(by: { (first, second) -> Bool in
                        return second.timeStamp!.isEarly(first.timeStamp!)
                    })
                    self.tableView.reloadData()
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
            }
            MenuWalletEthView.removeMenuWalletEthView(parent: self.view)
            btnRemove.isHidden = true
            btnRight.isSelected = false
        }
        if let model = WalletEthModel.search(withWhere: ["address": wallet.address])?.firstObject as? WalletEthModel {
            model.useDate = Date()
            model.saveToDB()
        }
    }
    
    func didSelectCreateAccountEthereum() {
        MenuWalletEthView.removeMenuWalletEthView(parent: self.view)
        btnRemove.isHidden = true
        btnRight.isSelected = false
        pushMnemonicGenerationViewController(isAddAccount: true)
    }
    
    func didSelectImportAccountEthereum() {
        MenuWalletEthView.removeMenuWalletEthView(parent: self.view)
        btnRemove.isHidden = true
        btnRight.isSelected = false
        pushImportWalletEthViewController(isImport: true)
    }
}

extension WalletEthViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "historyEthereumTableViewCell") as! HistoryEthereumTableViewCell
        cell.lblDate.text = listHistory[indexPath.row].timeStamp?.shortDateTime
        let myFloat = (listHistory[indexPath.row].amount as NSString).floatValue
        let newBalance = myFloat/1000000000000000000.0
        let number = NSNumber(value: newBalance)
        if listHistory[indexPath.row].fromAddress.lowercased() == walletEth.address.lowercased()  {
            cell.lblAmount.text = "-" + "\(number.decimalValue)" + " ETH"
            if listHistory[indexPath.row].input == "0x"{
                cell.lblTitle.text = "Transfer Ethereum".localizedString()
            } else {
                cell.lblTitle.text = "Interact with SC".localizedString()
            }
        } else {
            cell.lblAmount.text = "+" + "\(number.decimalValue)" + " ETH"
            cell.lblTitle.text = "Receive Ethereum".localizedString()
        }
        if listHistory[indexPath.row].isError == 0 {
            cell.lblStatus.text = "CONFIRMED"
            cell.lblStatus.textColor = BaseViewController.MainColor
            cell.viewStatus.backgroundColor = UIColor.init(rgb: 0x54FF9F)
        } else {
            cell.lblStatus.text = "FAILED"
            cell.lblStatus.textColor = .red
            cell.viewStatus.backgroundColor = UIColor.init(rgb: 0xFFC1C1)
        }
        cell.imgAvatar.image = LetterImageGenerator.imageWith(name: walletEth.name)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SettingApp.sharedInstance.typeNetwork == .main {
            let webVC = SwiftWebVC(urlString: "https://etherscan.io/tx/" + listHistory[indexPath.row].hashTransaction)
            webVC.delegate = self
            webVC.hidesBottomBarWhenPushed = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(webVC, animated: true)
        } else {
            let webVC = SwiftWebVC(urlString: "https://rinkeby.etherscan.io/tx/" + listHistory[indexPath.row].hashTransaction)
            webVC.delegate = self
            webVC.hidesBottomBarWhenPushed = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
}

extension WalletEthViewController: SwiftWebVCDelegate {
    
    func didStartLoading() {
        HUD.show(.labeledProgress(title: nil, subtitle: "Loading...".localizedString()))
    }
    
    func didFinishLoading(success: Bool) {
        HUD.hide()
    }
    
}

extension WalletEthViewController: LockScreenViewControllerDelegate {
    
    func didChangePassCode() {
        
    }
    
    func didConfirmPassCodeSuccess() {
        dismiss(animated: true, completion: nil)
    }
    
    func didInPutPassCodeSuccess(_ pass: String) {
        
    }
    
    func didConfirmPassCode() {
        
    }
    
    func didPopViewController() {
        
    }
    
    func didDisablePassCodeSuccess() {
        
    }
}

extension WalletEthViewController: LuvaEthWalletNotificationDelegate {
    func notifyTransactionPending() {
        HUD.flash(.label("The transaction is in the approval process.".localizedString()), delay: 1.0)
    }
    
    func notifySendEthSuccess(balance: String) {
        if SettingApp.sharedInstance.typeNetwork == .main {
            self.lblEth.text = balance + " ETH"
            self.balance = balance
            HUD.flash(.label("Transferred Eth successfully.".localizedString()), delay: 1.0)
            DispatchQueue.main.async {
                LuvaServiceData.sharedInstance.taskGetBalanceFromMainnet(address: self.walletEth.address, action: "balance").continueOnSuccessWith(continuation: { task in
                    let newBalance = task as! String
                    for (index, object) in self.listAccount.enumerated() {
                        if object.account.uppercased() == self.walletEth.address.uppercased() {
                            self.listAccount[index].balance = newBalance
                        }
                    }
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })

                LuvaServiceData.sharedInstance.taskGetHistoryFromMainnet(address: self.walletEth.address).continueOnSuccessWith(continuation: { task in
                    let result = task as! [HistoryEthModel]
                    self.listHistory = result.sorted(by: { (first, second) -> Bool in
                        return second.timeStamp!.isEarly(first.timeStamp!)
                    })
                    self.tableView.reloadData()
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
            }
        } else {
            self.lblEth.text = balance + " ETH"
            self.balance = balance
            HUD.flash(.label("Transferred Eth successfully.".localizedString()), delay: 1.0)
            DispatchQueue.main.async {
                LuvaServiceData.sharedInstance.taskGetBalanceFromRinkeby(address: self.walletEth.address, action: "balance").continueOnSuccessWith(continuation: { task in
                    let newBalance = task as! String
                    for (index, object) in self.listAccount.enumerated() {
                        if object.account.uppercased() == self.walletEth.address.uppercased() {
                            self.listAccount[index].balance = newBalance
                        }
                    }
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
                LuvaServiceData.sharedInstance.taskGetHistoryFromRinkeby(address: self.walletEth.address).continueOnSuccessWith(continuation: { task in
                    let result = task as! [HistoryEthModel]
                    self.listHistory = result.sorted(by: { (first, second) -> Bool in
                        return second.timeStamp!.isEarly(first.timeStamp!)
                    })
                    self.tableView.reloadData()
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
            }
        }
    }
}
extension WalletEthViewController: DetailsWalletEthViewControllerDelegate {
    func didReceiveTestNetEtherSuccess(balance: String) {
        DispatchQueue.main.async {
            if balance != "" {
                self.lblEth.text = balance + " ETH"
                self.balance = balance
                for account in self.listAccount {
                    if account.account == self.walletEth.address {
                        let amount = Double(balance)! * 1000000000000000000.0
                        account.balance = String(amount)
                    }
                }
            }
            LuvaServiceData.sharedInstance.taskGetHistoryFromRinkeby(address: self.walletEth.address).continueOnSuccessWith(continuation: { task in
                let result = task as! [HistoryEthModel]
                self.listHistory = result.sorted(by: { (first, second) -> Bool in
                    return second.timeStamp!.isEarly(first.timeStamp!)
                })
                self.tableView.reloadData()
            }).continueOnErrorWith(continuation: { error in
                print(error)
            })
        }

    }
}
