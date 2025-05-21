import Foundation
struct BookingRequest: Codable {
    let property: Int
    let tenant: Int
    let requestedStartDate: Date
    let requestedEndDate: Date
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case property = "property"  // Сервер ожидает camelCase
        case tenant = "tenant"
        case requestedStartDate = "requestedStartDate"
        case requestedEndDate = "requestedEndDate"
        case status
    }
    
    init(propertyId: Int, tenantId: Int, requestedStartDate: Date, requestedEndDate: Date) {
        self.property = propertyId
        self.tenant = tenantId
        self.requestedStartDate = requestedStartDate
        self.requestedEndDate = requestedEndDate
        self.status = "created"
    }
}
