import Blob "mo:base/Blob";

module {
  public type HttpHeader = {
    name : Text;
    value : Text;
  };

  public type HttpRequestArgs = {
    url : Text;
    max_response_bytes : ?Nat;
    headers : [HttpHeader];
    body : ?Blob;
    method : {#get; #post; #head};
    transform : ?TransformContext;
  };

  public type TransformArgs = {
    response : http_request_result;
    context : Blob;
  };

  public type TransformContext = {
    function : shared query TransformArgs -> async http_request_result;
    context : Blob;
  };

  public type http_request_result = {
    status : Nat;
    headers : [HttpHeader];
    body : Blob;
  };

  public type Self = actor {
    http_request : shared HttpRequestArgs -> async http_request_result;
    raw_rand : shared () -> async Blob;
  };
}