import SwiftUI
import CoreData

// Success Animation View
struct SuccessAnimationView: View {
    @Binding var isVisible: Bool
    var completion: () -> Void

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    Text("Registration Successful")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
            }
            .transition(.scale.combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isVisible = false
                    }
                    completion()
                }
            }
        }
    }
}

struct RegisterContactView: View {
    @Binding var contacts: [Contact]
        @Environment(\.managedObjectContext) private var context
        @Environment(\.presentationMode) var presentationMode
        @State var contact: Contact? // For handling existing contacts
        @State private var companyName = ""
        @State private var firstName = ""
        @State private var lastName = ""
        @State private var address = ""
        @State private var contactType = ""
        @State private var phoneNumber = ""
        @State private var email = ""
        @State private var materialsHandled = ""
        @State private var buying = ""
        @State private var selling = ""
        @State private var hasChanges = false
        @State private var showUnsavedChangesAlert = false
        @State private var showSuccessAnimation = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                if contact != nil {
                    Button(action: {
                        if hasChanges {
                            showUnsavedChangesAlert = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                Text(contact == nil ? "Új Kontakt Hozzáadása" : "Kontakt Szerkesztése")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            VStack(spacing: 15) {
                CustomTextField(placeholder: "Cégnév", text: $companyName.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Keresztnév", text: $firstName.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Vezetéknév", text: $lastName.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Cím", text: $address.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Értékesítő", text: $contactType.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Telefonszám", text: $phoneNumber.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Email", text: $email.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Érdekelt anyagok", text: $materialsHandled.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Vesz:", text: $buying.onChange(updateChangeStatus))
                CustomTextField(placeholder: "Elad:", text: $selling.onChange(updateChangeStatus))
            }
            .font(.title)
            .padding(.horizontal)
            .padding(.vertical, 20)
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Button(action: saveContact) {
                Text(contact == nil ? "Kontakt felvétele" : "Változtatások mentése")
                    .foregroundColor(.black)
                    .font(.title)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(5)
                    .shadow(radius: 5)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(20)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .alert(isPresented: $showUnsavedChangesAlert) {
            Alert(
                title: Text("Unsaved Changes"),
                message: Text("You have unsaved changes. Are you sure you want to close?"),
                primaryButton: .destructive(Text("Discard")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            print("RegisterContactView appeared")

            if let existingContact = contact {
                companyName = existingContact.companyName
                firstName = existingContact.firstName
                lastName = existingContact.lastName
                address = existingContact.address
                contactType = existingContact.contactType
                phoneNumber = existingContact.phoneNumber
                email = existingContact.email
                materialsHandled = existingContact.materialsHandled
                buying = existingContact.buying
                selling = existingContact.selling
                print("Loaded existing contact: \(existingContact)")
            } else {
                print("Creating a new contact")
            }
        }
        // Success Animation View
       SuccessAnimationView(isVisible: $showSuccessAnimation) {
           resetFormFields()
       }
    }

    private func updateChangeStatus() {
        hasChanges = true
        print("Form has changes")

    }

    private func saveContact() {
        let contactEntity: ContactEntity
        print("Saving contact")

        if let existingContact = contact {
            // Fetch and update an existing contact
            let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", existingContact.id as CVarArg)
            let results = try? context.fetch(fetchRequest)

            contactEntity = results?.first ?? ContactEntity(context: context)
        } else {
            // Create a new contact
            contactEntity = ContactEntity(context: context)
            contactEntity.id = UUID()
        }

        // Set properties
        contactEntity.companyName = companyName
        contactEntity.firstName = firstName
        contactEntity.lastName = lastName
        contactEntity.address = address
        contactEntity.contactType = contactType
        contactEntity.phoneNumber = phoneNumber
        contactEntity.email = email
        contactEntity.materialsHandled = materialsHandled
        contactEntity.buying = buying
        contactEntity.selling = selling

        // Save the context
        do {
            try context.save()
            print("Contact saved successfully")
            resetFormFields() // Reset the fields here
            showSuccessAnimation = true // Trigger the success animation
        } catch {
            print("Failed to save contact: \(error)")
        }
    }

    private func resetFormFields() {
        companyName = ""
        firstName = ""
        lastName = ""
        address = ""
        contactType = ""
        phoneNumber = ""
        email = ""
        materialsHandled = ""
        buying = ""
        selling = ""
    }

    struct CustomTextField: View {
        var placeholder: String
        @Binding var text: String
        
        var body: some View {
            ZStack {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .foregroundColor(text.isEmpty ? Color.white.opacity(0.9) : .white)
            }
            .padding(.horizontal, 5)
        }
    }
}

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
