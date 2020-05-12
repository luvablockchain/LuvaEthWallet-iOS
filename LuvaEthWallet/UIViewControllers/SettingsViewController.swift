//
//  SettingsViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/16/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import Eureka
import EZAlertController
import SwiftKeychainWrapper

class SettingsViewController: FormViewController {
    
    private var code: String = ""
    
    var isDisablePassCode = false
    
    var passCodeRow: SwitchRow!
    
    var changePassRow: LabelRow!
    
    var touchIDRow: SwitchRow!
    
    var timeRow: PushRow<String>!
    
    var helpRow: LabelRow!
    
    var termsRow: LabelRow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingApp.sharedInstance.loadLocalized()
        title = "Settings".localizedString()
        loadForm()
    }
    
    func loadForm() {
        
        self.passCodeRow = SwitchRow() {
            $0.title = "Set Passcode".localizedString()
            $0.tag = "PassCode"
            if(SettingApp.sharedInstance.enablePassCode == .on) {
                $0.value = true
                $0.cell.switchControl.isOn = true
                SettingApp.sharedInstance.disablePassCode = .on
            } else {
                $0.value = false
                $0.cell.switchControl.isOn = false
                SettingApp.sharedInstance.disablePassCode = .off
            }
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage.init(named: "ic_passcode")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        }.onChange { [weak self] in
            if $0.value == true {
                if SettingApp.sharedInstance.disablePassCode == .off {
                    self?.pushToLockScreenViewController(delegate:self!, isDisablePass: false)
                }
            } else {
                if SettingApp.sharedInstance.disablePassCode == .on {
                    self?.pushToLockScreenViewController(delegate:self!, isDisablePass: true)
                }
            }
        }.cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_passcode")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        })

        
        self.changePassRow = LabelRow () {
            $0.title = "Change Passcode".localizedString()
            $0.disabled = Eureka.Condition.function(["PassCode"], { (form) -> Bool in
                let row: SwitchRow! = form.rowBy(tag: "PassCode")
                if row.value == true {
                    self.changePassRow.cell.isUserInteractionEnabled = true
                    return false
                } else {
                    self.changePassRow.cell.isUserInteractionEnabled = false
                    return true
                }
            })

        }.cellSetup({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_changepass")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.default
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.height = { UITableView.automaticDimension }
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }).onCellSelection {[weak self] cell, row in
            SettingApp.sharedInstance.passCodeType = .change
            self?.pushToLockScreenViewController(delegate:self!)
        }.cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_changepass")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        })
        
        self.touchIDRow = SwitchRow() {
            $0.title = "Enable unlock with Touch ID or Face ID".localizedString()
            $0.tag = "TouchID"
            $0.disabled = Eureka.Condition.function(["PassCode"], { (form) -> Bool in
                let row: SwitchRow! = form.rowBy(tag: "PassCode")
                if row.value == true {
                    return false
                } else {
                    return true
                }
            })
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage.init(named: "ic_faceID")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        }.onChange { [weak self] in
            if $0.value == true {
                SettingApp.sharedInstance.enableTouchID = .on
            } else {
                SettingApp.sharedInstance.enableTouchID = .off
            }
            SettingApp.sharedInstance.saveSettingAppToDB()
        }.cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_faceID")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.textLabel?.numberOfLines = 0
        })
        
        self.timeRow = PushRow <String>() {
            $0.title = "Automatically".localizedString()
            $0.tag = "SetTime"
            $0.selectorTitle = "Time".localizedString()
            $0.options = ["Immediately".localizedString(), "5 seconds".localizedString(), "10 seconds".localizedString(), "15 seconds".localizedString(), "30 seconds".localizedString()]
            $0.disabled = Eureka.Condition.function(["PassCode"], { (form) -> Bool in
                let row: SwitchRow! = form.rowBy(tag: "PassCode")
                if row.value == true {
                    return false
                } else {
                    return true
                }
            })
            if SettingApp.sharedInstance.enablePassCode == .on {
                if let arr = $0.options {
                    if(SettingApp.sharedInstance.configType == .now) {
                        $0.value = arr[0]
                    } else if (SettingApp.sharedInstance.configType == .fiveSeconds) {
                        $0.value = arr[1]
                    } else if (SettingApp.sharedInstance.configType == .tenSeconds) {
                        $0.value = arr[2]
                    } else if (SettingApp.sharedInstance.configType == .fifteenSeconds) {
                        $0.value = arr[3]
                    } else if (SettingApp.sharedInstance.configType == .thirtySenconds) {
                        $0.value = arr[4]
                    }
                }
            } else {
                if let arr = $0.options {
                    if(SettingApp.sharedInstance.configType == .now) {
                        $0.value = arr[0]
                    } else if (SettingApp.sharedInstance.configType == .fiveSeconds) {
                        $0.value = arr[1]
                    } else if (SettingApp.sharedInstance.configType == .tenSeconds) {
                        $0.value = arr[2]
                    } else if (SettingApp.sharedInstance.configType == .fifteenSeconds) {
                        $0.value = arr[3]
                    } else if (SettingApp.sharedInstance.configType == .thirtySenconds) {
                        $0.value = arr[4]
                    }
                }
            }

        }.cellSetup({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_auto")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }).onChange({ (row) in
            if let arr = row.options {
                if(row.value == arr[0]) {
                    SettingApp.sharedInstance.configType = .now
                } else if (row.value == arr[1]) {
                    SettingApp.sharedInstance.configType = .fiveSeconds
                } else if (row.value == arr[2]) {
                    SettingApp.sharedInstance.configType = .tenSeconds
                } else if (row.value == arr[3]) {
                    SettingApp.sharedInstance.configType = .fifteenSeconds
                } else if (row.value == arr[4]) {
                    SettingApp.sharedInstance.configType = .thirtySenconds
                }
            }
            row.reload()
            SettingApp.sharedInstance.saveSettingAppToDB()
            
        }).cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_auto")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)

        })
    
        form
            +++
            Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
                        return view
                    }))
                    header.height = {0}
                    return header
                }()
            }
            <<<
            self.passCodeRow
            <<<
            self.changePassRow
            <<<
            self.touchIDRow
            <<<
            self.timeRow
            +++ Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
                        return view
                    }))
                    header.height = {0}
                    return header
                }()
            }
            <<< ActionSheetRow<String>() {
                
                $0.title = "App language".localizedString()
                $0.selectorTitle = "Select language"
                $0.options = ["Việt Nam", "English"]
                if(SettingApp.sharedInstance.languageApp == .en) {
                    $0.value = $0.options?.last
                } else {
                    $0.value = $0.options?.first
                }
            }.cellSetup({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_language")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }).onChange({ (row) in
                var content = ""
                if(row.value == row.options!.first) {
                    SettingApp.sharedInstance.languageApp = .vi
                    SettingApp.sharedInstance.saveToDB()
                    SettingApp.sharedInstance.loadLocalized()
                    content =  "\("Changed".localizedString()) \("languge to".localizedString()) Việt Nam"
                } else {
                    SettingApp.sharedInstance.languageApp = .en
                    SettingApp.sharedInstance.saveToDB()
                    SettingApp.sharedInstance.loadLocalized()
                    content =  "\("Changed".localizedString()) \("languge to".localizedString()) English"
                }
                EZAlertController.alert("Force restart app".localizedString(), message:"\("Change".localizedString()) \("App language".localizedString()) \("require restart app".localizedString())", buttons: ["Cancel".localizedString(), "Restart".localizedString()]) { (alertAction, position) -> Void in
                    if position == 0 {
                        self.dismiss(animated: true, completion: nil)
                    } else if position == 1 {
                        self.exitAppAndRequestReopenNotify(content: content)
                    }
                }
                
            }).cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_language")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
            })
            +++ Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
                        return view
                    }))
                    header.height = {0}
                    return header
                }()
            }
            <<< LabelRow () {
                $0.title = "Exit".localizedString()
            }.cellSetup({ (cell, row) in
                cell.selectionStyle = UITableViewCell.SelectionStyle.default
                cell.imageView?.image = UIImage.init(named: "ic_logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = UIColor.red
                cell.detailTextLabel?.textColor = UIColor.red
                cell.textLabel?.textColor = UIColor.red
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }).onCellSelection {[weak self] cell, row in
                row.reload()
                EZAlertController.alert("", message:"You want to exit this application".localizedString() + ".", buttons: ["Cancel".localizedString(), "OK".localizedString()]) { (alertAction, position) -> Void in
                    if position == 0 {
                        self!.dismiss(animated: true, completion: nil)
                    } else if position == 1 {
                        exit(0)
                    }
                }

                //ApplicationCoordinatorHelper.logout()
            }.cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = UIColor.red
                cell.textLabel?.textColor = UIColor.red
            })
            +++
            Section()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SettingsViewController: LockScreenViewControllerDelegate {
    func didChangePassCode() {
        self.code = ""
        SettingApp.sharedInstance.passCodeType = .confirm
        pushToLockScreenViewController(delegate: self)
    }
    func didInPutPassCodeSuccess(_ pass: String) {
        if SettingApp.sharedInstance.passCodeType == .confirm {
            if code.isEmpty {
                code = pass
                pushToLockScreenViewController(delegate: self, passCode: pass)
            } else {
                if code == pass {
                    self.navigationController?.popToViewController(self, animated: true)
                }
            }
        } else {
            if code.isEmpty {
                code = pass
                pushToLockScreenViewController(delegate: self, passCode: pass)
            } else {
                if code == pass {
                    self.navigationController?.popToViewController(self, animated: true)
                }
            }
        }
    }
    func didConfirmPassCode() {
        self.code = ""
        self.passCodeRow.value = true
        self.passCodeRow.cell.switchControl.isOn = true
//        self.passCodeRow.updateCell()
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didPopViewController() {
        self.code = ""
        SettingApp.sharedInstance.passCodeType = .normal
        if SettingApp.sharedInstance.enablePassCode == .on {
            SettingApp.sharedInstance.enablePassCode = .on
            SettingApp.sharedInstance.disablePassCode = .on
            self.passCodeRow.value = true
            self.passCodeRow.cell.switchControl.isOn = true
        } else {
            SettingApp.sharedInstance.enablePassCode = .off
            SettingApp.sharedInstance.disablePassCode = .off
            self.passCodeRow.value = false
            self.passCodeRow.cell.switchControl.isOn = false
        }
        SettingApp.sharedInstance.saveSettingAppToDB()
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didConfirmPassCodeSuccess() {
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didDisablePassCodeSuccess() {
        self.code = ""
        self.passCodeRow.value = false
        self.passCodeRow.cell.switchControl.isOn = false
        KeychainWrapper.standard.removeObject(forKey: "MYPASS")
        SettingApp.sharedInstance.disablePassCode = .off
        SettingApp.sharedInstance.enablePassCode = .off
        SettingApp.sharedInstance.saveSettingAppToDB()
        self.navigationController?.popToViewController(self, animated: true)
    }
}

