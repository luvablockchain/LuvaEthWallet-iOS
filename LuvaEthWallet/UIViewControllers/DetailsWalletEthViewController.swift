//
//  DetailsWalletEthViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import PKHUD

protocol DetailsWalletEthViewControllerDelegate:NSObject {
    func didReceiveTestNetEtherSuccess(balance:String)
}

class DetailsWalletEthViewController: UIViewController {
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var btnExport: UIButton!
    
    @IBOutlet weak var btnEthScan: UIButton!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var imgEdit: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var viewAccount: UIView!
    
    @IBOutlet weak var imgCopyAddress: UIImageView!
    
    @IBOutlet weak var lblAddressEth: UILabel!
    
    @IBOutlet weak var viewAddress: UIView!
    
    @IBOutlet weak var imgQRCode: UIImageView!
    
    var wallet: WalletEthModel!
    
    var textEdit = ""
    
    var viewBackGound: UIView!
    
    var isDeposit = false
    
    weak var delegate: DetailsWalletEthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        imgCopyAddress.image = UIImage(named: "ic_copy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgCopyAddress.tintColor = BaseViewController.MainColor
        imgEdit.image = UIImage(named: "ic_edit")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgEdit.tintColor = BaseViewController.MainColor
        viewAddress.layer.cornerRadius = 5
        viewAddress.layer.borderWidth = 1
        viewAddress.layer.borderColor = UIColor.lightGray.cgColor
        lblAddressEth.text = wallet.address
        txtName.text = wallet.name
        txtName.isHidden = true
        lblName.text = wallet.name
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2
        self.imgQRCode.image = generateQRCode(from: wallet.address)
        imgAvatar.image = LetterImageGenerator.imageWith(name:wallet.name)
        btnExport.layer.cornerRadius = 5
        btnExport.setTitle("Export Private Key".localizedString(), for: .normal)
        btnEthScan.layer.cornerRadius = 5
        if isDeposit {
            if SettingApp.sharedInstance.typeNetwork == .main {
                btnEthScan.isHidden = true
                btnExport.isHidden = true
                btnEdit.isHidden = true
                imgEdit.isHidden = true
            } else {
                btnEthScan.setTitle("Receive TestNet Ether".localizedString(), for: .normal)
                btnEthScan.isHidden = false
                btnExport.isHidden = true
                btnEdit.isHidden = true
                imgEdit.isHidden = true
            }
        } else {
            btnEthScan.setTitle("View on Ethersan".localizedString(), for: .normal)
            btnEthScan.isHidden = false
            btnExport.isHidden = false
            btnEdit.isHidden = false
            imgEdit.isHidden = false
        }
        viewBackGound = UIView.init(frame: .zero)
        viewBackGound.translatesAutoresizingMaskIntoConstraints = false
        navigationController?.view.addSubview(viewBackGound)
        NSLayoutConstraint.activate([
            navigationController!.view.leadingAnchor.constraint(equalTo: viewBackGound.leadingAnchor),
            navigationController!.view.trailingAnchor.constraint(equalTo: viewBackGound.trailingAnchor),
            navigationController!.view.bottomAnchor.constraint(equalTo: viewBackGound.bottomAnchor),
            navigationController!.view.topAnchor.constraint(equalTo:
                viewBackGound.topAnchor)
        ])
        viewBackGound.backgroundColor = .black
        viewBackGound.alpha = 0.5
        viewBackGound.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        viewBackGound.addGestureRecognizer(tap)
     }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        viewBackGound.isHidden = true
        ShowPrivateKeysView.removeShowPrivateKeysView(parent: self.navigationController!.view)
    }
    
    @IBAction func tappedExportPrivateKey(_ sender: Any) {
        viewBackGound.isHidden = false
        ShowPrivateKeysView.initShowPrivateKeysView(parent: self.navigationController!.view, delegate: self, wallet: wallet)
    }
    
    @IBAction func tappedViewEthereumScan(_ sender: Any) {
        if SettingApp.sharedInstance.typeNetwork == .main {
            let webVC = SwiftWebVC(urlString: "https://etherscan.io/address/" + wallet.address)
            webVC.delegate = self
            webVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(webVC, animated: true)
        } else {
            if isDeposit {
                HUD.show(.labeledProgress(title: "", subtitle: "Đang lấy ETH từ LuvaPay...".localizedString()))
                LuvaServiceData.sharedInstance.taskGetEtherFromLuva(address: self.wallet.address).continueOnSuccessWith(continuation: { task in
                    HUD.hide()
                    let balance = task as! String
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didReceiveTestNetEtherSuccess(balance: balance)
                }).continueOnErrorWith(continuation: { error in
                    print(error)
                })
            } else {
                let webVC = SwiftWebVC(urlString: "https://rinkeby.etherscan.io/address/" + wallet.address)
                webVC.delegate = self
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
    }
    
    @IBAction func tappedEditAccountName(_ sender: Any) {
        btnEdit.isSelected = !btnEdit.isSelected
        if btnEdit.isSelected {
            imgEdit.image = UIImage(named: "ic_choose")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgEdit.tintColor = BaseViewController.MainColor
            lblName.isHidden = true
            txtName.isHidden = false
            txtName.becomeFirstResponder()
        } else {
            imgEdit.image = UIImage(named: "ic_edit")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgEdit.tintColor = BaseViewController.MainColor
            lblName.isHidden = false
            txtName.isHidden = true
            if textEdit != "" {
                txtName.text = textEdit
                lblName.text = textEdit
                if let model = WalletEthModel.search(withWhere: ["address": wallet.address])?.firstObject as? WalletEthModel {
                    model.name = textEdit
                    model.saveToDB()
                    LuvaServiceData.sharedInstance.isEdit = true
                }
            }
            view.endEditing(true)
        }
    }
    
    @IBAction func tappedCopyAdressEth(_ sender: Any) {
        UIPasteboard.general.string = wallet.address
        HUD.flash(.success, delay: 1.0)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

}
extension DetailsWalletEthViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        self.textEdit = result
        return true
    }
}

extension DetailsWalletEthViewController: SwiftWebVCDelegate {
    
    func didStartLoading() {
        HUD.show(.labeledProgress(title: nil, subtitle: "Loading...".localizedString()))
    }
    
    func didFinishLoading(success: Bool) {
        HUD.hide()
    }
}

extension DetailsWalletEthViewController: ShowPrivateKeysViewDelegate {
    func didSelectDoneButton() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: WalletEthViewController.self) {
                viewBackGound.isHidden = true
                ShowPrivateKeysView.removeShowPrivateKeysView(parent: self.navigationController!.view)
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func didSelectCancelButton() {
        viewBackGound.isHidden = true
        ShowPrivateKeysView.removeShowPrivateKeysView(parent: self.navigationController!.view)
    }
}

