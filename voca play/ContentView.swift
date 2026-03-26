import SwiftUI

struct ContentView: View {
    var viewModel: AppViewModel

    var body: some View {
        GroupsListView(viewModel: viewModel)
    }
}

#Preview {
    ContentView(viewModel: AppViewModel())
}
