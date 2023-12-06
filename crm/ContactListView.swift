import SwiftUI
import CoreData

struct ContactListView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: ContactEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ContactEntity.firstName, ascending: true)],
        animation: .default)
    private var fetchedContacts: FetchedResults<ContactEntity>

    @Binding var selectedContact: Contact?
    var onSelect: (Contact) -> Void

    @State private var searchText = ""
    @State private var isFilterMenuVisible = false
    @State private var filterOptions = FilterOptions()
    @State private var showFilterPopover = false


    private var filteredContacts: [ContactEntity] {
        if searchText.isEmpty {
            return Array(fetchedContacts)
        } else {
            return fetchedContacts.filter { contact in
                (filterOptions.companyName && contact.companyName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.firstName && contact.firstName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.lastName && contact.lastName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.address && contact.address?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.contactType && contact.contactType?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.phoneNumber && contact.phoneNumber?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.email && contact.email?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.materialsHandled && contact.materialsHandled?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.buying && contact.buying?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (filterOptions.selling && contact.selling?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }

    var body: some View {
        VStack {
            // Enhanced Search Bar with Filter Button
            HStack {
                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(.leading, 15)
                            Text("Keresés ...")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    TextField("", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(15)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.25)))
                }
                Spacer()
                Button(action: { showFilterPopover = true }) {
                                    Image(systemName: "line.horizontal.3.decrease.circle")
                                        .imageScale(.large)
                                        .padding()
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle()) // Removes default button styling
                                .popover(isPresented: $showFilterPopover) {
                                    FilterView(filterOptions: $filterOptions, onApply: {
                                        showFilterPopover = false
                                    }, onCancel: {
                                        showFilterPopover = false
                                    })
                                    .frame(width: 300)
                                    .padding()
                                }
                            }
                            .padding([.horizontal, .top])

            
            // LIST SECTION

            List {
                ForEach(filteredContacts, id: \.self) { contactEntity in
                    Button(action: { onSelect(Contact(from: contactEntity)) }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(contactEntity.companyName ?? "Unknown Company")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.black)
                                Text("\(contactEntity.firstName ?? "") \(contactEntity.lastName ?? "")")
                                    .fontWeight(.regular)
                                    .foregroundColor(Color.black.opacity(0.6))
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.orange)
                    .cornerRadius(10)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.black)


        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FilterOptions {
    var companyName = true
    var firstName = true
    var lastName = true
    var address = true
    var contactType = true
    var phoneNumber = true
    var email = true
    var materialsHandled = true
    var buying = true
    var selling = true
}

struct FilterView: View {
    @Binding var filterOptions: FilterOptions
    var onApply: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("Filter Options")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            Form {
                Section() {
                    Toggle("Company Name", isOn: $filterOptions.companyName)
                    Toggle("First Name", isOn: $filterOptions.firstName)
                    Toggle("Last Name", isOn: $filterOptions.lastName)
                    Toggle("Address", isOn: $filterOptions.address)
                    Toggle("Contact Type", isOn: $filterOptions.contactType)
                    Toggle("Phone Number", isOn: $filterOptions.phoneNumber)
                    Toggle("Email", isOn: $filterOptions.email)
                    Toggle("Materials Handled", isOn: $filterOptions.materialsHandled)
                    Toggle("Buying", isOn: $filterOptions.buying)
                    Toggle("Selling", isOn: $filterOptions.selling)
                }
            }
            .padding(.horizontal)

            Spacer()

            HStack {
                            Button("Cancel", action: onCancel)
                            Spacer()
                            Button("Apply", action: onApply)
                        }
                        .padding()
                    }
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }


