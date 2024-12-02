unit AWS.SES.EmailService;

interface

uses
  AWS.SES.EmailData, System.SysUtils, AWS.SES.EmailResponse,
  AWS.SES.Authentication.Intf, RESTRequest4D;

type
  EAWSSESEmailServiceException = class(Exception);

  IAWSSESEmailService = interface
    ['{5D0FBE0B-338D-4646-B8D3-306785712D54}']
    function Authentication(const value: IAWSSESAuthentication): IAWSSESEmailService;
    function EmailData(const value: IEmailData): IAWSSESEmailService;
    function Send: IAWSSESEmailResponse;
  end;

  TAWSSESEmailService = class(TInterfacedObject, IAWSSESEmailService)
  strict private
    FAuthentication: IAWSSESAuthentication;
    FResponse: IAWSSESEmailResponse;
    FEmailData: IEmailData;
    FURL: string;
    // Internal Methods
    procedure ValidateDependencies;
    procedure SetAWSURL;
    function GeneratePayload(const EmailData: IEmailData): string;
    procedure PopulateResponse(request_response: IResponse);
    // Interface Methods
    function Authentication(const value: IAWSSESAuthentication): IAWSSESEmailService;
    function EmailData(const value: IEmailData): IAWSSESEmailService;
    function Send: IAWSSESEmailResponse;

    constructor Create;
  public
    class function New: IAWSSESEmailService;
  end;

implementation

uses
  System.DateUtils, System.Hash, System.Classes, System.NetEncoding, AWS.SES.EncodeQueryParams,
  System.JSON;

{ TAWSSESEmailService }

function TAWSSESEmailService.Send: IAWSSESEmailResponse;
var
  Payload: string;
  LRequest: IRequest;
  LResponse: IResponse;
begin
  ValidateDependencies;

  SetAWSURL;
  Payload := GeneratePayload(FEmailData);

  LRequest := TRequest.New
    .BaseURL(FURL)
    .AddBody(TStringStream.Create(Payload));

  FAuthentication.PrepareRequest(LRequest, Payload);
  LResponse := LRequest.Post;
  PopulateResponse(LResponse);
  Result := FResponse;
end;

procedure TAWSSESEmailService.SetAWSURL;
begin
  FURL := 'https://email.' + FAuthentication.Region + '.amazonaws.com';
end;

procedure TAWSSESEmailService.ValidateDependencies;
begin
  if not Assigned(FEmailData) then
    raise EAWSSESEmailServiceException.Create('EmailData not defined');
  if not Assigned(FAuthentication) then
    raise EAWSSESEmailServiceException.Create('Authentication not defined');
end;

function TAWSSESEmailService.Authentication(const value: IAWSSESAuthentication): IAWSSESEmailService;
begin
  Result := Self;
  FAuthentication := value;
end;

constructor TAWSSESEmailService.Create;
begin
  inherited Create;
  FResponse := TAWSSESEmailResponse.New;
end;

function TAWSSESEmailService.EmailData(const value: IEmailData): IAWSSESEmailService;
begin
  Result := Self;
  FEmailData := value;
end;

function TAWSSESEmailService.GeneratePayload(const EmailData: IEmailData): string;
const
  Action = 'SendEmail';
var
  I: Integer;
  BodyType, Source: string;
  LStream: TStringStream;
begin
  LStream := TStringStream.Create(EmptyStr, TEncoding.UTF8);
  try

    LStream.WriteString('Action=' + ACTION);

    Source := Format('=?utf-8?B?%s?= <%s>', [TNetEncoding.Base64.Encode(EmailData.FromName), EmailData.FromAddress]);
    LStream.WriteString(Format('&Source=%s', [TAWSEncodeQueryParams.Encode(Source)]));

    for I := 0 to Pred(EmailData.Recipients.Count) do
      LStream.WriteString(Format('&Destination.ToAddresses.member.%d=%s', [I + 1, TAWSEncodeQueryParams.Encode(EmailData.Recipients[I])]));

    for I := 0 to Pred(EmailData.Cc.Count) do
      LStream.WriteString(Format('&Destination.CcAddresses.member.%d=%s', [I + 1, TAWSEncodeQueryParams.Encode(EmailData.Cc[I])]));

    for I := 0 to Pred(EmailData.Bcc.Count) do
      LStream.WriteString(Format('&Destination.BccAddresses.member.%d=%s', [I + 1, TAWSEncodeQueryParams.Encode(EmailData.Bcc[I])]));

    LStream.WriteString('&Message.Subject.Charset=UTF-8');
    LStream.WriteString(Format('&Message.Subject.Data=%s', [TAWSEncodeQueryParams.Encode(EmailData.Subject)]));

    if EmailData.BodyType = btHTML then
      BodyType := 'Html'
    else
      BodyType := 'Text';

    LStream.WriteString(Format('&Message.Body.%s.Charset=UTF-8', [BodyType]));
    LStream.WriteString(Format('&Message.Body.%s.Data=%s', [BodyType, TAWSEncodeQueryParams.Encode(EmailData.Body)]));

    Result := LStream.DataString;

  finally
    LStream.Free;
  end;
end;

class function TAWSSESEmailService.New: IAWSSESEmailService;
begin
  Result := TAWSSESEmailService.create;
end;

procedure TAWSSESEmailService.PopulateResponse(request_response: IResponse);
begin
  FResponse.StatusCode(request_response.StatusCode)
    .Content(request_response.Content);

  if Assigned(request_response.JSONValue) then
    FResponse.JSONValue(TJSONObject.ParseJSONValue(request_response.JSONValue.ToJSON))
  else
    FResponse.JSONValue(Nil);
end;

end.
