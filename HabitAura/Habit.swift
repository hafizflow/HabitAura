//
//  Habit.swift
//  HabitAura
//
//  Created by Hafizur Rahman on 3/12/25.
//

import Foundation

struct Habit: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var completions: Int
}

@Observable
class Habits {
    var habits = [Habit]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(habits) {
                UserDefaults.standard.set(encoded, forKey: "Habits")
            }
        }
    }
    
    init() {
        if let savedHabits = UserDefaults.standard.data(forKey: "Habits") {
            if let decoded = try? JSONDecoder().decode([Habit].self, from: savedHabits) {
                habits = decoded
                return
            }
        }
        
        habits = []
    }
}
