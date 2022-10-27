import UIKit

extension GoalViewController {
    
    func defaultConfiguration(for cell: UICollectionViewListCell, at row: Row) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        // let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        // view.addGestureRecognizer(tap)
        return contentConfiguration
    }
    
    
    func headerConfiguration(for cell: UICollectionViewListCell, with title: String) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }
    
    func titleConfiguration(for cell: UICollectionViewListCell, with title: String?) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        checkTextFields(title: workingGoal.title, price: workingGoal.price)
        contentConfiguration.onChange = { [weak self] title in
            self?.workingGoal.title = title

            self?.checkTextFields(title: self?.workingGoal.title ?? "", price: self?.workingGoal.price ?? "")
        }
        
        return contentConfiguration
    }
    
    func dateConfiguration(for cell: UICollectionViewListCell, with date: Date) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.datePickerConfiguration()
        contentConfiguration.date = date
        contentConfiguration.onChange = { [weak self] dueDate in
            self?.workingGoal.dueDate = dueDate
        }
        return contentConfiguration
    }
    
    func priceConfiguration(for cell: UICollectionViewListCell, with price: String?) -> PriceTextFieldContentView.Configuration {
        var contentConfiguration = cell.priceTextFieldConfiguration() // in the original this is textview        
        contentConfiguration.text = price
        contentConfiguration.onChange = { [weak self] price in
            self?.workingGoal.price = price

            self?.checkTextFields(title: self?.workingGoal.title ?? "", price: self?.workingGoal.price ?? "")
        }
        return contentConfiguration
    }
    
    func budgetConfiguration(for cell: UICollectionViewListCell, with budget: String?) -> BudgetTextFieldContentView.Configuration {
        var contentConfiguration = cell.budgetTextFieldConfiguration()
        contentConfiguration.text = budget
        contentConfiguration.onChange = { [weak self] budget in
            self?.workingGoal.budget = budget
        }
        return contentConfiguration
    }
    
    func currencyConfiguration(for cell: UICollectionViewListCell, with currency: String?) -> CurrencyLabelContentView.Configuration {
        var contentConfiguration = cell.labelConfiguration()
        
        contentConfiguration.text = currency
        
        CurrencyLabelContentView.Configuration.action = { [weak self] in
            let currencyVC = CurrencyViewController(collectionViewLayout: UICollectionViewLayout())
            currencyVC.selectedGoal = self?.goal
            self?.navigationController?.pushViewController(currencyVC, animated: true)
        }
        cell.accessories = [.label(text: goal.selectedCurrency), .disclosureIndicator()]
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        cell.addGestureRecognizer(tap)
        
        
        contentConfiguration.onChange = { [weak self] currency in
            self?.workingGoal.selectedCurrency = currency
        }
        return contentConfiguration
    }
    
    @objc func tapAction() {
        CurrencyLabelContentView.Configuration.action()
    }

    
    
    func text(for row: Row) -> String? { // returns the text associated with the given row
        
        
        
        switch row {
        case .viewDate: return goal.dueDate.dayFormat
        case .viewPriceInLocal:
            
            return Int(goal.price)?.amountFormat ?? Int("0")?.amountFormat
        case .viewPriceInDollar:
            return Int(goal.price)?.dollarFormat ?? Int("0")?.dollarFormat
        case .viewPriceInEuro:
            return Int(goal.price)?.euroFormat ?? Int("0")?.euroFormat
            
            
        case .viewBudget:
            switch goal.selectedCurrency {
            case Currency.Local.rawValue:
                return Int(goal.budget)?.amountFormat ?? Int("0")?.amountFormat
            case Currency.Dollar.rawValue:
                return Int(goal.budget)?.dollarFormat ?? Int("0")?.dollarFormat
            case Currency.Euro.rawValue:
                return Int(goal.budget)?.euroFormat ?? Int("0")?.euroFormat
            default:
                return ""
            }
        case .viewIsComplete: return goal.isComplete ? "Accomplished!": "Not accomplished yet!"
        case .viewTitle: return goal.title.isEmpty ?  Goal.emptyTitle : (goal.title)
        default: return nil
        }
    }
    
    
    func checkTextFields(title: String, price: String) {
        (!(title.isEmpty )) ? (isTitleFilled = true) : (isTitleFilled = false)
        (!(price.isEmpty )) ? (isPriceFilled = true) : (isPriceFilled = false)


        if isTitleFilled && isPriceFilled {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}
