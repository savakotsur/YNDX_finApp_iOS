//
//  DatePickerCompactRoew.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 20.06.2025.
//

import SwiftUI

struct DatePickerCompactRow: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        ZStack {
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.lightGreen)
                .foregroundColor(.black)
                .cornerRadius(10)

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .blendMode(.destinationOver)
            .opacity(0.065)
        }
    }
}
