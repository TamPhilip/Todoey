//
//  ViewController.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-03.
//  Copyright © 2018 Philip Tam. All rights reserved.
//
import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{

    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    let realm = try!  Realm()
    
    var itemsToDo : Results<Item>?
    
    var selectedCategory : Category?{ //Nil until we can set it using the destinationVC!
        didSet{//Everything inside this happens as soon as selectedCategory is set!
            loadItems() //(Read)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    //    navigationItem.rightBarButtonItems?.append(editButtonItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let color = selectedCategory?.color else {fatalError("Selected Category has no Color")}
        updateNavBar(withHexCode: color)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
         updateNavBar(withHexCode:"1D9BF6")
    }
    
   
    
    //MARK: - NavBar Setup Methods
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        guard let navBarColor = UIColor.init(hexString: colorHexCode) else {fatalError("The hexstring color was empty within the Selected Category")}
        searchBarOutlet.barTintColor = navBarColor
        navBar.barTintColor = navBarColor
        navBar.tintColor = UIColor.init(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true)]
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true)]
        
        //Search Bar Borders
        searchBarOutlet.isTranslucent = false
        searchBarOutlet.backgroundImage = UIImage()
        
        //Status Bar
        if UIColor.init(contrastingBlackOrWhiteColorOn: navBarColor, isFlat: true) == UIColor.flatBlackColorDark(){
            UIApplication.shared.statusBarStyle = .default
        }else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
    }
    
    //MARK - Tableview Datasourcew Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if  let item = itemsToDo?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            guard let colour = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemsToDo!.count)) else {fatalError("Cell could not take the Selected Catogory's color")}
            cell.backgroundColor = colour
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: colour, isFlat: true)
            cell.tintColor = cell.textLabel?.textColor
            //Shorten with the Swift Ternary Operator ==> value = condition ? valueIfTrue : valueIfFalse Dont need to add condition because item.done is a bool
            
            cell.accessoryType = item.checkmark ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added Yet"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsToDo?.count ?? 1
    }
    
    //MARK - TableView Delagate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemsToDo?[indexPath.row]{
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
       
       itemsToDo = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexpath: IndexPath) {
        if let deleteItem = itemsToDo?[indexpath.row]{
            do{
                try realm.write {
                    realm.delete(deleteItem)
                }
            }
            catch{
                print("Error while deleting items \(error)")
            }
        }
    }
}
    
    //MARK: - Moving Rows Table View Method
    //    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    //        let movedObject = self.itemArray[fromIndexPath.row]
    //        itemArray.remove(at: fromIndexPath.row)
    //        itemArray.insert(movedObject, at: to.row)
    //    }
    
    // MARK: - EDIT BUTTON
    //    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//            if (editingStyle == .delete) && selectedCategory != nil{
//                do{
//                    try realm.write {
//                        realm.delete(itemsToDo![indexPath.row])
//                    }
//                }
//                catch{
//                    print("Error while deleting items \(error)")
//                }
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
    //    }

// MARK: Search Bar Methods
extension TodoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemsToDo = itemsToDo?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
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

