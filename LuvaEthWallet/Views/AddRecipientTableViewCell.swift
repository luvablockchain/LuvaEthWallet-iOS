//
//  AddRecipientTableViewCell.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/17/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

class AddRecipientTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var imgAvarta: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
