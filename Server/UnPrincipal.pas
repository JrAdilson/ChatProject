unit UnPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, HORSE,
  Vcl.StdCtrls, Vcl.ExtCtrls, UnChatHorus.Controller, HORSE.CORS;

type
  TFormPrincipal = class(TForm)
    mmoLog: TMemo;
    Panel1: TPanel;
    btnLigar: TButton;
    btnDesligar: TButton;
    edtPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblStatus: TLabel;
    edtUltimoIdMsg: TEdit;
    Label3: TLabel;
    procedure btnLigarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnDesligarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    Procedure AtualizarStatus;
    Procedure RegistrarLog(AMsg: String);

    procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure GetLogin(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure GetMensagensChat(Req: THorseRequest; Res: THorseResponse;
      Next: TProc);
    procedure DeleteParticipante(Req: THorseRequest; Res: THorseResponse;
      Next: TProc);
    procedure PostPessoa(Req: THorseRequest; Res: THorseResponse;
      Next: TProc);
    procedure GetPessoa(Req: THorseRequest; Res: THorseResponse;
      Next: TProc);

    procedure PostMensagemChat(Req: THorseRequest; Res: THorseResponse;
      Next: TProc);

    procedure GetUltimaMensagem(Req: THorseRequest; Res: THorseResponse;
      Next: TProc);
    procedure PostChat(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure PostApelido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure GetApelido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure GetChats(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure AtualizarUltimoIdMensagem;

  public

  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}


procedure TFormPrincipal.AtualizarStatus;
begin
  if THorse.IsRunning then
  Begin
    btnLigar.Enabled := False;
    btnDesligar.Enabled := True;
    edtPort.Enabled := False;
    lblStatus.Caption := 'Servidor rodando na porta ' + THorse.Port.ToString;
  End
  else
  begin
    btnLigar.Enabled := True;
    btnDesligar.Enabled := False;
    edtPort.Enabled := True;
    lblStatus.Caption := 'Servidor parado'
  end;
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  AtualizarStatus;
  AtualizarUltimoIdMensagem;
end;

procedure TFormPrincipal.AtualizarUltimoIdMensagem;
begin
  edtUltimoIdMsg.Text := IntToStr(BuscarIdUltimaMsg);
end;

procedure TFormPrincipal.btnDesligarClick(Sender: TObject);
begin
  THorse.StopListen;
  RegistrarLog('Servidor parado.');
  AtualizarStatus;
end;

procedure TFormPrincipal.DeleteParticipante(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
begin
  RegistrarLog('Requisição do DeleteParticipante.');
  try
    Res.Send(RemoverParticipante(
      Req.Query.Field('idusuario').AsInteger,
      Req.Query.Field('idchat').AsInteger))
      .ContentType('application/json; charset=utf-8')
      .Status(200);
  except
    On e: Exception Do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.GetApelido(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin
end;

procedure TFormPrincipal.GetChats(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin
  try
    RegistrarLog('Chamada do método GetChats');

    Res.Send(
      BuscarListaChats(Req.Query.Field('idusuario').AsInteger))
      .ContentType('application/json; charset=utf-8')
      .Status(200);
  except
    On e: Exception Do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.GetLogin(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  json: String;
begin
  RegistrarLog('Chamada do método GetLogin');
  try
    json := BuscarDadosLogin(
      Req.Query.Field('usuario').AsString,
      Req.Query.Field('senha').AsString);

    if json <> '' then
    Begin
      Res.Send(json)
        .ContentType('application/json; charset=utf-8')
        .Status(200);

      RegistrarLog('Usuário "' + Req.Query.Field('usuario').AsString +
        ' logado com sucesso');

    End
    Else
      Res.Send('{"erro": "usuario ou senha invalida"}')
        .ContentType('application/json; charset=utf-8')
        .Status(401);

  except
    On e: Exception Do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;

end;

procedure TFormPrincipal.GetMensagensChat(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
begin
  try
    RegistrarLog('Chamada do método GetMensagensChat.');

    Res.Send(

      BuscarMensagensChat(
      Req.Query.Field('idchat').AsInteger,
      Req.Query.Field('idusuariologado').AsInteger,
      Req.Query.Field('idmsg').AsInteger))
      .ContentType('application/json; charset=utf-8')
      .Status(200)

  except
    on e: Exception do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.GetPessoa(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin
  try
    RegistrarLog('Chamada do método GetPessoa.');

    If Req.Query.ContainsKey('id') Then
      Res.Send(BuscarPessoas(Req.Query.Field('id').AsInteger))
        .ContentType('application/json; charset=utf-8')
        .Status(200)

    Else
      Res.Send(BuscarPessoas(0))
        .ContentType('application/json; charset=utf-8')
        .Status(200);

  except
    on e: Exception do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.GetPing(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin
  RegistrarLog('Chamada do método GetPing');
  Res.Send('pong')
    .ContentType('application/json; charset=utf-8')
    .Status(200);
end;

procedure TFormPrincipal.GetUltimaMensagem(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
begin
  Res.Send('{"id": ' + edtUltimoIdMsg.Text + '}')
    .ContentType('application/json; charset=utf-8')
    .Status(200);
end;

procedure TFormPrincipal.PostApelido(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin
  RegistrarLog('Chamada do método PostApelido');
  try
    Res.Send(AdicionarApelido(Req.Body))
      .ContentType('application/json; charset=utf-8')
      .Status(201);
  except
    on e: Exception do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.PostChat(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin
  RegistrarLog('Chamada do método PostChat');
  try
    Res.Send(AdicionarChat(Req.Body))
      .ContentType('application/json; charset=utf-8')
      .Status(201);
  except
    on e: Exception do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.PostMensagemChat(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
begin

  try
    RegistrarLog('Chamada do método PostMensagemChat');

    Res.Send(InserirMensagem(Req.Body))
      .ContentType('application/json; charset=utf-8')
      .Status(201);

    AtualizarUltimoIdMensagem;

  except
    on e: Exception do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.PostPessoa(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin
  RegistrarLog('Chamada do método PostPessoa');
  try
    Res.Send(AdicionarPessoa(Req.Body))
      .ContentType('application/json; charset=utf-8')
      .Status(201);
  except
    on e: Exception do
      Res.Send('{"erro": "' + e.Message + '"}')
        .ContentType('application/json; charset=utf-8')
        .Status(500);
  end;
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if THorse.IsRunning then
    THorse.StopListen;
end;

procedure TFormPrincipal.RegistrarLog(AMsg: String);
begin
  mmoLog.Lines.Add(FormatDateTime('dd/mm/yy - hh:nn:ss: ', Now) + AMsg);
end;

procedure TFormPrincipal.btnLigarClick(Sender: TObject);
begin
  THorse.Use(CORS);

  THorse.Get('/ping', GetPing);

  THorse.Post('/pessoa', PostPessoa);

  THorse.Get('/pessoa', GetPessoa);

  THorse.Get('/login', GetLogin);

  THorse.Delete('/participantes', DeleteParticipante);

  THorse.Post('/mensagens-chat', PostMensagemChat);

  THorse.Get('/mensagens-chat', GetMensagensChat);

  THorse.Get('/ultima-msg', GetUltimaMensagem);

  THorse.Post('/chat', PostChat);

  THorse.Get('/chats', GetChats);

  THorse.Post('/apelido', PostApelido);

  THorse.Get('/apelido', GetApelido);

  THorse.Listen(StrToInt(edtPort.Text));
  RegistrarLog('Servidor ligado');

  AtualizarStatus;
end;

end.
