//
//  OperationView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 12.07.2025.
//

import SwiftUI

struct OperationView: View {
    @State
    var viewModel: OperationViewModel
    @State private var showSaveAlert = false
    @Environment(\.dismiss) private var dismiss
    
    let direction: Direction
    let onDismiss: (() -> Void)?
    
    init(direction: Direction, transaction: Transaction? = nil, onDismiss: (() -> Void)? = nil) {
        self.direction = direction
        self._viewModel = State(
            wrappedValue: OperationViewModel(
                mode: transaction == nil ? .create : .edit,
                transaction: transaction,
                direction: direction
            )
        )
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Статья", selection: $viewModel.selectedCategoryId) {
                        Text("Выберите статью").tag(Optional<Int>(nil))
                        ForEach(viewModel.categories, id: \.id) { category in
                            Text(category.name).tag(Optional(category.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.secondary)
                    
                    HStack {
                        Text("Сумма")
                        Spacer()
                        TextField("Введите сумму", text: $viewModel.amountString)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(minWidth: 100)
                            .foregroundStyle(Color.secondary)
                            .onChange(of: viewModel.amountString) {
                                let filtered = viewModel.amountString.filter { "0123456789,".contains($0) }
                                var components = filtered.components(separatedBy: ",")
                                if components.count > 2 {
                                    components = [components[0], components[1]]
                                }
                                viewModel.amountString = components.joined(separator: ",")
                            }
                    }
                    
                    DatePicker("Дата", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)

                    DatePicker("Время", selection: $viewModel.date, in: ...Date(), displayedComponents: .hourAndMinute)
                    
                    ZStack(alignment: .topLeading) {
                        if viewModel.comment.isEmpty {
                            Text("Комментарий")
                                .foregroundColor(Color.gray)
                                .padding(8)
                        }
                        TextEditor(text: $viewModel.comment)
                            .frame(minHeight: 80, maxHeight: 120)
                    }
                }
                if viewModel.mode == .edit {
                    Section {
                        Button("Удалить \(direction == .income ? "доход" : "расход")") {
                            Task {
                                await viewModel.delete()
                                if !viewModel.showAlert {
                                    dismiss()
                                    onDismiss?()
                                }
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Операция")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                        onDismiss?()
                    }
                    .foregroundStyle(Color.toolbarAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("\(viewModel.mode == .create ? "Создать" : "Сохранить")") {
                        Task {
                            await viewModel.save()
                            if viewModel.showAlert {
                                showSaveAlert = true
                            } else {
                                dismiss()
                                onDismiss?()
                            }
                        }
                    }
                    .foregroundStyle(Color.toolbarAccent)
                }
            }
            .alert(isPresented: $showSaveAlert) {
                Alert(title: Text("Ошибка"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            .task {
                await viewModel.loadCategories()
            }
        }
    }
}
