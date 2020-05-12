//
//  AddRecipientViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/17/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import web3swift
import EZAlertController
import PKHUD

class AddRecipientViewController: BaseViewController {

    @IBOutlet weak var btnShow: UIButton!
    
    @IBOutlet weak var btnSendETH: UIButton!
    
    @IBOutlet weak var leadingToImg: NSLayoutConstraint!
    
    @IBOutlet weak var leadingToView: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblInput: UILabel!
    
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var viewHeader: UIView!
    
    @IBOutlet weak var lblTtitle: UILabel!
    
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var viewMyAccounts: UIView!
    
    @IBOutlet weak var txtAddress: UITextView!
        
    @IBOutlet weak var viewSearch: UIView!
    
    var listWallet: [WalletEthModel] = []
    
    var listRecents: [String] = []
    
    var isSendBetween = false
    
    var walletEth: WalletEthModel!
    
    var balance = ""
    
    var btnRight:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = navigationController {
            btnRight = UIButton.init(type: .system)
            if #available(iOS 11.0, *) {
                btnRight?.contentHorizontalAlignment = .trailing
            }
            btnRight!.setImage(UIImage(named: "ic_scan")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            btnRight!.tintColor = BaseViewController.MainColor
            btnRight!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btnRight!.addTarget(self, action:#selector(tappedAtRightButton), for: .touchUpInside)
            let rightBarButton = UIBarButtonItem()
            rightBarButton.customView = btnRight
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
        self.imgBack.isHidden = true
        self.leadingToView.isActive = true
        self.leadingToImg.isActive = false
        self.view.layoutIfNeeded()
        lblInput.text = "Input Address".localizedString()
        lblTtitle.text = "Transfer between my accounts".localizedString()
        lblHeader.text = "Recents".localizedString()
        tableView.tableFooterView = UIView()
        self.imgBack.image = UIImage.init(named: "ic_backarrow")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgBack.tintColor = BaseViewController.MainColor
        btnSendETH.layer.cornerRadius = 5
        btnSendETH.setTitle("NEXT".localizedString(), for: .normal)
        if let model = WalletEthModel.search(withWhere: ["address": self.walletEth.address])?.firstObject as? WalletEthModel {
            self.listRecents = model.listRecents
        }
    }
    
    override func viewDidLayoutSubviews() {
        AppearanceHelper.setDashBorders(for: viewSearch, with: BaseViewController.MainColor.cgColor)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @objc func tappedAtRightButton(sender:UIButton) {
        presentToScanQRCodeViewController(delegate: self)
    }
    
    @IBAction func tappedSendETHToAddress(_ sender: Any) {
        view.endEditing(true)
        if txtAddress.text != "" {
            if EthereumAddress(txtAddress.text!) != nil {
                if walletEth.address.uppercased() == txtAddress.text!.uppercased() {
                    HUD.flash(.label("Unable to transfer ETH to yourself.".localizedString()), delay: 1.0)
                } else {
                    pushSendETHToAddressViewController(address: txtAddress.text!, model: walletEth, balance: self.balance)
                }
            } else {
                HUD.flash(.label("Invalid address.".localizedString()), delay: 1.0)
            }
        } else {
            EZAlertController.alert("", message:"Please enter the address to transfer ETH.".localizedString(), acceptMessage: "Ok".localizedString()) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func tappedShowMyAccounts(_ sender: Any) {
        btnShow.isSelected = !btnShow.isSelected
        if btnShow.isSelected {
            self.imgBack.isHidden = false
            self.leadingToView.isActive = false
            self.leadingToImg.isActive = true
            self.view.layoutIfNeeded()
            lblTtitle.text = "Back to All".localizedString()
            lblHeader.text = "My Accounts".localizedString()
            isSendBetween = true
            tableView.reloadData()
        } else {
            self.imgBack.isHidden = true
            self.leadingToView.isActive = true
            self.leadingToImg.isActive = false
            self.view.layoutIfNeeded()
            lblTtitle.text = "Transfer between my accounts".localizedString()
            lblHeader.text = "Recents".localizedString()
            isSendBetween = false
            tableView.reloadData()
        }
    }
}

extension AddRecipientViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSendBetween {
            return listWallet.count
        } else {
            return listRecents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "addRecipientTableViewCell") as! AddRecipientTableViewCell
        if isSendBetween {
            cell.lblName.text = listWallet[indexPath.row].name
            let endString = listWallet[indexPath.row].address.suffix(6)
            let beginString = listWallet[indexPath.row].address.prefix(6)
            cell.lblAddress.text = beginString.uppercased() + "...." + endString.uppercased()
            cell.lblAddress.isHidden = false
            cell.imgAvarta.setImageForAddress1(string: listWallet[indexPath.row].name, circular: true, gradient:true)
        } else {
            cell.lblAddress.isHidden = true
            let endString = listRecents[indexPath.row].suffix(6)
            let beginString = listRecents[indexPath.row].prefix(6)
            cell.lblName.text = beginString.uppercased() + "...." + endString.uppercased()
            cell.imgAvarta.setImageForAddress(string: listRecents[indexPath.row], circular: true, gradient:true)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSendBetween {
            if walletEth.address.uppercased() == listWallet[indexPath.row].address.uppercased() {
                HUD.flash(.label("Unable to transfer ETH to yourself.".localizedString()), delay: 1.0)
            } else {
                pushSendETHToAddressViewController(address: listWallet[indexPath.row].address, model: walletEth,balance: self.balance)
            }
        } else {
            if walletEth.address.uppercased() == listRecents[indexPath.row].uppercased() {
                HUD.flash(.label("Unable to transfer ETH to yourself.".localizedString()), delay: 1.0)
            } else {
                pushSendETHToAddressViewController(address: listRecents[indexPath.row], model: walletEth, balance: self.balance)
            }
        }
    }
}
extension AddRecipientViewController: ScanQRCodeViewControllerDelegate {
    func didScanQRCodeSuccess(address: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if self.walletEth.address.uppercased() == address.uppercased() {
                HUD.flash(.label("Unable to transfer ETH to yourself.".localizedString()), delay: 1.0)
            } else {
                self.pushSendETHToAddressViewController(address: address, model: self.walletEth,balance: self.balance)
            }
        }
    }
}
