unit AWS.SES.EmailResponse;

interface

uses
  System.JSON;

type
  IAWSSESEmailResponse = interface
    ['{03CEFE6B-4747-44AF-A82A-A74985DA50D2}']
    // Setters
    function StatusCode(value: Integer): IAWSSESEmailResponse; overload;
    function Content(value: string): IAWSSESEmailResponse; overload;
    function JSONValue(value: TJSONValue): IAWSSESEmailResponse; overload;
    // Getters
    function StatusCode: Integer; overload;
    function Content: string; overload;
    function JSONValue: TJSONValue; overload;
  end;

  TAWSSESEmailResponse = class(TInterfacedObject, IAWSSESEmailResponse)
  private
    FJSONValue: TJSONValue;
    FStatusCode: Integer;
    FContent: string;

    // Setters
    function StatusCode(value: Integer): IAWSSESEmailResponse; overload;
    function Content(value: string): IAWSSESEmailResponse; overload;
    function JSONValue(value: TJSONValue): IAWSSESEmailResponse; overload;
    // Getters
    function StatusCode: Integer; overload;
    function Content: string; overload;
    function JSONValue: TJSONValue; overload;

    constructor Create;
  public
    destructor Destroy; override;
    class function New: IAWSSESEmailResponse;
  end;

implementation

uses
  System.SysUtils;

{ TAWSSESEmailResponse }

function TAWSSESEmailResponse.Content: string;
begin
  Result := FContent;
end;

function TAWSSESEmailResponse.Content(value: string): IAWSSESEmailResponse;
begin
  Result := Self;
  FContent := value;
end;

constructor TAWSSESEmailResponse.Create;
begin
  inherited Create;
end;

destructor TAWSSESEmailResponse.Destroy;
begin
  if Assigned(FJSONValue) then
    FJSONValue.Free;
  inherited;
end;

function TAWSSESEmailResponse.JSONValue(value: TJSONValue): IAWSSESEmailResponse;
begin
  Result := Self;
  if Assigned(FJSONValue) then
    FreeAndNil(FJSONValue);
  FJSONValue := value;
end;

function TAWSSESEmailResponse.JSONValue: TJSONValue;
begin
  Result := FJSONValue;
end;

class function TAWSSESEmailResponse.New: IAWSSESEmailResponse;
begin
  Result := TAWSSESEmailResponse.Create;
end;

function TAWSSESEmailResponse.StatusCode(value: Integer): IAWSSESEmailResponse;
begin
  Result := Self;
  FStatusCode := value;
end;

function TAWSSESEmailResponse.StatusCode: Integer;
begin
  Result := FStatusCode;
end;

end.
