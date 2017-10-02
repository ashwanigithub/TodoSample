//
//  ToDoTaskList.swift
//  ToDo_Sample
//
//  Created by Ashwani Sharma  on 02/10/17.
//  Copyright © 2017 Ashwani Sharma . All rights reserved.
//

import RealmSwift


class ToDoEventList: Object {
    
    dynamic var nameToDo = ""
    dynamic var createdAtToDo = NSDate()
    let events = List<ToDoEvent>()

}
