//
//  AccountView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 27.06.2025.
//

import SwiftUI
import UIKit

struct AccountView: View {
    @State
    private var viewModel = AccountViewModel()
    @FocusState private var isBalanceFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack (alignment: .top) {
                    Text("💰   Баланс")
                    Spacer()
                    if viewModel.isEditing {
                        TextField("0", text: $viewModel.balanceInput)
                            .keyboardType(.decimalPad)
                            .focused($isBalanceFieldFocused)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black)
                            .frame(minWidth: 60, maxWidth: 120)
                            .onChange(of: viewModel.balanceInput) {
                                viewModel.updateBalanceInput(viewModel.balanceInput)
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button("Вставить") {
                                        if let text = UIPasteboard.general.string {
                                            viewModel.pasteBalance(text)
                                        }
                                    }
                                    Spacer()
                                    Button("Готово") { isBalanceFieldFocused = false }
                                }
                            }
                    } else {
                        if viewModel.isBalanceHidden {
                            SpoilerView(text: "\(viewModel.balance.groupedString) \(viewModel.currency.rawValue)")
                        } else {
                            Text("\(viewModel.balance.groupedString) \(viewModel.currency.rawValue)")
                        }
                    }
                }
                .padding(13)
                .frame(maxWidth: .infinity)
                .background(viewModel.isEditing == false ? Color.accentColor : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top)
                .padding(.horizontal)
                HStack (alignment: .top) {
                    Text("Валюта")
                    Spacer()
                    if viewModel.isEditing {
                        HStack {
                            Text("\(viewModel.currency.rawValue)")
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(Color(.systemGray2))
                        .onTapGesture {
                            viewModel.showCurrencyPicker = true
                        }
                    } else {
                        Text("\(viewModel.currency.rawValue)")
                    }
                }
                .padding(13)
                .frame(maxWidth: .infinity)
                .background(viewModel.isEditing == false ? Color.lightGreen : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 8)
                .padding(.horizontal)
                .confirmationDialog("Валюта", isPresented: $viewModel.showCurrencyPicker, titleVisibility: .visible) {
                    ForEach(viewModel.currencies) { currency in
                        Button {
                            withAnimation {
                                viewModel.selectCurrency(currency)
                            }
                        } label: {
                            Text("\(currency.rawValue)")
                        }
                    }
                    Button("Отмена", role: .cancel) { }
                        .foregroundStyle(.toolbarAccent)
                }
                Spacer()
            }
        }
        .refreshable {
            viewModel.refresh()
        }
        .background(Color(.systemGray6))
        .navigationTitle("Мой счет")
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            viewModel.save()
                        }
                    } label: {
                        Text("Cохранить")
                            .foregroundStyle(.toolbarAccent)
                    }
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            viewModel.startEditing()
                        }
                    } label: {
                        Text("Редактировать")
                            .foregroundStyle(.toolbarAccent)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            withAnimation {
                viewModel.toggleBalanceHidden()
            }
        }
    }
}

//MARK: Пока что работает кривовато (не похоже на телегу) - исправлю в будующем
struct SpoilerView: View {
    let text: String
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1)
            ZStack {
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .opacity(0)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .background(
                        GeometryReader { geo in
                            Canvas { context, size in
                                let width = size.width
                                let height = size.height
                                let barWidth: CGFloat = 8
                                let spacing: CGFloat = 4
                                let count = Int(width / (barWidth + spacing))
                                let offset = CGFloat(phase) * (barWidth + spacing)
                                for i in 0..<count {
                                    let x = CGFloat(i) * (barWidth + spacing) - offset
                                    let rect = CGRect(x: x, y: 0, width: barWidth, height: height)
                                    context.fill(Path(rect), with: .color(.gray.opacity(0.5)))
                                }
                            }
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.6)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    )
            }
        }
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}

extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}
