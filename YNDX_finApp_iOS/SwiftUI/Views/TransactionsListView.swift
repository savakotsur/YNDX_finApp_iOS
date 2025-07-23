//
//  TransactionsListView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 18.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    @State var vm: TransactionsViewModel
    @State private var showCreateModal = false
    @State private var selectedTransaction: Transaction?
    
    init(direction: Direction) {
        self.direction = direction
        _vm = State(initialValue: TransactionsViewModel(direction: direction, startDate: Date(), endDate: Date()))
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                Section {
                    HStack {
                        Text("Всего")
                        Spacer()
                        Text("\(vm.totalAmount.groupedString) ₽")
                    }
                }
                
                TransactionsSectionView(
                    transactions: vm.transactions,
                    isOutcome: direction == .outcome,
                    getEmoji: { vm.getEmoji(for: $0) },
                    getCategoryName: { vm.getCategoryName(for: $0) },
                    onTap: { transaction in
                        selectedTransaction = transaction
                    })
            }
            .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: TransactionsHistoryView(direction: direction)) {
                        Image(systemName: "clock")
                            .imageScale(.large)
                            .foregroundStyle(.toolbarAccent)
                    }
                }
            }
            
            Button {
                showCreateModal = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .padding()
            .fullScreenCover(isPresented: $showCreateModal) {
                OperationView(direction: direction)
                    .onDisappear {
                        Task {
                            await vm.fetchTransactions()
                        }
                    }
            }
            .fullScreenCover(item: $selectedTransaction) { transaction in
                OperationView(direction: direction, transaction: transaction)
                    .onDisappear {
                        Task {
                            await vm.fetchTransactions()
                        }
                    }
            }
        }
    }
}
