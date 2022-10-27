//
//  GoalViewController.swift
//  Accomplisher
//
//  Created by Artem Mkr on 09.08.2022.
//

import UIKit
import RealmSwift
import SwiftUI

class GoalViewController: UICollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    let realm = try! Realm()
    
    var goal: Goal {
        didSet {
            onChange(goal)
        }
    }
    var workingGoal: Goal // stores the edits until the user chooses to save or discard them
    var isAddingNewGoal = false // indicates whether the user is adding a new reminder, or viewing or editing an existing one
    var onChange: (Goal) -> Void
    private var dataSource: DataSource!
    
    
    private var editingSnapshot: Snapshot!
    
    
    var isTitleFilled = false
    var isPriceFilled = false
    var isPriceLabelTapped = false
    
    var showCelebrationScreen = false
    var initialCompletionStatus = false
    var finalCompletionStatus = false
    
    
    var delegate: GoalViewControllerDelegate?
    
    
    
    init(goal: Goal, onChange: @escaping (Goal)->Void) {
        self.goal = goal
        
        workingGoal = Goal(value: goal)
        // self.workingGoal = Goal(value: goal)
        
        
        
        self.onChange = onChange
        
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        listConfiguration.headerMode = .firstItemInSection
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        super.init(collectionViewLayout: listLayout)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialize GoalViewController using init(goal:)")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if isEditing {
            editingSnapshot.reloadItems([.header(Section.currency.name)])
            editingSnapshot.reloadSections([.currency])
            dataSource.apply(editingSnapshot)
            isPriceLabelTapped = false
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Row) in
            collectionView.allowsSelectionDuringEditing = true
            collectionView.keyboardDismissMode = .interactive
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        
        navigationItem.title = NSLocalizedString("Goal", comment: "Goal view controller title")
        navigationItem.rightBarButtonItem = editButtonItem
        
        self.tabBarController?.tabBar.isHidden = false
        
        navigationController?.tabBarItem.title = "Goal Info"
        navigationController?.tabBarItem.image = UIImage(systemName: "star.fill")
        
        
        if var controllers = tabBarController?.viewControllers {
            
            let tabItem = UITabBarItem(title: "Motivation", image: UIImage(systemName: "flame.fill"), selectedImage: nil)
            
            let layout = UICollectionViewFlowLayout()
            
            let myVC = GoalMotivationViewController(collectionViewLayout: layout)
            myVC.selectedGoal = goal
            
            let navCon = UINavigationController(rootViewController: myVC)
            navCon.navigationBar.tintColor = .label
            navCon.navigationBar.backgroundColor = .label
            
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navCon.navigationBar.scrollEdgeAppearance = navBarAppearance
            navCon.tabBarItem = tabItem
            if controllers.count != 2 {
                controllers.append(navCon)
            } else {
                controllers[1] = navCon
            }
            tabBarController?.setViewControllers(controllers, animated: true)
        }
        
        initialCompletionStatus = goal.isComplete
        updateSnapshotForViewing()
    }
    
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) { // called when the user taps the edit or done button
        super.setEditing(editing, animated: animated)
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Row) in
            //  collectionView.allowsSelection = false
            collectionView.allowsSelectionDuringEditing = true
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        if editing {
            prepareForEditing()
        } else {
            if !isAddingNewGoal {
                prepareForViewing()
            } else {
                
                onChange(workingGoal)
                
                
            }
            isPriceLabelTapped = false
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return (indexPath == IndexPath(row: 3, section: 0)) ? (true) : (false)
    }
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let section = section(for: indexPath) // retrieve the section from the index path
        switch (section, row) { // configure cells for different section and row combination
        case (_, .header(let title)): // this case configures the title for every section
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
            
        case (.view, _):
            cell.contentConfiguration = defaultConfiguration(for: cell, at: row)
        case (.title, .editTitleText(let title)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: title)
        case (.date, .editDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case (.price, .editPriceText(let price)):
            
            cell.contentConfiguration = priceConfiguration(for: cell, with: price)
            (isPriceLabelTapped) ? (cell.viewWithTag(1)?.becomeFirstResponder()) : (cell.viewWithTag(1)?.resignFirstResponder())
            
            
        case (.budget, .editBudgetText(let budget)):
            cell.contentConfiguration = budgetConfiguration(for: cell, with: budget)
        case (.currency, .editCurrencyText(let currency)):
            cell.contentConfiguration = currencyConfiguration(for: cell, with: currency)
            
        default:
            fatalError("Unexpected combination of section and row")
        }
        
        cell.tintColor = .label
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 3, section: 0) {
            isPriceLabelTapped = true
            
            setEditing(true, animated: true)
            //prepareForEditing()
            isEditing = true
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        finalCompletionStatus = goal.isComplete
        
        print(initialCompletionStatus)
        print(finalCompletionStatus)
        if initialCompletionStatus == false && finalCompletionStatus == true {
            showCelebrationScreen = true
            delegate?.sendData(value: showCelebrationScreen, id: goal.id)
            print("YES")
        } else {
            showCelebrationScreen = false
            delegate?.sendData(value: showCelebrationScreen, id: goal.id)
            
            print("NO")
        }
    }
    
    
    
    @objc func didCancelEdit() {
        workingGoal = Goal(value: goal)
        
        setEditing(false, animated: true)
    }
    
    private func prepareForEditing() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelEdit))
        navigationItem.rightBarButtonItem?.isEnabled = false
        updateSnapshotForEditing()
    }
    
    private func updateSnapshotForEditing() {
        collectionView.isScrollEnabled = true
        
        editingSnapshot = Snapshot()
        editingSnapshot.appendSections([.title, .date, .price, .budget, .currency])
        editingSnapshot.appendItems([.header(Section.title.name), .editTitleText(goal.title)], toSection: .title)
        editingSnapshot.appendItems([.header(Section.date.name), .editDate(goal.dueDate)], toSection: .date)
        editingSnapshot.appendItems([.header(Section.price.name), .editPriceText(goal.price.description)], toSection: .price)
        editingSnapshot.appendItems([.header(Section.budget.name), .editBudgetText(goal.budget.description)], toSection: .budget)
        editingSnapshot.appendItems([.header(Section.currency.name), .editCurrencyText("Currency")], toSection: .currency)
        
        dataSource.apply(editingSnapshot)
        
        
    }
    
    private func prepareForViewing() { // if the user made changes to the working reminder in the editing mode, copy the edits into the goal property that view mode displays
        
        collectionView.layoutIfNeeded()
        
        navigationItem.leftBarButtonItem = nil
        
        if workingGoal.title != goal.title || workingGoal.dueDate != goal.dueDate || workingGoal.price != goal.price || workingGoal.budget != goal.budget {
            goal = Goal(value: workingGoal)
            try? realm.write {
                realm.add(goal, update: .all)
            }
        }
        
        updateSnapshotForViewing()
        
    }
    
    private func updateSnapshotForViewing() {
        
        collectionView.isScrollEnabled = false
        
        var viewingSnapshot = Snapshot()
        viewingSnapshot.appendSections([.view])
        switch goal.selectedCurrency {
            
        case Currency.Dollar.rawValue:
            viewingSnapshot.appendItems([.header(""), .viewTitle, .viewDate, .viewPriceInDollar, .viewBudget, .viewIsComplete], toSection: .view)
        case Currency.Euro.rawValue:
            viewingSnapshot.appendItems([.header(""), .viewTitle, .viewDate, .viewPriceInEuro, .viewBudget, .viewIsComplete], toSection: .view)
        default:
            viewingSnapshot.appendItems([.header(""), .viewTitle, .viewDate, .viewPriceInLocal, .viewBudget, .viewIsComplete], toSection: .view)
        }
        dataSource.apply(viewingSnapshot)
    }
    
    private func section(for indexPath: IndexPath) -> Section { // accepts an index path and returns a Section
        let sectionNumber = isEditing ? indexPath.section + 1: indexPath.section // Int editing mode, all properties are separated into section 1,2,3..etc
        guard let section = Section(rawValue: sectionNumber) else { // creating an instance of Section
            fatalError("Unable to find matching section") // the raw value is outside the defined range
        }
        return section
    }
    
}
   


protocol GoalViewControllerDelegate {
    func sendData(value: Bool, id: String)
}
