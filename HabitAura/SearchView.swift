import SwiftUI

struct SearchView: View {
    @Environment(\.isSearching) var isSearching
    
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .searchable(text: $searchQuery)
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                
                ToolbarSpacer(placement: .bottomBar)
                
                ToolbarItem(placement: .bottomBar) {
                    Button {} label: { Label("New", systemImage: "square.and.pencil") }
                }
            }
            .onChange(of: isSearching) { _, newValue in
                print(newValue ? "Search active" : "Search inactive")
            }
        }
    }
}

#Preview {
    SearchView()
}
