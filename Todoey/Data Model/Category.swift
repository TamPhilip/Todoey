//
//  Category.swift
//  Todoey
//
//  Created by Philip Tam on 2018-03-19.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object{
    @objc dynamic var name = ""
    var items = List<Item>()
}
