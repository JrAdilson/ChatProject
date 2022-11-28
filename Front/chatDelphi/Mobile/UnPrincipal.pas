unit UnPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.TextLayout, RESTRequest4D, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Json;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    Layout1: TLayout;
    Label1: TLabel;
    imgVoltar: TImage;
    Layout2: TLayout;
    Circle1: TCircle;
    Label2: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    edtTexto: TEdit;
    btnEnviar: TSpeedButton;
    Image1: TImage;
    lvChat: TListView;
    lvChats: TListView;
    TabItem4: TTabItem;
    Layout6: TLayout;
    Label3: TLabel;
    edtUsuario: TEdit;
    Label4: TLabel;
    edtSenha: TEdit;
    SpeedButton1: TSpeedButton;
    imgFundo: TImage;
    TabMensagem: TFDMemTable;
    StyleBook1: TStyleBook;
    lblSenhaInvalido: TLabel;
    procedure lvChatUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure FormCreate(Sender: TObject);
    Function BuscarIdUltimaMsgEnviada: Integer;
    procedure FormShow(Sender: TObject);
    procedure lvChatsItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure SpeedButton1Click(Sender: TObject);
    procedure imgVoltarClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);

  private
    IdUltimaMsgCarregada: Integer;

    procedure AddMessage(id_msg: Integer; texto, dt: string;
      ind_proprio: boolean; nome_usuario: String);
    Procedure AddChat(id_chat: Integer; nome, descricao: string);
    procedure LayoutLv(item: TListViewItem);
    procedure LayoutLvProprio(item: TListViewItem);
    function GetTextHeight(const D: TListItemText; const Width: single;
      const Text: string): Integer;
    procedure ListarMensagens(AIdChat: Integer;
      AidUltimaMsgCarregada: Integer);
    procedure BuscandoNovasMensagens;
    procedure ListarChats(AidUsuario: Integer);
  public
    { Public declarations }
  end;

Const
  CCaminhoServer = 'http://localhost:9000';

var
  Form1: TForm1;

  idChatExibido: Integer;
  idUsuarioLogado: Integer;

implementation

{$R *.fmx}


procedure TForm1.AddChat(id_chat: Integer; nome, descricao: string);
var
  item: TListViewItem;
  CampoText: TListItemText;
  img: TListItemImage;

begin
  item := lvChats.Items.Add;

  item.Height := 55;
  item.Tag := id_chat;

  CampoText := TListItemText(item.Objects.FindDrawable('txtMsg'));

  CampoText.Text := nome;
  CampoText.Height := GetTextHeight(CampoText, CampoText.Width, CampoText.Text);
  CampoText.Width := lvChats.Width;

  img := TListItemImage(item.Objects.FindDrawable('imgFundo'));
  img.Bitmap := imgFundo.Bitmap;
  img.Width := lvChat.Width + 10;
  img.PlaceOffset.X := 0;
  img.PlaceOffset.Y := 0;
  img.Height := CampoText.Height;
  img.Opacity := 0.8;
end;

procedure TForm1.AddMessage(id_msg: Integer; texto, dt: string;
  ind_proprio: boolean; nome_usuario: String);
var
  item: TListViewItem;
begin
  item := lvChat.Items.Add;

  item.Height := 100;
  item.Tag := id_msg;

  if ind_proprio then
    item.TagString := 'S'
  else
    item.TagString := 'N';

  // Fundo...
  TListItemImage(item.Objects.FindDrawable('imgFundo')).Bitmap :=
    imgFundo.Bitmap;

  // Texto...
  TListItemText(item.Objects.FindDrawable('txtMsg')).Text := texto;

  // Data...
  TListItemText(item.Objects.FindDrawable('txtData')).Text := dt;

  // Nome/apelido...
  TListItemText(item.Objects.FindDrawable('txtNomeUsuario')).Text :=
    nome_usuario + ':';

  if ind_proprio then
    LayoutLvProprio(item)
  else
    LayoutLv(item);

  if lvChat.GetItemRect(lvChat.Items.Count - 1).Top <= lvChat.Height then
    lvChat.ScrollTo(lvChat.Items.Count - 1);

end;

procedure TForm1.btnEnviarClick(Sender: TObject);
var
  resp: IResponse;
  conteudo: String;
begin
  if Trim(edtTexto.Text) = '' then
    exit;

  conteudo :=
    '  {' +
    '    "idchat": ' + IntToStr(idChatExibido) + ',' +
    '    "idpessoa": ' + IntToStr(idUsuarioLogado) + ', ' +
    '    "mensagem": "' + edtTexto.Text + '"' +
    '}';

  edtTexto.Text := '';

  resp := TRequest.New.BaseURL(CCaminhoServer)
    .Resource('mensagens-chat')
    .AddBody(conteudo)
    .Accept('application/json')
    .Post;

  if resp.StatusCode <> 201 then
    ShowMessage('Erro ao enviar mensagem!')

