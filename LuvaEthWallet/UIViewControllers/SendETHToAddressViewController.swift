//
//  SendETHToAddressViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/17/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//
import UIKit
import web3swift
import Eureka
import EZAlertController
import SwiftKeychainWrapper
import PKHUD

class SendETHToAddressViewController: BaseViewController {
    
    @IBOutlet weak var bottomContriansToLabel: NSLayoutConstraint!
    
    @IBOutlet weak var topContrainsToLabel: NSLayoutConstraint!
    
    @IBOutlet weak var lblBottomCheckPolyci: UILabel!
    
    @IBOutlet weak var lblCheckPolyci: UILabel!
    
    @IBOutlet weak var lblPolyci: UILabel!
    
    @IBOutlet weak var btnPolyci: UIButton!
    
    @IBOutlet weak var lblBottomAmounts: UILabel!
    
    @IBOutlet weak var lblCheckAmounts: UILabel!
    
    @IBOutlet weak var lblAmounts: UILabel!
    
    @IBOutlet weak var txtAmounts: UITextField!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    
    @IBOutlet weak var imgPolicy: UIImageView!
    
    @IBOutlet weak var mtView: MTSlideToOpenView!
    
    var address = ""
    
    var isCheckBox = false
    
    var walletEth: WalletEthModel!
    
    var web3 = Web3.InfuraRinkebyWeb3()
    
    var amounts = ""
    
    var balance = ""
    
    var balanceString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblAmounts.text = "ETH Number".localizedString()
        mtView.sliderViewTopDistance = 0
        mtView.sliderCornerRadious = 28
        mtView.showSliderText = true
        mtView.defaultLabelText = "Slide to transfer".localizedString()
        mtView.sliderTextLabel.text = "Slide to transfer".localizedString()
        mtView.defaultThumbnailColor = BaseViewController.MainColor
        mtView.defaultSlidingColor = BaseViewController.MainColor
        mtView.defaultSliderBackgroundColor = UIColor(red:0.88, green:1, blue:0.98, alpha:1.0)
        mtView.delegate = self
        mtView.thumnailImageView.image = UIImage.init(named: "ic_arrow")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        mtView.thumnailImageView.tintColor = .white
        let endString = address.suffix(6)
        let beginString = address.prefix(6)
        lblAddress.text = beginString.uppercased() + "...." + endString.uppercased()
        imgAvatar.setImageForAddress(string: address, circular: true)
        lblCheckPolyci.text = ""
        lblBottomAmounts.isHidden = true
        lblCheckAmounts.text = ""
        lblBottomCheckPolyci.isHidden = true
        topContrainsToLabel.isActive = true
        bottomContriansToLabel.isActive = false
        view.layoutIfNeeded()
        imgPolicy.image = UIImage.init(named: "ic_check")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgPolicy.tintColor = BaseViewController.MainColor
        btnPolyci.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnPolyci.isSelected = false
        lblPolyci.text = "I have read and agree to the Terms of Use.".localizedString()
        HUD.show(.labeledProgress(title: "", subtitle: "Loading...".localizedString()))
        initWeb3()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func tappedCheckPolicy(_ sender: Any) {
        btnPolyci.isSelected = !btnPolyci.isSelected
        if btnPolyci.isSelected {
            imgPolicy.image = UIImage.init(named: "ic_checked")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgPolicy.tintColor = BaseViewController.MainColor
            isCheckBox = true
            lblCheckPolyci.text = ""
            lblBottomCheckPolyci.isHidden = true
        } else {
            isCheckBox = false
            imgPolicy.image = UIImage.init(named: "ic_check")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgPolicy.tintColor = BaseViewController.MainColor
        }
    }
    
    func initWeb3() {
        DispatchQueue.main.async {
            let data = self.walletEth.data
            let keystoreManager: KeystoreManager
            if self.walletEth.isHD {
                let keystore = BIP32Keystore(data!)!
                keystoreManager = KeystoreManager([keystore])
            } else {
                let keystore = EthereumKeystoreV3(data!)!
                keystoreManager = KeystoreManager([keystore])
            }
            self.web3.addKeystoreManager(keystoreManager)
            let walletAddress = EthereumAddress(self.walletEth.address)! // Address which balance we want to know
            let balanceResult = try! self.web3.eth.getBalance(address: walletAddress)
            self.balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 5)!
            HUD.hide()
            self.txtAmounts.becomeFirstResponder()
        }
    }
}

extension SendETHToAddressViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.amounts = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        return true
    }
}


