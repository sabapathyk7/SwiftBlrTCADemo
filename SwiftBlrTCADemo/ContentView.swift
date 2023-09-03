//
//  ContentView.swift
//  SwiftBlrTCADemo
//
//  Created by kanagasabapathy on 02/09/23.
//

import SwiftUI
import ComposableArchitecture
struct ContentView: View {
    let store: StoreOf<CurrencyConverter>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    TextField(
                        "Enter text",
                        text: viewStore.binding(
                            get: \.priceQuantityEntered,
                            send: { .quantityTextFieldEntered($0) }
                        )
                    )
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    Spacer()
                    Picker("Currency",
                           selection: viewStore.binding(
                            get: \.selectedBaseCurrency,
                            send: { .countryCodePickerSelected($0) })
                    ) {
                        ForEach(viewStore.currencies) {
                            Text($0.currencyCode)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Spacer()
                List(viewStore.currencies) { tableViewData in
                    CurrencyRowView(tableViewData: tableViewData)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialState: .init(), reducer: { CurrencyConverter() }))
    }
}
