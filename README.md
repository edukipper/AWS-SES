## ⚙️ Installation 

* **Manual installation**: Add the following folders to your project, in *Project > Options > Building > Delphi Compiler > Search path*

```
../AWS_SES/src
```

* Installation using the [**Boss**](https://github.com/HashLoad/boss):

```
boss install github.com/edukipper/AWS-SES
```

## ⚡️ Quickstart

You need to use AWS_SES

```pascal
uses AWS.SES.Authentication.AWS4.Impl, AWS.SES.Authentication.Intf,
     AWS.SES.EmailData, AWS.SES.EmailService, AWS.SES.EmailResponse;
```


```pascal
var
  EmailData: IEmailData;
  AWS4Authentication: IAWSSESAuthentication;
  Response: IAWSSESEmailResponse;
begin

  // Email configuration
  EmailData := TEmailData.New
    .FromName('Your Name')
    .FromAddress('your-email@domain.com')
    .AddRecipient('recipient@domain.com')
    .AddCC('cc@domain.com')              // Optional
    .AddBCC('bcc@domain.com')            // Optional
    .Subject('Email Subject')
    .Body('<p>Email body in HTML format</p>')
    .BodyType(TBodyType.btHTML);         // Use btText for plain text emails

  // AWS SES Authentication
  AWS4Authentication := TAWSSESAuthenticationAWS4.New
    .AccessKey('YOUR_ACCESS_KEY')        // Replace with your Access Key
    .AccessSecret('YOUR_ACCESS_SECRET')  // Replace with your Access Secret
    .Region('us-east-2');                // AWS SES region

  // Sending the email
  Response := TAWSSESEmailService.New
    .Authentication(AWS4Authentication)
    .EmailData(EmailData)
    .Send;

  // Check for success
  if Response.StatusCode = 200 then
    ShowMessage('Email sent successfully!')
  else
    ShowMessage('Failed to send email. Error: ' + Response.Content);
end;

``` 

## ⚠️ License

`AWS-SES` is free and open-source software licensed under the [MIT License](https://github.com/edukipper/AWS-SES/blob/main/LICENSE). 
