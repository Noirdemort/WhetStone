//
//  ResultsViewController.swift
//  WhetStone
//
//  Created by Noirdemort on 30/09/20.
//

import UIKit

class ResultsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		filterTable.delegate = self
		filterTable.dataSource = self
		print(data)
    }
		
	var data: [[String]] = []
	var cellStorage: [Int: UITableViewCell] = [:]
	
	@IBOutlet weak var filterTable: UITableView!
	
	@IBAction func goBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
    
}



extension ResultsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
	
}


extension ResultsViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = self.cellStorage[indexPath.row] {
			return cell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "filterTableCell", for: indexPath) as! FilterTableCell
		
		cell.record = data[indexPath.row]
		cell.filterCollection.delegate = cell
		cell.filterCollection.dataSource = cell
		
		self.cellStorage[indexPath.row] = cell
		return cell
		
	}
	
	
}



class FilterTableCell: UITableViewCell {
	
	var record: [String] = []
	
	var collectionStorage: [Int: UICollectionViewCell] = [:]
	
	@IBOutlet weak var filterCollection: UICollectionView!
	
}


extension FilterTableCell: UICollectionViewDelegate {
	
	
	
}


extension FilterTableCell: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return record.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if let cell = self.collectionStorage[indexPath.row] {
			return cell
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCollectionCell", for: indexPath) as! FilterCollectionCell
		
		cell.dataLabel.text = record[indexPath.row]
		self.collectionStorage[indexPath.row] = cell
		return cell
	}
	
	
	
}




class FilterCollectionCell: UICollectionViewCell {
	
	@IBOutlet weak var dataLabel: UILabel!
	
}
