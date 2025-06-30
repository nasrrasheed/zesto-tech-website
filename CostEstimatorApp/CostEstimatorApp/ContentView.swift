import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.name, ascending: true)],
        animation: .default)
    private var customers: FetchedResults<Customer>

    var body: some View {
        NavigationView {
            Text("Select an item")
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}