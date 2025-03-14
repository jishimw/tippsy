import SwiftUI
import MapKit

struct DiscoverView: View {
    // Add city struct and array
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

    @State private var selectedCity = "San Francisco"
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var venues: [Venue] = []
    @State private var searchText = ""

    func searchVenues() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "bars"
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error: (error?.localizedDescription ?? "Unknown error")")
                return
            }

            let newVenues = response.mapItems.map { item in
                Venue(
                    name: item.name ?? "Unknown",
                    type: "Bar",
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }

            DispatchQueue.main.async {
                self.venues = newVenues
            }
        }
    }
    
    var filteredVenues: [Venue] {
        if searchText.isEmpty {
            return venues
        }
        return venues.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // Add function to update region based on selected city
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

    var body: some View {
        NavigationStack {
            VStack {
                // City Picker
                Picker("Select City", selection: $selectedCity) {
                    ForEach(cities.map { $0.name }, id: .self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .onChange(of: selectedCity) { newCity in
                    updateRegion(for: newCity)
                }

                // Map View
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
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search venues...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // List of Venues
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
            .navigationTitle("Discover")
            .padding(.top, 10)
            .onAppear {
                searchVenues()
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
