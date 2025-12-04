import SwiftUI
import Combine
import CoreLocation

    // MARK: - View Model
class SpeedViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var rawSpeed: Double = 0.0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var showMissingPlistAlert = false
    
        // Previous location to calculate manual speed
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        
            // CHANGED: "Best" is stable enough for walking. "Navigation" is too sensitive to noise.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
            // CHANGED: Only trigger update if moved at least 5 meters.
            // This prevents the speed from fluctuating wildly while standing still.
        locationManager.distanceFilter = 5 // meters
        
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestPermission() {
        let key = "NSLocationWhenInUseUsageDescription"
        let hasKey = Bundle.main.object(forInfoDictionaryKey: key) != nil
        
        if hasKey {
            locationManager.requestWhenInUseAuthorization()
        } else {
            showMissingPlistAlert = true
        }
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
        // MARK: - CLLocationManagerDelegate Methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.startTracking()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
            // 1. Accuracy Filter:
            // Relaxed to 70m to allow getting a lock even in cities/indoors
        if newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 70 {
            return
        }
        
        DispatchQueue.main.async {
                // STRATEGY: Hybrid Approach
            
                // Case A: Hardware Speed (High Confidence)
                // The GPS chip knows the speed via Doppler shift.
                // Note: 0 is a valid speed (standing still), so we check >= 0.
            if newLocation.speed >= 0 {
                self.rawSpeed = newLocation.speed
                self.lastLocation = newLocation
            }
            
                // Case B: Manual Calculation (Fallback for Walking/Weak Signal)
                // If hardware speed is -1 (invalid), we calculate it manually.
            else if let lastLocation = self.lastLocation {
                
                let distanceChange = newLocation.distance(from: lastLocation)
                let timeChange = newLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
                
                    // BUG FIX: Prevent negative time or division by zero
                if timeChange > 0 {
                    let calculatedSpeed = distanceChange / timeChange
                    
                        // BUG FIX: The "Negative Speed" issue
                        // Use abs() to ensure positive and max(0) to never go below zero
                    let safeSpeed = max(0, abs(calculatedSpeed))
                    
                        // BUG FIX: The "Drops to 0" issue
                        // I lowered the threshold from 0.5 (1.8kmh) to 0.1 (0.36kmh).
                        // This allows very slow walking to still register.
                    if safeSpeed > 0.1 && safeSpeed < 100 {
                        self.rawSpeed = safeSpeed
                    } else if safeSpeed <= 0.1 {
                            // Only snap to zero if we are practically not moving
                        self.rawSpeed = 0
                    }
                }
                self.lastLocation = newLocation
                
            } else {
                    // First point received
                self.lastLocation = newLocation
                self.rawSpeed = 0
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

    // MARK: - Speed Unit Enum
enum SpeedUnit: String, CaseIterable, Identifiable {
    case kmh = "km/h"
    case mph = "mph"
    case knots = "knots"
    case mps = "m/s"
    
    var id: String { self.rawValue }
    
    var conversionFactor: Double {
        switch self {
            case .kmh: return 3.6
            case .mph: return 2.23694
            case .knots: return 1.94384
            case .mps: return 1.0
        }
    }
}

    // MARK: - Custom Animation Component
    // This struct handles the smooth counting from 10 -> 11 -> 12
struct RollingSpeedText: View, Animatable {
    var value: Double
    var color: Color
    
        // This property tells SwiftUI how to interpolate numbers between updates
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        Text(String(format: "%.1f", value))
            .font(.system(size: 120, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 0)
            // Monospaced digit prevents the text from jittering left/right
            .monospacedDigit()
    }
}

    // MARK: - Main View
struct SpeedTrackerView: View {
    @StateObject private var viewModel = SpeedViewModel()
    @State private var selectedUnit: SpeedUnit = .kmh
    
    var body: some View {
        ZStack {
                // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(UIColor.darkGray)]),
                           startPoint: .top,
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            switch viewModel.authorizationStatus {
                case .notDetermined:
                    permissionRequestView
                case .restricted, .denied:
                    permissionDeniedView
                case .authorizedAlways, .authorizedWhenInUse:
                    speedometerView
                @unknown default:
                    permissionRequestView
            }
        }
        .preferredColorScheme(.dark)
    }
    
        // MARK: - Subviews
    
    var speedometerView: some View {
        VStack(spacing: 40) {
            Text("SPEEDOMETER")
                .font(.caption)
                .fontWeight(.bold)
                .tracking(2)
                .foregroundColor(.gray)
                .padding(.top, 50)
            
            Spacer()
            
            VStack(spacing: 0) {
                    // ANIMATED SPEED TEXT
                RollingSpeedText(value: displaySpeed, color: speedColor)
                    // This creates the physical "needle" movement feeling
                    .animation(.interactiveSpring(response: 0.8, dampingFraction: 0.7), value: displaySpeed)
                    // This smooths the color transition
                    .animation(.easeInOut(duration: 0.5), value: speedColor)
                
                Text(selectedUnit.rawValue)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .id("UnitText" + selectedUnit.rawValue)
            }
            .padding()
            .background(
                ZStack {
                        // Outer Ring
                    Circle()
                        .stroke(lineWidth: 4)
                        .foregroundColor(speedColor.opacity(0.3))
                        .animation(.easeInOut(duration: 0.5), value: speedColor)
                    
                        // Subtle Inner Glow
                    Circle()
                        .fill(RadialGradient(colors: [speedColor.opacity(0.15), .clear], center: .center, startRadius: 0, endRadius: 150))
                        .animation(.easeInOut(duration: 0.5), value: speedColor)
                }
                    .frame(width: 300, height: 300)
            )
            
            Spacer()
            
            Picker("Unit", selection: $selectedUnit.animation()) {
                ForEach(SpeedUnit.allCases) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 50)
            .padding(.bottom, 20)
            
            HStack {
                Image(systemName: "location.fill")
                Text("GPS Active")
            }
            .font(.caption)
            .foregroundColor(.green)
            .padding(.bottom, 20)
        }
    }
    
    var permissionRequestView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Location Access Needed")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("To calculate your speed, this app needs access to your location.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            Button(action: {
                viewModel.requestPermission()
            }) {
                Text("Enable Location")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            .alert(isPresented: $viewModel.showMissingPlistAlert) {
                Alert(
                    title: Text("Configuration Error"),
                    message: Text("Please add 'Privacy - Location When In Use Usage Description' to your Info.plist file."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Access Denied")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please enable Location Services in Settings to use the speedometer.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            Button(action: {
                viewModel.openSettings()
            }) {
                Text("Open Settings")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
    }
    
        // Helper to calculate speed based on unit
    var displaySpeed: Double {
        return viewModel.rawSpeed * selectedUnit.conversionFactor
    }
    
        // Helper to change color based on intensity
    var speedColor: Color {
        let value = displaySpeed
        if value < 10 { return Color.green }
        else if value < 30 { return Color.cyan }
        else if value < 60 { return Color.blue }
        else if value < 90 { return Color.orange }
        else { return Color.red }
    }
}

#Preview {
    SpeedTrackerView()
}
