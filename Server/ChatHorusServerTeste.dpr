program ChatHorusServerTeste;

uses
  Vcl.Forms,
  UnPrincipal in 'UnPrincipal.pas' {FormPrincipal},
  UnDadosDm in 'UnDadosDm.pas' {DmDados: TDataModule},
  UnChatHorus.Controller in 'UnChatHorus.Controller.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
