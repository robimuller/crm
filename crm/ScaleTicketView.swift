import SwiftUI
import CoreData
import AppKit
import UniformTypeIdentifiers



struct ScaleTicketView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: ScaleTicketEntity.entity(), sortDescriptors: []) var savedDocuments: FetchedResults<ScaleTicketEntity>
    @State private var documents: [ScaleTicket] = []
    // Bindings from ContentView
    @Binding var selectedScaleTicket: ScaleTicket?
       var onSelect: (ScaleTicket) -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    pickFile { url in
                        if let url = url {
                            let newDocument = ScaleTicket(name: url.lastPathComponent, uploadDate: "Date", fileFormat: url.pathExtension, fileSize: "Size")
                            self.documents.append(newDocument)
                            _ = newDocument.toEntity(context: self.managedObjectContext)

                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print("Error saving context: \(error)")
                            }
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                }
                Text("Mérlegjegy feltöltése")
            }
            .padding()

            HStack {
                            Text("Megnevezés").bold() // Name
                            Spacer()
                            Text("Feltöltés dátuma").bold() // Upload Date
                            Spacer()
                            Text("Fájltípus").bold() // File Format
                            Spacer()
                            Text("Fájlméret").bold() // File Size
                        }.padding(.horizontal)

                        List(documents) { document in
                            HStack {
                                Text(document.name)
                                Spacer()
                                Text(document.uploadDate)
                                Spacer()
                                Text(document.fileFormat)
                                Spacer()
                                Text(document.fileSize)
                            }
                            .onTapGesture {
                                                onSelect(document)
                                            }
                        }
                        .listStyle(PlainListStyle())

                        Spacer()
                    }
                    .onAppear {
                        self.loadSavedDocuments()
                    }
                }

    private func loadSavedDocuments() {
        self.documents = savedDocuments.map { ScaleTicket(from: $0) }
    }
    
    private func pickFile(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg, .pdf, .plainText] // Update as needed

        if panel.runModal() == .OK, let url = panel.url {
            let fileManager = FileManager.default
            var fileSizeString = "Unknown Size"
            var uploadDateString = "Unknown Date"

            do {
                let attributes = try fileManager.attributesOfItem(atPath: url.path)
                if let fileSize = attributes[.size] as? NSNumber {
                    fileSizeString = formatFileSize(fileSize.intValue)
                }
                if let uploadDate = attributes[.modificationDate] as? Date {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    uploadDateString = dateFormatter.string(from: uploadDate)
                }
            } catch {
                print("Error reading file attributes: \(error)")
            }

            let newDocument = ScaleTicket(name: url.lastPathComponent, uploadDate: uploadDateString, fileFormat: url.pathExtension, fileSize: fileSizeString)
            
            self.documents.append(newDocument) // Append to documents array
            _ = newDocument.toEntity(context: self.managedObjectContext) // Save to CoreData

            do {
                try self.managedObjectContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
            
            completion(url)
        } else {
            completion(nil)
        }
    }

    private func formatFileSize(_ fileSizeInBytes: Int) -> String {
        let bytesInKB = 1024
        let bytesInMB = 1024 * bytesInKB

        if fileSizeInBytes < bytesInKB {
            return "\(fileSizeInBytes) bytes"
        } else if fileSizeInBytes < bytesInMB {
            return "\(fileSizeInBytes / bytesInKB) KB"
        } else {
            return String(format: "%.2f MB", Double(fileSizeInBytes) / Double(bytesInMB))
        }
    }

}






