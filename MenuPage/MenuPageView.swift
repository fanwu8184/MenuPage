//
//  MenuWithContent.swift
//  workDictionary
//
//  Created by Fan Wu on 10/17/18.
//  Copyright © 2018 8184. All rights reserved.
//

import Foundation
import UIKit

class MenuPageView: BasicView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "PageCell"
    
    var menuPages = [MenuPage]() {
        didSet {
            pageCollectionView.reloadData()
            populateMenuBar()
            scrollToMenuIndex(IndexPath(item: 0, section: 0))  //need to set it back to origin
        }
    }
    
     private lazy var menuBarView: MenuBarView = {
        let mb = MenuBarView()
        mb.menuPageView = self
        return mb
    }()
    
    //The default setting of MenuBar Height
    var menuBarHeight: CGFloat = 50 {
        didSet {
            menuBarHeightConstraint?.constant = menuBarHeight
        }
    }
    
    var menuBarBackgroundColor: UIColor = .clear {
        didSet {
            menuBarView.backgroundColor = menuBarBackgroundColor
        }
    }
    
    var selectedMenuColor: UIColor! {
        didSet {
            menuBarView.selectedColor = selectedMenuColor
        }
    }
    var notSelectedMenuColor: UIColor! {
        didSet {
            menuBarView.notSelectedColor = notSelectedMenuColor
        }
    }
    
    var horizontalMenuBarColor: UIColor! {
        didSet {
            menuBarView.horizontalBarColor = horizontalMenuBarColor
        }
    }
    
    private lazy var pageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PageCellView.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private var menuBarHeightConstraint: NSLayoutConstraint?
    private var pageCollectionViewHeightAnchorConstraint: NSLayoutConstraint?
    
    convenience init(_ menuPages: [MenuPage]) {
        self.init(frame: .zero)
        self.menuPages = menuPages
        populateMenuBar()
    }
    
    internal override func setupViews() {
        super.setupViews()
        setupMenuBarView()
        setupPageCollectionView()
    }
    
    private func setupMenuBarView(){
        addSubview(menuBarView)
        menuBarView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        menuBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        menuBarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        menuBarHeightConstraint = menuBarView.heightAnchor.constraint(equalToConstant: menuBarHeight)
        menuBarHeightConstraint?.isActive = true
    }
    
    private func setupPageCollectionView() {
        addSubview(pageCollectionView)
        pageCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        pageCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        pageCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        pageCollectionViewHeightAnchorConstraint = pageCollectionView.heightAnchor.constraint(equalToConstant: 0)
        pageCollectionViewHeightAnchorConstraint?.isActive = true
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        updatePageCollectionViewHeight()
    }
    
    private func updatePageCollectionViewHeight() {
        if menuBarHeight > bounds.height {
            menuBarHeight = bounds.height
            pageCollectionViewHeightAnchorConstraint?.constant = 0
        } else {
            pageCollectionViewHeightAnchorConstraint?.constant = bounds.height - menuBarHeight
        }
        pageCollectionView.collectionViewLayout.invalidateLayout()  //inorder to update cell's size
    }
    
    private func populateMenuBar() {
        menuBarView.menuItems = menuPages.map({ $0.menuView })
    }
    
    internal func scrollToMenuIndex(_ indexPath: IndexPath) {
        if indexPath.row >= 0 && indexPath.row < menuPages.count {
            pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    // MARK: scrollView
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if menuPages.count > 0 {
            menuBarView.setHorizontalBarLeadingAnchorConstraint(scrollView.contentOffset.x / CGFloat(menuPages.count))
        }
    }

    internal func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / frame.width)
        menuBarView.selectMenuItemAt(index)
    }
    
    // MARK: collectionView
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuPages.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let pageCell = cell as? PageCellView {
            pageCell.page = menuPages[indexPath.row].pageView
        }
    }
}
