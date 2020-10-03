//
//  Parser.swift
//  WhetStone
//
//  Created by Noirdemort on 28/09/20.
//

import Foundation

fileprivate let csvText = """
Date,Open,High,Low,Close,Volume,Adj. Close
19-Sep-03,29.76,29.97,29.52,29.96,92433800,29.79
18-Sep-03,28.49,29.51,28.42,29.50,67268096,29.34
17-Sep-03,28.76,28.95,28.47,28.50,47221600,28.34
16-Sep-03,28.41,28.95,28.32,28.90,52060600,28.74
15-Sep-03,28.37,28.61,28.33,28.36,41432300,28.20
12-Sep-03,27.48,28.40,27.45,28.34,55777200,28.18
11-Sep-03,27.66,28.11,27.59,27.84,37813300,27.68
10-Sep-03,28.03,28.18,27.48,27.55,54763500,27.40
9-Sep-03,28.65,28.71,28.31,28.37,44315200,28.21
"""


enum Comparison: String, CaseIterable {
	
//	case lessThan
//	case lessThanOrEqualTo
//
//	case greaterThan
//	case greaterThanOrEqualTo
	
	case equal
	case notEqual
	
	var description: String { return rawValue }
	
}


struct Filter<T: Equatable> {
	private(set) var key: String
	private(set) var target: T
	private(set) var comparison: Comparison
}


protocol TableParser {
	
	associatedtype T: Equatable & LosslessStringConvertible
	
	var columns: [T] { get }
	var data: [[T]] { get }
	
	mutating func parse(rawData: String)
	func rows(for params: [Filter<T>]) -> [[T]]
	func satisfies(filter: Filter<T>, values: [T]) -> Bool
}



struct CSVParser: TableParser {
	
	typealias T = String
	
	var columns: [String] = []
	
	private(set) var data: [[String]] = []
	
	
	mutating func parse(rawData: String) {
		
		var record: [String] = []
		
		rawData
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.components(separatedBy: "\n")
			.filter { !$0.isEmpty }
			.forEach {
				record = $0.trimmingCharacters(in: .whitespaces).components(separatedBy: ",")
				if !record.isEmpty {
					data.append(record)
				}
			}
		
		columns = data.removeFirst()
			
	}
	
	
	func rows(for params: [Filter<String>]) -> [[String]] {
		var filters = params
		var records: [[String]] = []

		if let last = filters.popLast() {
			records = data.filter { satisfies(filter: last, values: $0) }
		}
		
		filters.forEach { filter in
			records = records.filter { satisfies(filter: filter, values: $0) }
		}
				
		return records
	}
	
	
	func satisfies(filter: Filter<String>, values: [String]) -> Bool {
		
		guard let index = columns.firstIndex(of: filter.key) else { return false }
			
		switch filter.comparison {
			case .equal:
				return values[index] == filter.target
			default:
				return !(values[index] == filter.target)
		}
		
	}
	
}



var localParser = CSVParser()
//localParser.parse(rawData: csvText)


let highFilter = Filter<String>(key: "High", target: "28.95", comparison: .equal)
let volumeFilter = Filter<String>(key: "Volume", target: "52060600", comparison: .notEqual)



//localParser.rows(for: [highFilter, volumeFilter]).forEach {
//	print($0)
//}

