//
//  ShowPrivateKeysView.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import web3swift
import PKHUD
import SwiftKeychainWrapper

protocol ShowPrivateKeysViewDelegate: AnyObject {
    func didSelectDoneButton()
    func didSelectCancelButton()
}

class ShowPrivateKeysView: UICustomView {

    @IBOutlet weak var textFiledPrivateKeys: UITextField!
    
    @IBOutlet weak var btnCopy: UIButton!
    
    @IBOutlet weak var viewPrivate: UIView!
    
    @IBOutlet weak var lblType: UILabel!
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var lblWarning: UILabel!
    
    @IBOutlet weak var viewWarning: UIView!
    
    @IBOutlet weak var lblCheck: UILabel!
    
    @IBOutlet weak var txtPrivate: UITextView!
    
    @IBOutlet weak var heightContrains: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    weak var delegate: ShowPrivateKeysViewDelegate?
    
    var wallet: WalletEthModel!
    
    var newText = ""
    
    var isShow = false
    
    var privateKey = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 5
        lblTitle.text = "Show Private Keys"
        lblCheck.text = ""
        lblWarning.text = "Warning: Never disclose this key. Anyone with your private keys can steal any assets held in your account."
        viewWarning.layer.cornerRadius = 5
        lblType.text = "Type your password"
        viewPrivate.layer.borderWidth = 1
        viewPrivate.layer.borderColor = UIColor.lightGray.cgColor
        btnCancel.setTitle("Cancel", for: .normal)
        btnConfirm.setTitle("Confirm", for: .normal)
        btnCancel.layer.cornerRadius = 5
        btnCancel.layer.masksToBounds = true
        btnCancel.setBackgroundColor(BaseViewController.MainColor, for: .normal)
        btnConfirm.isEnabled = false
        btnConfirm.setBackgroundColor(.lightGray, for: .normal)
        btnCopy.isEnabled = false
        txtPrivate.isHidden = true
    }
    
    class func initShowPrivateKeysView(parent: UIView,delegate: ShowPrivateKeysViewDelegate,wallet: WalletEthModel) {
        let privateKeyView = ShowPrivateKeysView.init(frame: .zero)
        privateKeyView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(privateKeyView)
        NSLayoutConstraint.activate([
            privateKeyView.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            privateKeyView.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            parent.leadingAnchor.constraint(equalTo: privateKeyView.leadingAnchor,constant: -20),
            parent.trailingAnchor.constraint(equalTo: privateKeyView.trailingAnchor, constant: 20),
        ])
        privateKeyView.delegate = delegate
        privateKeyView.wallet = wallet
    }
    
    class func removeShowPrivateKeysView(parent: UIView) {
        for view: UIView in parent.subviews {
            if view is ShowPrivateKeysView {
                view.removeFromSuperview()
                break
            }
        }
    }

    
    @IBAction func tappedCopyPrivateKeys(_ sender: Any) {
        if privateKey != "" {
            UIPasteboard.general.string = privateKey
            HUD.flash(.success, delay: 1.0)
        }
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        delegate?.didSelectCancelButton()
    }
    
    @IBAction func tappedConfirmButton(_ sender: Any) {
        if isShow {
            delegate?.didSelectDoneButton()
        } else {
            if let password = KeychainWrapper.standard.string(forKey: wallet.address) {
                if newText != "" && newText == password {
                    heightContrains.constant = 80
                    let data = wallet.data
                    let keystoreManager: KeystoreManager
                    if wallet.isHD {
                        let keystore = BIP32Keystore(data!)!
                        keystoreManager = KeystoreManager([keystore])
                    } else {
                        let keystore = EthereumKeystoreV3(data!)!
                        keystoreManager = KeystoreManager([keystore])
                    }
                    let ethereumAddress = EthereumAddress(wallet.address)!
                    self.privateKey = try! keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
                    txtPrivate.text = privateKey.uppercased()
                    lblCheck.text = ""
                    lblType.text = "This is your private key (click to copy)"
                    btnCancel.isHidden = true
                    isShow = true
                    textFiledPrivateKeys.isHidden = true
                    txtPrivate.isHidden = false
                    btnConfirm.setTitle("Done", for: .normal)
                    txtPrivate.isUserInteractionEnabled = false
                    btnCopy.isEnabled = true
                } else {
                    lblCheck.text = "Incorrect Password."
                }
            }
        }
    }
}

extension ShowPrivateKeysView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        if newText == "" {
            btnConfirm.isEnabled = false
            btnConfirm.layer.cornerRadius = 5
            btnConfirm.layer.masksToBounds = true
            btnConfirm.setBackgroundColor(.lightGray, for: .disabled)
        } else {
            btnConfirm.isEnabled = true
            btnConfirm.layer.cornerRadius = 5
            btnConfirm.layer.masksToBounds = true
            btnConfirm.setBackgroundColor(BaseViewController.MainColor, for: .normal)
        }
        return true
    }
}

