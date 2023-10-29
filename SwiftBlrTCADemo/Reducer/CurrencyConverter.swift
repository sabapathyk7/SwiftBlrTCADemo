//
//  CurrencyConverter.swift
//  SwiftBlrTCADemo
//
//  Created by kanagasabapathy on 02/09/23.
//

import Foundation
import ComposableArchitecture

struct CurrencyConverter: Reducer {
    typealias Currencies = [TableViewData]
    private let baseURL = "https://v6.exchangerate-api.com/v6/"
    private let accessKey = "c1a4fe51ecfcebb4ddda0835"

    struct State: Equatable {
        var initialCurrencies: Currencies = []
        var currencies: Currencies = []
        var priceQuantityEntered = "1"
        var selectedBaseCurrency: String = "EUR"
    }
    
    enum Action: Equatable {
        case onAppear
        case processAPIResponse(CurrencyData)
        case updateCurrencies(Currencies)
        case quantityTextFieldEntered(String)
        case countryCodePickerSelected(String)
    }
    
    var body: some ReducerOf<Self> {
        Reduce{ state, action in
            let selectedBase = state.selectedBaseCurrency
            switch action {
            case .onAppear:
                return .run { send in
                    let (data, _) = try await URLSession.shared.data(from: URL(string: baseURL + accessKey + "/latest/\(selectedBase)")!)
                    let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                    await send(.processAPIResponse(currencyData))
                }
            case let .processAPIResponse(data):
                let cuurencies = getTableViewDataArray(currencyListView: data)
                state.initialCurrencies = cuurencies
//                return .send(.updateCurrencies(cuurencies))
                guard let convertPrice = Double(state.priceQuantityEntered) else {
                    return .none
                }
                if convertPrice > 1.0 {
                    return .send(.updateCurrencies(reactToEnteredAmount(state: state, amount: Double(state.priceQuantityEntered) ?? 1.0)))
                } else {
                    return .send(.updateCurrencies(cuurencies))
                }
            case let .updateCurrencies(currencies):
                state.currencies = currencies
                return .none
            case let .quantityTextFieldEntered(string):
                state.priceQuantityEntered = string
                print(string)
                return .send(.updateCurrencies(reactToEnteredAmount(state: state, amount: Double(string) ?? 1.0)))
            case let .countryCodePickerSelected(currencyCode):
                state.selectedBaseCurrency = currencyCode
                return .run { send in
                    let (data, _) = try await URLSession.shared.data(from: URL(string: baseURL + accessKey + "/latest/\(currencyCode)")!)
                    let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                    await send(.processAPIResponse(currencyData))
                }
            }
        }
    }
}


private extension CurrencyConverter {
    func getTableViewDataArray(currencyListView: CurrencyData) -> Currencies {
        let currencyDet = self.fetchAllCurrencyDetails()
        var arrayOfTableViewData: Currencies = Currencies()
        for (key, value) in currencyListView.conversion_rates {
            guard let currencySymbol = currencyDet.filter({ $0.code.contains(key)}).last else {
                continue
            }
            let locale = Locale.current
            guard let currencyName = locale.localizedString(forCurrencyCode: key) else {
                continue
            }
            let tableViewData = TableViewData(base: "EUR", currencyCode: key,
                                              currencyName: currencyName,
                                              currencyValue: value.rounded(toPlaces: 2),
                                              currencySymbol: currencySymbol.symbol)
            arrayOfTableViewData.append(tableViewData)
        }
        arrayOfTableViewData = arrayOfTableViewData.sorted(by: { tableViewData1, tableViewData2 in
            let currencyName1 = tableViewData1.currencyCode
            let currencyName2 = tableViewData2.currencyCode
            return (currencyName1.localizedCaseInsensitiveCompare(currencyName2) == .orderedAscending)
        })
        return arrayOfTableViewData
    }
    func fetchAllCurrencyDetails() -> [Currency] {
        var currencyDet: [Currency] = [Currency]()
        for localeID in Locale.availableIdentifiers {
            let locale = Locale(identifier: localeID)
            guard let currencyCode = locale.currency?.identifier,
                  let currencySymbol = locale.currencySymbol else {
                continue
            }
            if !currencySymbol.validateGenericString(currencySymbol) {
                let filter = currencyDet.filter { $0.code.contains(currencyCode) }
                if filter.isEmpty {
                    currencyDet.append(Currency(code: currencyCode, symbol: currencySymbol))
                }
            }
        }
        return currencyDet
    }
    func reactToEnteredAmount(state: CurrencyConverter.State, amount: Double) -> Currencies {
        if amount != 0 {
            return state.initialCurrencies.map { data in
                return TableViewData(base: state.selectedBaseCurrency,
                                     currencyCode: data.currencyCode,
                                     currencyName: data.currencyName,
                                     currencyValue: (data.currencyValue * amount).rounded(toPlaces: 2),
                                     currencySymbol: data.currencySymbol)
            }
        }
        return []
    }
}

extension String {
    
    func validateGenericString(_ string: String) -> Bool {
        return string.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil
    }
}
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

