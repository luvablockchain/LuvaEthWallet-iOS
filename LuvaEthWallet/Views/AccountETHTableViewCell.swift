//
//  AccountETHTableViewCell.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

class AccountETHTableViewCell: UITableViewCell {
    
    static let key = "AccountETHTableViewCell"
    
    static let nib = UINib(nibName: "AccountETHTableViewCell", bundle: nil)

    @IBOutlet weak var lblBalance: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var imgAvarta: UIImageView!
    
    @IBOutlet weak var imgChoose: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        imgAvarta.layer.cornerRadius = imgAvarta.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

