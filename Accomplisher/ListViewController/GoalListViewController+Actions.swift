import UIKit

extension GoalListViewController {
    
    @objc func didPressAddButton(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Add New Quote", style: .default, handler: addQuote))
        ac.addAction(UIAlertAction(title: "Add New Goal", style: .default, handler: addGoal))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac,animated: true)
    }
    
    @objc func addQuote(alert: UIAlertAction) {
        let controller = NewQuoteViewController()
        
        controller.delegate = self
        controller.navigationItem.title = "Add quote"
        
        
        navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    
    
    
    
    
    @objc func addGoal(alert: UIAlertAction) {
        let goal = Goal()
        let viewController = GoalViewController(goal: goal) { [weak self] goal in
            self?.add(goal)
            self?.save(goal: goal)
            self?.updateSnapshot()
            
            self?.dismiss(animated: true)
        }
        viewController.isAddingNewGoal = true
        viewController.setEditing(true, animated: false)
        viewController.collectionView.keyboardDismissMode = .interactive
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAdd(_:)))
        viewController.navigationItem.title = NSLocalizedString("Add Goal", comment: "Add Goal view controller title")
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    @objc func didCancelAdd(_ sender: UIBarButtonItem) { // this function dismisses the view controller
        dismiss(animated: true)
    }
    
    @objc func didChangeListStyle(_ sender: UISegmentedControl) {
        listStyle = GoalListStyle(rawValue: sender.selectedSegmentIndex) ?? .ongoing
        updateSnapshot()
    }
    
    
    
    func showDetail(for id: Goal.ID) {
        let goal = goal(for: id)
        let progVC = ProgressViewController()
        progVC.selectedGoal = goal
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.pushViewController(progVC, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            
            let viewController = GoalViewController(goal: goal) { [weak self] goal in
                
                self?.updateSnapshot(reloading: [goal.id]) // updates data in the goal list view controller
                
            }
            
            self?.navigationController?.setNavigationBarHidden(false, animated: false)
            self?.navigationController?.pushViewController(viewController, animated: true)
            self?.navigationController?.viewControllers.remove(at: 1)
            viewController.delegate = self
            
            
            
            
        }
        
        
        
    }
}