extension SendETHToAddressViewController: MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        view.endEditing(true)
        if isCheckBox {
            if self.amounts != "" && self.amounts != "0" {
                if Float(self.amounts)! < Float(self.balance)! {
                    if (SettingApp.sharedInstance.enablePassCode == .on) {
                        presentToLockScreenViewController(delegate: self)
                    } else {
                        print("amounts: \(amounts)")
                        print("balance: \(balance)")
                        HUD.show(.labeledProgress(title: "", subtitle: "Transferring Eth...".localizedString()))
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            if let password = KeychainWrapper.standard.string(forKey:self.walletEth.address) {
                                let value: String = self.amounts
                                let walletAddress = EthereumAddress(self.walletEth.address)! // Your wallet address
                                let toAddress = EthereumAddress(self.address)!
                                let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
                                let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                                var options = TransactionOptions.defaultOptions
                                options.value = amount
                                options.from = walletAddress
                                options.gasPrice = .automatic
                                options.gasLimit = .automatic
                                let tx = contract.write(
                                    "fallback",
                                    parameters: [AnyObject](),
                                    extraData: Data(),
                                    transactionOptions: options)!
                                let result = try! tx.send(password: password,transactionOptions: options)
                                print(result.hash)
                                if result.hash != "" {
                                    if let model = WalletEthModel.search(withWhere: ["address": self.walletEth.address])?.firstObject as? WalletEthModel {
                                        if model.listRecents.count > 0 {
                                            for address in model.listRecents {
                                                if address.uppercased() != self.address.uppercased() {
                                                    model.listRecents.append(self.address)
                                                }
                                            }
                                        } else {
                                            model.listRecents.append(self.address)
                                        }
                                        model.saveToDB()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20)) {
                                        let walletAddress = EthereumAddress(self.walletEth.address)! // Address which balance we want to know
                                        let balanceResult = try! self.web3.eth.getBalance(address: walletAddress)
                                        let newBalance = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 5)!
                                        HUD.hide()
                                        if newBalance == self.balanceString {
                                            for controller in self.navigationController!.viewControllers as Array {
                                                if controller.isKind(of: WalletEthViewController.self) {
                                                    self.navigationController!.popToViewController(controller, animated: true)
                                                    
                                                    Broadcaster.notify(LuvaEthWalletNotificationDelegate.self) {
                                                        $0.notifyTransactionPending()
                                                    }
                                                    break
                                                }
                                            }
                                        } else {
                                            for controller in self.navigationController!.viewControllers as Array {
                                                if controller.isKind(of: WalletEthViewController.self) {
                                                    self.navigationController!.popToViewController(controller, animated: true)
                                                    
                                                    Broadcaster.notify(LuvaEthWalletNotificationDelegate.self) {
                                                        $0.notifySendEthSuccess(balance: newBalance)
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    HUD.hide()
                                    sender.resetStateWithAnimation(true)
                                    HUD.flash(.label("Something went wrong. Please try again.".localizedString()), delay: 1.0)
                                }
                            }
                        }
                    }
                } else {
                    EZAlertController.alert("", message: "Transfer request failed due to insufficient ETH.".localizedString(), acceptMessage: "Ok".localizedString()) {
                        self.dismiss(animated: true, completion: nil)
                        sender.resetStateWithAnimation(true)
                    }
                }
            } else {
                EZAlertController.alert("", message: "Please enter the ETH number.".localizedString(), acceptMessage: "Ok".localizedString()) {
                    self.dismiss(animated: true, completion: nil)
                    sender.resetStateWithAnimation(true)
                }
            }
        } else {
            lblBottomCheckPolyci.isHidden = false
            lblCheckPolyci.text = "Required check policy".localizedString()
            sender.resetStateWithAnimation(true)
        }
    }
}
extension SendETHToAddressViewController: LockScreenViewControllerDelegate {
    
    func didInPutPassCodeSuccess(_ pass: String) {
        
    }
    
    func didConfirmPassCode() {
        
    }
    
    func didChangePassCode() {
        
    }
    
    func didPopViewController() {
        
    }
    
    func didConfirmPassCodeSuccess() {
        dismiss(animated: true, completion: nil)
        HUD.show(.labeledProgress(title: "", subtitle: "Transferring Eth...".localizedString()))
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if let password = KeychainWrapper.standard.string(forKey:self.walletEth.address) {
                let value: String = self.amounts
                let walletAddress = EthereumAddress(self.walletEth.address)! // Your wallet address
                let toAddress = EthereumAddress(self.address)!
                let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
                let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
                var options = TransactionOptions.defaultOptions
                options.value = amount
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                let tx = contract.write(
                    "fallback",
                    parameters: [AnyObject](),
                    extraData: Data(),
                    transactionOptions: options)!
                let result = try! tx.send(password: password,transactionOptions: options)
                print(result.hash)
                if result.hash != "" {
                    if let model = WalletEthModel.search(withWhere: ["address": self.walletEth.address])?.firstObject as? WalletEthModel {
                        if model.listRecents.count > 0 {
                            for address in model.listRecents {
                                if address.uppercased() != self.address.uppercased() {
                                    model.listRecents.append(self.address)
                                }
                            }
                        } else {
                            model.listRecents.append(self.address)
                        }
                        model.saveToDB()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20)) {
                        let walletAddress = EthereumAddress(self.walletEth.address)! // Address which balance we want to know
                        let balanceResult = try! self.web3.eth.getBalance(address: walletAddress)
                        let newBalance = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 5)!
                        HUD.hide()
                        if newBalance == self.balanceString {
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: WalletEthViewController.self) {
                                    self.navigationController!.popToViewController(controller, animated: true)
                                    
                                    Broadcaster.notify(LuvaEthWalletNotificationDelegate.self) {
                                        $0.notifyTransactionPending()
                                    }
                                    break
                                }
                            }
                        } else {
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: WalletEthViewController.self) {
                                    self.navigationController!.popToViewController(controller, animated: true)
                                    
                                    Broadcaster.notify(LuvaEthWalletNotificationDelegate.self) {
                                        $0.notifySendEthSuccess(balance: newBalance)
                                    }
                                    break
                                }
                            }
                        }
                    }
                } else {
                    HUD.hide()
                    self.mtView.resetStateWithAnimation(true)
                    HUD.flash(.label("Something went wrong. Please try again.".localizedString()), delay: 1.0)
                }
            }
        }
    }
    
    func didDisablePassCodeSuccess() {
        
    }    
}
