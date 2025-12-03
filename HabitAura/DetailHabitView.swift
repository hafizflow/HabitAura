import SwiftUI
import Charts

struct DetailHabitView: View {
    let habit: Habit
    @Bindable var habits: Habits
    @State private var animatedCompletions: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Chart {
                    SectorMark(
                        angle: .value("Completed", animatedCompletions),
                        innerRadius: .ratio(0.6),
                        angularInset: 4
                    )
                    .cornerRadius(4)
                    .foregroundStyle(.orange.opacity(0.9))
                    
                    SectorMark(
                        angle: .value("Remaining", max(0, 1000 - animatedCompletions)),
                        innerRadius: .ratio(0.6),
                        angularInset: 0
                    )
                    .foregroundStyle(.gray.opacity(0.3))
                }
                .frame(height: 250)
                .chartLegend(.hidden)
                .overlay {
                    VStack(spacing: 4) {
                        Text(habit.completions, format: .number.notation(.compactName))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.default, value: habit.completions)
                        
                        Text("out of 1000")
                            .fontDesign(.rounded)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .animation(.spring(duration: 0.6), value: animatedCompletions)
                .onChange(of: habit.completions) { oldValue, newValue in
                    withAnimation(.spring(duration: 0.6)) {
                        animatedCompletions = Double(newValue)
                    }
                }
                .onAppear {
                    animatedCompletions = Double(habit.completions)
                }
                
                Button {
                    withAnimation {
                        var updatedHabit = habit
                        updatedHabit.completions += 1
                        
                        if let index = habits.habits.firstIndex(of: habit) {
                            habits.habits[index] = updatedHabit
                        }
                    }
                } label: {
                    HStack {
                        Text("Add")
                        Image(systemName: "plus.app")
                    }
                    .padding(12)
                }
                .buttonStyle(.glass)
                .buttonRepeatBehavior(.enabled)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Description").font(.title).fontDesign(.rounded)
                    Text(habit.description)
                        .fontDesign(.rounded)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DetailHabitView(habit: Habit(id: UUID(), title: "Hello", description: "This is a multiline description for my first habit. It can be as long as you want. And it will still look good. I hope.", completions: 350), habits: Habits())
    }
}
