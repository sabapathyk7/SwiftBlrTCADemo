//
//  Currency.swift
//  SwiftBlrTCADemo
//
//  Created by kanagasabapathy on 02/09/23.
//

import Foundation

struct CurrencyData: Decodable, Hashable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
}

struct TableViewData: Equatable, Identifiable, Hashable, Decodable {
    var id = UUID()
    var base: String
    var currencyCode: String
    var currencyName: String
    var currencyValue: Double
    var currencySymbol: String
}

struct Currency {
    var code: String
    var symbol: String
}
