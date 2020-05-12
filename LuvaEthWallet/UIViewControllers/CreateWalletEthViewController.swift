//
//  CreateWalletEthViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

class CreateWalletEthViewController: UIViewController {

    @IBOutlet weak var lblTitleCreate: UILabel!
    
    @IBOutlet weak var lblTitleImport: UILabel!
    
    @IBOutlet weak var lblStart: UILabel!
    
    @IBOutlet weak var btnImport: UIButton!
    
    @IBOutlet weak var btnCreate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //"Nhập từ mã khoá riêng"
        lblTitleImport.text = "You can enter your Ethereum account via a private key.".localizedString()
        lblStart.text = "Start!".localizedString()
        lblTitleCreate.text = "Create account Ethereum.".localizedString()
        btnImport.setTitle("Import PrivateKey".localizedString(), for: .normal)
        btnImport.layer.cornerRadius = 5
        btnCreate.setTitle("Create Account".localizedString(), for: .normal)
        btnCreate.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func tappedImportEthWallet(_ sender: Any) {
        pushImportWalletEthViewController(isImport: false)
    }
    
    @IBAction func tappedCreateEthWallet(_ sender: Any) {
        pushMnemonicGenerationViewController()
    }
}
