// import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Float "mo:base/Float";
import List "mo:base/List";
import Array "mo:base/Array";

actor WeatherDApp {

  // ========== TYPES ==========
  type Weather = {
    location : Text;
    temperature : Float;
    description : Text;
    humidity : Nat;
  };

  type Forecast = {
    date : Text;
    high : Float;
    low : Float;
    description : Text;
  };

  // ========== STORAGE ==========
  stable var currentWeather : ?Weather = null;
  stable var weatherForecast : List.List<Forecast> = List.nil<Forecast>();


  // =====================================================
  // ✅ OMASKS – INTERNET IDENTITY AUTHENTICATION ENDPOINTS
  // /register, /login using Principal
  // =====================================================
  // TODO: Add functions for user registration and login here





  // =====================================================
  // ✅ TINA – WEATHER ENDPOINTS
  // /weather/current, /weather/forecast
  // =====================================================

  // Set current weather data
  public func set_weather(weather : Weather) : async Text {
    currentWeather := ?weather;
    return "Current weather data saved.";
  };

  // Get current weather data
  public query func get_weather() : async ?Weather {
    return currentWeather;
  };

  // Set forecast list (override existing)
  public func set_forecast(forecastList : [Forecast]) : async Text {
    weatherForecast := List.fromArray(forecastList);
    return "Forecast data saved.";
  };

  // Get forecast list
  public query func get_forecast() : async [Forecast] {
    return List.toArray(weatherForecast);
  };




  // =====================================================
  // ✅ LEVI – SAVED LOCATIONS & USER PREFERENCES
  // /locations/*, /preferences
  // =====================================================
  // TODO: Add functions to save/get favorite locations and user preferences

  // Type for user preferences
  type Preferences = {
    tempUnit: Text;       // Temperature unit (e.g., "C" for Celsius, "F" for Fahrenheit)
    windSpeedUnit: Text;  // Wind speed unit (e.g., "km/h", "mph")
    alertsEnabled: Bool;  // Whether weather alerts are enabled or not
  };

  // Storage for saved locations (list of cities)
  stable var savedLocations : [Text] = [];

  // Storage for user preferences
  stable var userPreferences : Preferences = {
    tempUnit = "C";         // Default: Celsius
    windSpeedUnit = "km/h"; // Default: kilometers per hour
    alertsEnabled = true;   // Default: alerts enabled
  };

  // Add a new location to the saved locations list
  public func addLocation(location: Text) : async Text {
    savedLocations := Array.append(savedLocations, [location]);  // Add the location to the list
    return "Location added.";
  };

  // Get the list of saved locations
  public query func listLocations() : async [Text] {
    return savedLocations;  // Return the list of saved locations
  };

  // Update user preferences
  public func updatePreferences(preference: Preferences) : async Text {
    userPreferences := preference;  // Update the preferences
    return "Preferences updated.";
  };

  // Get the current user preferences
  public query func getPreferences() : async Preferences {
    return userPreferences;  // Return the current preferences
  };





  // =====================================================
  // ✅ EL-SURAJ – FEEDBACK
  // /feedback
  // =====================================================
  // TODO: Add function to submit and retrieve feedback

}
