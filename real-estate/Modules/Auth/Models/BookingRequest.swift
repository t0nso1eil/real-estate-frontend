import Foundation

struct BookingRequest: Codable {
    let propertyId: Int
    let tenantId: Int
    let requestedStartDate: String
    let requestedEndDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case propertyId = "property_id"
        case tenantId = "tenant_id"
        case requestedStartDate = "requested_start_date"
        case requestedEndDate = "requested_end_date"
        case status
    }
    
    init(propertyId: Int, tenantId: Int, startDate: Date, endDate: Date) {
        self.propertyId = propertyId
        self.tenantId = tenantId
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate] // Только дата без времени
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.requestedStartDate = dateFormatter.string(from: startDate)
        self.requestedEndDate = dateFormatter.string(from: endDate)
        self.status = "created"
    }
}

struct PropertyReference: Codable {
    let id: Int
}

struct TenantReference: Codable {
    let id: Int
}
