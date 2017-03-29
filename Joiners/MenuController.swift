//
//  MenuController.swift
//  Joiners
//
//  Created by Peter Buerer on 3/23/17.
//  Copyright © 2017 Peter Buerer. All rights reserved.
//

import UIKit
import CoreData

class MenuController: UITableViewController, NSFetchedResultsControllerDelegate {
    private let cellIdentifier = "MenuCellIdentifier"
    private let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    private var container: NSPersistentContainer
    
   // TODO: Create an abstraction layer between the database and the view controller so that this isn't tied to Core Data
    init(container: NSPersistentContainer) {
        self.container = container
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Joiner")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        // TODO: see if "couldn't read cache file to update store info timestamps" thing is fixed...
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: "JoinerResultsCache")
        super.init(nibName: nil, bundle: nil)
        
        self.fetchedResultsController.delegate = self
        self.fetchData()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addJoiner))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK:- Actions
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch let error {
            // TODO: show dialog saying "Could not refresh Joiner list...add manual way to refresh??..seems weird to do that with no networking aspect though
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func addJoiner() {
        // TODO: handle the case where they make a new Joiner, and don't want to save it...
        guard let joiner = NSEntityDescription.insertNewObject(forEntityName: "Joiner", into: container.viewContext) as? Joiner else {
            // TODO: show dialog saying couldn't create new joiner???..
            fatalError("Could not creat new Joiner")
        }
        
        // TODO: make non-optional in database?
        joiner.creationDate = NSDate()
        let canvas = CanvasController(joiner, container: container, completion: { [weak self] in
            // I don't think the weak capture is necessary but not 100% on that
            guard let strongSelf = self else {
                return
            }
            strongSelf.fetchData()
            strongSelf.dismiss(animated: true, completion: nil)
        })
        let canvasNavigationController = UINavigationController(rootViewController: canvas)
        present(canvasNavigationController, animated: true)
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
        guard let joiner = fetchedResultsController.fetchedObjects?[indexPath.row] as? Joiner else {
            print("No joiner at index: \(indexPath.row)")
            return
        }
        
        let canvas = CanvasController(joiner, container: container, completion: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.fetchData()
            strongSelf.dismiss(animated: true, completion: nil)
        })
        let canvasNavigationController = UINavigationController(rootViewController: canvas)
        present(canvasNavigationController, animated: true)
    }
}
