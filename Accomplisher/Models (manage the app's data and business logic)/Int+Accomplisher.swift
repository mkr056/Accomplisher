//
//  Money+Accomplisher.swift
//  Accomplisher
//
//  Created by Artem Mkr on 24.08.2022.
//

import Foundation

extension  Int {
    var amountFormat: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current 
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.allowsFloats = true
        guard let formattedAmount = formatter.string(from: self as NSNumber) else { return self.description }
           return formattedAmount
        
    }
    
    var dollarFormat: String {
        let formatter = NumberFormatter()
        formatter.currencyCode = "USD"
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.allowsFloats = true
        guard let formattedAmount = formatter.string(from: self as NSNumber) else { return self.description }
           return formattedAmount
    }
    
    var euroFormat: String {
        let formatter = NumberFormatter()
        formatter.currencyCode = "EUR"
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.allowsFloats = true
        guard let formattedAmount = formatter.string(from: self as NSNumber) else { return self.description }
           return formattedAmount
    }

}
