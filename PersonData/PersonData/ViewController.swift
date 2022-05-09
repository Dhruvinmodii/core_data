//
//  ViewController.swift
//  PersonData
//
//  Created by bmiit on 09/05/22.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*get managed object*/
        let person = people[indexPath.row]
        
        /*initialize alert controller*/
        let alert = UIAlertController(title: "Update Name",
                                          message: "Update Name",
                                          preferredStyle: .alert)
            
            /*add name textfield*/
            alert.addTextField(configurationHandler: { (textFieldName) in
              
              /*set name as plaveholder in textfield*/
              textFieldName.placeholder = "name"
              
              /*use key value coding to get value for key "name" and set it as text of UITextField.*/
              textFieldName.text = person.value(forKey: "name") as? String
              
            })
            
            /*add ssn textfield*/
            alert.addTextField(configurationHandler: { (textFieldSSN) in
              
              /*set ssn as plaveholder in textfield*/
              textFieldSSN.placeholder = "ssn"
              
              /*use key value coding to get value for key "ssn" and set it as text of UITextField.*/
              textFieldSSN.text = "\(person.value(forKey: "ssn") as? Int16 ?? 0)"
            })
            
            /*configure update event*/
            let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned self] action in
              
              guard let textField = alert.textFields?[0],
                let nameToSave = textField.text else {
                  return
              }
              
              guard let textFieldSSN = alert.textFields?[1],
                let SSNToSave = textFieldSSN.text else {
                  return
              }
              
              /*imp part, responsible for update, pass nameToSave and SSn to update: method.*/
              self.update(name : nameToSave, ssn: Int16(SSNToSave)!, person : person as! Person)
              
              /*finally reload table view*/
              tableView.reloadData()
            
          }
        /*configure delete event*/
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { [unowned self] action in
              
              /*look at implementation of delete method */
              self.delete(person : person as! Person)
              
              /*remove person object from array also, so that datasource have correct data*/
              self.people.remove(at: (self.people.index(of: person))!)
              
              /*Finally reload tableview*/
              tableView.reloadData()
              
            }
            
            /*configure cancel action*/
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .default)
            
            /*add all the actions*/
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            
            /*finally present*/
            present(alert, animated: true)
    }
    
    func update(name:String, ssn : Int16, person : Person) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let context = appDelegate.persistentContainer.viewContext
            
            do {
              
              
              /*
               With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model
               */
              person.setValue(name, forKey: "name")
              person.setValue(ssn, forKey: "ssn")
              
              print("\(person.value(forKey: "name"))")
              print("\(person.value(forKey: "ssn"))")
              
              /*
               You commit your changes to person and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads.
               */
              do {
                try context.save()
                print("saved!")
              } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
              } catch {
                
              }
              
            } catch {
              print("Error with request: \(error)")
            }
    }
    
    
    
    @IBOutlet weak var tableview: UITableView!
    
    var people: [NSManagedObject] = []
    
    @IBAction func addName(_ sender: Any) {
        
        /*init alert controller with title, message & .alert style*/
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        /*create a name text field, with placeholder "name"*/
        alert.addTextField(configurationHandler: {(textFieldName) in textFieldName.placeholder = "name"})
        
        /*create a ssn text field, with placeholder "ssn"*/
        alert.addTextField(configurationHandler: {(textFieldSSN) in textFieldSSN.placeholder = "ssn"})
        
        /*create a save action*/
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
        /*find textfield's text (name) guard let way to get unwrap value otherwise return early*/
        guard  let textField = alert.textFields?.first,
               let nameToSave = textField.text else{
                   return
               }
            
            /*find textfield's text (ssn) guard let way to get unwrap value  otherwise return early*/
            guard let textFieldSSN = alert.textFields?[1],
                  let SSNToSave = textFieldSSN.text else
                  {
                      return
                  }
            
            /*call save method by passing nameToSave and SSNToSave*/
            self.save(name: nameToSave, ssn: Int16(SSNToSave)!)
            self.tableview.reloadData()
    }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    
    //insert logic
    func save(name: String, ssn: Int16){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        /*
             An NSEntityDescription object is associated with a specific class instance
             Class
             NSEntityDescription
             A description of an entity in Core Data.
             
             Retrieving an Entity with a Given Name here person
             */
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        /*
             Initializes a managed object and inserts it into the specified managed object context.
             
             init(entity: NSEntityDescription,
             insertInto context: NSManagedObjectContext?)
             */
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)

        /*
             With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model
             */
        
        person.setValue(name, forKey: "name")
        person.setValue(ssn, forKey: "ssn")
        
        /*
             You commit your changes to person and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads.
             */
        
        do{
            try managedContext.save()
            people.append(person)
            tableview.reloadData()
            
        } catch let error as NSError{
            print("Could not save \(error), \(error.userInfo)")
        }
        
        
        
    }
    
    func fetchAllPersons(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        
        /*Before you can do anything with Core Data, you need a managed object context. */
        let managedContext = appDelegate.persistentContainer.viewContext
        
        /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
         
         Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
         */
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        /*You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.*/
        do {
          people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
      }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        /*init alert controller with title and message*/
               let alert = UIAlertController(title: "Delete by ssn", message: "Enter ssn", preferredStyle: .alert)
             
             /*configure delete action*/
               let deleteAction = UIAlertAction(title: "Delete", style: .default) { [unowned self] action in
                   guard let textField = alert.textFields?.first , let itemToDelete = textField.text else {
                       return
                   }
                 /*pass ssn number to delete(:) method*/
                 self.delete(ssn: itemToDelete)
                 /*reoad tableview*/
                tableview.reloadData()
                   
               }
             
             /*configure cancel action*/
               let cancelAciton = UIAlertAction(title: "Cancel", style: .default)
             
             /*add text field*/
               alert.addTextField()
             /*add actions*/
               alert.addAction(deleteAction)
               alert.addAction(cancelAciton)
               
               present(alert, animated: true, completion: nil)
           }
    
    func delete(person : Person){
        // Assuming type has a reference to managed object context
        
        // Assuming that a specific NSManagedObject's objectID property is accessible
        // Alternatively, could supply a predicate expression that's precise enough
        // to select only a _single_ entity
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            /*call delete method of managed object context and pass person object in parameter*/
            managedContext.delete(person)
          
        } catch {
          // Do something in response to error condition
        }
        
        do {
          try managedContext.save()
        } catch {
          // Do something in response to error condition
        }
      }
           func delete(ssn: String) {
             /*get reference to appdelegate file*/
               guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                   return
               }
             
             /*get reference of managed object context*/
               let managedContext = appDelegate.persistentContainer.viewContext
             
             /*init fetch request*/
               let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
             
             /*pass your condition with NSPredicate. We only want to delete those records which match our condition*/
               fetchRequest.predicate = NSPredicate(format: "ssn == %@" ,ssn)
               do {
                 
                 /*managedContext.fetch(fetchRequest) will return array of person objects [personObjects]*/
                   let item = try managedContext.fetch(fetchRequest)
                   for i in item {
                     
                     /*call delete method(aManagedObjectInstance)*/
                     /*here i is managed object instance*/
                       managedContext.delete(i)
                     
                     /*finally save the contexts*/
                       try managedContext.save()
                     
                     /*update your array also*/
                     people.remove(at: (people.index(of: i))!)
                   }
               } catch let error as NSError {
                   print("Could not fetch. \(error), \(error.userInfo)")
               }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllPersons()
      }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }


}

