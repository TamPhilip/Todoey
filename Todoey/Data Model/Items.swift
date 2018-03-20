//
//  Items.swift
//  Todoey
//
//  Created by Philip Tam on 2018-03-19.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object{
    @objc dynamic var title : String = ""
    @objc dynamic var checkmark : Bool = false
    @objc dynamic var dateCreated = Date()
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
