import SwiftUI

struct ContentView: View {
    @Environment(\.isSearching) private var isSearching
    
    @State private var habits = Habits()
    @State private var addHabit = false
    
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
                            HabitView(habit: habit, habits: habits)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(habit.id == habits.habits.first?.id ? .hidden : .visible, edges: .top)
                }
                .onDelete(perform: delete)
            }
            .navigationLinkIndicatorVisibility(.hidden)
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
            .onChange(of: isSearching) { _, newValue in
                print(newValue ? "Search active" : "Search inactive")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        addHabit.toggle()
                    }
                }
                ToolbarSpacer(placement: .topBarTrailing)
                    
                ToolbarItem(placement: .topBarTrailing) {
                    Text(.now, style: .time).padding()
                }
                
                // My Practice
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                
                ToolbarSpacer(placement: .bottomBar)
                
                if isSearching {
                    ToolbarItem(placement: .bottomBar) {
                        Button {} label: { Label("New", systemImage: "square.and.pencil") }
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



