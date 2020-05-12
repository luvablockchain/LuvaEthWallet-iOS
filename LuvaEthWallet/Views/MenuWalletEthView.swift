//
//  MenuWalletEthView.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

protocol MenuWalletEthViewDelegate: AnyObject {
    func didSelectWallet(wallet:WalletEthModel,balance: String)
    func didSelectCreateAccountEthereum()
    func didSelectImportAccountEthereum()
}

class MenuWalletEthView: UICustomView {
    
    @IBOutlet weak var lblCreate: UILabel!
    
    @IBOutlet weak var imgCreate: UIImageView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblImport: UILabel!
    
    @IBOutlet weak var imgImport: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    weak var delegate:MenuWalletEthViewDelegate?
    
    var listAccount:[WalletEthModel] = []
    
    var address:String = ""
    
    var arrAccount: [MultiBalanceModel] = []
    
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
        lblTitle.text = "My Accounts".localizedString()
        lblCreate.text = "Create Account".localizedString()
        lblImport.text = "Import Account".localizedString()
        tableView.register(AccountETHTableViewCell.nib, forCellReuseIdentifier: AccountETHTableViewCell.key)
        WalletEthModel.getListWalletEthFromDB{ (result) in
            self.listAccount = result.sorted(by: { (first, second) -> Bool in
                return first.createDate.isEarly(second.createDate)
            })
        }
    }
    
    class func initMenuWalletEthView(parent: UIView,button: UIButton,delegate:MenuWalletEthViewDelegate, address: String, listAccount: [MultiBalanceModel]) {
        let menuView = MenuWalletEthView.init(frame: .zero)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(menuView)
        NSLayoutConstraint.activate([
            parent.leadingAnchor.constraint(equalTo: menuView.leadingAnchor,constant: -20),
            parent.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: 20),
            button.bottomAnchor.constraint(equalTo: menuView.topAnchor,constant: -10)
        ])
        menuView.delegate = delegate
        menuView.address = address
        menuView.arrAccount = listAccount
        menuView.imgImport.image = UIImage(named: "ic_import")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        menuView.imgImport.tintColor = .white
        menuView.imgCreate.image = UIImage(named: "ic_plus")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        menuView.imgCreate.tintColor = .white
        if menuView.listAccount.count == 1 {
            menuView.tableViewHeight.constant = 90
        } else if menuView.listAccount.count == 2 {
            menuView.tableViewHeight.constant = 180
        }  else if menuView.listAccount.count == 3 {
            menuView.tableViewHeight.constant = 270
        } else {
            menuView.tableViewHeight.constant = 360
        }
    }
    
    class func removeMenuWalletEthView(parent: UIView) {
        for view: UIView in parent.subviews {
            if view is MenuWalletEthView {
                view.removeFromSuperview()
                break
            }
        }
    }
    
    @IBAction func tappedImportAccountEthereum(_ sender: Any) {
        delegate?.didSelectImportAccountEthereum()
        print("Import")
    }
    
    @IBAction func tappedCreateAccountEthereum(_ sender: Any) {
        delegate?.didSelectCreateAccountEthereum()
        print("Create")
    }
}

extension MenuWalletEthView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listAccount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: AccountETHTableViewCell.key) as! AccountETHTableViewCell
        cell.lblName.text = listAccount[indexPath.row].name
        for account in arrAccount {
            if account.account == listAccount[indexPath.row].address {
                if account.balance == "0" {
                    cell.lblBalance.text = "0 ETH"
                } else {
                    let myFloat = (account.balance as NSString).floatValue
                    let newBalance = myFloat/1000000000000000000.0
                    cell.lblBalance.text = String(newBalance) + " ETH"
                }
            }
        }
        cell.imgAvarta.image = LetterImageGenerator.imageWith(name:listAccount[indexPath.row].name)
        if listAccount[indexPath.row].address == self.address {
            cell.imgChoose.image = UIImage.init(named: "ic_choose")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imgChoose.tintColor = .white
            cell.imgChoose.isHidden = false
        } else {
            cell.imgChoose.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var balance = ""
        for account in arrAccount {
            if account.account == listAccount[indexPath.row].address {
                balance = account.balance
            }
        }
        delegate?.didSelectWallet(wallet: listAccount[indexPath.row],balance:balance)
    }
}
