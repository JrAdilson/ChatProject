program ChatHorusMobile;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnPrincipal in 'UnPrincipal.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
