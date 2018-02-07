//
//  Item.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-06.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import Foundation

//Encodable = this means that the item type to encode itself to json or plist
// For it to be encodable all of its properties must be standard data type

class Item : Codable{
    var title : String = ""
    var checkmark : Bool = false
}
