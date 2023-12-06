import CoreData

struct Contact {
    var id = UUID()
    var companyName: String
    var firstName: String
    var lastName: String
    var address: String
    var contactType: String
    var phoneNumber: String
    var email: String
    var materialsHandled: String
    var buying: String
    var selling: String

    // Initializer to create a Contact from a ContactEntity
    init(from entity: ContactEntity) {
        id = entity.id ?? UUID() // Assign the same UUID from the entity
        companyName = entity.companyName ?? ""
        firstName = entity.firstName ?? ""
        lastName = entity.lastName ?? ""
        address = entity.address ?? ""
        contactType = entity.contactType ?? ""
        phoneNumber = entity.phoneNumber ?? ""
        email = entity.email ?? ""
        materialsHandled = entity.materialsHandled ?? ""
        buying = entity.buying ?? ""
        selling = entity.selling ?? ""
    }
    

    // Convert a Contact to a ContactEntity
    func toEntity(context: NSManagedObjectContext) -> ContactEntity {
        let entity = ContactEntity(context: context)
        entity.id = id
        entity.companyName = companyName
        entity.firstName = firstName
        entity.lastName = lastName
        entity.address = address
        entity.contactType = contactType
        entity.phoneNumber = phoneNumber
        entity.email = email
        entity.materialsHandled = materialsHandled
        entity.buying = buying
        entity.selling = selling

        return entity
    }
}
