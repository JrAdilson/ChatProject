unit UnChatHorus.Controller;

interface

Uses
  Json;

Function BuscarDadosEmJsonString(ASql: String; ALista: Boolean): String;
Function BuscarDadosEmJson(ASql: String; ALista: Boolean): TJSONValue;
Function BuscarPessoas(AId: integer): String;
Function AdicionarPessoa(Json: String): String;
Function BuscarDadosLogin(login, senha: String): String;
Function BuscarIdUsuario(ASql: String): integer;
Function BuscarListaChats(idUsuario: integer): String;
Function InserirMensagem(Json: String): String;
Function AdicionarApelido(Json: String): String;
Function BuscarIdUltimaMsg: integer;
Function AdicionarChat(Json: String): String;
Function BuscarMensagensChat(IdChat, idUsuario, IdMsg: integer): String;
Function RemoverParticipante(idUsuario, IdChat: integer): String;

implementation

uses
  FireDAC.Comp.Client, UnDadosDm, DataSet.Serialize, system.SysUtils;

Function AdicionarChat(Json: String): String;
var
  body: TJSONValue;
  participantes: TJSONArray;
  DmDados: TDmDados;
  nome, descricao: String;
  idusuarioLogado: integer;
Begin
  body := TJSONObject.ParseJSONValue(Json);

  nome := body.GetValue<String>('nome');
  descricao := body.GetValue<String>('descricao');
  idusuarioLogado := body.GetValue<integer>('idusuariologado');
  participantes := body.GetValue<TJSONArray>('participantes', nil);

  DmDados := TDmDados.Create(Nil);
  try
    Result := DmDados.InserirChat(
      idusuarioLogado, nome, descricao, participantes);


  finally
    DmDados.Free;
  end;
end;

Function BuscarDadosEmJson(ASql: String; ALista: Boolean): TJSONValue;
var
  DmDados: TDmDados;
  Qry: TFDQuery;
Begin
  DmDados := TDmDados.Create(Nil);
  try
    Qry := DmDados.BuscarDadosSql(ASql);

    if ALista then
      Result := Qry.ToJSONArray

    Else
      Result := Qry.ToJSONObject;

  finally
    Qry.Free;
    DmDados.Free;
  end;
End;

Function BuscarDadosEmJsonString(ASql: String; ALista: Boolean): String;
Begin
  Result := BuscarDadosEmJson(ASql, ALista).ToJSON;
End;

Function BuscarPessoas(AId: integer): String;
Begin
  if AId = 0 then
    Result := BuscarDadosEmJsonString('SELECT * FROM PESSOA', True)

  Else
    Result := BuscarDadosEmJsonString(
      'SELECT * FROM PESSOA WHERE PESSOA.ID = ' + IntTostr(AId), True);
End;

Function AdicionarApelido(Json: String): String;
var
  body: TJSONValue;
  DmDados: TDmDados;
Begin
  body := TJSONObject.ParseJSONValue(Json);
  DmDados := TDmDados.Create(Nil);
  try
    Result := DmDados.InserirApelido(
      body.GetValue<integer>('idusuariologado'),
      body.GetValue<integer>('idpessoa'),
      body.GetValue<String>('apelido'));
  finally
    DmDados.Free;
  end;
End;

Function AdicionarPessoa(Json: String): String;
var
  body: TJSONValue;
  DmDados: TDmDados;
  nome, Usuario, senha, Fone, Cpf, Email, DescricaoPerfil: String;
Begin
  body := TJSONObject.ParseJSONValue(Json);

  nome := body.GetValue<String>('nome');
  Usuario := body.GetValue<String>('usuario');
  senha := body.GetValue<String>('senha');
  Fone := body.GetValue<String>('fone');
  Cpf := body.GetValue<String>('cpf');
  Email := body.GetValue<String>('email');
  DescricaoPerfil := body.GetValue<String>('descricao_perfil');

  DmDados := TDmDados.Create(Nil);
  try
    Result := DmDados.InserirPessoa(
      nome, Usuario, senha, Fone, Cpf, Email, DescricaoPerfil);
  finally
    DmDados.Free;
  end;
End;

Function RemoverParticipante(idUsuario, IdChat: integer): String;
Var
  SQL: String;
  DmDados: TDmDados;
Begin

  SQL :=
    'DELETE FROM PARTICIPANTES       ' + slineBreak +
    ' WHERE PARTICIPANTES.IDCHAT =   ' + IntTostr(IdChat) + slineBreak +
    '   AND PARTICIPANTES.IDPESSOA = ' + IntTostr(idUsuario);

  DmDados := TDmDados.Create(Nil);
  try
    DmDados.ExecutarComando(SQL);

  finally
    DmDados.Free;
  end;

