//
//  MainToDoViewController.swift
//  ToDo_Sample
//
//  Created by Ashwani Sharma  on 02/10/17.
//  Copyright © 2017 Ashwani Sharma . All rights reserved.
//

import UIKit
import RealmSwift

class MainToDoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var todoLists : Results<ToDoEventList>! // Object get from ToDoEventList.
    var editModeOn = false // Edit mode on/off bool set.
    var customAlertAction:UIAlertAction! // Custom Alert Action declare
    @IBOutlet weak var todosTableView: UITableView!// UITable View Outlet
    
    //MARK:- View did load call.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.todosTableView.tableFooterView = UIView()
    }
    
    //MARK:- View will appear call.
    override func viewWillAppear(_ animated: Bool) {
        listupdated()//list read and update UI interface method.
    }
    
    // MARK: - List sorting and using date segment action.
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            self.todoLists = self.todoLists.sorted(byProperty: "nameToDo")
        }
        else{
            self.todoLists = self.todoLists.sorted(byProperty: "createdAtToDo", ascending:false)
        }
        self.todosTableView.reloadData()
    }
    
    //MARK:- Edit Click Action Button.
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        editModeOn = !editModeOn
        self.todosTableView.setEditing(editModeOn, animated: true)
    }
    
    //MARK:- Add Click Action Button.
    @IBAction func didClickOnAddButton(_ sender: UIBarButtonItem) {
        customAlertView(nil)//Alert view show/hide
    }
    
    //MARK:- Add Target Action Method Call.
    func listNameFieldDidChange(_ textField:UITextField){
        self.customAlertAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    //MARK:- List update method.
    func listupdated(){
        todoLists = uiRealm.objects(ToDoEventList.self)
        self.todosTableView.setEditing(false, animated: true)
        self.todosTableView.reloadData()
    }
  
    // MARK: - UITableViewDataSource and UITableViewDelegate.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let listsEvents = todoLists
        {
            return listsEvents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")
        let list = todoLists[indexPath.row]
        cell?.textLabel?.text = list.nameToDo
        cell?.detailTextLabel?.text = "\(list.events.count) Event"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
        let listToBeDeleted = self.todoLists[indexPath.row]
            try! uiRealm.write
            {
                uiRealm.delete(listToBeDeleted)
                self.listupdated()//update list method call.
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            let listToBeUpdated = self.todoLists[indexPath.row]
            self.customAlertView(listToBeUpdated)//Alert view show
            
        }
        return [deleteAction, editAction]
    }
        
    //MARK:- Custom Alert View.
    func customAlertView(_ updatedList:ToDoEventList!){
        
        var title = "New Event"
        var doneTitle = "Create"
        
        if updatedList != nil
        {
            title = "Update Event"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            let listName = alertController.textFields?.first?.text
            
            if updatedList != nil
            {
                try! uiRealm.write{
                    updatedList.nameToDo = listName!
                    self.listupdated()//update list method call.
                }
            }
            else{
                let newEventList = ToDoEventList()
                newEventList.nameToDo = listName!
                try! uiRealm.write{
                    uiRealm.add(newEventList)
                    self.listupdated()//update list method call.
                }
            }
        }
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.customAlertAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alertController.addTextField { (textField) -> Void in
            
            textField.placeholder = "Event Name"
            textField.addTarget(self, action: #selector(MainToDoViewController.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            
            if updatedList != nil
            {
                textField.text = updatedList.nameToDo
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
}
