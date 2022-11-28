unit UnDadosDm;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  System.JSON;

type
  TDmDados = class(TDataModule)
    FDConnection1: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);

  public
    Function InserirPessoa(Nome, Usuario, Senha, Fone, Cpf, Email,
      DescricaoPerfil: String): String;
    Function InserirMensagem(IdChat, IdPessoa: Integer;
      Mensagem: String): String;
    Function InserirChat(idUsuarioLogado: Integer;
      Nome, Descricao: String; ListaParticipantes: tjsonArray): String;
    Function InserirApelido(idUsuarioLogado, idUsuarioApelidado: Integer;
      Apelido: String): String;
    Procedure ExecutarComando(Sql: String);

    Function BuscarDadosSql(ASql: String): TFDQuery;
    Function BuscarIdUltimaMsg: Integer;
    Function BuscarMensagensChat(IdChat, IdUsuario, IdMsg: Integer): String;

  end;

var
  DmDados: TDmDados;

implementation

Uses
  DataSet.Serializ e, DataSet.Serialize.Config;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{ TDmDados }

function TDmDados.BuscarDadosSql(ASql: String): TFDQuery;
begin
  Result := TFDQuery.Create(Nil);
  Result.Connection := FDConnection1;

  Result.Sql.Text := ASql;
  Result.Open;
end;

function TDmDados.BuscarIdUltimaMsg: Integer;
var
  qry: TFDQuery;
begin
  qry := BuscarDadosSql('SELECT MAX(ID) AS ID FROM MENSAGEM');
  try
    Result := qry.FieldByName('ID').AsInteger;
  finally
    qry.Free;
  end;
end;

function TDmDados.BuscarMensagensChat(IdChat, IdUsuario,
  IdMsg: Integer): String;
var
  qry: TFDQuery;
  idInserido: Integer;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := FDConnection1;

    qry.Sql.Text :=
      'SELECT MENSAGEM.ID, MENSAGEM.IDPESSOA,                     ' +
      '       MENSAGEM.MENSAGEM, MENSAGEM.DATAHORA,                 ' +


		'LPAD( EXTRACT(DAY FROM MENSAGEM.DATAHORA), 2, 0) || ''/'' ||   ' +
		'LPAD( EXTRACT(MONTH FROM MENSAGEM.DATAHORA), 2, 0) || ''/'' ||  ' +
		'LPAD( EXTRACT(YEAR FROM MENSAGEM.DATAHORA), 4, 0) || '' - '' || ' +
		'LPAD( EXTRACT(HOUR FROM MENSAGEM.DATAHORA), 2, 0) || '':'' || ' +
		'LPAD( EXTRACT(MINUTE FROM MENSAGEM.DATAHORA), 2, 0)      '     +
	  '	AS data_texto,                                           '     +

      ' 	    IIF(MENSAGEM.IDPESSOA = :IDUSUARIO, ''sim'', ''nao'') ' +
      '        AS proprioautor,                                     ' +
      ' 	    COALESCE(APELIDO.APELIDO, PESSOA.NOME) AS NOME          ' +
      ' FROM MENSAGEM                                               ' +
      ' JOIN PESSOA ON (PESSOA.ID = MENSAGEM.IDPESSOA)               ' +
      ' LEFT JOIN APELIDO ON (PESSOA.ID = APELIDO.IDPESSOA_APELIDADA ' +
      ' 			    AND APELIDO.IDPESSOA_APELIDOU = :IDUSUARIO)        ' +
      ' WHERE MENSAGEM.IDCHAT = :IDCHAT                              ' +
      '   AND MENSAGEM.ID > :IDMENSAGEM ' +
      ' ORDER BY MENSAGEM.DATAHORA  ';

    qry.ParamByName('IDUSUARIO').AsInteger := IdUsuario;
    qry.ParamByName('IDCHAT').AsInteger := IdChat;
    qry.ParamByName('IDMENSAGEM').AsInteger := IdMsg;

    qry.Open;

    Result := qry.ToJSONArrayString;
  finally
    qry.Free;
  end;
end;

procedure TDmDados.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
  TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';
  TDataSetSerializeConfig.GetInstance.DateIsFloatingPoint := True;
  // TDataSetSerializeConfig.GetInstance.DateTimeIsISO8601 := True;
end;

procedure TDmDados.ExecutarComando(Sql: String);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := FDConnection1;

    qry.Sql.Text := Sql;
    qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

function TDmDados.InserirApelido(idUsuarioLogado, idUsuarioApelidado: Integer;
  Apelido: String): String;
