//
//  SummaryViewController.swift
//  WhetStone
//
//  Created by Noirdemort on 28/09/20.
//

import UIKit


class SummaryViewController: UIViewController {

	var parser: CSVParser = CSVParser()
	
	var selectedColumn: String? = nil
	var selectedComparison: Comparison? = nil
	
	var filters: [Filter<String>] = []
	var stats: [String: String] = [:]
	
	var statsKeys: [String] {
		get {
			return Array(stats.keys)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		addStats()
		
		tableColumnPicker.delegate = self
		tableColumnPicker.dataSource = self
	
		filterTable.delegate = self
		filterTable.dataSource = self
		
		summaryTable.delegate = self
		summaryTable.dataSource = self
		
    }
	
	
	@IBOutlet weak var valueField: UITextField!
	
	@IBOutlet weak var tableColumnPicker: UIPickerView!
		
	@IBOutlet weak var filterTable: UITableView!
	
	@IBOutlet weak var summaryTable: UITableView!
	
	
	@IBAction func goBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	
	@IBAction func addFilter(_ sender: Any) {
		
		guard let value = valueField.text else {
			presentAlert(with: "Value field is null")
			return
		}
		
		if value.isEmpty {
			presentAlert(with: "Value is required")
			return
		}
		
		guard let comparison = selectedComparison else {
			presentAlert(with: "Comparison is not selected")
			return
		}
		
		guard let column = selectedColumn else {
			presentAlert(with: "Table Column in not selected")
			return
		}
		
		let filter = Filter(key: column, target: value, comparison: comparison)
		self.filters.append(filter)
		
		self.filterTable.reloadData()
		
	}
	
	
	@IBAction func processFilters(_ sender: Any) {
		self.performSegue(withIdentifier: "resultSegue", sender: nil)
	}
	
	
	func presentAlert(with message: String){
		let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		
		alertController.addAction(UIAlertAction(title: "OK" ,style: .default, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if let destination = segue.destination as? FilterViewController {
//			destination.filteredResult = parser.rows(for: filters)
//			destination.columns = parser.columns
//		}
		
		if let destination = segue.destination as? ResultsViewController {
			var filteredData = parser.rows(for: filters)
			filteredData.insert(parser.columns, at: 0)
			destination.data = filteredData
		}
	}
	
	
	func addStats(){
		stats["Columns"] = parser.columns.joined(separator: ", ")
		stats["Data Columns"] = "\(parser.data.count)"
		stats["Sample Data"] = parser.data.last?.joined(separator: ", ") ?? ""
		stats["Sample Record"] = "[".appending(zip(parser.columns, parser.data.last ?? Array(repeating: "?", count: parser.columns.count)).map { a,b in a.appending(": ").appending(b) }.joined(separator: ", ")).appending(" ]")
	}
	
	
	
}

 
extension SummaryViewController: UIPickerViewDelegate {
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		switch component {
		case 0:
			self.selectedColumn = parser.columns[row]
		default:
			self.selectedComparison = Comparison.allCases[row]
		}
	}
	
}


extension SummaryViewController: UIPickerViewDataSource {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		switch component {
		case 0:
			return self.parser.columns.count
		default:
			return Comparison.allCases.count
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch component {
		case 0:
			return self.parser.columns[row]
		default:
			return Comparison.allCases[row].rawValue
		}
	}
	
}

extension SummaryViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete && tableView == filterTable {
			self.filters.remove(at: indexPath.row)
			self.filterTable.deleteRows(at: [indexPath], with: .fade)
		}
		
	}
	
}


extension SummaryViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch tableView {
		
		case self.filterTable:
			return self.filters.count
		
		case self.summaryTable:
			return statsKeys.count
			
		default:
			return 0
			
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch tableView {
		
		case self.filterTable:
			let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as! FilterCell
			let filter = self.filters[indexPath.row]
			cell.headerLabel.text = filter.key
			cell.targetLabel.text = filter.target
			cell.comparatorLabel.text = filter.comparison.rawValue
			return cell
		
		case self.summaryTable:
			let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) as! SummaryCell
			let key = statsKeys[indexPath.row]
			cell.summaryLabel.text = "\(key) => \(stats[key] ?? "?") "
			return cell
			
		default:
			return tableView.cellForRow(at: indexPath) ?? UITableViewCell()
			
		}
		
	}
	
	
}


class FilterCell: UITableViewCell {
	
	@IBOutlet weak var headerLabel: UILabel!
	
	@IBOutlet weak var comparatorLabel: UILabel!
	
	@IBOutlet weak var targetLabel: UILabel!
	
}



class SummaryCell: UITableViewCell {
	
	
	@IBOutlet weak var summaryLabel: UILabel!
	
}
