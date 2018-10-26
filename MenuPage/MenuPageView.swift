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
    
    var currentIndexDidChange: ((Int)->())?
    private var currentIndex: Int! {
        didSet {
            if oldValue != currentIndex {
                currentIndexDidChange?(currentIndex)
            }
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
            updatePosition(true)
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
    
    var isMenuBarAtTop = true {
        didSet {
            updatePosition(true)
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updatePosition(false)  //animation at the begining will cause errors
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
    
    private var menuBarTopConstraint: NSLayoutConstraint?
    private var menuBarHeightConstraint: NSLayoutConstraint?
    private var pageCollectionViewBottomConstraint: NSLayoutConstraint?
    private var pageCollectionViewHeightConstraint: NSLayoutConstraint?
    
    convenience init(menuPages: [MenuPage], currentIndexDidChange: ((Int)->())? = nil) {
        self.init(frame: .zero)
        self.menuPages = menuPages
        self.currentIndexDidChange = currentIndexDidChange
        populateMenuBar()
    }
    
    override func setupViews() {
        super.setupViews()
        setupPageCollectionView()
        setupMenuBarView()
    }
    
    private func setupMenuBarView(){
        addSubview(menuBarView)
        menuBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        menuBarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        menuBarTopConstraint = menuBarView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        menuBarTopConstraint?.isActive = true
        menuBarHeightConstraint = menuBarView.heightAnchor.constraint(equalToConstant: menuBarHeight)
        menuBarHeightConstraint?.isActive = true
    }
    
    private func setupPageCollectionView() {
        addSubview(pageCollectionView)
        pageCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        pageCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        pageCollectionViewBottomConstraint = pageCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        pageCollectionViewBottomConstraint?.isActive = true
        pageCollectionViewHeightConstraint = pageCollectionView.heightAnchor.constraint(equalToConstant: 0)
        pageCollectionViewHeightConstraint?.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePageCollectionViewHeight()
        scrollToMenuIndex(IndexPath(item: currentIndex, section: 0))  //fix rotation bug
    }
    
    private func updatePageCollectionViewHeight() {
        if menuBarHeight > bounds.height {
            menuBarHeight = bounds.height
            pageCollectionViewHeightConstraint?.constant = 0
        } else {
            pageCollectionViewHeightConstraint?.constant = bounds.height - menuBarHeight
        }
        //inorder to update cell's size
        pageCollectionView.collectionViewLayout.invalidateLayout()
        pageCollectionView.layoutIfNeeded()
    }
    
    private func updatePosition(_ animation: Bool) {
        if isMenuBarAtTop {
            menuBarTopConstraint?.constant = 0
            pageCollectionViewBottomConstraint?.constant = 0
        } else {
            menuBarTopConstraint?.constant = frame.height - menuBarHeight
            pageCollectionViewBottomConstraint?.constant = -menuBarHeight
        }
        
        if animation {
            animate()
        }
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func populateMenuBar() {
        menuBarView.menuItems = menuPages.map({ $0.menuView })
    }
    
    func scrollToMenuIndex(_ indexPath: IndexPath) {
        if indexPath.row >= 0 && indexPath.row < menuPages.count {
            currentIndex = indexPath.row
            pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    // MARK: scrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if menuPages.count > 0 {
            menuBarView.setHorizontalBarLeadingAnchorConstraint(scrollView.contentOffset.x / CGFloat(menuPages.count))
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        currentIndex = Int(targetContentOffset.pointee.x / frame.width)
        menuBarView.selectMenuItemAt(currentIndex)
    }
    
    // MARK: collectionView
    func setPagesBounce(_ bounce: Bool) {
        pageCollectionView.bounces = bounce
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let pageCell = cell as? PageCellView {
            pageCell.page = menuPages[indexPath.row].pageView
        }
    }
}
