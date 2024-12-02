unit AWS.SES.EmailData;

interface

uses
  System.Generics.Collections;

type

  TBodyType = (btHTML, btText);

  IEmailData = interface
    ['{04ACACC8-51CC-4647-BFEA-DDE61D77198A}']
    // Setters
    function FromName(const Value: string): IEmailData; overload;
    function FromAddress(const Value: string): IEmailData; overload;
    function AddRecipient(const Value: string): IEmailData; overload;
    function AddCC(const Value: string): IEmailData;
    function AddBCC(const Value: string): IEmailData;
    function Subject(const Value: string): IEmailData; overload;
    function Body(const Value: string): IEmailData; overload;
    function BodyType(const Value: TBodyType): IEmailData; overload;
    // Getters
    function FromName: string; overload;
    function FromAddress: string; overload;
    function Recipients: TList<string>;
    function CC: TList<string>;
    function BCC: TList<string>;
    function Subject: string; overload;
    function Body: string; overload;
    function BodyType: TBodyType; overload;

  end;

  TEmailData = class(TInterfacedObject, IEmailData)
  private
    FBodyType: TBodyType;
    FFromAddress: string;
    FBody: string;
    FFromName: string;
    FSubject: string;
    FCC: TList<string>;
    FRecipients: TList<string>;
    FBCC: TList<string>;

    // Setters
    function FromName(const Value: string): IEmailData; overload;
    function FromAddress(const Value: string): IEmailData; overload;
    function AddRecipient(const Value: string): IEmailData; overload;
    function AddCC(const Value: string): IEmailData;
    function AddBCC(const Value: string): IEmailData;
    function Subject(const Value: string): IEmailData; overload;
    function Body(const Value: string): IEmailData; overload;
    function BodyType(const Value: TBodyType): IEmailData; overload;
    // Getters
    function FromName: string; overload;
    function FromAddress: string; overload;
    function Recipients: TList<string>;
    function CC: TList<string>;
    function BCC: TList<string>;
    function Subject: string; overload;
    function Body: string; overload;
    function BodyType: TBodyType; overload;
    constructor Create;

  public
    destructor Destroy; override;
    class function New: IEmailData;
  end;

implementation

{ TEmailData }

destructor TEmailData.Destroy;
begin
  FRecipients.Free;
  FCC.Free;
  FBCC.Free;

  inherited;
end;

function TEmailData.FromAddress: string;
begin
  Result := FFromAddress;
end;

function TEmailData.FromAddress(const Value: string): IEmailData;
begin
  Result := Self;
  FFromAddress := Value;
end;

function TEmailData.FromName(const Value: string): IEmailData;
begin
  Result := Self;
  FFromName := Value;
end;

function TEmailData.FromName: string;
begin
  Result := FFromName;
end;

class function TEmailData.New: IEmailData;
begin
  Result := TEmailData.Create;
end;

function TEmailData.Recipients: TList<string>;
begin
  Result := FRecipients;
end;

function TEmailData.Subject(const Value: string): IEmailData;
begin
  Result := Self;
  FSubject := Value;
end;

function TEmailData.Subject: string;
begin
  Result := FSubject;
end;

{ TEmailData }

function TEmailData.AddBCC(const Value: string): IEmailData;
begin
  Result := Self;
  FBCC.Add(Value);
end;

function TEmailData.AddCC(const Value: string): IEmailData;
begin
  Result := Self;
  FCC.Add(Value);
end;

function TEmailData.AddRecipient(const Value: string): IEmailData;
begin
  Result := Self;
  FRecipients.Add(Value);
end;

function TEmailData.BCC: TList<string>;
begin
  Result := FBCC;
end;

function TEmailData.Body(const Value: string): IEmailData;
begin
  Result := Self;
  FBody := Value;
end;

function TEmailData.Body: string;
begin
  Result := FBody;
end;

function TEmailData.BodyType(const Value: TBodyType): IEmailData;
begin
  Result := Self;
  FBodyType := Value;
end;

function TEmailData.BodyType: TBodyType;
begin
  Result := FBodyType;
end;

function TEmailData.CC: TList<string>;
begin
  Result := FCC;
end;

constructor TEmailData.Create;
begin
  FRecipients := TList<string>.Create;
  FCC := TList<string>.Create;
  FBCC := TList<string>.Create;
end;

end.
