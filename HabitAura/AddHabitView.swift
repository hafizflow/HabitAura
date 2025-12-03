//
//  AddHabitView.swift
//  HabitAura
//
//  Created by Hafizur Rahman on 3/12/25.
//

import SwiftUI

struct AddHabitView: View {
    let habits: Habits
    
    @Environment(\.dismiss) var dismiss
    
    @State private var habitTitle = ""
    @State private var habitDescription = ""
    
    func isEmpty() -> Bool {
        habitTitle.isEmpty || habitDescription.isEmpty
    }
    
    var body: some View {
        VStack {
            Form {
                Section("Title") {
                    TextField("Habit Title...", text: $habitTitle)
                }
                
                Section("Description") {
                    TextField("Habit Description...", text: $habitDescription, axis: .vertical)
                }
            }
        }
        .navigationTitle("Add Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "multiply") { dismiss() }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "checkmark") {
                    habits.habits.append(
                        Habit(title: habitTitle, description: habitDescription, completions: 0)
                    )
                    
                    habitTitle = ""
                    habitDescription = ""
                    dismiss()
                }
                .disabled(isEmpty())
                .buttonStyle(.glassProminent)
            }
        }
    }
}


#Preview {
    AddHabitView(habits: Habits())
}
