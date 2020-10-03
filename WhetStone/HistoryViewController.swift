//
//  HistoryViewController.swift
//  WhetStone
//
//  Created by Noirdemort on 03/10/20.
//

import UIKit

class HistoryViewController: UIViewController {

	var history: [String] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		historyTableView.delegate = self
		historyTableView.dataSource = self
		if let stored = UserDefaults.standard.array(forKey: "accessCodes") as? [String] {
			print(history)
			history = stored
		}
		print(history)
    }
    
	var selectedHistory = 0
	
	@IBOutlet weak var historyTableView: UITableView!

	
	@IBAction func goBack(_ sender: Any){
		self.navigationController?.popViewController(animated: true)
	}
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let destination = segue.destination as? SummaryViewController {
			UserDefaults.standard.set(history, forKey: "accessCodes")
			var localParser = CSVParser()
			localParser.parse(rawData: history[self.selectedHistory])
			destination.parser = localParser
		}
    }
    

}


extension HistoryViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
			
		if editingStyle == .delete {
			
			// remove corresponding file
			do {
				let fileManager = FileManager.default
				let docs = try fileManager.url(for: .documentDirectory,
											   in: .userDomainMask,
											appropriateFor: nil, create: false)
				let path = docs.appendingPathComponent(history[indexPath.row])
			  
				try fileManager.removeItem(atPath: path.absoluteString)
				
			} catch {
			  // handle error
			}

			// remove the item from the data model
			self.history.remove(at: indexPath.row)
				
			// delete the table view row
			self.historyTableView.deleteRows(at: [indexPath], with: .fade)
			
			
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.selectedHistory = indexPath.row
		self.performSegue(withIdentifier: "localSummarySegue", sender: nil)
	}
	
}


extension HistoryViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return history.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableCell
		cell.accessCodeLabel.text = history[indexPath.row]
		return cell
	}
		
}


class HistoryTableCell: UITableViewCell {
	
	@IBOutlet weak var accessCodeLabel: UILabel!
	
}
