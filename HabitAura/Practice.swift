//
//  Practice.swift
//  HabitAura
//
//  Created by Hafizur Rahman on 4/12/25.
//

import SwiftUI

struct Practice: View {
    @State private var num = 0
    
    var body: some View {
        VStack {
            Text(String(num)).font(.title).contentTransition(.numericText())
            Button("Add") {
                withAnimation {
                    num += 1
                }
            }
            .buttonStyle(.glassProminent)
            .buttonRepeatBehavior(.enabled)
        }
    }
}

#Preview {
    Practice()
}
