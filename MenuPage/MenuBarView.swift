//
//  MenuBar.swift
//  workDictionary
//
//  Created by Fan Wu on 10/16/18.
//  Copyright © 2018 8184. All rights reserved.
//

import Foundation
import UIKit

class MenuBarView: BasicView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "MenuCell"
    private let heightOfHorizontalBar: CGFloat = 4
    private let padding: CGFloat = 4
    
    internal var menuPageView: MenuPageView?
    //default colors
    var selectedColor: UIColor = .red {
        didSet {
            menuBarCollectionView.visibleCells.forEach { (cell) in
                if let menuCell = cell as? MenuCellView {
                    menuCell.selectedColor = selectedColor
                    if menuCell.isSelected {
                        menuCell.isSelected = true  //trigger update cell UI
                    }
                }
            }
        }
    }
    
    var notSelectedColor: UIColor = .blue {
        didSet {
            menuBarCollectionView.visibleCells.forEach { (cell) in
                if let menuCell = cell as? MenuCellView {
                    menuCell.notSelectedColor = notSelectedColor
                    if !menuCell.isSelected {
                        menuCell.isSelected = false //trigger update cell UI
                    }
                }
            }
        }
    }
    
    var horizontalBarColor: UIColor = .lightGray {
        didSet {
            horizontalBarView.backgroundColor = horizontalBarColor
        }
    }
    
    var menuItems = [UIView]() {
        didSet {
            menuBarCollectionView.reloadData()
            selectMenuItemAt(0)
            updateHorizontalBarWidth()
        }
    }
    
     private lazy var menuBarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MenuCellView.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var horizontalBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = horizontalBarColor
        return view
    }()
    
    override var bounds: CGRect {
        didSet {
            updateHorizontalBarWidth()
            updateMenuBarCollectionViewHeightAndHorizontalBarHeight()
        }
    }
    
    private var menuBarCollectionViewHeightAnchorConstraint: NSLayoutConstraint?
    private var horizontalBarViewHeightAnchorConstrain: NSLayoutConstraint?
    private var horizontalBarViewWidthAnchorConstraint: NSLayoutConstraint?
    private var horizontalBarLeadingAnchorConstraint: NSLayoutConstraint?
    
    internal override func setupViews() {
        super.setupViews()
        setupMenuBarCollectionView()
        setupHorizontalBar()
    }
    
    private func setupMenuBarCollectionView() {
        addSubview(menuBarCollectionView)
        menuBarCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        menuBarCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        menuBarCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        menuBarCollectionViewHeightAnchorConstraint = menuBarCollectionView.heightAnchor.constraint(equalToConstant: 0)
        menuBarCollectionViewHeightAnchorConstraint?.isActive = true
    }
    
     private func setupHorizontalBar() {
        addSubview(horizontalBarView)
        horizontalBarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        horizontalBarViewHeightAnchorConstrain = horizontalBarView.heightAnchor.constraint(equalToConstant: 0)
        horizontalBarViewHeightAnchorConstrain?.isActive = true
        horizontalBarViewWidthAnchorConstraint = horizontalBarView.widthAnchor.constraint(equalToConstant: 0)
        horizontalBarViewWidthAnchorConstraint?.isActive = true
        horizontalBarLeadingAnchorConstraint = horizontalBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        horizontalBarLeadingAnchorConstraint?.isActive = true
    }
    
    private func updateHorizontalBarWidth() {
        let width: CGFloat = (menuItems.count == 0) ? 0 : bounds.width/CGFloat(menuItems.count)
        horizontalBarViewWidthAnchorConstraint?.constant = width
    }
    
    private func updateMenuBarCollectionViewHeightAndHorizontalBarHeight() {
        let height = bounds.height
        if height < 0 {
            horizontalBarViewHeightAnchorConstrain?.constant = 0
            menuBarCollectionViewHeightAnchorConstraint?.constant = 0
        } else  if height <= heightOfHorizontalBar {
            horizontalBarViewHeightAnchorConstrain?.constant = height
            menuBarCollectionViewHeightAnchorConstraint?.constant = 0
        } else if height <= height - heightOfHorizontalBar - padding {
            horizontalBarViewHeightAnchorConstrain?.constant = heightOfHorizontalBar
            menuBarCollectionViewHeightAnchorConstraint?.constant = 0
        } else {
            horizontalBarViewHeightAnchorConstrain?.constant = heightOfHorizontalBar
            menuBarCollectionViewHeightAnchorConstraint?.constant = height - heightOfHorizontalBar - padding
        }
        menuBarCollectionView.collectionViewLayout.invalidateLayout()  //inorder to update cell's size
    }
    
    internal func selectMenuItemAt(_ index: Int) {
        if menuItems.count > 0 && index < menuItems.count {
            let indexPath = IndexPath(item: index, section: 0)
            menuBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    internal func setHorizontalBarLeadingAnchorConstraint(_ constant: CGFloat) {
        horizontalBarLeadingAnchorConstraint?.constant = constant
    }
    
    // MARK: collectionView
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / CGFloat(menuItems.count), height: collectionView.frame.height)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let menuCell = cell as? MenuCellView {
            menuCell.selectedColor = selectedColor
            menuCell.notSelectedColor = notSelectedColor
            menuCell.item = menuItems[indexPath.row]
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuPageView?.scrollToMenuIndex(indexPath)
    }
}
