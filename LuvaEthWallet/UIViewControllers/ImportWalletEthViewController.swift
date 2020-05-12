//
//  ImportWalletEthViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import PKHUD
import web3swift
import secp256k1
import SwiftKeychainWrapper

struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

struct HDKey {
    let name: String?
    let address: String
}

enum ImportType: Int {
    case privateKey = 0, mnemonic = 1
}


class ImportWalletEthViewController: BaseViewController {
    
    @IBOutlet weak var imgShow: UIImageView!
    
    @IBOutlet weak var btnShowPass: UIButton!
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var txtMnemonic: UITextView!
    
    @IBOutlet weak var lblConfirmPass: UILabel!
    
    @IBOutlet weak var lblCheckPass: UILabel!
    
    @IBOutlet weak var viewMnemonic: UIView!
    
    @IBOutlet weak var txtConfirmPass: HoshiTextField!
    
    @IBOutlet weak var txtNewPass: HoshiTextField!
    
    var type: ImportType = .privateKey
    
    var isCheckPass = false
    
    var isCheckLength = false
    
    var isCheckMnemonic = false
    
    var isImport = false
    
    var countWallet = 0
    
    var mnemonic = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtNewPass.placeholder = " New Password".localizedString()
        txtNewPass.isSecureTextEntry = true
        txtConfirmPass.placeholder = " Confirm Password".localizedString()
        txtConfirmPass.isSecureTextEntry = true
        btnConfirm.setTitle("Import".localizedString(), for: .normal)
        btnConfirm.layer.cornerRadius = 5
        lblConfirmPass.text = ""
        lblCheckPass.text = ""
        btnConfirm.isEnabled = false
        btnConfirm.backgroundColor = .lightGray
        imgShow.image = UIImage.init(named: "ic_invisible")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgShow.tintColor = BaseViewController.MainColor
        btnShowPass.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnShowPass.isSelected = false
        segmentedControl.setTitle("Private Key", forSegmentAt: 0)
        segmentedControl.setTitle("Mnemonic", forSegmentAt: 1)
        WalletEthModel.getListWalletEthFromDB { (result) in
            self.countWallet = result.count
        }
    }
    
    override func viewDidLayoutSubviews() {
        setDashBorders(for: viewMnemonic, with: BaseViewController.MainColor.cgColor)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    @IBAction func tappedShowPassword(_ sender: Any) {
        btnShowPass.isSelected = !btnShowPass.isSelected
        if btnShowPass.isSelected {
            imgShow.image = UIImage.init(named: "ic_show")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgShow.tintColor = BaseViewController.MainColor
            txtNewPass.isSecureTextEntry = false
        } else {
            imgShow.image = UIImage.init(named: "ic_invisible")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgShow.tintColor = BaseViewController.MainColor
            txtNewPass.isSecureTextEntry = true
        }
    }
    
    @IBAction func tappedConfirmButton(_ sender: Any) {
        self.view.endEditing(true)
        if isImport {
            let password = self.txtNewPass.text
            let key = self.txtMnemonic.text
            if type == .mnemonic {
                do {
                    let keystore = try BIP32Keystore(
                        mnemonics: self.mnemonic,
                        password: password!,
                        mnemonicsPassword: "",
                        language: .english)!
                    let name = "Account " + String(countWallet + 1)
                    let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                    let address = keystore.addresses!.first!.address
                    if (WalletEthModel.search(withWhere: ["address":address])?.firstObject as? WalletEthModel) != nil {
                        HUD.flash(.label("Account already exists.".localizedString()), delay: 1.0)
                    } else {
                        WalletEthModel.sharedInstance.address = address
                        WalletEthModel.sharedInstance.data = keyData
                        WalletEthModel.sharedInstance.name = name
                        WalletEthModel.sharedInstance.isHD = true
                        WalletEthModel.sharedInstance.createDate = Date()
                        WalletEthModel.sharedInstance.useDate = Date()
                        KeychainWrapper.standard.set(password!, forKey: address)
                        WalletEthModel.sharedInstance.saveConfigToDB()
                        self.pushMainTabbarViewController()
                    }
                } catch {
                    HUD.flash(.label("The string is not valid.".localizedString()), delay: 1.0)
                }
            } else {
                let formattedKey = key!.trimmingCharacters(in: .whitespacesAndNewlines)
                if let dataKey = Data.fromHex(formattedKey) {
                    if SECP256K1.verifyPrivateKey(privateKey: dataKey) {
                        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password!)!
                        let name = "Account " + String(countWallet + 1)
                        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                        let address = keystore.addresses!.first!.address
                        if (WalletEthModel.search(withWhere: ["address":address])?.firstObject as? WalletEthModel) != nil {
                            HUD.flash(.label("The string is not valid.".localizedString()), delay: 1.0)
                        } else {
                            WalletEthModel.sharedInstance.address = address
                            WalletEthModel.sharedInstance.data = keyData
                            WalletEthModel.sharedInstance.name = name
                            WalletEthModel.sharedInstance.isHD = false
                            WalletEthModel.sharedInstance.createDate = Date()
                            WalletEthModel.sharedInstance.useDate = Date()
                            KeychainWrapper.standard.set(password!, forKey: address)
                            WalletEthModel.sharedInstance.saveConfigToDB()
                            self.pushMainTabbarViewController()
                        }
                    } else {
                        HUD.flash(.label("Something went wrong. Please try again.".localizedString()), delay: 1.0)
                    }
                } else {
                    HUD.flash(.label("Something went wrong. Please try again.".localizedString()), delay: 1.0)
                }
            }
        } else {
            let password = self.txtNewPass.text
            let key = self.txtMnemonic.text
            if type == .mnemonic {
                do {
                    let keystore = try BIP32Keystore(
                        mnemonics: self.mnemonic,
                        password: password!,
                        mnemonicsPassword: "",
                        language: .english)!
                    let name = "Account 1"
                    let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                    let address = keystore.addresses!.first!.address
                    WalletEthModel.sharedInstance.address = address
                    WalletEthModel.sharedInstance.data = keyData
                    WalletEthModel.sharedInstance.name = name
                    WalletEthModel.sharedInstance.isHD = true
                    WalletEthModel.sharedInstance.createDate = Date()
                    WalletEthModel.sharedInstance.useDate = Date()
                    SettingApp.sharedInstance.typeNetwork = .main
                    KeychainWrapper.standard.set(password!, forKey: address)
                    WalletEthModel.sharedInstance.saveConfigToDB()
                    self.pushMainTabbarViewController()
                } catch {
                    HUD.flash(.label("The string is not valid.".localizedString()), delay: 1.0)
                }

            } else {
                let formattedKey = key!.trimmingCharacters(in: .whitespacesAndNewlines)
                if let dataKey = Data.fromHex(formattedKey) {
                    if SECP256K1.verifyPrivateKey(privateKey: dataKey) {
                        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password!)!
                        let name = "Account 1"
                        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                        let address = keystore.addresses!.first!.address
                        WalletEthModel.sharedInstance.address = address
                        WalletEthModel.sharedInstance.data = keyData
                        WalletEthModel.sharedInstance.name = name
                        WalletEthModel.sharedInstance.isHD = false
                        WalletEthModel.sharedInstance.createDate = Date()
                        WalletEthModel.sharedInstance.useDate = Date()
                        SettingApp.sharedInstance.typeNetwork = .main
                        KeychainWrapper.standard.set(password!, forKey: address)
                        WalletEthModel.sharedInstance.saveConfigToDB()
                        self.pushMainTabbarViewController()
                    } else {
                        HUD.flash(.label("Something went wrong. Please try again.".localizedString()), delay: 1.0)
                    }
                } else {
                    HUD.flash(.label("Something went wrong. Please try again.".localizedString()), delay: 1.0)
                }
            }
        }
    }
    
    func setDashBorders(for view: UIView, with color: CGColor) {
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = color
        viewBorder.lineDashPattern = [6, 2]
        viewBorder.frame = view.bounds
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(rect: view.bounds).cgPath
        view.layer.addSublayer(viewBorder)
    }
    
    func changeDashBorderColor(for view: UIView, with color: CGColor) {
        let viewBorder = view.layer.sublayers?.last as? CAShapeLayer
        viewBorder?.strokeColor = color
    }

    func checkInfomation() {
        if isCheckPass && isCheckLength && isCheckMnemonic {
            btnConfirm.isEnabled = true
            btnConfirm.backgroundColor = BaseViewController.MainColor
        } else {
            btnConfirm.isEnabled = false
            btnConfirm.backgroundColor = .lightGray
        }
    }
    
    @IBAction func tappedChangeSegmented(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            type = .privateKey
        } else {
            type = .mnemonic
        }
    }
}

extension ImportWalletEthViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        if textField == txtNewPass {
            if result.length < 8 {
                lblCheckPass.text = "Must be at least 8 characters".localizedString()
                isCheckLength = false
                checkInfomation()
            } else {
                lblCheckPass.text = ""
                isCheckLength = true
                checkInfomation()
            }
        } else if textField == txtConfirmPass {
            if result != txtNewPass.text {
                lblConfirmPass.text = "Passwords do not match".localizedString()
                isCheckPass = false
                checkInfomation()
            } else {
                lblConfirmPass.text = ""
                isCheckPass = true
                checkInfomation()
            }
        }
        return true
    }
}
extension ImportWalletEthViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText == "" {
            isCheckMnemonic = false
            checkInfomation()
        } else {
            isCheckMnemonic = true
            checkInfomation()
            mnemonic = newText
        }
        return true
    }
}
