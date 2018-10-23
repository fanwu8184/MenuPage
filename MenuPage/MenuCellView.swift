//
//  MenuCell.swift
//  workDictionary
//
//  Created by Fan Wu on 10/17/18.
//  Copyright © 2018 8184. All rights reserved.
//

import Foundation
import UIKit

class MenuCellView: BasicCollectionViewCell {
    
    var item = UIView() {
        didSet {
            item.translatesAutoresizingMaskIntoConstraints = false
            setupItemView()
            updateItem()
        }
    }
    
    var selectedColor: UIColor!
    var notSelectedColor: UIColor!
    
    override var isSelected: Bool {
        didSet {
            updateItem()
        }
    }
    
    private func setupItemView() {
        subviews.forEach { $0.removeFromSuperview() }  //this is needed because of reusable cells
        addSubview(item)
        item.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        item.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        item.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        item.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
    
    private func updateItem() {
        if let imageView = item as? UIImageView {
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = isSelected ? selectedColor : notSelectedColor
        } else if let label = item as? UILabel {
            label.textColor = isSelected ? selectedColor : notSelectedColor
            label.textAlignment = .center
        } else if let button = item as? UIButton {
            button.isUserInteractionEnabled = false
            let color = isSelected ? selectedColor : notSelectedColor
            if button.currentImage == nil && button.currentTitle == nil {
                button.backgroundColor = color
            } else {
                let image = button.currentImage?.withRenderingMode(.alwaysTemplate)
                button.setImage(image, for: .normal)
                button.tintColor = color
                button.setTitleColor(color, for: .normal)
            }
        } else {
            backgroundColor = isSelected ? selectedColor : notSelectedColor
        }
    }
}
