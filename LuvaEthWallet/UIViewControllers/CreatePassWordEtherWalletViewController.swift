//
//  CreatePassWordEtherWalletViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import web3swift
import PKHUD
import SwiftKeychainWrapper

class CreatePassWordEtherWalletViewController: BaseViewController {

    @IBOutlet weak var btnShowPass: UIButton!
    
    @IBOutlet weak var lblTerms: UILabel!
    
    @IBOutlet weak var imgShow: UIImageView!
    
    @IBOutlet weak var btnPolicy: UIButton!
    
    @IBOutlet weak var btnCreate: UIButton!
    
    @IBOutlet weak var lblPolicy: UILabel!
    
    @IBOutlet weak var imgPolicy: UIImageView!
    
    @IBOutlet weak var lblCheckPass: UILabel!
    
    @IBOutlet weak var txtConfirmPass: HoshiTextField!
    
    @IBOutlet weak var lblCheckLength: UILabel!
    
    @IBOutlet weak var txtNewPass: HoshiTextField!
    
    var isCheckBox = false
    
    var isCheckPass = false
    
    var isCheckLength = false

    var isAddAcount = false
    
    var password = ""
    
    var countWallet = 0
    
    var mnemonicList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtNewPass.placeholder = " New Password".localizedString()
        txtNewPass.isSecureTextEntry = true
        txtConfirmPass.placeholder = " Confirm Password".localizedString()
        txtConfirmPass.isSecureTextEntry = true
        btnCreate.setTitle("Create".localizedString(), for: .normal)
        btnCreate.layer.cornerRadius = 5
        lblCheckLength.text = ""
        lblCheckPass.text = ""
        lblTerms.text = ""
        btnCreate.isEnabled = false
        btnCreate.backgroundColor = .lightGray
        imgShow.image = UIImage.init(named: "ic_invisible")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgShow.tintColor = BaseViewController.MainColor
        
        imgPolicy.image = UIImage.init(named: "ic_check")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgPolicy.tintColor = BaseViewController.MainColor
        btnShowPass.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnShowPass.isSelected = false
        btnPolicy.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnPolicy.isSelected = false
        lblPolicy.text = "I have read and agree to the Terms of Use.".localizedString()
        WalletEthModel.getListWalletEthFromDB { (result) in
            self.countWallet = result.count
        }
    }

    @IBAction func tappedShowPass(_ sender: Any) {
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
    
    @IBAction func tappedCreateButton(_ sender: Any) {
        if isCheckBox {
            lblTerms.text = ""
            if isAddAcount {
                let mnemonics = MnemonicHelper.getStringFromSeparatedWords(in: mnemonicList)
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
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
                    KeychainWrapper.standard.set(password, forKey: address)
                    WalletEthModel.sharedInstance.saveConfigToDB()
                    self.pushMainTabbarViewController()
                }
            } else {
                let mnemonics = MnemonicHelper.getStringFromSeparatedWords(in: mnemonicList)
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
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
                KeychainWrapper.standard.set(password, forKey: address)
                WalletEthModel.sharedInstance.saveConfigToDB()
//                self.pushWalletEthViewController(address: address)
                self.pushMainTabbarViewController()
            }
        } else {
            lblTerms.text = "Required check policy".localizedString()
        }
    }
    
    @IBAction func tappedCheckPolicyButton(_ sender: Any) {
        btnPolicy.isSelected = !btnPolicy.isSelected
        if btnPolicy.isSelected {
            imgPolicy.image = UIImage.init(named: "ic_checked")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgPolicy.tintColor = BaseViewController.MainColor
            isCheckBox = true
            lblTerms.text = ""
        } else {
            isCheckBox = false
            imgPolicy.image = UIImage.init(named: "ic_check")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgPolicy.tintColor = BaseViewController.MainColor
        }
    }
    
    func checkInfomation() {
        if isCheckPass && isCheckLength {
            btnCreate.isEnabled = true
            btnCreate.backgroundColor = BaseViewController.MainColor
        } else {
            btnCreate.isEnabled = false
            btnCreate.backgroundColor = .lightGray
        }
    }

}

extension CreatePassWordEtherWalletViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        if textField == txtNewPass {
            if result.length < 8 {
                lblCheckLength.text = "Must be at least 8 characters".localizedString()
                isCheckLength = false
                checkInfomation()
            } else {
                lblCheckLength.text = ""
                isCheckLength = true
                checkInfomation()
            }
        } else if textField == txtConfirmPass {
            if result != txtNewPass.text {
                lblCheckPass.text = "Passwords do not match".localizedString()
                isCheckPass = false
                checkInfomation()
            } else {
                lblCheckPass.text = ""
                isCheckPass = true
                self.password = result
                checkInfomation()
            }
        }
        return true
    }
}

