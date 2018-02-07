//
//  ViewController.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-03.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]() //["Find Myself","Find An Idea", "Make Idea Happen"]
    
    //Local Data Storage using User Defaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
      
        let newItems = Item()
        newItems.title = "Find Myself"
        itemArray.append(newItems)
        
        let newItems2 = Item()
        newItems2.title = "Find An Idea"
        itemArray.append(newItems2)
        
        let newItems3 = Item()
        newItems3.title = "Make Idea Happen"
        itemArray.append(newItems3)
        
        if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
            itemArray = items
        }
    }

    //MARK - Tableview Datasourcew Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      //  let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        
        print("CellForRowAtCalled")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) //Cells get reused causing multiple checkmarks
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Shorten this code with the Swift Ternary Operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        //Dont need to add condition because item.done is a bool
        
        cell.accessoryType = item.done ? .checkmark : .none
        
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        }
//        else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK - TableView Delagate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].checkmark = !itemArray[indexPath.row].checkmark
        // ! is reverses the value of the .checkmark
        
        tableView.reloadData() // This also reloads the Cell
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
       
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user hits the Add Item button on our UIAlert
            
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData() //Reloard the data of the tableview
        }
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

