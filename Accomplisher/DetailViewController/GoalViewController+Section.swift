//
//  GoalViewController+Section.swift
//  Accomplisher
//
//  Created by Artem Mkr on 10.08.2022.
//

import Foundation

extension GoalViewController { // represents the different sections of the collection view
    enum Section: Int, Hashable { // Hashable is needed to determine changes in your data
        case view
        case title
        case date
        case price
        case budget
        case currency
        
        
        var name: String { // computes heading text for each section
            switch self {
            case .view:
                return ""
            case .title:
                return NSLocalizedString("Title", comment: "Title section name")
            case .date:
                return NSLocalizedString("Date", comment: "Date section name")
            case .price:
                return NSLocalizedString("Price", comment: "Price section name")
            case .budget:
                return NSLocalizedString("Budget", comment: "Budget section name")
            case .currency:
                return NSLocalizedString("", comment: "Currency section name")
            }
        }
    }
}
