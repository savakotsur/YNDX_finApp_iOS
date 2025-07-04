//
//  MyCategoriesView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 04.07.2025.
//

import SwiftUI

struct MyCategoriesView: View {
    @State
    var vm = MyCategoriesViewModel()
    
    var body: some View {
        HStack {
            List {
                Section("СТАТЬИ") {
                    ForEach(vm.filteredCategories, id: \.id) { category in
                        HStack {
                            Text("\(category.icon)")
                                .font(.subheadline)
                                .padding(5)
                                .background(.lightGreen)
                                .clipShape(.circle)
                            Text(category.name)
                        }
                    }
                }
            }
        }
        .searchable(text: $vm.searchText)
        .accentColor(Color.toolbarAccent)
        .navigationTitle("Мои статьи")
    }
}

#Preview {
    NavigationStack {
        MyCategoriesView()
    }
}
