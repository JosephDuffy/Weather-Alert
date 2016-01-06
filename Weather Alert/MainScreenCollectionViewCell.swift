//
//  MainScreenCollectionViewCell.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 06/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit

class MainScreenCollectionViewCell: UICollectionViewCell {

    override var selected: Bool {
        didSet {
            self.backgroundColor = selected ? .lightGrayColor() : nil
        }
    }

    override var highlighted: Bool {
        didSet {
            self.backgroundColor = highlighted ? .lightGrayColor() : nil
        }
    }

}
