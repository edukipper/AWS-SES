unit AWS.SES.Authentication.Intf;

interface

uses
  RESTRequest4D, System.SysUtils;

type
  EAWSSESAuthenticationException = class(Exception);

  IAWSSESAuthentication = interface
    ['{D14B6620-BAFB-4650-91F5-2E8C9A13D4DC}']
    function AccessKey(value: string): IAWSSESAuthentication;
    function AccessSecret(value: string): IAWSSESAuthentication;
    function Region(value: string): IAWSSESAuthentication; overload;
    function Region: string; overload;
    procedure PrepareRequest(ARequest: IRequest; APayLoad: string);
  end;

implementation

end.
