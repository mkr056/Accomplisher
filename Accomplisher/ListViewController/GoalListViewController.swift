import UIKit
import RealmSwift

class GoalListViewController: UICollectionViewController {
    // A collection view with a list layout that displays the user's goals
    
    let realm = try! Realm()
    
    var dataSource: DataSource!
    var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped) // UICollectionLayoutListConfiguration creates a section in a list layout
    var goals: Results<Goal>? {
        didSet {
            checkIfEmpty()
        }
    }
    var filteredGoals: [Goal] { // stores a collection of goals for the given list style
        return (goals?.filter { self.listStyle.shouldInclude(goal: $0) }.sorted { $0.dueDate < $1.dueDate }) ?? [Goal()]
    }
    
    var listStyle: GoalListStyle = .ongoing
    let listStyleSegmentedControl = UISegmentedControl(items: [
        GoalListStyle.ongoing.name, GoalListStyle.complete.name
    ])
    
    
    var headerView: QuoteHeaderView?
    var footerView: GoalFooterView?
    
    
    var isAddingNewQuote: Bool = false
    var isEditingQuote: Bool = false
    var indexOfModificationQuote = 0
    var currentQuoteIndex = 0
    
    var shouldShowCelebrationScreen: Bool?
    var goalId: String?

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        updateSnapshot()

        if let show = shouldShowCelebrationScreen {
            if show {
                listStyle = .complete
                listStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
                let vc = CelebrationViewController()
                if #available(iOS 15.0, *) {
                    if let sheet = vc.sheetPresentationController {
                        sheet.detents = [.medium()]
                        present(vc, animated: true)
                    }
                } else {
                    present(vc, animated: true)

                }
                if goalId != nil {
                    updateSnapshot(reloading: [goalId!])
                } else {
                    updateSnapshot()
                }
                
            } else {
                
            }
        } else {
            collectionView.reloadData()
        }

        
        
        
    }
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let listLayout = listLayout()

        collectionView.collectionViewLayout = listLayout // assigning the list layout the collection view layout
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler) // Cell Registration specifies how to configure the content and appearance of a cell
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Goal.ID) in
            // connecting the diffable data source to the collection view by passing in the collection view to the diffable data source initializer
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            // configuring and returning a cell for a collection view
              
            
        }
        
        
        let headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: QuoteHeaderView.elementKind, handler: headerRegistrationHandler)
        let footerRegistration = UICollectionView.SupplementaryRegistration(elementKind: GoalFooterView.elementKind, handler: footerRegistrationHandler)
       
        
        dataSource.supplementaryViewProvider = { supplementaryView, elementKind, indexPath in

            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            case UICollectionView.elementKindSectionFooter:
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
            default:
                assert(false, "Unexpected element kind")
                return UICollectionReusableView()
            }
        }
        
        
        
        
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add Goal", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        
        listStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue // when the view first appears, the current listStyle should be selected in the segmented control
        listStyleSegmentedControl.addTarget(self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentedControl
        collectionView.showsVerticalScrollIndicator = false
        
        loadGoals()
        // updateSnapshot()
        
        
        
        
        collectionView.dataSource = dataSource
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isAddingNewQuote = false
        isEditingQuote = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredGoals[indexPath.item].id
        showDetail(for: id)
        return false
    }
    
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        // configuring the collection view appearance using compositional layout
        // this function creates a new list configuration variable with the grouped appearance
        // defines how the list appears using a predefined configuration as a starting point
        
        
        listConfiguration.headerMode = .supplementary
        listConfiguration.footerMode = .supplementary
        
        
        
        
        listConfiguration.showsSeparators = true
        
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        
        
        return UICollectionViewCompositionalLayout.list(using: listConfiguration) // returns a new compositional layout with the list configuration
        
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? { // A UISwipeActionsConfiguration object associates custom swipe actions with a row in a list. This function generates a configuration for each item in the list.
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, completion in
            // Each swipe action configuration object contains a set of UIContextualAction objects that defines the actions a user can perform by left or right swiping.
            self?.deleteGoal(with: id)
            self?.updateSnapshot()
            self?.collectionView.reloadData()
            
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
    
    private func headerRegistrationHandler(quoteView: QuoteHeaderView, elementKind: String, indexPath: IndexPath) {
        
        headerView = quoteView

        QuoteHeaderView.addQuoteButtonClicked = { [weak self] in
            self?.addQuote(alert: UIAlertAction())
        }
        
        QuoteHeaderView.goToEditQuote = { [weak self] in
            self?.editNote(alert: UIAlertAction())
        }
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap))
        longGesture.minimumPressDuration = 0.2
        headerView?.quoteLabel.addGestureRecognizer(longGesture)
        headerView?.quoteLabel.isUserInteractionEnabled = true
        loadQuotes()
        if isAddingNewQuote {
            headerView?.counter = (headerView?.quotes!.count)! - 1
        } else if isEditingQuote {
            headerView?.counter = indexOfModificationQuote
        } else {
            (headerView?.quotes?.isEmpty ?? true) ? (currentQuoteIndex = 0) : (currentQuoteIndex = Int.random(in: 0..<(headerView?.quotes?.count ?? 0)))
            
            headerView?.counter = currentQuoteIndex
        }
        
        (headerView?.quotes?.isEmpty ?? true) ? (headerView?.tap?.isEnabled = false) : (headerView?.tap?.isEnabled = true)
        


        
    }
    
    private func footerRegistrationHandler(progressView: GoalFooterView, elementKind: String, indexPath: IndexPath) {
        footerView = progressView
        GoalFooterView.addGoalButtonClicked = { [weak self] in
            self?.addGoal(alert: UIAlertAction())
        }
        
        checkIfEmpty()
    }
    
    
    @objc func longTap(sender : UIGestureRecognizer){
        var timer = Timer()
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(showAlert), userInfo: nil, repeats: false)
        }
        
        if sender.state == .ended {
            timer.invalidate()
            
        }
        
    }
    
    @objc func showAlert() {
        let ac = UIAlertController(title: "Choose action", message: "What do you want to do with the note", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Edit", style: .default, handler: editNote))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteNote))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        guard let currentQuotes = headerView?.quotes else { return }
        if currentQuotes.isEmpty {
            return
        }
        present(ac, animated: true)
    }
    
    func editNote(alert: UIAlertAction) {
        let vc = NewQuoteViewController()
        

        NewQuoteViewController.removeQuote = { [weak self] in
            self?.deleteNote(alert: UIAlertAction())
        }

        vc.quoteToEdit = headerView?.quotes?[headerView!.counter]
        
        vc.delegate = self
        vc.navigationItem.title = "Edit your quote"
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func deleteNote(alert: UIAlertAction) {
        
        guard let index = headerView?.counter else { return }
        
        do {
            try realm.write {
                if index == 0 {
                    realm.delete((headerView?.quotes?[index])!)
                    headerView?.counter = 0
                } else {
                    realm.delete((headerView?.quotes?[index])!)
                    headerView?.counter -= 1
                }                
            }
        } catch {
            print("Error deleting quote \(error)")
        }
        
        if (headerView?.quotes?.isEmpty) ?? false {
            collectionView.reloadData()
        }
        
        
        
    }
    
    
    func loadGoals() {
        goals = realm.objects(Goal.self)
    }
    
    func save(goal: Goal) {
        do {
            try realm.write {
                realm.add(goal)
            }
        } catch {
            print("Error saving goal \(error)")
        }
        collectionView.reloadData()
    }
   
    
    func loadQuotes() {
        headerView?.quotes = realm.objects(Quote.self)
        // collectionView.reloadData()
    }
    
    func save(quote: Quote) {
        do {
            try realm.write {
                realm.add(quote)
            }
        } catch {
            print("Error saving quote \(error)")
        }
        collectionView.reloadData()
    }
    


    

    
}


extension GoalListViewController: AddNewQuoteDelegate, GoalViewControllerDelegate {
    
    func editExistingQuote(old: String, new: String) {
        guard let index = headerView?.counter else { return }
        indexOfModificationQuote = index
        if new.isEmpty {
            print("HERE")
           deleteNote(alert: UIAlertAction())
            return
        }
        do {
            try realm.write {
                
                headerView?.quotes?[index].quoteText = new
            }
            
        } catch {
            print("Error updating quote text \(error)")
        }
        isEditingQuote = true
        collectionView.reloadData()
    }
    
    func addQuote(quote: String) {
        if quote.isEmpty {
            currentQuoteIndex = headerView!.counter
            return
        }
        let newQuote = Quote()
        
        newQuote.quoteText = quote
        self.save(quote: newQuote)
        isAddingNewQuote = true
        
    }
    
    func sendData(value: Bool, id: String) {
        shouldShowCelebrationScreen = value
        goalId = id
        
    }
    
}