End;

Function BuscarListaChats(idUsuario: integer): String;
Var
  SQL: String;
Begin
  SQL :=
    'SELECT CHAT.* FROM CHAT     ' + slineBreak +
    '  JOIN PARTICIPANTES ON (PARTICIPANTES.IDCHAT = CHAT.ID) ' + slineBreak +
    '   WHERE PARTICIPANTES.IDPESSOA = ' + IntTostr(idUsuario);

  Result := BuscarDadosEmJson(SQL, True).ToJSON;
End;

Function BuscarDadosLogin(login, senha: String): String;
var
  jsonSaida: TJSONObject;
  SQL: String;
  JsonUsuario, JsonChats, JsonApelidos: TJSONValue;
  idUsuario: integer;
Begin
  if (login = '') Or (senha = '') then
    raise Exception.Create('Usuário ou senha não informados');

  SQL :=
    'SELECT FIRST 1 PESSOA.*     ' + slineBreak +
    '  FROM PESSOA               ' + slineBreak +
    ' WHERE PESSOA.SENHA = ' + QuotedStr(senha) + slineBreak +
    '   AND UPPER(PESSOA.USUARIO) = UPPER(' + QuotedStr(login) + ')';

  JsonUsuario := BuscarDadosEmJson(SQL, False);
  if JsonUsuario.ToString = '{}' then
    Exit('');

  idUsuario := BuscarIdUsuario(SQL);

  SQL :=
    'SELECT CHAT.* FROM CHAT     ' + slineBreak +
    '  JOIN PARTICIPANTES ON (PARTICIPANTES.IDCHAT = CHAT.ID) ' + slineBreak +
    '   WHERE PARTICIPANTES.IDPESSOA = ' + IntTostr(idUsuario);

  JsonChats := BuscarDadosEmJson(SQL, True);

  SQL :=
    'SELECT APELIDO.APELIDO, APELIDO.IDPESSOA_APELIDADA ' + slineBreak +
    '  FROM APELIDO' + slineBreak +
    '  JOIN PESSOA ON (PESSOA.ID = APELIDO.IDPESSOA_APELIDADA)' + slineBreak +
    ' WHERE APELIDO.IDPESSOA_APELIDOU = ' + IntTostr(idUsuario);

  JsonApelidos := BuscarDadosEmJson(SQL, True);

  jsonSaida := TJSONObject.Create;
  try
    jsonSaida.AddPair('pessoa', JsonUsuario);
    jsonSaida.AddPair('chats', JsonChats);
    jsonSaida.AddPair('apelidos', JsonApelidos);

    Result := jsonSaida.ToJSON;

  finally
    jsonSaida.Free;
  end;

End;

Function BuscarIdUsuario(ASql: String): integer;
var
  DmDados: TDmDados;
  Qry: TFDQuery;
Begin
  DmDados := TDmDados.Create(Nil);
  try
    Qry := DmDados.BuscarDadosSql(ASql);

    Result := Qry.FieldByName('id').AsInteger;

  finally
    Qry.Free;
    DmDados.Free;
  end;

End;

Function InserirMensagem(Json: String): String;
var
  body: TJSONValue;
  DmDados: TDmDados;
  IdChat, idPessoa: integer;
  Mensagem: String;
Begin
  body := TJSONObject.ParseJSONValue(Json);

  IdChat := body.GetValue<integer>('idchat');
  idPessoa := body.GetValue<integer>('idpessoa');
  Mensagem := body.GetValue<String>('mensagem');

  DmDados := TDmDados.Create(Nil);
  try
    Result := DmDados.InserirMensagem(IdChat, idPessoa, Mensagem);
  finally
    DmDados.Free;
  end;

End;

Function BuscarIdUltimaMsg: integer;
var
  DmDados: TDmDados;
Begin
  DmDados := TDmDados.Create(Nil);
  try
    Result := DmDados.BuscarIdUltimaMsg;
  finally
    DmDados.Free;
  end;
End;

Function BuscarMensagensChat(IdChat, idUsuario, IdMsg: integer): String;
var
  DmDados: TDmDados;
Begin
  DmDados := TDmDados.Create(Nil);
  try
    Result := DmDados.BuscarMensagensChat(IdChat, idUsuario, IdMsg);
  finally
    DmDados.Free;
  end;
End;

end.
