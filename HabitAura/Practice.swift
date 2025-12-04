//
//  Practice.swift
//  HabitAura
//
//  Created by Hafizur Rahman on 4/12/25.
//

import SwiftUI
import AlertAdvance

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

struct AlertView: View {
    @State private var showAlert = false
    @State private var showSheet = false
    @State private var search = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Show alert") { showAlert = true }
                .alert("Title", isPresented: $showAlert) {
                    Button("OK") {}
                }
                .alertContent(isPresented: showAlert) {
                    VStack {
                        Text("Custom alert content")
                        
                        Rectangle()
                            .background(.gray.opacity(0.1))
                            .frame(width: .infinity, height: 40)
                            .clipShape(.rect(cornerRadius: 16))
                            .padding(.horizontal)
                            .overlay {
                                HStack(spacing: 8) {
                                    TextField("Hafiz....", text: $search).padding(.horizontal)
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.secondary)
                                        .padding(.trailing)
                                }
                                .padding(.horizontal)
                            }
                    }
                    .padding()
                }
            
            Button("Show confirmation") { showSheet = true }
                .confirmationDialog("Title", isPresented: $showSheet) {
                    Button("Action") {}
                }
                .confirmationDialogContent(isPresented: showSheet) {
                    VStack {
                        Text("Custom sheet content")
                        Image(systemName: "hand.thumbsup.fill")
                    }
                    .padding()
                }
        }
        .padding()
    }
}

#Preview {
    AlertView()
}
