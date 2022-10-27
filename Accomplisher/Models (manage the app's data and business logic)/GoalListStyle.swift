import Foundation

enum GoalListStyle: Int { // contains cases  for each of the available styles (two categories of viewing)
    case ongoing
    case complete
    
    var name: String { // names for the segmented control
        switch self {
        case .ongoing:
            return NSLocalizedString("Ongoing", comment: "Ongoing style name")
        case .complete:
            return NSLocalizedString("Complete", comment: "Completed style name")
        }
    }
    
    func shouldInclude(goal: Goal) -> Bool { // used to filter goals for each style
        let completionStatus = goal.isComplete
        switch self {
        case .ongoing:
            return !completionStatus
        case .complete:
            return completionStatus
        }
    }
}
