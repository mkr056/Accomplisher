import UIKit
import RealmSwift

class Goal: Object, Identifiable { // contains the structure for my goal data model
    static let emptyTitle = "No title"
    @objc dynamic var id: String = UUID().uuidString // you use identifiers to inform the data source of which items to include in the collection view and which items to reload when data changes
    @objc dynamic var title: String = ""
    @objc dynamic var price: String = ""
    @objc dynamic var budget: String = ""
    @objc dynamic var percentComplete: Int {

        if Int(price) ?? 0 <= 0 {
            return 0
        }
        if Int(budget) ?? 0 <= 0 {
            return 0
        }
        let rounded = Int(((Double(budget)!) / (Double(price)!)) * 100)
            return rounded
    }
    
    @objc dynamic var dueDate: Date = Date()
    @objc dynamic var isComplete: Bool {
        if price.isEmpty {
            return true
        }
        if budget.isEmpty {
            return false
        }
        return Int(budget)! >= Int(price)!

    }
    @objc dynamic var selectedCurrency: String = Currency.Local.rawValue
    let files = List<Media>()
    var image = [UIImage]()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}



extension Results where Element == Goal { // accepts an id argument and returns its index
    func indexOfGoal(with id: Goal.ID) -> Self.Index {
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError()
        }
        return index
    }
}


enum Currency: String, CaseIterable {
    case Local, Euro, Dollar
}

