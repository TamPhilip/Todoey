//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-09.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        navigationItem.leftBarButtonItem = editButtonItem

    }
    
    //MARK: - Table View DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }

    //MARK: - Table View Data Manipulation Methods
    func saveCategories(){
        do {
            try context.save()
        }
        catch {
            print("Error while saving context \(error)")
        }
        tableView.reloadData()
    }
    func loadCategories(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do{
              categoryArray = try context.fetch(request)
        }
        catch{
            print("Error while fetching Category Data \(error)")
        }
        tableView.reloadData()
    }
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() //Stores textfield
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "New Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            
            newCategory.name = textField.text!
            
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Insert New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //    MARK: - EDIT BUTTON
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            context.delete(categoryArray[indexPath.row]) // This does nothing to the actual Database because it has to be saved to the Database therefore context.save() must be used to update the Database after
            
            categoryArray.remove(at: indexPath.row)
            //This does nothing to the Core Data because it merely updates our itemArray which is used to populate our tableView so that when we reload it were able to reload the freshest items! This should be done after because of the item at the indexPath.row will be gone and cannot be deleted from the context.delete where the context.delete used the itemArray to find the NSManagedObject
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveCategories()
        }
    }
    //MARK: - Moving Rows Table View Method
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedObject = self.categoryArray[fromIndexPath.row]
        categoryArray.remove(at: fromIndexPath.row)
        categoryArray.insert(movedObject, at: to.row)
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {  //Identify the current row that is selected
           destinationVC.selectedCategory = categoryArray[indexPath.row]
            destinationVC.selectedCategory?.name = categoryArray[indexPath.row].name!
        }
    }
}
