struct Property: Identifiable, Decodable {
    let id: Int
    let title: String
    let description: String
    let price: String
    let location: String
    let propertyType: String
    let createdAt: String
    let owner: Int?
    

    var numericPrice: Double {
        Double(price) ?? 0.0
    }
}
