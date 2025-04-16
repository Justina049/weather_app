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