end;

function TForm1.BuscarIdUltimaMsgEnviada: Integer;
var
  resp: IResponse;
begin
  Try
    TabMensagem.Close;

    resp := TRequest.New.BaseURL(CCaminhoServer)
      .Resource('ultima-msg')
      .Accept('application/json')
      .DataSetAdapter(TabMensagem)
      .Get;

    If Not TabMensagem.IsEmpty Then
      Result := TabMensagem.FieldByName('id').AsInteger;

  Except
    Result := 0;
  End;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IdUltimaMsgCarregada := 0;

  TabControl1.TabIndex := 0;
  TabControl1.TabPosition := TTabPosition.None;
  lblSenhaInvalido.Visible := False;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  tthread.CreateAnonymousThread(BuscandoNovasMensagens).Start;
end;

function TForm1.GetTextHeight(const D: TListItemText; const Width: single;
  const Text: string): Integer;
var
  Layout: TTextLayout;
begin
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := D.WordWrap;
      Layout.Trimming := D.Trimming;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;

    Result := Round(Layout.Height);

    Layout.Text := 'm';
    Result := Result + Round(Layout.Height);
  finally
    Layout.Free;
  end;
end;

procedure TForm1.imgVoltarClick(Sender: TObject);
begin
  TabControl1.TabIndex := 0;
end;

procedure TForm1.LayoutLv(item: TListViewItem);
var
  img: TListItemImage;
  txt: TListItemText;
begin

  // Nome...
  txt := TListItemText(item.Objects.FindDrawable('txtNomeUsuario'));
  txt.PlaceOffset.X := 10;
  txt.PlaceOffset.Y := 10;

  // Posiciona o texto...
  txt := TListItemText(item.Objects.FindDrawable('txtMsg'));
  txt.Width := lvChat.Width / 2 - 16;
  txt.PlaceOffset.X := 10;
  txt.PlaceOffset.Y := 30;
  txt.Height := GetTextHeight(txt, txt.Width, txt.Text);
  txt.TextColor := $FF000000;

  // Balao msg...
  img := TListItemImage(item.Objects.FindDrawable('imgFundo'));
  img.Width := lvChat.Width / 2;
  img.PlaceOffset.X := 10;
  img.PlaceOffset.Y := 30;
  img.Height := txt.Height;
  img.Opacity := 0.1;

  if txt.Height < 40 then
    img.Width := Trunc(txt.Text.Length * 8);

  // Data...
  txt := TListItemText(item.Objects.FindDrawable('txtData'));
  txt.PlaceOffset.X := img.PlaceOffset.X + img.Width - 100;
  txt.PlaceOffset.Y := img.PlaceOffset.Y + img.Height + 2;

  // Altura do item da Lv...
  item.Height := Trunc(img.PlaceOffset.Y + img.Height + 25);
end;

procedure TForm1.LayoutLvProprio(item: TListViewItem);
var
  img: TListItemImage;
  txt: TListItemText;
begin
  // Nome...
  txt := TListItemText(item.Objects.FindDrawable('txtNomeUsuario'));
  txt.Visible := False;

  // Posiciona o texto...
  txt := TListItemText(item.Objects.FindDrawable('txtMsg'));
  txt.Width := lvChat.Width / 2 - 16;
  txt.PlaceOffset.Y := 10;
  txt.Height := GetTextHeight(txt, txt.Width, txt.Text);
  txt.TextColor := $FFFFFFFF;

  // Balao msg...
  img := TListItemImage(item.Objects.FindDrawable('imgFundo'));

  if txt.Height < 40 then // Msg com apenas uma linha...
    img.Width := Trunc(txt.Text.Length * 8)
  else
    img.Width := lvChat.Width / 2;

  img.PlaceOffset.X := lvChat.Width - 10 - img.Width;
  img.PlaceOffset.Y := 10;
  img.Height := txt.Height;
  img.Opacity := 1;

  txt.PlaceOffset.X := lvChat.Width - img.Width;

  // Data...
  txt := TListItemText(item.Objects.FindDrawable('txtData'));
  txt.PlaceOffset.X := img.PlaceOffset.X + img.Width - 100;
  txt.PlaceOffset.Y := img.PlaceOffset.Y + img.Height + 2;

  // Altura do item da Lv...
  item.Height := Trunc(img.PlaceOffset.Y + img.Height + 30);
