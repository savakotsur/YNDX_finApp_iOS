//
//  TransationsHistoryView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 19.06.2025.
//

import SwiftUI

struct TransactionsHistoryView: View {
    @State var vm: TransactionsViewModel
    var direction: Direction
    @Environment(\.dismiss) private var dismiss
    
    init(direction: Direction) {
        self.direction = direction
        _vm = State(initialValue: TransactionsViewModel(direction: direction, startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), endDate: Date()))
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Начало")
                    Spacer()
                    DatePickerCompactRow(selectedDate: $vm.startDate)
                }
                HStack {
                    Text("Конец")
                    Spacer()
                    DatePickerCompactRow(selectedDate: $vm.endDate)
                    
                }
                HStack {
                    Text("Сумма")
                    Spacer()
                    Text("\(vm.totalAmount.groupedString) ₽")
                }
            }
            
            TransactionsSectionView(
                transactions: vm.transactions,
                isOutcome: true,
                getEmoji: { vm.getEmoji(for: $0) },
                getCategoryName: { vm.getCategoryName(for: $0) }
            )
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                        Text("Назад")
                    }
                    .foregroundStyle(.toolbarAccent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Text("Сортировать по: ")
                    Button {
                        vm.sortByDate()
                    } label: {
                        Text("Дате")
                        Image(systemName: "clock")
                    }
                    Button {
                        vm.sortByAmount()
                    } label: {
                        Text("Сумме")
                        Image(systemName: "rublesign")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundStyle(.toolbarAccent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("тут будет анализ")
                } label: {
                    Image(systemName: "document")
                        .foregroundStyle(.toolbarAccent)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
