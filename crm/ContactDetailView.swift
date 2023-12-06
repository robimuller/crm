import SwiftUI
import CoreData

struct ContactDetailView: View {
    let contact: Contact
    @Environment(\.managedObjectContext) private var context
    @State private var showingEditView = false
    @Binding var isDetailViewVisible: Bool

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        DetailRow(label: "Keresztnév", value: contact.firstName)
                        DetailRow(label: "Vezetéknév", value: contact.lastName)
                        DetailRow(label: "Cégnév", value: contact.companyName)
                        DetailRow(label: "Cím", value: contact.address)
                        DetailRow(label: "Kontakt típusa", value: contact.contactType)
                        DetailRow(label: "Telefonszám", value: contact.phoneNumber)
                        DetailRow(label: "Email", value: contact.email)
                    }

                    Divider().background(Color.orange.opacity(0.3)).padding(.vertical)

                    SectionView(title: "Érdekelt Anyagok", item: contact.materialsHandled)
                    SectionView(title: "Vesz", item: contact.buying)
                    SectionView(title: "Elad", item: contact.selling)

                }
                .padding()
                .background(Color.black.opacity(0.25))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            }
            .navigationTitle(contact.firstName)
            .background(Color.gray.opacity(0.2))
            .frame(maxHeight: .infinity)

            // Bottom Bar with Buttons
            HStack {

                // Delete Button
                                Button(action: { deleteContact(contact) }) {
                                    HStack {
                                        Image(systemName: "trash.circle")
                                            .foregroundColor(.red)
                                            .font(.system(size: 20))

                                        Text("Törlés")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(width: 140, height: 40) // Fixed width of 100 points
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                                }        .buttonStyle(PlainButtonStyle())

                                // Edit Button
                                Button(action: { showingEditView = true }) {
                                    HStack {
                                        Image(systemName: "pencil.circle")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 20))



                                        Text("Szerkesztés")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(width: 140, height: 40) // Fixed width of 100 points
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                                } .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingEditView) {
                                    // Assuming RegisterContactView is the view for editing a contact
                                    RegisterContactView(contacts: .constant([]), contact: contact)
                                }


                Spacer(minLength: 0) // Same as above, for even spacing

                // ToggleDetailViewButton
                Button(action: {
                    isDetailViewVisible.toggle()
                }) {
                    Image(systemName: isDetailViewVisible ? "square.rightthird.inset.filled" : "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal) // Add horizontal padding to the entire HStack
                       .padding(.bottom, 10)

        }
    }

    private func deleteContact(_ contact: Contact) {
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", contact.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let contactEntity = results.first {
                context.delete(contactEntity)
                try context.save()
            }
        } catch {
            print("Error deleting contact: \(error)")
        }
    }
}

struct DetailRow: View {
    var label: String
    var value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label)").font(.title2).fontWeight(.light).foregroundColor(.white.opacity(0.6))
            Text(value).font(.title3)
        }
    }
}

struct SectionView: View {
    var title: String
    var item: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title)").font(.title2).fontWeight(.light).foregroundColor(.white.opacity(0.6))
            Text(item).font(.title3)
        }
    }
}

struct ToggleDetailViewButton: View {
    @Binding var isDetailViewVisible: Bool

    var body: some View {
        Button(action: {
            isDetailViewVisible.toggle()
        }) {
            Image(systemName: isDetailViewVisible ? "square.rightthird.inset.filled" : "arrow.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
                .foregroundColor(.blue)
                .padding()
                .padding(.bottom, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

