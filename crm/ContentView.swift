import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selectedView: String?
    @State private var contacts = [Contact]()
    @State private var selectedContact: Contact?
    @State private var showClearConfirmation = false
    @State private var isDetailViewVisible = false
    
    // State for ScaleTicket
       @State private var selectedScaleTicket: ScaleTicket?
       @State private var isScaleTicketDetailViewVisible = false


    var body: some View {
            HStack(spacing: 0) {
                Sidebar(selectedView: $selectedView, showClearConfirmation: $showClearConfirmation)
                    .frame(width: 250) // Adjust width as necessary

                mainContent
                    .frame(maxWidth: .infinity)

                // Contact Detail View
                if selectedView == "ListContacts", let selectedContact = selectedContact, isDetailViewVisible {
                    ContactDetailView(contact: selectedContact, isDetailViewVisible: $isDetailViewVisible)
                        .frame(width: 600)
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut, value: isDetailViewVisible)
                }

                if selectedView == "ScaleTicket", let selectedTicket = selectedScaleTicket, isScaleTicketDetailViewVisible {
                    ScaleTicketDetailView(scaleTicket: selectedTicket, isDetailViewVisible: $isScaleTicketDetailViewVisible, onDelete: {
                        // Call the refresh function here
                        (self.mainContent as? ScaleTicketView)?.refreshData()
                    })
                    .frame(width: 600)
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut, value: isScaleTicketDetailViewVisible)
                }
            }
        }

    var mainContent: some View {
        Group {
            switch selectedView {
            case "RegisterContact":
                RegisterContactView(contacts: $contacts)
            case "ListContacts":
                ContactListView(selectedContact: $selectedContact) { contact in
                    selectedContact = contact
                    isDetailViewVisible = true
                }
            case "ScaleTicket":
                // In ContentView or wherever you define what happens onSelect
                ScaleTicketView(selectedScaleTicket: $selectedScaleTicket) { scaleTicket in
                    selectedScaleTicket = scaleTicket
                    isScaleTicketDetailViewVisible = true
                }

            default:
                Text("Select an action")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .background(Color.orange)
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
