import SwiftUI
import CoreData
import AppKit
import UniformTypeIdentifiers

struct ScaleTicketView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: ScaleTicketEntity.entity(), sortDescriptors: []) var savedDocuments: FetchedResults<ScaleTicketEntity>
    @State private var documents: [ScaleTicket] = []
    @Binding var selectedScaleTicket: ScaleTicket?
    @State private var selectedDocument: ScaleTicket?
    
    @State private var searchText = ""
    @State private var sortingOption: SortingOption = .nameAscending

    var onSelect: (ScaleTicket) -> Void
    
    // Computed property to filter and sort documents
        private var filteredAndSortedDocuments: [ScaleTicket] {
            var filteredDocuments = searchText.isEmpty ? documents : documents.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }

            switch sortingOption {
            case .nameAscending:
                filteredDocuments.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            case .nameDescending:
                filteredDocuments.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
            // Add other cases for different sorting options
            }

            return filteredDocuments
        }

        enum SortingOption {
            case nameAscending, nameDescending
            // Add other sorting options as needed
        }

    var body: some View {
        VStack {
            // Search bar
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
                

                    
                    Spacer()  // Add a spacer to push the button to the end of the HStack

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
                    }){
                        Image(systemName: "plus.circle.fill")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.blue)
                                            .padding()

                                    }
                                    .buttonStyle(PlainButtonStyle())  // Apply the plain button style
                                }
                                .padding([.horizontal, .top])  // Apply padding similar to the second snippet
                                    
            // Define headers
                        HStack {
                            Text("Megnevezés").bold().frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                            Text("Feltöltés dátuma").bold().frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                            Text("Fájltípus").bold().frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                            Text("Fájlméret").bold().frame(minWidth: 100, maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))

            // Scrollable list of documents
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredAndSortedDocuments, id: \.self) { document in
                        HStack {
                            Text(document.name).frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                            Text(document.uploadDate).frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                            Text(document.fileFormat).frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                            Text(document.fileSize).frame(minWidth: 100, maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .contentShape(Rectangle()) // Makes the entire area tappable
                        .background(document == selectedDocument ? Color.orange : Color.clear)
                        .foregroundColor(document == selectedDocument ? Color.black : Color.white)
                        // In ScaleTicketView
                        .onTapGesture {
                            selectedDocument = document
                            selectedScaleTicket = document // Assuming this is how you set the selected ticket
                            onSelect(document)
                        }

                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                    }
        .background(.black.opacity(0.25))

                    .onAppear {
                        self.loadSavedDocuments()
                    }
                }

    private func loadSavedDocuments() {
            // Load documents from Core Data
            self.documents = savedDocuments.map { ScaleTicket(from: $0) }
        }
    
    func refreshData() {
        documents = savedDocuments.map { ScaleTicket(from: $0) }
    }

    
    private func pickFile(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg, .pdf] // Update as needed

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

            // Get the app's documents directory
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

            // Destination URL for the file in the app's documents directory
            let destinationURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent)

            do {
                // If file already exists at destination, remove it
                if let destinationURL = destinationURL, fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                // Copy the file to the app's documents directory
                try fileManager.copyItem(at: url, to: destinationURL!)

                // Create a new ScaleTicket using the file name from the destination URL
                let newDocument = ScaleTicket(name: destinationURL!.lastPathComponent, uploadDate: uploadDateString, fileFormat: destinationURL!.pathExtension, fileSize: fileSizeString)

                self.documents.append(newDocument) // Append to documents array
                _ = newDocument.toEntity(context: self.managedObjectContext) // Save to CoreData

                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Error saving context: \(error)")
                }

                completion(destinationURL) // Pass the destination URL
                self.refreshData()
            } catch {
                print("Error copying file: \(error)")
                completion(nil)
            }
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






