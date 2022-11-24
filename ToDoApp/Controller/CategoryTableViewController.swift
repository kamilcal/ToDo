//
//  CategoryTableViewController.swift
//  ToDoApp
//
//  Created by kamilcal on 24.11.2022.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var button = UIAlertController()
    
    var categoryData = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryData.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryData[indexPath.row].name
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryData[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try self.context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categoryData = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
       
        self.tableView.reloadData()
        
    }
    
    //MARK: - Add New Categories

    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
        func presentAddAlert() {
            presentAlert(title: "Yeni Eleman Ekle",
                         message: nil,
                         defaultButtonTitle: "Ekle",
                         cancelButtonTitle: "Vazgeç",
                         isTextFieldAvaible: true,
                         defaultButtonHandler: { _ in
                
                let text = self.button.textFields?.first?.text
                if text != "" {

                    if let action = NSEntityDescription.entity(forEntityName: "Category", in: self.context) {
                        
                        let newCategory = Category(entity: action, insertInto: self.context)
                        
                        newCategory.setValue(text, forKey: "name")
                        //              newItem.title = textfield.text!
                        
                        self.saveCategories()
                        self.loadCategories()
                    }
                } else {
                    self.presentWarningAlert()
                }
            })
        }
                         
        
        //    MARK: - presentAlert&presentWarningAlert
        
        func presentWarningAlert() {
            
            presentAlert(title: "Uyarı", message: "Listeye Boş Eleman Ekleyemezsin", cancelButtonTitle: "Anladım")
        }
        
        func presentAlert(title: String?,
                          message: String?,
                          preferredStyle: UIAlertController.Style = .alert,
                          defaultButtonTitle: String? = nil,
                          cancelButtonTitle: String?,
                          isTextFieldAvaible: Bool = false,
                          defaultButtonHandler: ((UIAlertAction) -> Void)? = nil){
            
            button = UIAlertController (title: title,
                                        message: message,
                                        preferredStyle: preferredStyle)
            if defaultButtonTitle != nil {
                let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                                  style: .default,
                                                  handler: defaultButtonHandler)
                button.addAction(defaultButton)
            }
            
            let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                             style: .cancel)
            
            if isTextFieldAvaible {
                button.addTextField()
            }
            button.addAction(cancelButton)
            present(button, animated: true)
        }
    //    MARK: - Swipe Actions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteActions = UIContextualAction(style: .normal,
                                               title: "Delete") { _, _, _ in
            self.context.delete(self.categoryData[indexPath.row])
            self.saveCategories()
            self.loadCategories()
        }
        let editActions = UIContextualAction(style: .normal,
                                             title: "Düzenle",
                                             handler: { _, _, _ in
            self.presentAlert(title: "Elemanı Düzenle",
                              message: nil,
                              defaultButtonTitle: "Düzenle",
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvaible: true,
                              defaultButtonHandler: { _ in
                
                let text = self.button.textFields?.first?.text
                if text != "" {
                    self.categoryData[indexPath.row].setValue(text, forKey: "title")
                    
                    if ((self.context.hasChanges) != nil) {
                        self.saveCategories()
                    }
                    self.tableView.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            })
        })
        deleteActions.backgroundColor = .systemRed
        
        let config = UISwipeActionsConfiguration(actions: [deleteActions, editActions])
        return config
    }
    
  
    }


