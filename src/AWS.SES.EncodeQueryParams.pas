unit AWS.SES.EncodeQueryParams;

interface

type
  TAWSEncodeQueryParams = class
  public
    class function Encode(const Str: string): string; overload; static;
    class function Encode(const Str: UTF8String): string; overload; static;
  end;

implementation

uses
  SysUtils;

class function TAWSEncodeQueryParams.Encode(const Str: string): string;
begin
  Result := Encode(UTF8Encode(Str));
end;

class function TAWSEncodeQueryParams.Encode(const Str: UTF8String): string;
const
  SAFE_CHARS = ['A' .. 'Z', 'a' .. 'z', '0', '1' .. '9', '-', '_', '~', '.'];
var
  Ch: AnsiChar;
begin
  Result := '';
  for Ch in Str do
    if not CharInSet(Ch, SAFE_CHARS) then
      Result := Result + '%' + IntToHex(Ord(Ch), 2)
    else
      Result := Result + WideChar(Ch);
end;

end.
