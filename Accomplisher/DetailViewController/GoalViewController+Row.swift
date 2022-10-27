//
//  GoalViewController+Row.swift
//  Accomplisher
//
//  Created by Artem Mkr on 09.08.2022.
//

import UIKit

extension GoalViewController {
    
    
    enum Row: Hashable { // used to specify the appropriate content and unique styling for each row
        case header(String) // associated value is displayed as the header title
        case viewDate
        case viewPriceInLocal
        case viewPriceInDollar
        case viewPriceInEuro
        case viewBudget
        case viewIsComplete
        case viewTitle
        case editDate(Date)
        case editTitleText(String?)
        case editPriceText(String?)
        case editBudgetText(String?)
        case editCurrencyText(String?)
        
        
        

        
        
        var imageName: String? { // returns an appropriate SFSymbol name for each case
            switch self {
            case .viewDate:
                return "calendar.circle"
            case .viewPriceInLocal:
                return "globe"
            case .viewPriceInDollar:
               return "dollarsign.square.fill"
            case .viewPriceInEuro:
                return "eurosign.square.fill"


                
            case .viewBudget:
                return "case.fill"
            case .viewIsComplete:
                return "checkmark.seal.fill"
            default: return nil
            }
        }
        
        var image: UIImage? { // returns an image based on the image name
            guard let imageName = imageName else { return nil }
            let configuration = UIImage.SymbolConfiguration(textStyle: .headline)
            return UIImage(systemName: imageName, withConfiguration: configuration)
        }
        
        var textStyle: UIFont.TextStyle { // returns the text style associated with each case
            switch self {
            case .viewTitle: return .headline
            default: return .subheadline
            }
        }
    }
}
