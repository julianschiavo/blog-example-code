//
//  ViewController.swift
//  CoreData+DiffableDataSource
//
//  Created by Julian Schiavo on 24/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import UIKit

protocol AllShortcutsViewControllerDataSourceDelegate: AnyObject {
    var addedShortcuts: [ShortcutsManager.Shortcut] { get }
    var allShortcuts: [ShortcutsManager.Shortcut] { get }
}

class AllShortcutsViewController: UITableViewController, ShortcutsManagerDelegate, AllShortcutsViewControllerDataSourceDelegate {
    enum Section: Hashable {
        case addedShortcuts
        case allShortcuts
        
        var title: String? {
            switch self {
            case .addedShortcuts: return "Your Shortcuts"
            case .allShortcuts: return "All Shortcuts"
            }
        }
    }
    
    var addedShortcuts = [ShortcutsManager.Shortcut]()
    var allShortcuts = [ShortcutsManager.Shortcut]()
    
    var dataSource: DataSource!
    
    init() {
        super.init(style: .insetGrouped)
        
        title = "Siri Shortcuts"
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DataSource.cellReuseIdentifier)
        
        setupDataSource()
        reloadShortcuts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDataSource() {
        dataSource = DataSource(delegate: self, tableView: tableView)
        dataSource.reload()
    }
    
    func reloadShortcuts() {
        ShortcutsManager.shared.loadShortcuts(kinds: ShortcutsManager.Kind.allCases) { [weak self] shortcuts in
            self?.allShortcuts = shortcuts.filter { $0.voiceShortcut == nil }
            self?.addedShortcuts = shortcuts.filter { $0.voiceShortcut != nil }
            
            DispatchQueue.main.async {
                self?.dataSource.reload()
            }
        }
    }
    
    class DataSource: UITableViewDiffableDataSource<Section, ShortcutsManager.Shortcut> {
        static let cellReuseIdentifier = "SettingsCell"
        weak var delegate: AllShortcutsViewControllerDataSourceDelegate?
        var snapshot: NSDiffableDataSourceSnapshot<Section, ShortcutsManager.Shortcut>!
        
        func getSection(for section: Int) -> Section? {
            snapshot?.sectionIdentifiers[section]
        }
        
        func getItem(at indexPath: IndexPath) -> ShortcutsManager.Shortcut? {
            itemIdentifier(for: indexPath)
        }
        
        init(delegate: AllShortcutsViewControllerDataSourceDelegate, tableView: UITableView) {
            self.delegate = delegate
            super.init(tableView: tableView) { tableView, indexPath, shortcut -> UITableViewCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: DataSource.cellReuseIdentifier, for: indexPath)
                cell.textLabel?.text = shortcut.kind.suggestedInvocationPhrase
                
                let phrase = shortcut.voiceShortcut?.invocationPhrase ?? ""
                cell.detailTextLabel?.text = phrase.isEmpty ? nil : "Say \"" + phrase + "\""
                
                if shortcut.voiceShortcut == nil {
                    cell.accessoryView = UIImageView(image: UIImage(systemName: "plus"))
                } else {
                    cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark"))
                }
                cell.accessoryView?.tintColor = .orange
                
                return cell
            }
        }
        
        func reload() {
            guard let addedShortcuts = delegate?.addedShortcuts, let allShortcuts = delegate?.allShortcuts else { return }
            
            snapshot = NSDiffableDataSourceSnapshot<Section, ShortcutsManager.Shortcut>()
            
            if !addedShortcuts.isEmpty {
                snapshot.appendSections([.addedShortcuts])
                snapshot.appendItems(addedShortcuts, toSection: .addedShortcuts)
            }
            
            if !allShortcuts.isEmpty {
                snapshot.appendSections([.allShortcuts])
                snapshot.appendItems(allShortcuts, toSection: .allShortcuts)
            }
            
            apply(snapshot, animatingDifferences: true)
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            getSection(for: section)?.title
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let shortcut = dataSource.getItem(at: indexPath) else { return }
        ShortcutsManager.shared.showShortcutsPhraseViewController(for: shortcut, on: self, delegate: self)
    }
    
    // MARK: - ShortcutsManagerDelegate
    
    func shortcutViewControllerDidCancel() {
        return
    }
    
    func shortcutViewControllerDidFinish(with shortcut: ShortcutsManager.Shortcut) {
        reloadShortcuts()
    }
    
    func shortcutViewControllerDidDeleteShortcut(_ shortcut: ShortcutsManager.Shortcut, identifier: UUID) {
        reloadShortcuts()
    }
    
    func shortcutViewControllerFailed(with error: Error?) {
        reloadShortcuts()
    }
}
