import SwiftUI
import MapKit

struct DiscoverView: View {
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
            ForEach(["San Francisco", "London", "Toronto"], id: \..self) { city in
                Text(city).tag(city)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        .onChange(of: selectedCity) { newCity in
            updateRegion(for: newCity)
        }
    }
    
    var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: venues) { venue in
            MapMarker(coordinate: venue.coordinate, tint: .blue)
        }
        .frame(height: 300)
        .cornerRadius(10)
        .padding()
    }
    
    var venueList: some View {
        List(venues) { venue in
            Text(venue.name)
        }
    }
    
    var userList: some View {
            List(topUsers, id: \..id) { user in
                Text(user.username)
            }
        }
        
    
    var drinkList: some View {
        List(topDrinks) { drink in
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
                    DispatchQueue.main.async {
                        self.topUsers = users
                    }
                }
            case .drinks:
                SearchService.fetchTopDrinks { drinks in
                    DispatchQueue.main.async {
                        self.topDrinks = drinks
                    }
                }
            }
        }
    
    func searchVenues() {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "bars"
            request.region = region
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response else { return }
                DispatchQueue.main.async {
                    self.venues = response.mapItems.map { item in
                        Venue(name: item.name ?? "Unknown", type: "Bar", latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                    }
                }
            }
        }
    
    private func updateRegion(for cityName: String) {
        let cityCoordinates = [
            "San Francisco": CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            "London": CLLocationCoordinate2D(latitude: 42.9849, longitude: -81.2453),
            "Toronto": CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
        ]
        if let coord = cityCoordinates[cityName] {
            region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            searchVenues()
        }
    }
}

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

