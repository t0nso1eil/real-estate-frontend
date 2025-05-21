import SwiftUI

struct PropertyView: View {
    @State private var properties: [Property] = []
    @State private var filteredProperties: [Property] = []
    @State private var selectedTypes: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 0
    @State private var currentMinPrice: Double = 0
    @State private var currentMaxPrice: Double = 0
    @State private var searchText = ""

    private let propertyService: PropertyServiceProtocol

    init(propertyService: PropertyServiceProtocol = PropertyService()) {
           self.propertyService = propertyService
       }
    
    private var allPropertyTypes: [String] {
        Array(Set(properties.map { $0.propertyType })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                SearchBar(text: $searchText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .onChange(of: searchText) {
                        applyFilters()
                    }
                // Фильтр по цене
                VStack(alignment: .leading, spacing: 12) {
                                    Text("Цена")
                                        .font(.headline)
                                        .padding(.horizontal, 18)
                                    
                                    HStack(spacing: 8) {
                                        // Поле "От"
                                        ZStack(alignment: .leading) {
                                            if currentMinPrice == 0 {
                                                Text("От")
                                                    .foregroundColor(.gray.opacity(0.5))
                                                    .padding(.leading, 8)
                                            }
                                            TextField("", value: $currentMinPrice, formatter: NumberFormatter())
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.trailing)
                                                .padding(.horizontal, 8)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .frame(height: 36)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        
                                        Text("-")
                                            .frame(width: 20)
                                        
                                        // Поле "До"
                                        ZStack(alignment: .leading) {
                                            if currentMaxPrice == maxPrice {
                                                Text("До")
                                                    .foregroundColor(.gray.opacity(0.5))
                                                    .padding(.leading, 8)
                                            }
                                            TextField("", value: $currentMaxPrice, formatter: NumberFormatter())
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.trailing)
                                                .padding(.horizontal, 8)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .frame(height: 36)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Комбинированный слайдер
                                    RangeSlider(
                                        minValue: $minPrice,
                                        maxValue: $maxPrice,
                                        currentMin: $currentMinPrice,
                                        currentMax: $currentMaxPrice
                                    )
                                    .frame(height: 40)
                                    .padding(.horizontal, 16)
                                    .onChange(of: currentMinPrice) { applyFilters() }
                                    .onChange(of: currentMaxPrice) { applyFilters() }
                                }
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                            // Фильтры по типам недвижимости
                VStack(alignment: .leading, spacing: 8) {
                    Text("Тип недвижимости")
                        .font(.headline)
                        .padding(.horizontal, 18)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Кнопка "Все"
                            FilterPill(
                                title: "Все",
                                isSelected: selectedTypes.isEmpty,
                                action: {
                                    selectedTypes.removeAll()
                                    applyFilters()
                                }
                            )
                            
                            // Кнопки для каждого типа
                            ForEach(allPropertyTypes, id: \.self) { type in
                                FilterPill(
                                    title: type.capitalized,
                                    isSelected: selectedTypes.contains(type),
                                    action: {
                                        if selectedTypes.contains(type) {
                                            selectedTypes.remove(type)
                                        } else {
                                            selectedTypes.insert(type)
                                        }
                                        applyFilters()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(Color(.systemBackground))
                }
                            // Список недвижимости
                Group {
                    if isLoading {
                        LoadingView()
                    } else if let errorMessage = errorMessage {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                Text("Ошибка: \(errorMessage)")
                                .foregroundColor(.red)}}
                    } else if filteredProperties.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                Text("Нет объектов по выбранным фильтрам")
                                    .foregroundColor(.gray)
                                    .padding(.top, 100)
                            }}
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredProperties) { property in
                                    NavigationLink(destination: PropertyDetailView(property: property)) {
                                        PropertyRow(property: property)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 8)
                        }.background(Color(.systemBackground))
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Поиск")
            .onAppear {
                Task {
                    await loadProperties()
                }
            }
        }
    }
    
    private func applyFilters() {
           filteredProperties = properties.filter { property in
               // Фильтр по типу
               let typeMatch = selectedTypes.isEmpty || selectedTypes.contains(property.propertyType)
               
               // Фильтр по цене
               let priceMatch = (property.numericPrice >= currentMinPrice) &&
                               (property.numericPrice <= currentMaxPrice)
               
               // Фильтр по поиску
               let searchMatch = searchText.isEmpty ||
                                property.title.localizedCaseInsensitiveContains(searchText) ||
                                property.location.localizedCaseInsensitiveContains(searchText) ||
                                property.description.localizedCaseInsensitiveContains(searchText)
               
               return typeMatch && priceMatch && searchMatch
           }
       }
    
    private func loadProperties() async {
            isLoading = true
            errorMessage = nil
            
        do {
                  
            let decodedData = try await propertyService.fetchProperties()
                    
                    await MainActor.run {
                        self.properties = decodedData
                        
                        if !decodedData.isEmpty {
                                           let prices = decodedData.map { $0.numericPrice }
                                           self.minPrice = prices.min() ?? 0
                                           self.maxPrice = prices.max() ?? 0
                                           self.currentMinPrice = self.minPrice
                                           self.currentMaxPrice = self.maxPrice
                                       }
                        self.filteredProperties = decodedData
                        self.isLoading = false
                    }
                } catch {
                    await handleError(error)
                    self.isLoading = false
                }
            }
    
    func handleError(_ error: any Error) async {
        await MainActor.run {
            if let propertyError = error as? PropertyError {
                self.errorMessage = propertyError.localizedDescription
            } else {
                self.errorMessage = error.localizedDescription
            }
            
        }
    }
            
        }
    

struct PropertyView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyView()
    }
}

