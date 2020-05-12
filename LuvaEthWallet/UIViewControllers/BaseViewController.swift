//
//  BaseViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {
    
    static let MainColor = UIColor.init(rgb: 0x70b500)

    var backBarItem: UIBarButtonItem!

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = BaseViewController.MainColor
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        backBarItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backBarItemPressed(_:)))
        backBarItem.setFAIcon(icon: .FAAngleLeft, iconSize: 25)
    }
    
    @objc func backBarItemPressed(_: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}
extension UIViewController {
    
    public static func getBundle() -> Bundle? {
        return Bundle.main
    }
    
    func pushCreateEthWallet() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "createWalletEthViewController") as? CreateWalletEthViewController
        vc!.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushWalletEthViewController(address: String = "") {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "walletEthViewController") as? WalletEthViewController
        vc!.address = address
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushAddRecipientViewController(listWallet:[WalletEthModel], model: WalletEthModel? = nil,balance: String) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "addRecipientViewController") as? AddRecipientViewController
        vc?.hidesBottomBarWhenPushed = true
        vc!.listWallet = listWallet
        vc?.walletEth = model
        vc?.balance = balance
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushSendETHToAddressViewController(address: String, model: WalletEthModel? = nil, balance: String) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "sendETHToAddressViewController") as? SendETHToAddressViewController
        vc?.hidesBottomBarWhenPushed = true
        vc!.address = address
        vc?.walletEth = model
        vc?.balance = balance
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushToScanQRCodeViewController(delegate: ScanQRCodeViewControllerDelegate? = nil) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "scanQRCodeViewController") as? ScanQRCodeViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.delegate = delegate
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func presentToScanQRCodeViewController(delegate: ScanQRCodeViewControllerDelegate? = nil) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "scanQRCodeViewController") as? ScanQRCodeViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.delegate = delegate
        if #available(iOS 13.0, *) {
            vc?.modalPresentationStyle = .fullScreen
        }
        self.present(vc!, animated: true, completion: nil)
    }

    func pushImportWalletEthViewController(isImport: Bool) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "importWalletEthViewController") as? ImportWalletEthViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.isImport = isImport
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    
    func pushDetailsWalletEthViewController(wallet: WalletEthModel, isDeposit:Bool = false,delegate: DetailsWalletEthViewControllerDelegate? = nil) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "detailsWalletEthViewController") as? DetailsWalletEthViewController
        vc!.wallet = wallet
        vc!.isDeposit = isDeposit
        vc!.delegate = delegate
        vc?.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    
    func pushMnemonicGenerationViewController(isAddAccount:Bool = false) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mnemonicGenerationViewController") as? MnemonicGenerationViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.isAddAcount = isAddAccount
        self.navigationController?.pushViewController(vc!, animated: true)
    }
        
    func pushMnemonicVerificationViewController(mnemonicList:[String] = [],isAddAccount:Bool = false) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mnemonicVerificationViewController") as? MnemonicVerificationViewController
        vc?.mnemonicList = mnemonicList
        vc?.isAddAcount = isAddAccount
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushCreatePassWordEtherWalletViewController(isAddAccount: Bool = false,mnemonicList:[String] = [] ) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "createPassWordEtherWalletViewController") as? CreatePassWordEtherWalletViewController
        vc?.isAddAcount = isAddAccount
        vc?.mnemonicList = mnemonicList
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushInfoTokenViewController() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "infoTokenViewController") as? InfoTokenViewController
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    func pushToLockScreenViewController(delegate:LockScreenViewControllerDelegate, passCode: String = "", isDisablePass: Bool = false) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "lockScreenViewController") as? LockScreenViewController
        vc?.delegate = delegate
        vc?.passCode = passCode
        vc?.isEnableBackButton = true
        vc?.isDisablePass = isDisablePass
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushMainTabbarViewController() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mainTabbarViewController") as? MainTabbarViewController
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func presentToLockScreenViewController(delegate:LockScreenViewControllerDelegate) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "lockScreenViewController") as? LockScreenViewController
        vc?.delegate = delegate
        vc?.hidesBottomBarWhenPushed = true
        vc?.isEnableBackButton = false
        if #available(iOS 13.0, *) {
            vc?.modalPresentationStyle = .fullScreen
        }
        self.present(vc!, animated: true, completion: nil)
    }

    func exitAppAndRequestReopenNotify(content: String) {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Touch reopen app".localizedString()
        notificationContent.body = "\(content)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.4, repeats: false)
        let request = UNNotificationRequest(identifier: "1", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                exit(0);
            }
        }
    }
}
