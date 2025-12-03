//
//  HabitView.swift
//  HabitAura
//
//  Created by Hafizur Rahman on 3/12/25.
//

import SwiftUI

struct HabitView: View {
    let habit: Habit
    @Bindable var habits: Habits
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Text(habit.title)
                        .fontDesign(.rounded)
                        .font(.title.bold())
                    
                    Text(habit.completions, format: .number.notation(.compactName))
                        .fontDesign(.rounded)
                        .font(.caption.bold())
                        .contentTransition(.numericText())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .glassEffect(in: .rect(cornerRadius: 6.0))
                }
                
                Text(habit.description)
                    .fontDesign(.rounded)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            
            Spacer()
            
            Button {
                withAnimation {
                    var updatedHabit = habit
                    updatedHabit.completions += 1
                    
                    if let index = habits.habits.firstIndex(of: habit) {
                        habits.habits[index] = updatedHabit
                    }
                }
            } label: {
                Image(systemName: "checkmark")
                    .padding(8)
            }
            .labelsHidden()
            .buttonStyle(.glass)
            
        }
    }
}

#Preview {
    HabitView(
        habit: Habit(id: UUID(),title: "Hi",description: "Hello",completions: 0),
        habits: Habits()
    )
}
