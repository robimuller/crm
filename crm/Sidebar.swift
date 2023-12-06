import SwiftUI

struct Sidebar: View {
    @Binding var selectedView: String?
    @Binding var showClearConfirmation: Bool

    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all) // Background color

            List {
                SidebarButton(icon: "person.crop.circle.fill", title: "Kontakt Hozzáadása", isSelected: selectedView == "RegisterContact") {
                    withAnimation {
                        selectedView = "RegisterContact"
                    }
                }
                SidebarButton(icon: "list.bullet.rectangle.portrait.fill", title: "Céglista", isSelected: selectedView == "ListContacts") {
                    withAnimation {
                        selectedView = "ListContacts"
                    }
                }
                SidebarButton(icon: "gear", title: "Settings", isSelected: false) {
                    withAnimation {
                        // Handle settings action
                    }
                }
                SidebarButton(icon: "trash", title: "Clear Database", isSelected: false) {
                    withAnimation {
                        showClearConfirmation = true
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Actions")
            .alert(isPresented: $showClearConfirmation) {
                Alert(
                    title: Text("Confirm Clear Database"),
                    message: Text("Are you sure you want to delete all contacts? This action cannot be undone."),
                    primaryButton: .destructive(Text("Clear")) {
                        // clearAllContacts() // Define this action in the ContentView
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .foregroundColor(.white) // White text color for better contrast
    }
}

// ... SidebarButton struct ...


struct SidebarButton: View {
    var icon: String
    let title: String
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .orange : .gray)
                .imageScale(.large)
                .padding(.horizontal, 10)

            Text(title)
                .foregroundColor(isSelected ? .white : .gray)
                .fontWeight(isSelected ? .bold : .regular)

            Spacer()
        }
        .padding(.vertical, 10)
        .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onTapGesture(perform: action)
        .animation(.easeInOut, value: isSelected) // Subtle animation for button selection
    }
}

