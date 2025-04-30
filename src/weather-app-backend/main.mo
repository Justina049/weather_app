import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Float "mo:base/Float";
import List "mo:base/List";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
// import Result "mo:base/Result";
// import Buffer "mo:base/Buffer";
// import Blob "mo:base/Blob";
import IC "IC";


actor WeatherDApp {

  // ========== TYPES ==========
  type Weather = {
    location : Text;
    temperature : Float;
    description : Text;
    humidity : Nat;
    timestamp : Int;  // Timestamp in nanoseconds
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

  // ========== FETCH WEATHER FROM API ==========

  public query func transform(args: IC.TransformArgs) : async IC.http_request_result {
    {
      status = args.response.status;
      body = args.response.body;
      headers = [];
    };
  };

  private func make_api_url(city : Text, kind : Text) : Text {
    let apiKey = "60b93f6ca3ac45c3b3050a7c23c3c022";
    if (kind == "current") {
      return "https://api.openweathermap.org/data/2.5/weather?q=" # city # "&appid=" # apiKey # "&units=metric";
    } else if (kind == "forecast") {
      return "https://api.openweathermap.org/data/2.5/forecast?q=" # city # "&appid=" # apiKey # "&units=metric";
    } else {
      return "";
    };
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
type Feedback = {
    id : Nat;
    user : Principal;
    message : Text;
    location : ?{ lat : Float; lng : Float }; // Location tagging
    timestamp : Int;
  };

  type RateLimit = {
    lastSubmissionTime : Int;
    submissionCount : Nat;
  };

  //======= CONSTANTS =======
  let RATE_LIMIT_WINDOW : Int = 60; // 1 minute
  let MAX_SUBMISSIONS : Nat = 5; // Max submissions in the window

  //======= STORAGE =======
  stable var nextFeedbackId : Nat = 0;
  stable var feedbacks : [Feedback] = [];
  stable var stableRateLimit : [(Principal, RateLimit)] = [];

  var ratelimits = HashMap.fromIter<Principal, RateLimit>(
    stableRateLimit.vals(),
    0,
    Principal.equal,
    Principal.hash,
  );

  //======= METHODS =======
  public shared ({ caller }) func submit_feedback(
    message : Text,
    location : ?{ lat : Float; lng : Float },
  ) : async Text {
    //rate limit check
    let now = Time.now();
    let milliseconds = now / 1_000_000; // Convert to milliseconds
    // Store `milliseconds` instead of `now`
    let userLimit = switch (ratelimits.get(caller)) {
      case (?limit) {
        if (now - limit.lastSubmissionTime < RATE_LIMIT_WINDOW) {
          assert (limit.submissionCount < MAX_SUBMISSIONS);
          {
            lastSubmissionTime = limit.lastSubmissionTime; // original time
            submissionCount = limit.submissionCount + 1;
          };
        } else {
          {
            lastSubmissionTime = now;
            submissionCount = 1;
          };
        };
      };
      case null {
        {
          lastSubmissionTime = now;
          submissionCount = 1;
        };
      };
    };
    ratelimits.put(caller, userLimit);

    //store feedback
    let newFeedback : Feedback = {
      id = nextFeedbackId;
      user = caller;
      message;
      location;
      timestamp = milliseconds;
    };

    feedbacks := Array.append(feedbacks, [newFeedback]);
    nextFeedbackId += 1;

    return "Feedback submitted successfully.";
  };

  public query func get_feedback() : async [Feedback] {
    return feedbacks;
  };

  //=========SYSTEM METHODS ===========
  system func preupgrade() {
    stableRateLimit := Iter.toArray(ratelimits.entries());
  };

  system func postupgrade() {
    ratelimits := HashMap.fromIter<Principal, RateLimit>(
      stableRateLimit.vals(),
      0,
      Principal.equal,
      Principal.hash,
    );
  };
}
