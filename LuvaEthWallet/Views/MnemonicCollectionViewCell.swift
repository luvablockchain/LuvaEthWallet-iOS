//
//  MnemonicCollectionViewCell.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

class MnemonicCollectionViewCell: UICollectionViewCell {

    static let key = "MnemonicCollectionViewCell"
    static let nib = UINib(nibName: "MnemonicCollectionViewCell", bundle: nil)
    var isRestore = false
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        if isRestore {
            self.backgroundColor = UIColor.lightGray
        } else {
            self.backgroundColor = UIColor.white
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if !isRestore {
                setAppearance()
            }
        }
    }
        
    private func setAppearance() {
        if !isRestore {
            backgroundColor = isSelected ? UIColor.init(rgb: 0xDEE7D6) : BaseViewController.MainColor
            lblTitle.isHidden = isSelected
            if isSelected {
                AppearanceHelper.setDashBorders(for: self, with: BaseViewController.MainColor.cgColor)
            } else {
                AppearanceHelper.removeDashBorders(from: self)
            }
        }
    }
}
