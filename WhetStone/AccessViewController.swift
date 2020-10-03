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
				
					DispatchQueue.main.async {
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
		if let destination = segue.destination as? SummaryViewController {
			
			var localParser = CSVParser()
			localParser.parse(rawData: csv)
			
			destination.parser = localParser
		}
	}
	

}

