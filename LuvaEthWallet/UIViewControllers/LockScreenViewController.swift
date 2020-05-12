//
//  LockScreenViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/16/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import SmileLock
import SwiftKeychainWrapper
import EZAlertController
import PKHUD

protocol LockScreenViewControllerDelegate:NSObject {
    func didInPutPassCodeSuccess(_ pass:String)
    func didConfirmPassCode()
    func didChangePassCode()
    func didPopViewController()
    func didConfirmPassCodeSuccess()
    func didDisablePassCodeSuccess()
}


class LockScreenViewController: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var svPass: UIStackView!
    
    private var alertView: UIView!
    
    private var textLabel: UILabel!

    private var passwordContainerView: PasswordContainerView!
    
    let kPasswordDigit = 6
    
    var passCode: String = ""
    
    var isEnableBackButton = false
    
    var mnemonic: String?
    
    var isCreateAccount = false
    
    var isDisablePass = false
    
    weak var delegate:LockScreenViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingApp.sharedInstance.loadLocalized()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let imgBack = UIImage.init(named: "ic_backarrow")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        btnBack.setImage(imgBack, for: .normal)
        btnBack.tintColor = BaseViewController.MainColor
        btnBack.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if isEnableBackButton {
            btnBack.isHidden = false
        } else {
            btnBack.isHidden = true
        }
        passwordContainerView = PasswordContainerView.create(in: svPass, digit: kPasswordDigit)
        let imgDelete = UIImage.init(named: "ic_backspace")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        passwordContainerView.deleteButton.setImage(imgDelete, for: .normal)
        passwordContainerView.deleteButtonLocalizedTitle = ""
        passwordContainerView.tintColor = BaseViewController.MainColor
        passwordContainerView.touchAuthenticationButton.tintColor = .white
        passwordContainerView.highlightedColor = UIColor.init(rgb: 0x555555)
        self.view.backgroundColor = .white
        lblTitle.textColor = .darkText
        passwordContainerView.delegate = self
        passwordContainerView.touchAuthenticationButton.isEnabled = false
        if let _ = KeychainWrapper.standard.string(forKey: "MYPASS") {
            if SettingApp.sharedInstance.passCodeType == .change {
                lblTitle.text = "Enter Current Passcode".localizedString()
            } else if SettingApp.sharedInstance.passCodeType == .confirm {
                if passCode.isEmpty {
                    lblTitle.text = "Enter New Passcode".localizedString()
                } else {
                    lblTitle.text = "Confirm New Passcode".localizedString()
                }
            } else if SettingApp.sharedInstance.passCodeType == .normal {
                lblTitle.text = "Enter Passcode".localizedString()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    if SettingApp.sharedInstance.enablePassCode == .on && SettingApp.sharedInstance.enableTouchID == .on {
                        self.passwordContainerView.touchAuthentication()
                    }
                }
            }
        } else {
            if passCode.isEmpty {
                lblTitle.text = "Enter New Passcode".localizedString()
            } else {
                lblTitle.text = "Confirm New Passcode".localizedString()
            }
        }
    }
    

    
    @IBAction func tappedBackButton(_ sender: Any) {
        if isCreateAccount {
            EZAlertController.alert("Are you sure".localizedString() + "?", message: "This action will cancel account creation".localizedString() + ". " + "Shown recovery phrase will be deleted".localizedString(), buttons: ["Cancel".localizedString(), "OK".localizedString()]) { (alertAction, position) -> Void in
                if position == 0 {
                    self.dismiss(animated: true, completion: nil)
                } else if position == 1 {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            delegate?.didPopViewController()
        }
    }
}

extension LockScreenViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if let passWord = KeychainWrapper.standard.string(forKey: "MYPASS") {
            if SettingApp.sharedInstance.passCodeType == .change {
                if passWord == input {
                    delegate?.didChangePassCode()
                } else {
                    passwordContainerView.wrongPassword()
                }
            } else if SettingApp.sharedInstance.passCodeType == .confirm {
                if passCode.isEmpty {
                    delegate?.didInPutPassCodeSuccess(input)
                } else {
                    if passCode == input {
                        KeychainWrapper.standard.set(passCode, forKey: "MYPASS")
                        SettingApp.sharedInstance.disablePassCode = .off
                        SettingApp.sharedInstance.enablePassCode = .on
                        SettingApp.sharedInstance.passCodeType = .normal
                        SettingApp.sharedInstance.saveSettingAppToDB()
                        delegate?.didConfirmPassCode()
                    } else {
                        passwordContainerView.wrongPassword()
                    }
                }
            } else if SettingApp.sharedInstance.passCodeType == .normal {
                if isDisablePass {
                    if passWord == input {
                        delegate?.didDisablePassCodeSuccess()
                    } else {
                        passwordContainerView.wrongPassword()
                    }
                } else {
                    if passWord == input {
                        delegate?.didConfirmPassCodeSuccess()
                    } else {
                        passwordContainerView.wrongPassword()
                    }
                }
            }
        } else {
            if passCode.isEmpty {
                delegate?.didInPutPassCodeSuccess(input)
            } else {
                if passCode == input {
                    KeychainWrapper.standard.set(passCode, forKey: "MYPASS")
                    SettingApp.sharedInstance.disablePassCode = .on
                    SettingApp.sharedInstance.enablePassCode = .on
                    SettingApp.sharedInstance.saveSettingAppToDB()
                    delegate?.didConfirmPassCode()
                } else {
                    passwordContainerView.wrongPassword()
                }
            }
        }

    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if isDisablePass {
            if success {
                delegate?.didDisablePassCodeSuccess()
            } else {
                passwordContainerView.clearInput()
            }
        } else {
            if success {
                delegate?.didConfirmPassCodeSuccess()
            } else {
                passwordContainerView.clearInput()
            }
        }
    }
}
