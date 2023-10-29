//
//  Currency.swift
//  SwiftBlrTCADemo
//
//  Created by kanagasabapathy on 02/09/23.
//

import Foundation

struct CurrencyData: Decodable, Hashable {
//    let success: Bool
//    let timestamp: Int
//    let base: String
//    let date: String
//    let rates: [String: Double]

    let result: String
    let documentation: String
    let terms_of_use: String
    let time_last_update_unix: Int
    let time_last_update_utc: String
    let time_next_update_unix: Int
    let time_next_update_utc: String
    let base_code: String
    let conversion_rates: [String: Double]
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
