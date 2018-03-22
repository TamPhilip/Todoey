//
//  Category.swift
//  Todoey
//
//  Created by Philip Tam on 2018-03-19.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Category : Object{
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    var items = List<Item>()
}
