// import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Float "mo:base/Float";
import List "mo:base/List";

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





  // =====================================================
  // ✅ EL-SURAJ – FEEDBACK
  // /feedback
  // =====================================================
  // TODO: Add function to submit and retrieve feedback

}
