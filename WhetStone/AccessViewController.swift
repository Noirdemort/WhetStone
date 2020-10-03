//
//  AccessViewController.swift
//  WhetStone
//
//  Created by Noirdemort on 28/09/20.
//

import UIKit

// TODO:- Add Storage based on access codes to provide history, should've read and delete ops

class AccessViewController: UIViewController {

	
	@IBOutlet weak var accessCodeField: UITextField!
	
	var csv: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	
	@IBAction func showHistory(_ sender: Any){
		self.performSegue(withIdentifier: "storageSegue", sender: nil)
	}

	
	@IBAction func showData(_ sender: Any) {
		guard let accessCode = self.accessCodeField.text else { return }
		guard let url = URL(string: "http://127.0.0.1:5000/access/\(accessCode)") else {
			self.presentAlert(with: "Invalid Access Code")
			return
		}
		
		DispatchQueue.global(qos: .userInitiated).async {
			let session = URLSession.shared
			session.dataTask(with: url){ [unowned self](data, response, err) in
				
				if err != nil {
					DispatchQueue.main.async {
						self.presentAlert(with: "Failed to get response from server. Some Error Occurred.")
					}
					return
				}
				
				if let httpResponse = response as? HTTPURLResponse {
					if httpResponse.statusCode != 200 {
						DispatchQueue.main.async {
							self.presentAlert(with: "Request to server failed with access code: \(httpResponse.statusCode)")
						}
						return
					}
					
					guard let parseData = data else { return }
					
					guard let csv = String(data: parseData, encoding: .utf8) else { return }
					
					do {
					  	let fileManager = FileManager.default
						let docs = try fileManager.url(for: .documentDirectory,
													   in: .userDomainMask,
													appropriateFor: nil, create: false)
						let path = docs.appendingPathComponent(accessCode)
					  
					  	fileManager.createFile(atPath: path.absoluteString,
											 contents: parseData, attributes: nil)
						
					} catch {
					  // handle error
					}
				
					DispatchQueue.main.async {
						if let history = UserDefaults.standard.array(forKey: "accessCodes") as? [String] {
							var records = history
							records.append(accessCode)
							UserDefaults.standard.set(records, forKey: "accessCodes")
						}
						self.csv = csv
						self.performSegue(withIdentifier: "summarySegue", sender: nil)
					}
				}
				
			}.resume()
		}
	}
	
	func presentAlert(with message: String){
		let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		
		alertController.addAction(UIAlertAction(title: "OK" ,style: .default, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let _ = segue.destination as? HistoryViewController {
			
		}
		
		if let destination = segue.destination as? SummaryViewController {
			
			var localParser = CSVParser()
			localParser.parse(rawData: csv)
			
			destination.parser = localParser
		}
	}
	

}

