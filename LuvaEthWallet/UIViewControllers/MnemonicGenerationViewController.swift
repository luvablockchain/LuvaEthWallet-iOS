//
//  MnemonicGenerationViewController.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit
import PKHUD
import web3swift

struct AppearanceHelper {
    
    static func setDashBorders(for view: UIView, with color: CGColor) {
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = color
        viewBorder.lineDashPattern = [6, 2]
        viewBorder.frame = view.bounds
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(rect: view.bounds).cgPath
        view.layer.addSublayer(viewBorder)
    }
    
    static func changeDashBorderColor(for view: UIView, with color: CGColor) {
        let viewBorder = view.layer.sublayers?.last as? CAShapeLayer
        viewBorder?.strokeColor = color
    }
    
    static func removeDashBorders(from view: UIView) {
        let viewBorder = view.layer.sublayers?.last as? CAShapeLayer
        viewBorder?.removeFromSuperlayer()
    }
}

struct MnemonicHelper {
    
    static func getSeparatedWords(from string: String) -> [String] {
        let components = string.components(separatedBy: .whitespacesAndNewlines)
        
        return components.filter { !$0.isEmpty }
    }
    
    static func getStringFromSeparatedWords(in wordArray: [String]) -> String {
        var string = ""
        
        for (index, word) in wordArray.enumerated() {
            let space = (index < wordArray.count - 1) ? " " : ""
            string.append(word + space)
        }
        
        return string
    }

}

class MnemonicGenerationViewController: BaseViewController {
    
    @IBOutlet weak var btnNext: UIButton!
        
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblTitleCopy: UILabel!
    
    @IBOutlet weak var btnCopy: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    var mnemonicList: [String] = []
    
    var mnemonic: String = ""
    
    var isAddAcount = false
    
    var isNewAccount = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Backup Phrase".localizedString()
               btnNext.layer.cornerRadius = 5
               btnNext.setTitle("NEXT".localizedString(), for: .normal)
               btnCopy.setImage(UIImage(named: "ic_copy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
               btnCopy.tintColor = BaseViewController.MainColor
               btnCopy.setTitle(" " + "Copy".localizedString(), for: .normal)
               btnCopy.layer.cornerRadius = 5
               btnCopy.layer.borderWidth = 1
               btnCopy.layer.borderColor = BaseViewController.MainColor.cgColor
               lblTitle.text = "Your secret backup phrase makes it easy to back up and restore your account".localizedString() + "."
        lblTitleCopy.text = "WARNING: ".localizedString() + "Never disclose your backup phrase".localizedString() + ". " + "Anyone with this phrase can take your Ether forever.".localizedString()
               collectionView.register(MnemonicCollectionViewCell.nib, forCellWithReuseIdentifier: MnemonicCollectionViewCell.key)
        let bitsOfEntropy: Int = 128
        self.mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
        self.mnemonicList = MnemonicHelper.getSeparatedWords(from: mnemonic)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLayoutSubviews() {
        AppearanceHelper.setDashBorders(for: collectionView, with: BaseViewController.MainColor.cgColor)
    }

    @IBAction func tappedCopyToClipBoard(_ sender: Any) {
        UIPasteboard.general.string = mnemonic
        HUD.flash(.success, delay: 1.0)
    }
    
    @IBAction func tappedNextButton(_ sender: Any) {
        pushMnemonicVerificationViewController(mnemonicList: mnemonicList,isAddAccount: isAddAcount)
    }

}

extension MnemonicGenerationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return mnemonicList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:MnemonicCollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: MnemonicCollectionViewCell.key, for: indexPath) as! MnemonicCollectionViewCell
        cell.lblTitle.text = mnemonicList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (collectionView.frame.width - 40)/3
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

}
