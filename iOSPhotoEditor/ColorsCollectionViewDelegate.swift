//
//  ColorsCollectionViewDelegate.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/1/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

class ColorsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var colorDelegate : ColorDelegate?
    
    /**
     Array of Colors that will show while drawing or typing
     */
    var colors = [UIColor.black,
                  UIColor.darkGray,
                  UIColor.gray,
                  UIColor.lightGray,
                  UIColor.white,
                  UIColor.blue,
                  UIColor.green,
                  UIColor.red,
                  UIColor.yellow,
                  UIColor.orange,
                  UIColor.purple,
                  UIColor.cyan,
                  UIColor.brown,
                  UIColor.magenta]
    
    override init() {
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorDelegate?.didSelectColor(color: colors[indexPath.item])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ColorCollectionViewCell.self), for: indexPath) as! ColorCollectionViewCell
        cell.colorView.backgroundColor = colors[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalCellWidth = flowLayout.itemSize.width * CGFloat(collectionView.numberOfItems(inSection: 0))
        let totalSpacingWidth = flowLayout.minimumInteritemSpacing * CGFloat((collectionView.numberOfItems(inSection: 0) - 1))

        let leftInset = max(0.0, (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2)
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
