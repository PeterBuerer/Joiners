//
//  MenuController.swift
//  Joiners
//
//  Created by Peter Buerer on 3/23/17.
//  Copyright © 2017 Peter Buerer. All rights reserved.
//

import UIKit
import CoreData

class MenuController: UITableViewController {
    private let cellIdentifier = "MenuCellIdentifier"
    private let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    private var container: NSPersistentContainer
    init(container: NSPersistentContainer) {
        self.container = container
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Joiner")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: "JoinerResultsCache")
        do {
            try fetchedResultsController.performFetch()
        }
        catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addJoiner))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(tableView)
//        let views = ["table": tableView]
//        NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[table]|", options: [], metrics: nil, views: views))
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: nil, views: views))
//    }
   
    
    // MARK:- Actions
    
    func addJoiner() {
        print("add Joiner")
    }
    
    // MARK:- UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let joiner = fetchedResultsController.fetchedObjects?[indexPath.row] as? Joiner else {
            print("No joiner for index: \(indexPath.row)")
            return cell
        }
        
        cell.textLabel?.text = joiner.name
        return cell
    }
    
    
    // MARK:- UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: present canvas
    }
    
    
    // MARK:- Views
//    
//    lazy var tableView: UITableView = {
//        let table = UITableView(frame: CGRect.zero, style: .plain)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.delegate = self
//        table.dataSource = self
//        table.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
//        return table
//    }()
}
