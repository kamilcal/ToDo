//
//  TableViewController.swift
//  ToDoApp
//
//  Created by kamilcal on 22.11.2022.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var button = UIAlertController()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var data = [Item]()
    
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch()
    }
    //    MARK: - didAddBarButtonItemTapped

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
            
            let entity = NSEntityDescription.entity(forEntityName: "Item", in: self.managedObjectContext)
            
            let newItem = Item(entity: entity!, insertInto: self.managedObjectContext)
            
            newItem.setValue(text, forKey: "title")
//              newItem.title = textfield.text!
            newItem.done = false
            
            self.saveItems()
            self.fetch()
        } else {
            self.presentWarningAlert()
        }
    })
}

    //MARK: - didRemoveBarButtonItemTapped
    
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "Uyarı",
                     message: "Listedeki tüm öğeleri silmek istediğinizden emin misiniz ?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç") { _ in
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Item")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! self.managedObjectContext.execute(deleteRequest)
            self.fetch()
            
        }
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = data[indexPath.row]
        cell.textLabel?.text = item.value(forKey: "title") as? String
        
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
        
    }
    
    //    MARK: -UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        data[indexPath.row].done = !data[indexPath.row].done
        
        saveItems()

        tableView.deselectRow(at: indexPath, animated: true)
        
        
        tableView.reloadData()
        
        
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
    
    //    MARK: -saveItem-fetch
    
    func saveItems() {
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func fetch(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        do {
            data = try managedObjectContext.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    //    MARK: - Swipe Actions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteActions = UIContextualAction(style: .normal,
                                               title: "Delete") { _, _, _ in
            self.managedObjectContext.delete(self.data[indexPath.row])
            self.saveItems()
            self.fetch()
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
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if ((self.managedObjectContext.hasChanges) != nil) {
                        self.saveItems()
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
//    MARK: - Search Bar Methods

extension TableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetch(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetch()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}

