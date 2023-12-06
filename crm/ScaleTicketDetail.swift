import SwiftUI
import CoreData
import AppKit

struct ScaleTicketDetailView: View {
    let scaleTicket: ScaleTicket
    @Environment(\.managedObjectContext) private var context
    @Binding var isDetailViewVisible: Bool
    var onDelete: (() -> Void)?

    var body: some View {
        VStack {
            Text("Name: \(scaleTicket.name)")
            Text("Upload Date: \(scaleTicket.uploadDate)")
            Text("File Format: \(scaleTicket.fileFormat)")
            Text("File Size: \(scaleTicket.fileSize)")

            if scaleTicket.fileFormat.lowercased() == "pdf" {
                Image(systemName: "doc.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
            } else {
                if let image = loadImage(from: scaleTicket.name) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                } else {
                    Text("Image preview not available")
                }
            }
            Button("Open Image File") {
                           openImageFile()
                       }
                       .padding()

            Button("Delete Ticket") {
                deleteTicket()
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(.red)
            .padding()

            Button("Close") {
                isDetailViewVisible = false
            }
            .padding()
        }
    }
    
    private func openImageFile() {
           guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
           let fileURL = documentsDirectory.appendingPathComponent(scaleTicket.name)

           NSWorkspace.shared.open(fileURL)
       }

    private func deleteTicket() {
        let fetchRequest: NSFetchRequest<ScaleTicketEntity> = ScaleTicketEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", scaleTicket.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let ticketEntity = results.first {
                context.delete(ticketEntity)
                try context.save()
                onDelete?()
            }
        } catch {
            print("Error deleting scale ticket: \(error)")
        }
    }

    private func loadImage(from fileName: String) -> NSImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsDirectory?.appendingPathComponent(fileName).path

        if let path = filePath, let image = NSImage(contentsOfFile: path) {
            return image
        }
        return nil
    }
}
