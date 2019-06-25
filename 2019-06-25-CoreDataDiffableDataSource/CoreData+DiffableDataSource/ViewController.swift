//
//  ViewController.swift
//  CoreData+DiffableDataSource
//
//  Created by Julian Schiavo on 24/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import CoreData
import UIKit

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

    var container = NSPersistentContainer(name: "CoreData_DiffableDataSource")
    var fetchedResultsController: NSFetchedResultsController<Color>!
    
    var diffableDataSource: UITableViewDiffableDataSource<Int, Color>?
    var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Color>()
    
    var currentSearchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCoreData()
        setupFetchedResultsController()
        
        setupTableView()
        setupSearchController()
        downloadColors()
    }
    
    // MARK: - Table View Setup
    
    /// Setup the `UITableViewDiffableDataSource` with a cell provider that sets up the default table view cell
    private func setupTableView() {
        diffableDataSource = UITableViewDiffableDataSource<Int, Color>(tableView: tableView) { (tableView, indexPath, color) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
            
            cell.textLabel?.text = color.name
            cell.detailTextLabel?.text = color.hexColor
            
            let backgroundColor = color.uiColor ?? .systemBackground
            cell.textLabel?.textColor = UIColor.basedOnBackgroundColor(backgroundColor)
            cell.detailTextLabel?.textColor = UIColor.basedOnBackgroundColor(backgroundColor)
            cell.contentView.backgroundColor = backgroundColor
            
            return cell
        }
        
        setupSnapshot()
    }
    
    /// Create a `NSDiffableDataSourceSnapshot` with the table view data
    private func setupSnapshot() {
        diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, Color>()
        diffableDataSourceSnapshot.appendSections([0])
        diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
        diffableDataSource?.apply(self.diffableDataSourceSnapshot)
    }
    
    // MARK: - Delete support
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            guard let color = self.diffableDataSource?.itemIdentifier(for: indexPath) else { return }
            self.container.viewContext.delete(color)
            self.setupSnapshot()
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Networking
    
    let colorListURL = URL(string: "https://github.com/bahamas10/css-color-names/raw/master/css-color-names.json")
    
    /// Download a list of colors from the above URL and load them
    private func downloadColors() {
        DispatchQueue.global(qos: .userInteractive).async {
            let decoder = JSONDecoder()
            
            guard let url = self.colorListURL,
                let data = try? Data(contentsOf: url),
                let dict = try? decoder.decode([String: String].self, from: data) else { return }
            
            DispatchQueue.main.async {
                self.loadColors(dict)
            }
        }
    }
    
    /// Load the downloaded colors into CoreData and display them
    private func loadColors(_ colors: [String: String]) {
        for jsonColor in colors {
            let color = Color(context: self.container.viewContext)
            color.name = jsonColor.key
            color.hexColor = jsonColor.value
        }
        
        saveChangesToDisk()
        setupSnapshot()
    }
    
    // MARK: - Core Data
    
    /// Setup the CoreData database
    private func setupCoreData() {
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Failed to load database: \(error)")
            }
        }
    }
    
    /// Setup the `NSFetchedResultsController`, which manages the data shown in our table view
    private func setupFetchedResultsController() {
        let request = Color.createFetchRequest()
        request.fetchBatchSize = 30
        
        if !currentSearchText.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR hexColor CONTAINS[c] %@", currentSearchText, currentSearchText)
        }
        
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            setupSnapshot()
        } catch {
            print("Fetch failed")
        }
    }
    
    /// Save the changes from the CoreData database held in memory to the on disk database
    func saveChangesToDisk() {
        guard container.viewContext.hasChanges else { return }
        
        do {
            try container.viewContext.save()
        } catch {
            print("Failed to save changes to disk: \(error)")
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Whenever the `NSFetchedResultsController` data changes, reload the table view data with animations
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupSnapshot()
    }
    
    // MARK: - Search
    
    /// Setup the `UISearchController` to let users search through the list of colors
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Colors"
        navigationItem.searchController = searchController
    }
    
    /// When a user enters a search term, filter the table view
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        currentSearchText = text
        setupFetchedResultsController()
    }
    
}

