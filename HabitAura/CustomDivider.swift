//
//  CustomDivider.swift
//  HabitAura
//
//  Created by Hafizur Rahman on 3/12/25.
//

import SwiftUI

struct CustomDividerModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            Rectangle()
                .frame(height: 2)
                .foregroundStyle(.gray.opacity(0.3))
                .padding(.vertical)
        }
    }
}


extension View {
    func customDivider() -> some View {
        self.modifier(CustomDividerModifier())
    }
}
