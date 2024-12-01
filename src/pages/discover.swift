import SwiftUI
import MapKit

struct DiscoverView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default: San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var venues: [Venue] = [
        Venue(name: "The Tipsy Tavern", type: "Bar", latitude: 37.7751, longitude: -122.4183),
        Venue(name: "Brew Haven", type: "Restaurant", latitude: 37.7765, longitude: -122.4200),
        Venue(name: "Cocktail Creations", type: "Lounge", latitude: 37.7742, longitude: -122.4179)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // Map View
                Map(coordinateRegion: $region, annotationItems: venues) { venue in
                    MapMarker(coordinate: venue.coordinate, tint: .blue)
                }
                .frame(height: 300)
                .cornerRadius(10)
                .padding()
                
                // List of Venues
                List(venues) { venue in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(venue.name)
                                .font(.headline)
                            Text(venue.type)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            // Action for exploring venue (e.g., navigation or favorite)
                            print("Explore \(venue.name)")
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Discover")
            .padding(.top, 10)
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
