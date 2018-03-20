//
//  ViewController.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-03.
//  Copyright © 2018 Philip Tam. All rights reserved.
//
import UIKit
import RealmSwift

class TodoListViewController: UITableViewController{

    let realm = try!  Realm()
    
    var itemArray : Results<Item>?
    
    var selectedCategory : Category?{ //Nil until we can set it using the destinationVC!
        didSet{//Everything inside this happens as soon as selectedCategory is set!
            loadItems() //(Read)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        navigationItem.title = selectedCategory?.name
    }

    //MARK - Tableview Datasourcew Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if  let item = itemArray?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            //Shorten with the Swift Ternary Operator ==> value = condition ? valueIfTrue : valueIfFalse Dont need to add condition because item.done is a bool
            
            cell.accessoryType = item.checkmark ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added Yet"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    //MARK - TableView Delagate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write {
                    item.checkmark = !item.checkmark
                }
            }
            catch{
                print("Error while checkmark \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
// MARK: - EDIT BUTTON
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) && selectedCategory != nil{
            do{
                try realm.write {
                    realm.delete(itemArray![indexPath.row])
                }
            }
            catch{
                print("Error while deleting items \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
       
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user hits the Add Item button on our UIAlert
            
            if let currentCateogry = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCateogry.items.append(newItem)
                    }
                }
                catch{
                    print("Error while saving Item \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }

    
    //MARK: Model Manipulation Methods
    func loadItems(){
       
       itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    //MARK: - Moving Rows Table View Method
    //    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    //        let movedObject = self.itemArray[fromIndexPath.row]
    //        itemArray.remove(at: fromIndexPath.row)
    //        itemArray.insert(movedObject, at: to.row)
    //    }
}

// MARK: Search Bar Methods
extension TodoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async { //This is done so that our app does not freeze because whenever we are writing methods that affect the User Interface we want it done in the background or else it freezes the app!
                searchBar.resignFirstResponder() //means that it should not be currently selected
            } //Is the manager that assigns processes to different threads
            
        }
    }
}

