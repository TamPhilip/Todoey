//
//  ViewController.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-03.
//  Copyright © 2018 Philip Tam. All rights reserved.
//
import UIKit
import CoreData

class TodoListViewController: UITableViewController{

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    // UIApplication.shared.delegate as! AppDelegate goes into the AppDelegate and grabs the persistent container
    // Where from there we grav the context of the persistent container
    
    var selectedCategory : Category?{ //Nil until we can set it using the destinationVC!
        didSet{//Everything inside this happens as soon as selectedCategory is set!
            loadItems() //(Read)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        navigationItem.title = selectedCategory?.name
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
        
       // itemArray[indexPath.row].setValue("Completed", forKey: title) Sets the value of title to = "Completed"
        
        itemArray[indexPath.row].checkmark = !itemArray[indexPath.row].checkmark
        // ! is reverses the value of the .checkmark
        
        saveItems() // (Updates)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
//    MARK: - EDIT BUTTON
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            context.delete(itemArray[indexPath.row]) // This does nothing to the actual Database because it has to be saved to the Database therefore context.save() must be used to update the Database after

            itemArray.remove(at: indexPath.row)
                    //This does nothing to the Core Data because it merely updates our itemArray which is used to populate our tableView so that when we reload it were able to reload the freshest items! This should be done after because of the item at the indexPath.row will be gone and cannot be deleted from the context.delete where the context.delete used the itemArray to find the NSManagedObject
            tableView.deleteRows(at: [indexPath], with: .fade)

            saveItems()
        }
    }
    
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
       
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user hits the Add Item button on our UIAlert
            
            //Create new object of type Item that has all access to all the properties that were specified as attributes: checkmark and title. That Item is an object of type NSManagedObject (A.K.A they are the rows inside the tables where every row is an individual NSManagedObject)
            let newItem = Item(context: self.context)
            
            //Following the creation it is necessary to fill out the fields! (Create)
            newItem.title = textField.text!
            newItem.checkmark = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            //Following all that we save our Item!
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
    //MARK: - Moving Rows Table View Method
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedObject = self.itemArray[fromIndexPath.row]
        itemArray.remove(at: fromIndexPath.row)
        itemArray.insert(movedObject, at: to.row)
    }
    
    //MARK: Model Manipulation Methods
    
    func saveItems(){ // Saves the Data from the Context to the Persistent Storage (Create)
        do{
           try context.save()
            // It looks at the context and saves the uncommited changes towards the Persistent Storage
        }
        catch {
            print("Error saving context \(error)")
        }
        //Reloard the data of the tableview
        tableView.reloadData()
    }
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
        //Send fetch request to the context where they grab the Data from the Persistent Storage (Read)
        // Array of Items (DATA TYPE) that was stored in the Persistent Storage
        // You have to specify the Data Type of the Outpute and the Entity you are trying to request!
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        //predicate overwrite each others!

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else{
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        }
        catch{
            print("Error fetching Data from context \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: Search Bar Methods
//SOMETHING NEW I LEARNED: EXTENSION
extension TodoListViewController : UISearchBarDelegate{ //Try to split up the functionality and that you modularize for debugging and code organization!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //title of the item %@ = searchBar.text
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //NSPredicate is a foundation class that specifies how data should be fetched or filtered. Essentially, its query language!
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
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

