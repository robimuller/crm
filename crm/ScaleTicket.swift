import CoreData

struct ScaleTicket: Identifiable, Hashable  {
    var id: UUID
    var name: String
    var uploadDate: String
    var fileFormat: String
    var fileSize: String

    // Initializer for creating a new ScaleTicket
    init(id: UUID = UUID(), name: String, uploadDate: String, fileFormat: String, fileSize: String) {
        self.id = id
        self.name = name
        self.uploadDate = uploadDate
        self.fileFormat = fileFormat
        self.fileSize = fileSize
    }

    // Initializer from ScaleTicketEntity
    init(from entity: ScaleTicketEntity) {
        id = entity.id ?? UUID()
        name = entity.name ?? ""
        uploadDate = entity.uploadDate ?? ""
        fileFormat = entity.fileFormat ?? ""
        fileSize = entity.fileSize ?? ""
    }

    // Convert to ScaleTicketEntity
    func toEntity(context: NSManagedObjectContext) -> ScaleTicketEntity {
        let entity = ScaleTicketEntity(context: context)
        entity.id = id
        entity.name = name
        entity.uploadDate = uploadDate
        entity.fileFormat = fileFormat
        entity.fileSize = fileSize

        return entity
    }
}
