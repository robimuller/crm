import SwiftUI
import CoreData
import AppKit // Import AppKit for NSImage

struct ScaleTicketDetailView: View {
    let scaleTicket: ScaleTicket
    @Environment(\.managedObjectContext) private var context
    @Binding var isDetailViewVisible: Bool

    var body: some View {
        VStack {
            Text("Name: \(scaleTicket.name)")
            Text("Upload Date: \(scaleTicket.uploadDate)")
            Text("File Format: \(scaleTicket.fileFormat)")
            Text("File Size: \(scaleTicket.fileSize)")

            if scaleTicket.fileFormat.lowercased() == "pdf" {
                // Display a PDF thumbnail or icon
                Image(systemName: "doc.fill") // Placeholder for a PDF icon
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
            } else {
                // For image files, display the image
                if let image = loadImage(from: scaleTicket.name) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                } else {
                    Text("Image preview not available")
                }
            }

            Button("Close") {
                isDetailViewVisible = false
            }
        }
    }

    private func loadImage(from fileName: String) -> NSImage? {
        // Assuming file paths are stored in the app's documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentsDirectory?.appendingPathComponent(fileName).path

        if let path = filePath, let image = NSImage(contentsOfFile: path) {
            return image
        }
        return nil
    }
}
