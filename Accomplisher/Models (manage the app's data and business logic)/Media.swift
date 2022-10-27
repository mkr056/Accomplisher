//
//  Media.swift
//  Accomplisher
//
//  Created by Artem Mkr on 30.08.2022.
//

import Foundation
import RealmSwift

class Media: Object {
    @objc dynamic var collectionViewImage = Data()
    @objc dynamic var originalImage = Data()
    @objc dynamic var videoURLString = ""
    @objc dynamic var date = Date()
    @objc dynamic var isImage: Bool = false
    var parentGoal = LinkingObjects(fromType: Goal.self, property: "files")
}
