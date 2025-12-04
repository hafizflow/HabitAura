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
    
    @State private var showSheet = false
    
    func delete(offSets: IndexSet) {
        habits.habits.remove(atOffsets: offSets)
    }
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habits.habits) { habit in
                    NavigationLink {
                        DetailHabitView(habit: habit, habits: habits)
                    } label: {
                        VStack(spacing: 0) {
                            if habit.id == habits.habits.first?.id {
                                Color.clear.frame(height: 8)
                            }
                            HabitView(habit: habit, habits: habits)
                        }
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
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        addHabit.toggle()
                    }
                }
                
                ToolbarSpacer(.fixed)

                ToolbarItem(placement: .topBarTrailing) {
                    Button("alert", systemImage: "return") { showSheet = true }
                        .alert("Title", isPresented: $showSheet) {
                        }
                        .alertContent(isPresented: showSheet) {
                            VStack {
                                TextField("Hafiz", text: $searchText)
                                Text("Custom alert content")
                                ProgressView()
                            }
                            .padding()
                        }
                }
                
                // My Practice
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                
                ToolbarSpacer(placement: .bottomBar)
                
                ToolbarItem(placement: .bottomBar) {
                    Button {} label: { Label("New", systemImage: "square.and.pencil") }
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



