//
//  CurrencyViewController.swift
//  Accomplisher
//
//  Created by Artem Mkr on 05.09.2022.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "Cell"

class CurrencyViewController: UICollectionViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    var selectedGoal: Goal?
    let realm = try! Realm()

    
    var dataSource: DataSource!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Currency"
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        let cellRegistration = UICollectionView.CellRegistration { [weak self] (cell: UICollectionViewListCell, indexPath: IndexPath, itemIdentifier: String) in
            let reminder = Currency.allCases[indexPath.item]
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = reminder.rawValue
            if contentConfiguration.text == self?.selectedGoal?.selectedCurrency {
                cell.accessories = [.checkmark()]
            }
            
            cell.contentConfiguration = contentConfiguration
            
        }
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: String) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(Currency.allCases.map { $0.rawValue })
        dataSource.apply(snapshot)
        
        collectionView.dataSource = dataSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell {
            // if the selected cell does not have a checkmark deselect all cells and check the selected one
            if cell.accessories.isEmpty {
                for row in 0..<collectionView.numberOfItems(inSection: 0) {
                    
                    let currentIndexPath = IndexPath(row: row, section:0)
                    if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? UICollectionViewListCell {
                        currentCell.accessories.removeAll()
                    }
                    
                }
            }
            cell.accessories = [.checkmark()]
            do {
                try realm.write {
                    selectedGoal?.selectedCurrency = Currency.allCases[indexPath.item].rawValue
                }
                
            } catch {
                print("Error updating currency text \(error)")
            }
            
            
            collectionView.deselectItem(at: indexPath, animated: true)
            collectionView.dataSource = dataSource

        }
        return false
    }
    
    
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.backgroundColor = .systemGroupedBackground
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
   
    
    
}
