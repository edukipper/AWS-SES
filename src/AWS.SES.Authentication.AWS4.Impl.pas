unit AWS.SES.Authentication.AWS4.Impl;

interface

uses
  RESTRequest4D, System.SysUtils, AWS.SES.EmailData,
  System.Classes, AWS.SES.Authentication.Intf;

type
  EAWSSESAuthenticationAWS4Exception = class(EAWSSESAuthenticationException);

  TAWSSESAuthenticationAWS4 = class(TInterfacedObject, IAWSSESAuthentication)
  strict private
    FAccessKey: string;
    FSecretKey: string;
    FRegion: string;
    FService: string;

    procedure Validate;
    function GetTimestamp: string;
    function GetDateStamp: string;
    function GenerateCanonicalRequest(const Payload: string): string;
    function GenerateStringToSign(const CanonicalRequest, Timestamp: string): string;
    function GenerateSignature(const StringToSign: string): string;
    function GetAuthorizationHeader(const Signature: string): string;
    class function HMACSHA256(const Key: TBytes; const Data: string): string;

    function Region: string; overload;
    function AccessKey(value: string): IAWSSESAuthentication;
    function AccessSecret(value: string): IAWSSESAuthentication;
    function Region(value: string): IAWSSESAuthentication; overload;

    procedure PrepareRequest(ARequest: IRequest; APayLoad: string);
    constructor Create;
  public
    class function New: IAWSSESAuthentication;
  end;

implementation

uses
  System.DateUtils, System.Hash, System.NetEncoding, AWS.SES.EncodeQueryParams;

{ TAWSSESAuthenticationAWS4 }

function TAWSSESAuthenticationAWS4.AccessKey(value: string): IAWSSESAuthentication;
begin
  Result := Self;
  FAccessKey := value;
end;

function TAWSSESAuthenticationAWS4.AccessSecret(value: string): IAWSSESAuthentication;
begin
  Result := Self;
  FSecretKey := value;
end;

constructor TAWSSESAuthenticationAWS4.Create;
begin
  inherited Create;
  FService := 'ses';
end;

function TAWSSESAuthenticationAWS4.GenerateCanonicalRequest(
  const Payload: string): string;
begin
  Result := 'POST' + #10 +
    '/' + #10 +
    '' + #10 +
    'host:email.' + FRegion + '.amazonaws.com' + #10 + #10 +
    'host' + #10 +
    THashSHA2.GetHashString(Payload);
end;

function TAWSSESAuthenticationAWS4.GenerateSignature(
  const StringToSign: string): string;
var
  DateKey, RegionKey, ServiceKey, SigningKey: TBytes;
begin
  // Calculando as chaves intermediárias
  DateKey := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes(GetDateStamp), TEncoding.UTF8.GetBytes('AWS4' + FSecretKey));
  RegionKey := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes(FRegion), DateKey);
  ServiceKey := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes(FService), RegionKey);
  SigningKey := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes('aws4_request'), ServiceKey);

  // Calculando a assinatura final
  Result := HMACSHA256(SigningKey, StringToSign); // Passa a chave diretamente como TBytes
end;

function TAWSSESAuthenticationAWS4.GenerateStringToSign(
  const CanonicalRequest, Timestamp: string): string;
var
  DateStamp: string;
begin
  DateStamp := GetDateStamp;
  Result := 'AWS4-HMAC-SHA256' + #10 +
    Timestamp + #10 +
    Format('%s/%s/%s/aws4_request', [DateStamp, FRegion, FService]) + #10 +
    THashSHA2.GetHashString(CanonicalRequest);
end;

function TAWSSESAuthenticationAWS4.GetAuthorizationHeader(
  const Signature: string): string;
var
  CredentialScope: string;
begin
  CredentialScope := Format('%s/%s/%s/aws4_request', [GetDateStamp, FRegion, FService]);
  Result := Format('AWS4-HMAC-SHA256 Credential=%s/%s, SignedHeaders=host, Signature=%s',
    [FAccessKey, CredentialScope, Signature]);
end;

function TAWSSESAuthenticationAWS4.GetDateStamp: string;
begin
  Result := FormatDateTime('yyyymmdd', TTimeZone.Local.ToUniversalTime(Now));
end;

function TAWSSESAuthenticationAWS4.Region: string;
begin
  Result := FRegion;
end;

function TAWSSESAuthenticationAWS4.GetTimestamp: string;
begin
  Result := FormatDateTime('yyyymmdd"T"hhnnss"Z"', TTimeZone.Local.ToUniversalTime(Now));
end;

class function TAWSSESAuthenticationAWS4.HMACSHA256(const Key: TBytes;
  const Data: string): string;
var
  DataBytes, HashBytes: TBytes;
  Hex: string;
  I: Integer;
begin
  // Converte os dados (StringToSign) para bytes
  DataBytes := TEncoding.UTF8.GetBytes(Data);

  // Calcula o HMAC-SHA256
  HashBytes := THashSHA2.GetHMACAsBytes(DataBytes, Key);

  // Converte o hash para uma string hexadecimal
  Hex := '';
  for I := 0 to Length(HashBytes) - 1 do
    Hex := Hex + IntToHex(HashBytes[I], 2);

  Result := LowerCase(Hex); // AWS espera o resultado em hexadecimal minúsculo
end;

class function TAWSSESAuthenticationAWS4.New: IAWSSESAuthentication;
begin
  Result := Create;
end;

procedure TAWSSESAuthenticationAWS4.PrepareRequest(ARequest: IRequest; APayLoad: string);
var
  CanonicalRequest, StringToSign, Signature, Authorization: string;
  LHoraRequisicao: string;
begin
  Validate;

  LHoraRequisicao := GetTimestamp;

  CanonicalRequest := GenerateCanonicalRequest(APayLoad);
  StringToSign := GenerateStringToSign(CanonicalRequest, LHoraRequisicao);
  Signature := GenerateSignature(StringToSign);
  Authorization := GetAuthorizationHeader(Signature);

  ARequest.ContentType('application/x-www-form-urlencoded')
    .AddHeader('Authorization', Authorization, [poDoNotEncode])
    .AddHeader('x-amz-date', LHoraRequisicao, [poDoNotEncode]);
end;

function TAWSSESAuthenticationAWS4.Region(value: string): IAWSSESAuthentication;
begin
  Result := Self;
  FRegion := value;
end;

procedure TAWSSESAuthenticationAWS4.Validate;
begin
  if FRegion.IsEmpty then
    raise EAWSSESAuthenticationAWS4Exception.Create('The Region parameter is required');
  if FAccessKey.IsEmpty then
    raise EAWSSESAuthenticationAWS4Exception.Create('The AccessKey parameter is required');
  if FSecretKey.IsEmpty then
    raise EAWSSESAuthenticationAWS4Exception.Create('The SecretKey parameter is required');
end;

end.
