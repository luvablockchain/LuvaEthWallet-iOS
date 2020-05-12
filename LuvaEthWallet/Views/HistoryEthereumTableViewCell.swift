//
//  HistoryEthereumTableViewCell.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

class HistoryEthereumTableViewCell: UITableViewCell {

    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var viewStatus: UIView!
    
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2
        viewStatus.layer.cornerRadius = 8
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

