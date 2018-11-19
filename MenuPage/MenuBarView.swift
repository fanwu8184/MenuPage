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
    
    private var currentIndex = IndexPath(item: 0, section: 0) {
        didSet {
            selectMenuItemAt(currentIndex)
            updateSelectedCellX()
            updateMenuCellUI(oldValue)
            updateMenuCellUI(currentIndex)
            menuPageView?.scrollToMenuIndex(currentIndex)
            menuPageView?.currentIndexDidChange?(currentIndex)
        }
    }
    
    var menuPageView: MenuPageView?
    //default colors
    var selectedColor: UIColor = .red {
        didSet {
            menuBarCollectionView.visibleCells.forEach { (cell) in
                if let menuCell = cell as? MenuCellView {
                    menuCell.selectedColor = selectedColor
                    menuCell.updateUI()
                }
            }
        }
    }
    
    var heightOfHorizontalBar: CGFloat = 4 {
        didSet {
            if oldValue != heightOfHorizontalBar {
                updateMenuBarCollectionViewHeightAndHorizontalBarHeight()
            }
        }
    }
    var paddingBetweenHorizontalBarAndMenuBarCollectionView: CGFloat = 4 {
        didSet {
            if oldValue != paddingBetweenHorizontalBarAndMenuBarCollectionView {
                updateMenuBarCollectionViewHeightAndHorizontalBarHeight()
            }
        }
    }
    
    var columnsOfMenuOnScreen = 5 {
        didSet {
            if oldValue != columnsOfMenuOnScreen {
                reset()
            }
        }
    }
    
    var notSelectedColor: UIColor = .blue {
        didSet {
            menuBarCollectionView.visibleCells.forEach { (cell) in
                if let menuCell = cell as? MenuCellView {
                    menuCell.notSelectedColor = notSelectedColor
                    menuCell.updateUI()
                }
            }
        }
    }
    
    var horizontalBarColor: UIColor = .lightGray {
        didSet {
            horizontalBarView.backgroundColor = horizontalBarColor
        }
    }
    
    var expandIndicatorColor: UIColor = .black {
        didSet {
            leadingExpandView.setTitleColor(expandIndicatorColor, for: .normal)
            trailingExpandView.setTitleColor(expandIndicatorColor, for: .normal)
        }
    }
    
    var menuItems = [UIView]() {
        didSet {
            currentIndex = IndexPath(item: 0, section: 0)
            reset()
        }
    }
    
    //x value of selected Cell in the collection view
    private var selectedCellX: CGFloat = 0 {
        didSet {
            setHorizontalBarLeadingAnchorConstraint()
            updateIndicationViewConstraint()
            Animation.generalAnimate(animations: { self.layoutIfNeeded() })
        }
    }
    
    //x value of scrill view contentOffset
    private var scrollViewContentOffsetX: CGFloat = 0 {
        didSet {
            if oldValue != scrollViewContentOffsetX {
                setHorizontalBarLeadingAnchorConstraint()
                updateIndicationViewConstraint()
            }
        }
    }
    
    private var menuItemWidth: CGFloat {
        if menuItems.count > columnsOfMenuOnScreen {
            return bounds.width / CGFloat(columnsOfMenuOnScreen)
        }
        return (menuItems.count == 0) ? 0 : bounds.width / CGFloat(menuItems.count)
    }
    
    private lazy var menuBarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MenuCellView.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var horizontalBarView: UIView = {
        let view = UIView()
        view.backgroundColor = horizontalBarColor
        return view
    }()
    
    private lazy var leadingExpandView: UIButton = {
        let button = UIButton()
        button.setTitle("⟨", for: .normal)
        button.setTitleColor(expandIndicatorColor, for: .normal)
        button.addTarget(self, action: #selector(leadingExpand), for: .touchUpInside)
        return button
        }()
    
    private lazy var trailingExpandView: UIButton = {
        let button = UIButton()
        button.setTitle("⟩", for: .normal)
        button.setTitleColor(expandIndicatorColor, for: .normal)
        button.addTarget(self, action: #selector(trailingExpand), for: .touchUpInside)
        return button
    }()
    
    private var maxIndex = 0
    private var minIndex = 0
    var isMenuOut = false
    private var saveCellHeight: CGFloat = 0
    
    let indicationView = UIView()
    
    override var bounds: CGRect {
        didSet {
            updateMenuBarCollectionViewHeightAndHorizontalBarHeight()
            updateHorizontalBarWidth()
            
            //In order to update UI after device rotation
            layoutIfNeeded()
            self.menuBarCollectionView.scrollToItem(at: self.currentIndex, at: [], animated: true)
            self.updateSelectedCellX()
        }
    }
    
    private var menuBarCollectionViewHeightAnchorConstraint: NSLayoutConstraint?
    private var horizontalBarViewHeightAnchorConstrain: NSLayoutConstraint?
    private var horizontalBarViewWidthAnchorConstraint: NSLayoutConstraint?
    private var horizontalBarLeadingAnchorConstraint: NSLayoutConstraint?
    
    private var indicationViewLeftConstraint: NSLayoutConstraint?
    private var indicationViewTopConstraint: NSLayoutConstraint?
    private var indicationViewHeightConstraint: NSLayoutConstraint?
    private var indicationViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: Setup Functions
    override func setupViews() {
        super.setupViews()
        setupIndicationView()
        setupMenuBarCollectionView()
        setupHorizontalBar()
        setupExpandViews()
    }
    
    private func setupMenuBarCollectionView() {
        addSubview(menuBarCollectionView)
        menuBarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        menuBarCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        menuBarCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        menuBarCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        menuBarCollectionViewHeightAnchorConstraint = menuBarCollectionView.heightAnchor.constraint(equalToConstant: 0)
        menuBarCollectionViewHeightAnchorConstraint?.isActive = true
    }
    
     private func setupHorizontalBar() {
        addSubview(horizontalBarView)
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        horizontalBarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        horizontalBarViewHeightAnchorConstrain = horizontalBarView.heightAnchor.constraint(equalToConstant: 0)
        horizontalBarViewHeightAnchorConstrain?.isActive = true
        horizontalBarViewWidthAnchorConstraint = horizontalBarView.widthAnchor.constraint(equalToConstant: 0)
        horizontalBarViewWidthAnchorConstraint?.isActive = true
        horizontalBarLeadingAnchorConstraint = horizontalBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        horizontalBarLeadingAnchorConstraint?.isActive = true
    }
    
    private func setupExpandViews() {
        addSubview(leadingExpandView)
        addSubview(trailingExpandView)
        leadingExpandView.translatesAutoresizingMaskIntoConstraints = false
        trailingExpandView.translatesAutoresizingMaskIntoConstraints = false
        leadingExpandView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        leadingExpandView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        leadingExpandView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        leadingExpandView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        trailingExpandView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        trailingExpandView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        trailingExpandView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        trailingExpandView.widthAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    private func setupIndicationView() {
        addSubview(indicationView)
        indicationView.translatesAutoresizingMaskIntoConstraints = false
        indicationViewLeftConstraint = indicationView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        indicationViewTopConstraint = indicationView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        indicationViewHeightConstraint = indicationView.heightAnchor.constraint(equalToConstant: 0)
        indicationViewWidthConstraint = indicationView.widthAnchor.constraint(equalToConstant: 0)
        indicationViewLeftConstraint?.isActive = true
        indicationViewTopConstraint?.isActive = true
        indicationViewHeightConstraint?.isActive = true
        indicationViewWidthConstraint?.isActive = true
    }
    
    // MARK: HorizontalBar Functions
    private func updateHorizontalBarWidth() {
        horizontalBarViewWidthAnchorConstraint?.constant = menuItemWidth
    }
    
    private func setHorizontalBarLeadingAnchorConstraint() {
        horizontalBarLeadingAnchorConstraint?.constant = selectedCellX - scrollViewContentOffsetX
    }
    
    // MARK: HorizontalBar And MenuBarCollectionView Functions
    private func updateMenuBarCollectionViewHeightAndHorizontalBarHeight() {
        let height = bounds.height
        if height < 0 {
            horizontalBarViewHeightAnchorConstrain?.constant = 0
            menuBarCollectionViewHeightAnchorConstraint?.constant = 0
        } else  if height <= heightOfHorizontalBar {
            horizontalBarViewHeightAnchorConstrain?.constant = height
            menuBarCollectionViewHeightAnchorConstraint?.constant = 0
        } else if height <= heightOfHorizontalBar + paddingBetweenHorizontalBarAndMenuBarCollectionView {
            horizontalBarViewHeightAnchorConstrain?.constant = heightOfHorizontalBar
            menuBarCollectionViewHeightAnchorConstraint?.constant = 0
        } else {
            horizontalBarViewHeightAnchorConstrain?.constant = heightOfHorizontalBar
            menuBarCollectionViewHeightAnchorConstraint?.constant = height - heightOfHorizontalBar - paddingBetweenHorizontalBarAndMenuBarCollectionView
        }
        //need to update cell's size
        menuBarCollectionView.collectionViewLayout.invalidateLayout()
        menuBarCollectionView.layoutIfNeeded()
        layoutIfNeeded()
        updateIndicationViewConstraint()
    }
    
    // MARK: ExpandView Functions
    private func updateExpandView() {
        let indexsOfVisibleItems = menuBarCollectionView.indexPathsForVisibleItems.map { $0.row }
        
        if let max = indexsOfVisibleItems.max() {
            maxIndex = max
            if maxIndex + 1 < menuItems.count {
                trailingExpandView.isHidden = false
            } else {
                trailingExpandView.isHidden = true
            }
        }
        
        if let min = indexsOfVisibleItems.min() {
            minIndex = min
            if minIndex > 0 {
                leadingExpandView.isHidden = false
            } else {
                leadingExpandView.isHidden = true
            }
        }
    }
    
    @objc private func leadingExpand() {
        let indexPath = IndexPath(item: minIndex - 1, section: 0)
        menuBarCollectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }
    
    @objc private func trailingExpand() {
        let indexPath = IndexPath(item: maxIndex + 1, section: 0)
        menuBarCollectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }
    
    // MARK: IndicationView Constraints Funtions
    private func updateIndicationViewConstraint() {
        if let seletedCell = menuBarCollectionView.cellForItem(at: currentIndex) {
            indicationViewLeftConstraint?.constant = menuBarCollectionView.frame.origin.x + seletedCell.frame.origin.x - scrollViewContentOffsetX
            indicationViewTopConstraint?.constant = menuBarCollectionView.frame.origin.y + seletedCell.frame.origin.y
            indicationViewHeightConstraint?.constant = seletedCell.frame.height
            indicationViewWidthConstraint?.constant = seletedCell.frame.width
        }
    }
    
    // MARK: Miscellaneous Functions
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateExpandView()
    }
    
    private func updateSelectedCellX() {
        if let seletedCell = menuBarCollectionView.cellForItem(at: currentIndex) {
            selectedCellX = seletedCell.frame.origin.x
        }
    }
    
    func getCurrentIndex() -> IndexPath {
        return currentIndex
    }
    
    func setCurrentIndex(_ indexPath: IndexPath) {
        if indexPath.row < menuItems.count {
            currentIndex = indexPath
        }
    }
    
    private func selectMenuItemAt(_ indexPath: IndexPath) {
        if menuItems.count > 0 && indexPath.row < menuItems.count {
            menuBarCollectionView.scrollToItem(at: indexPath, at: [], animated: true)
            menuBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
    }
    
    private func reset() {
        menuBarCollectionView.reloadData()
        selectMenuItemAt(currentIndex)
        updateHorizontalBarWidth()
        layoutIfNeeded()
        updateIndicationViewConstraint()
        Animation.generalAnimate(animations: { self.layoutIfNeeded() })
    }
    
    private func updateMenuCellUI(_ indexPath: IndexPath) {
        if let menuCell = menuBarCollectionView.cellForItem(at: indexPath) as? MenuCellView {
            menuCell.updateUI()
        }
    }
    
    // MARK: ScrollView Functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewContentOffsetX = scrollView.contentOffset.x
    }
    
    // MARK: CollectionView Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isMenuOut {
            return CGSize(width: menuItemWidth, height: saveCellHeight)
        }
        saveCellHeight = collectionView.frame.height
        return CGSize(width: menuItemWidth, height: saveCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let menuCell = cell as? MenuCellView {
            
            menuCell.selectedColor = selectedColor
            menuCell.notSelectedColor = notSelectedColor
            menuCell.item = menuItems[indexPath.row]
            
            //not visible cells cause problems (selectMenuItemAt not working properly), so have to run the code below to update UI
            if indexPath == currentIndex {
                menuCell.isSelected = true
                menuCell.updateUI()
                selectedCellX = menuCell.frame.origin.x
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath
    }
}
