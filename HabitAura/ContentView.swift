//
//  ContentView.swift
//  HabitAura
//
//  Created by Hafizur Rahman on 3/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var habits = Habits()
    @State private var addHabit = false
    
    func delete(offSets: IndexSet) {
        habits.habits.remove(atOffsets: offSets)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habits.habits) { habit in
                    NavigationLink {
                        DetailHabitView(habit: habit, habits: habits)
                    } label: {
                        HabitView(habit: habit, habits: habits)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(habit.id == habits.habits.first?.id ? .hidden : .visible, edges: .top)
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .navigationTitle("HabitAura")
            .navigationSubtitle("Track Your Daily Habits")
            .sheet(isPresented: $addHabit) {
                NavigationStack {
                    AddHabitView(habits: habits)
                }
                .presentationDetents([.medium])
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        addHabit.toggle()
                    }
                }
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}



