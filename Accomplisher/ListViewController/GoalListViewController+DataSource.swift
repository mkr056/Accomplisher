import UIKit
import RealmSwift

extension GoalListViewController { // manages the data in the collection view
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Goal.ID> // diffable data source updates and animates the UI when the data changes
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Goal.ID> // a snapshot represents the state of your data at a specific point in time
    
    func updateSnapshot(reloading idsThatChanged: [Goal.ID] = []) {
        
        let ids = idsThatChanged.filter { id in filteredGoals.contains(where: { $0.id == id })}
        var snapshot = Snapshot()
        snapshot.appendSections([0]) // adding a single section
        snapshot.appendItems(filteredGoals.map { $0.id }) //creates an array of identifiers
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        
        dataSource.apply(snapshot) // applying the snapshot reflects the changes in the UI
        // data source provides collection view with snapshots to display
        
        
        
    }
    
    public static func daysBetween(start: Date, end: Date) -> Int {
       Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    

    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Goal.ID) {
        let goal = goal(for: id) // retrieve the goal for the provided id
        var contentConfiguration = cell.defaultContentConfiguration() // retrieving the cell's default content configuration. defaultContentConfiguration creates a content configuration with the predefined system style
        goal.title.isEmpty ? (contentConfiguration.text = Goal.emptyTitle) : (contentConfiguration.text = goal.title)
        
        
        let dayDiff = GoalListViewController.daysBetween(start: Date(), end: goal.dueDate)
        if !goal.isComplete {
            if dayDiff < 0 {
                (dayDiff == -1) ? (contentConfiguration.secondaryText = "Accomplishment date expired by \(abs(dayDiff)) day") : (contentConfiguration.secondaryText = "Expired by \(abs(dayDiff)) days")
            } else {
                (dayDiff == 1) ? (contentConfiguration.secondaryText = "\(dayDiff) day left") : (contentConfiguration.secondaryText = "\(dayDiff) days left\n\(goal.dueDate.dayFormat)")
            }
        } else {
            contentConfiguration.secondaryText = ""
        }


        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration // set the appearance of the cells using a content configuration object
        cell.accessories = [.disclosureIndicator(displayed: .always)]
        
        let backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        cell.backgroundConfiguration = backgroundConfiguration
        
        
        
    }
    
    func add(_ goal: Goal) { // this method is used to save a new goal when the user taps the Done button
        //goals.insert(goal, at: 0)
        if goal.isComplete {
            listStyle = .complete
        } else {
            listStyle = .ongoing
        }
        listStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
        
        
    }
    
    
    func deleteGoal(with id: Goal.ID) { // removes a goal with the specified identifier
        guard let index = goals?.indexOfGoal(with: id) else { return }
        do {
            try realm.write {
                realm.delete((goals?[index])!)
            }
        } catch {
            print("Error deleting goal \(error)")
        }
        
    }
    
    func goal(for id: Goal.ID) -> Goal { // accepts a goal identifier and returns the corresponding goal from the goal array
        let index = goals?.indexOfGoal(with: id)
        
        return goals?[index ?? 0] ?? Goal()
    }
    

    
    func checkIfEmpty() {
        if goals?.isEmpty ?? true {
            footerView?.isHidden = false
            collectionView.isScrollEnabled = false
        } else {
            
            footerView?.isHidden = true
            collectionView.isScrollEnabled = true

        }
    }
}