end;

procedure TForm1.ListarChats(AidUsuario: Integer);
var
  resp: IResponse;
begin
  lvChats.Items.Clear;

  TabMensagem.Close;
  TabMensagem.FieldDefs.Clear;

  resp := TRequest.New.BaseURL(CCaminhoServer)
    .Resource('chats')
    .AddParam('idusuario', IntToStr(AidUsuario))
    .Accept('application/json')
    .DataSetAdapter(TabMensagem)
    .Get;

  if resp.StatusCode <> 200 then
    ShowMessage('Erro ao listar mensagens')
  else
  begin
    while NOT TabMensagem.Eof do
    begin
      AddChat(
        TabMensagem.FieldByName('id').AsInteger,
        TabMensagem.FieldByName('nome').AsString,
        TabMensagem.FieldByName('descricao').AsString);

      TabMensagem.Next;
    end;
  end;

  if not TabMensagem.IsEmpty then
  Begin
    TabMensagem.First;
    ListarMensagens(TabMensagem.FieldByName('id').AsInteger, 0)
  End;
end;

procedure TForm1.ListarMensagens(AIdChat: Integer;
  AidUltimaMsgCarregada: Integer);
var
  resp: IResponse;
begin
  if AidUltimaMsgCarregada = 0 then
    lvChat.Items.Clear;

  TabMensagem.Close;
  TabMensagem.FieldDefs.Clear;

  resp := TRequest.New.BaseURL(CCaminhoServer)
    .Resource('mensagens-chat')
    .AddParam('idchat', IntToStr(AIdChat))
    .AddParam('idusuariologado', IntToStr(idUsuarioLogado))
    .AddParam('idmsg', IntToStr(AidUltimaMsgCarregada))
    .Accept('application/json')
    .AcceptEncoding('UTF-8')
    .DataSetAdapter(TabMensagem)
    .Get;

  if resp.StatusCode <> 200 then
    ShowMessage('Erro ao listar mensagens')
  else
  begin
    while NOT TabMensagem.Eof do
    begin
      AddMessage(
        TabMensagem.FieldByName('id').AsInteger,
        TabMensagem.FieldByName('mensagem').AsString,
        formatDateTime('dd/mm/yyy hh:nn:ss',
        TabMensagem.FieldByName('datahora').AsFloat),
        TabMensagem.FieldByName('proprioautor').AsString = 'sim',
        TabMensagem.FieldByName('nome').AsString);

      TabMensagem.Next;
    end;
  end;

end;

procedure TForm1.lvChatsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  idChatExibido := AItem.Tag;
  ListarMensagens(idChatExibido, 0);
end;

procedure TForm1.lvChatUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if AItem.TagString = 'S' then
    LayoutLvProprio(AItem)
  Else
    LayoutLv(AItem);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  response: IResponse;
  body: TJSONValue;
begin
  // realizar GET do login

  lblSenhaInvalido.Visible := False;

  response :=
    TRequest.New.BaseURL(CCaminhoServer)
    .Resource('login')
    .AddParam('usuario', edtUsuario.Text)
    .AddParam('senha', edtSenha.Text)
    .Accept('application/json')
    .Get;

  if response.StatusCode = 200 then
  begin
    body := TJSONObject.ParseJSONValue(response.Content);
    idUsuarioLogado :=
      body.GetValue<TJSONValue>('pessoa').GetValue<Integer>('id');

    ListarChats(idUsuarioLogado);
    TabControl1.TabIndex := 1;

  end
  Else
    lblSenhaInvalido.Visible := True;

end;

Procedure TForm1.BuscandoNovasMensagens();
var
  ultimoIdServer: Integer;
  resp: IResponse;
  MemTable: TFDMemTable;
begin
  MemTable := TFDMemTable.Create(Self);

  while True do
  begin
    sleep(1000);

    ultimoIdServer := 0;
    Try
      MemTable.Close;
      MemTable.FieldDefs.Clear;

      resp := TRequest.New.BaseURL(CCaminhoServer)
        .Resource('ultima-msg')
        .Accept('application/json')
        .DataSetAdapter(MemTable)
        .Get;

      If Not MemTable.IsEmpty Then
        ultimoIdServer := MemTable.FieldByName('id').AsInteger;

    Except
    End;

    if ultimoIdServer > IdUltimaMsgCarregada then
    begin
      tthread.Synchronize(tthread.Current,
        procedure
        begin
          ListarMensagens(idChatExibido, IdUltimaMsgCarregada);
          IdUltimaMsgCarregada := ultimoIdServer;
        end);
    end;
  end
end;

end.
