//
//  ScaleTicketDetail.swift
//  crm
//
//  Created by Robert Muller on 06/12/2023.
//

import Foundation
import SwiftUI


struct ScaleTicketDetailView: View {
    let scaleTicket: ScaleTicket
    @Environment(\.managedObjectContext) private var context
    @Binding var isDetailViewVisible: Bool

    var body: some View {
        VStack {
            // Display scale ticket details here
            // For example:
            Text("Name: \(scaleTicket.name)")
            Text("Upload Date: \(scaleTicket.uploadDate)")
            Text("File Format: \(scaleTicket.fileFormat)")
            Text("File Size: \(scaleTicket.fileSize)")
            // Add more details and styling as needed

            // Close button or other UI elements
            Button("Close") {
                isDetailViewVisible = false
            }
        }
    }
}

