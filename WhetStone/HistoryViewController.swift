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
		if let stored = UserDefaults.standard.array(forKey: "accessCodes") as? [String] {
			history = stored
		}
    }
    
	var selectedHistory = 0

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? SummaryViewController {
			var localParser = CSVParser()
			localParser.parse(rawData: history[self.selectedHistory])
			destination.parser = localParser
		}
    }
    

}


extension HistoryViewController: UITableViewDelegate {
	
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
