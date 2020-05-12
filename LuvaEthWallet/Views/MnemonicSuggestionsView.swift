//
//  MnemonicSuggestionsView.swift
//  LuvaEthWallet
//
//  Created by Nguyen Xuan Khang on 4/13/20.
//  Copyright © 2020 Nguyen Xuan Khang. All rights reserved.
//

import UIKit

protocol MnemonicSuggestionsViewDelegate {
  func suggestionWordWasPressed(_ suggestionWord: String)
}

class MnemonicSuggestionsView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var suggestionList: [String] = []
    
    var delegate: MnemonicSuggestionsViewDelegate?

    override func awakeFromNib() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MnemonicCollectionViewCell.nib, forCellWithReuseIdentifier: MnemonicCollectionViewCell.key)
        
    }
    
    func setData(suggestions: [String]) {
      suggestionList = suggestions
      collectionView.reloadData()
    }

}

extension MnemonicSuggestionsView: UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return suggestionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MnemonicCollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: MnemonicCollectionViewCell.key, for: indexPath) as! MnemonicCollectionViewCell
        cell.lblTitle.text = suggestionList[indexPath.item]
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let suggestionWord = suggestionList[indexPath.row]
        collectionView.reloadData()
        
        delegate?.suggestionWordWasPressed(suggestionWord)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 79, height: 36)
    }
}
