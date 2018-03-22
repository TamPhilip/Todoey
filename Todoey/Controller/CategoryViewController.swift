//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Philip Tam on 2018-02-09.
//  Copyright © 2018 Philip Tam. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var categories : Results<Category>?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    //    navigationItem.leftBarButtonItem = editButtonItem

    }
    
    //MARK: - Table View DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Created Yet"
        
        guard let color = UIColor.init(hexString: categories?[indexPath.row].color) else {fatalError("Category Color caused fatal error there is no color!")}
            cell.backgroundColor = color
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        
        return cell
    }
    
    //MARK: - Table View Data Manipulation Methods
    func saveCategories(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }
        catch{
            print("Error while saving Category \(error)")
        }
        
        tableView.reloadData()
    }
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexpath: IndexPath) {
        if let deleteCategory = categories?[indexpath.row]{
            do{
                try realm.write {
                    realm.delete(deleteCategory.items)
                    realm.delete(deleteCategory)
                }
            }catch{
                print("Error while deleting Categories \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() //Stores textfield
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "New Category", style: .default) { (action) in
            let newCategory = Category()
            
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.saveCategories(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Insert New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {  //Identify the current row that is selected
           destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Moving Rows Table View Method
    //    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    //        let movedObject = self.categoryArray[fromIndexPath.row]
    //        categoryArray.remove(at: fromIndexPath.row)
    //        categoryArray.insert(movedObject, at: to.row)
    //    }
    
    //    MARK: - EDIT BUTTON
    //    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //        if (editingStyle == .delete){
    //            do{
    //                try realm.write {
    //                    realm.delete(categories![indexPath.row].items)
    //                    realm.delete(categories![indexPath.row])
    //                }
    //            }
    //            catch{
    //                print("Error while deleting Categories \(error)")
    //            }
    //            tableView.deleteRows(at: [indexPath], with: .fade)
    //        }
    //    }

}