var
  qry: TFDQuery;
  idInserido: Integer;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := FDConnection1;

    qry.Sql.Text :=
      'UPDATE OR INSERT INTO apelido ( ' +
      '   idpessoa_apelidou, idpessoa_apelidada, apelido)' +
      ' values (:idpessoa_apelidou, :idpessoa_apelidada, :apelido) ' +
      '  matching (idpessoa_apelidou, idpessoa_apelidada) ' +
      ' returning id, idpessoa_apelidou, idpessoa_apelidada, apelido';

    qry.ParamByName('idpessoa_apelidou').AsInteger := idUsuarioLogado;
    qry.ParamByName('idpessoa_apelidada').AsInteger := idUsuarioApelidado;
    qry.ParamByName('apelido').AsString := Apelido;

    qry.Open;

    Result := qry.ToJSONArrayString;

  finally
    qry.Free;
  end;
end;

Function TDmDados.InserirChat(idUsuarioLogado: Integer;
  Nome, Descricao: String; ListaParticipantes: tjsonArray): String;
var
  qry: TFDQuery;
  idInserido: Integer;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := FDConnection1;

    qry.Sql.Text :=
      'INSERT INTO chat ( ' +
      '   nome, descricao)' +
      ' values (:nome, :descricao) ' +
      ' returning id, nome, descricao';

    qry.ParamByName('descricao').AsString := Descricao;
    qry.ParamByName('nome').AsString := Nome;

    qry.Open;

    Result := qry.ToJSONArrayString;

    if Assigned(ListaParticipantes) then
    Begin
      for var I := 0 to ListaParticipantes.Count - 1 do
      begin
        var
        script :=
          'INSERT INTO PARTICIPANTES (IDCHAT, IDPESSOA) ' +
          ' VALUES (' + qry.FieldByName('id').AsString + ',' +
          ListaParticipantes.Items[I].Value + ' )';

        ExecutarComando(script);
      end;
    End
    Else
    Begin
      var
      script :=
        'INSERT INTO PARTICIPANTES (IDCHAT, IDPESSOA)' +
        'SELECT CHAT.ID, PESSOA.ID AS IDPESSOA ' +
        '  FROM PESSOA ' +
        '  INNER JOIN CHAT ON (CHAT.ID = ' +
        qry.FieldByName('id').AsString + ') ' +
        '  LEFT JOIN PARTICIPANTES PART ON ( ' +
        '      PART.IDCHAT = CHAT.ID AND PART.IDPESSOA = PESSOA.ID)' +
        ' WHERE PART.IDPESSOA IS NULL;';
      ExecutarComando(script);
    End;
  finally
    qry.Free;
  end;
end;

function TDmDados.InserirMensagem(IdChat, IdPessoa: Integer;
  Mensagem: String): String;
var
  qry: TFDQuery;
  idInserido: Integer;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := FDConnection1;

    qry.Sql.Text :=
      'INSERT INTO MENSAGEM ( ' +
      '   idchat, idpessoa, mensagem, datahora, editada)' +
      ' values (:idchat, :idpessoa, :mensagem, :datahora, :editada) ' +
      ' returning id, idchat, idpessoa, mensagem, datahora, editada;';

    qry.ParamByName('idchat').AsInteger := IdChat;
    qry.ParamByName('idpessoa').AsInteger := IdPessoa;
    qry.ParamByName('mensagem').AsString := Mensagem;
    qry.ParamByName('datahora').AsDateTime := Now;
    qry.ParamByName('editada').AsBoolean := False;

    qry.Open;

    Result := qry.ToJSONArrayString;

  finally
    qry.Free;
  end;
end;

function TDmDados.InserirPessoa(Nome, Usuario, Senha, Fone, Cpf,
  Email, DescricaoPerfil: String): String;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Nil);
  try
    qry.Connection := FDConnection1;

    qry.Sql.Clear;
    qry.Sql.add(
      'INSERT INTO PESSOA ( ' +
      '   nome, usuario, senha, fone, cpf, email, descricao_perfil ) ' +
      ' values (:nome, :usuario, :senha, :fone, :cpf, :email, :desc) ' +
      ' returning id, nome, usuario, senha, fone, cpf, email, descricao_perfil');

    qry.ParamByName('nome').AsString := Nome;
    qry.ParamByName('usuario').AsString := Usuario;
    qry.ParamByName('senha').AsString := Senha;
    qry.ParamByName('fone').AsString := Fone;
    qry.ParamByName('cpf').AsString := Cpf;
    qry.ParamByName('email').AsString := Email;
    qry.ParamByName('desc').AsString := DescricaoPerfil;

    qry.Open;

    Result := qry.ToJSONArrayString;

  finally
    qry.Free;
  end;
end;

end.
