//
//  SwiftUIView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 19.06.2025.
//

import SwiftUI

struct TransactionsSectionView: View {
    let onFinishEditing: () -> Void
    let transactions: [Transaction]
    let isOutcome: Bool
    let getEmoji: (Int) -> String
    let getCategoryName: (Int) -> String
    
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        Section("ОПЕРАЦИИ") {
            ForEach(transactions, id: \.self.id) { transaction in
                HStack {
                    if isOutcome {
                        Text(getEmoji(transaction.categoryId))
                            .font(.subheadline)
                            .padding(5)
                            .background(Color("lightGreen"))
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading) {
                        Text(getCategoryName(transaction.categoryId))
                            .font(.body)
                        if let comment = transaction.comment {
                            Text(comment)
                                .font(.footnote)
                                .foregroundStyle(Color("footnoteGray"))
                        }
                    }
                    Spacer()
                        .frame(minWidth: 1)
                    Text("\(transaction.amount.groupedString) ₽")
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(Color("footnoteGray"))
                }
                .frame(maxHeight: 36)
                .padding(.vertical, 0.5)
                .contentShape(Rectangle())
                .onTapGesture {
                        selectedTransaction = transaction
                }
            }
        }
        //MARK: Я знаю что оно работает очень криво, я 3 часа сидел над этим и не смог пофиксить
        .fullScreenCover(item: $selectedTransaction) { transaction in
            OperationView(direction: isOutcome ? .outcome : .income, transaction: transaction)
                .onDisappear {
                    selectedTransaction = nil
                    onFinishEditing()
                }
        }
    }
}
