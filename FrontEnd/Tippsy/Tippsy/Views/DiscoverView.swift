import SwiftUI
import MapKit

struct DiscoverView: View {
    
    
    // City struct and array
    struct City {
        let name: String
        let latitude: Double
        let longitude: Double
    }
    
    let cities = [
        City(name: "San Francisco", latitude: 37.7749, longitude: -122.4194),
        City(name: "London", latitude: 42.9849, longitude: -81.2453),
        City(name: "Toronto", latitude: 43.6532, longitude: -79.3832)
    ]
    
    enum SearchCategory {
        case map, users, drinks
    }
    
    @State private var searchCategory: SearchCategory = .map
    @State private var selectedCity = "San Francisco"
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var venues: [Venue] = []
    @State private var topUsers: [User] = []
    @State private var topDrinks: [Drink] = []
    @State private var searchText = ""
    
    
    var filteredVenues: [Venue] {
        if searchText.isEmpty {
            return venues
        }
        return venues.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                categorySelector
                searchBar
                if searchCategory == .map {
                    cityPicker
                    mapView
                    venueList
                } else if searchCategory == .users {
                    userList
                } else if searchCategory == .drinks {
                    drinkList
                }
            }
            .navigationTitle("Discover")
            .padding(.top, 10)
            .onAppear {
                fetchData()
            }
        }
    }
    
    var categorySelector: some View {
            HStack {
                ForEach([("Map", SearchCategory.map), ("Users", SearchCategory.users), ("Drinks", SearchCategory.drinks)], id: \..1) { label, category in
                    Button(action: {
                        searchCategory = category
                        fetchData()
                    }) {
                        Text(label)
                            .padding()
                            .background(searchCategory == category ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        .padding()
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
    
    var cityPicker: some View {
        Picker("Select City", selection: $selectedCity) {
            ForEach(cities.map { $0.name }, id: \.self) { city in
                Text(city).tag(city)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        .onChange(of: selectedCity) { newCity in
            updateRegion(for: newCity)
        }
    }
    
    
    // Map View subview
        var mapView: some View {
            Map(coordinateRegion: $region, annotationItems: filteredVenues) { venue in
                MapMarker(coordinate: venue.coordinate, tint: .blue)
            }
            .frame(height: 300)
            .cornerRadius(10)
            .padding()
            .gesture(
                DragGesture()
                    .onEnded { _ in
                        searchVenues()
                    }
            )
        }
    
    // Venue List subview
    var venueList: some View {
        List(filteredVenues) { venue in
            NavigationLink(destination: RestaurantView(
                viewModel: RestaurantViewModel(),
                restaurantName: venue.name
            )) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(venue.name)
                            .font(.headline)
                        Text(venue.type)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 5)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    


    
            
    var userList: some View {
        List(topUsers, id: \.id) { user in
            Text(user.username)
        }
        
    }
    
    
    var drinkList: some View {
        List(topDrinks,  id: \._id) { drink in
            VStack(alignment: .leading) {
                Text(drink.name).font(.headline)
                Text(drink.category).font(.subheadline).foregroundColor(.gray)
            }
        }
    }
    
            
    func fetchData() {
        switch searchCategory {
        case .map:
            searchVenues()
        case .users:
            SearchService.fetchTopUsers { users in
                //DispatchQueue.main.async {
                  //  self.topUsers = users
                    //print("Fetched users: \(users)")
                //}
                print("Raw user response: \(users)")
            }
        case .drinks:
            SearchService.fetchTopDrinks { drinks in
                //DispatchQueue.main.async {
                  //  self.topDrinks = drinks
                    //print("Fetched drinks: \(drinks)")
                //}
                print("Raw drink response: \(drinks)")
            }
        }
    }
            
            
    // Update region based on selected city and refresh venues
    private func updateRegion(for cityName: String) {
        if let city = cities.first(where: { $0.name == cityName }) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: city.latitude,
                    longitude: city.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            searchVenues()
        }
    }
            
    // Search venues using MKLocalSearch
    func searchVenues() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "bars"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            var newVenues = response.mapItems.map { item in
                Venue(
                    name: item.name ?? "Unknown",
                    type: "Bar",
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }

        // this Check if London is the selected city and append BarX.
        if self.selectedCity == "London" {
            let barX = Venue(
                name: "BarX",
                type: "Bar",
                latitude: 42.9849,
                longitude: -81.2453
            )
            newVenues.append(barX)
        }
            
            DispatchQueue.main.async {
                self.venues = newVenues
            }
        }
    }
}
        
// Venue Data Model
struct Venue: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}

