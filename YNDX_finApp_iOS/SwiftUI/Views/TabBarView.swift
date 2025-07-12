//
//  ContentView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 13.06.2025.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TransactionsListView(direction: .outcome)
            }
            .tabItem {
                Image("downtrend")
                    .renderingMode(.template)
                Text("Расходы")
            }
            .toolbarBackground(.visible, for: .tabBar)
            
            NavigationStack {
                TransactionsListView(direction: .income)
            }
            .tabItem {
                Image("uptrend")
                    .renderingMode(.template)
                Text("Доходы")
            }
            .toolbarBackground(.visible, for: .tabBar)
            
            NavigationStack {
                AccountView()
            }
                .tabItem {
                    Image("calculator")
                        .renderingMode(.template)
                    Text("Счет")
                }
                .toolbarBackground(.visible, for: .tabBar)
            
            NavigationStack {
                MyCategoriesView()
            }
                .tabItem {
                    Image("bar-chart-side") 
                        .renderingMode(.template)
                    Text("Статьи")
                }
                .toolbarBackground(.visible, for: .tabBar)
            
            Text("Настройки")
                .tabItem {
                    Image("settings")
                        .renderingMode(.template)
                    Text("Настройки")
                }
                .toolbarBackground(.visible, for: .tabBar)
        }
        
    }
}


//MARK: Preview оставлен для удобства проверки - будет убран в будующем
#Preview {
    TabBarView()
}
