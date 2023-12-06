import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selectedView: String?
    @State private var contacts = [Contact]()
    @State private var selectedContact: Contact?
    @State private var showClearConfirmation = false
    @State private var isDetailViewVisible = false


    var body: some View {
        HStack(spacing: 0) {
            Sidebar(selectedView: $selectedView, showClearConfirmation: $showClearConfirmation)
                .frame(width: 250) // Adjust width as necessary

            mainContent
                .frame(maxWidth: .infinity)

            if selectedView == "ListContacts", let selectedContact = selectedContact, isDetailViewVisible {
                ContactDetailView(contact: selectedContact, isDetailViewVisible: $isDetailViewVisible)
                    .frame(width: 600)
                    .transition(.move(edge: .trailing)) // Slides in and out from the right edge
                    .animation(.easeInOut, value: isDetailViewVisible) // Smooth transition
            }


        }
    }

    var mainContent: some View {
        Group {
            switch selectedView {
            case "RegisterContact":
                RegisterContactView(contacts: $contacts) // Corrected syntax
            case "ListContacts":
                ContactListView(selectedContact: $selectedContact) { contact in
                    selectedContact = contact
                    isDetailViewVisible = true // Show the detail view when a contact is selected
                }
            default:
                Text("Select an action")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .background(Color.orange) // Dark background for the sidebar

            }
        }
    }

    private func clearAllContacts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ContactEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
        } catch {
            print("Error clearing contacts: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// ... Rest of your code including RegisterContactView, ContactDetailView, etc.
