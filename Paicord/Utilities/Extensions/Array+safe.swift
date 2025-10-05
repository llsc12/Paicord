//
//  Array+safe.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 05/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Collections

extension OrderedDictionary.Elements {
	subscript(safe index: Int) -> Element? {
		(startIndex..<endIndex).contains(index) ? self[index] : nil
	}
}
extension Array {
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}
