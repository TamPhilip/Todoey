//
//  ViewController.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-03.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    // Object that provides a convenient interface to the contents of the File System / Shared File Manager Object = Singleton //userDomainMask = where we install the Users Personal Items
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(dataFilePath)
        
        loadItems()
    }

    //MARK - Tableview Datasourcew Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      //  let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        
        print("CellForRowAtCalled")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) //Cells get reused causing multiple checkmarks
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Shorten with the Swift Ternary Operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        //Dont need to add condition because item.done is a bool
        
        cell.accessoryType = item.checkmark ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK - TableView Delagate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].checkmark = !itemArray[indexPath.row].checkmark
        // ! is reverses the value of the .checkmark
        
        saveItems()
        
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
            
            self.saveItems()
            
            //We must stop using UserDefaults because of it cannot save our own custom data type Item! Therefore antother solution must be found at all cost! UserDefaults can only take standard data! Also it is not a database!
        }
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){ // Encodes the data
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(self.itemArray)
            try data.write(to: dataFilePath!)
        }
        catch {
            print("Error encoding item array \(error)")
        }
        //Reloard the data of the tableview
        tableView.reloadData()
    }
    func loadItems(){ //Decodes the data
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            }
            catch{
                print("Error decoding item array \(error)")
            }
        }
    }
}

