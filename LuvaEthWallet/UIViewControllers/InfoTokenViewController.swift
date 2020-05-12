//
//  InfoTokenViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 5/11/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import web3swift
import PKHUD

class InfoTokenViewController: UIViewController {
    
    @IBOutlet weak var txtDecimals: UITextView!
    
    @IBOutlet weak var viewDecimals: UIView!
    
    @IBOutlet weak var txtSymbol: UITextView!
    
    @IBOutlet weak var viewSymbol: UIView!
    
    @IBOutlet weak var txtAddress: UITextView!
    
    @IBOutlet weak var viewAddress: UIView!
    
    @IBOutlet weak var lblDecimals: UILabel!
    
    @IBOutlet weak var lblSymbol: UILabel!
    
    @IBOutlet weak var lblTokenAddress: UILabel!
    
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    var web3 = Web3.InfuraRinkebyWeb3()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCancel.layer.cornerRadius = 10
        btnNext.layer.cornerRadius = 10
        btnNext.layer.masksToBounds = true
        btnNext.isEnabled = false
        btnNext.setBackgroundColor(.lightGray, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        AppearanceHelper.setDashBorders(for: viewSymbol, with: BaseViewController.MainColor.cgColor)
        AppearanceHelper.setDashBorders(for: viewAddress, with: BaseViewController.MainColor.cgColor)
        AppearanceHelper.setDashBorders(for: viewDecimals, with: BaseViewController.MainColor.cgColor)

    }

    @IBAction func tappedNextButton(_ sender: Any) {
        
    }
    
    @IBAction func tappedButtonCancel(_ sender: Any) {
        
    }
}

extension InfoTokenViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText.isEmpty {
            btnNext.isEnabled = false
            btnNext.setBackgroundColor(.lightGray, for: .normal)
            btnNext.layer.cornerRadius = 10
            btnNext.layer.masksToBounds = true
            self.txtDecimals.isUserInteractionEnabled = true
            self.txtSymbol.isUserInteractionEnabled = true
        } else {
            if EthereumAddress(newText) != nil {
                HUD.show(.labeledProgress(title: "", subtitle: "Loading...".localizedString()))
                DispatchQueue.main.async {
                    let erc20ContractAddress = EthereumAddress(newText)!
                    let token = ERC20(web3: self.web3, provider: InfuraProvider(.Rinkeby)!, address: erc20ContractAddress)
                    if token.name == "" {
                        HUD.hide()
                        HUD.flash(.label("Personal address detected. Input the token contract address.".localizedString()), delay: 1.0)
                    } else {
                        self.txtDecimals.isUserInteractionEnabled = false
                        self.txtSymbol.isUserInteractionEnabled = false
                        self.btnNext.isEnabled = true
                        self.btnNext.layer.cornerRadius = 10
                        self.btnNext.layer.masksToBounds = true
                        self.btnNext.setBackgroundColor(BaseViewController.MainColor, for: .normal)
                        self.txtSymbol.text = token.symbol
                        self.txtDecimals.text = token.decimals.description
                        HUD.hide()
                    }
                }
            } else {
                HUD.flash(.label("Invalid address.".localizedString()), delay: 1.0)
            }
        }
        return true
    }
}
