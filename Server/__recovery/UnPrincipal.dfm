object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  Caption = 'Servidor do Chat Horus'
  ClientHeight = 495
  ClientWidth = 603
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 19
  object mmoLog: TMemo
    Left = 0
    Top = 137
    Width = 603
    Height = 358
    Align = alClient
    ReadOnly = True
    TabOrder = 0
    ExplicitWidth = 599
    ExplicitHeight = 357
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 603
    Height = 137
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 599
    object Label1: TLabel
      Left = 91
      Top = 33
      Width = 35
      Height = 19
      Caption = 'Port:'
    end
    object Label2: TLabel
      Left = 80
      Top = 61
      Width = 49
      Height = 19
      Caption = 'Status:'
    end
    object lblStatus: TLabel
      Left = 135
      Top = 61
      Width = 63
      Height = 18
      Caption = 'Status...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 357
      Top = 31
      Width = 157
      Height = 19
      Caption = #218'ltimo ID mensagem:'
    end
    object btnLigar: TButton
      Left = 135
      Top = 87
      Width = 150
      Height = 25
      Caption = 'Ligar servidor'
      TabOrder = 0
      OnClick = btnLigarClick
    end
    object btnDesligar: TButton
      Left = 291
      Top = 87
      Width = 150
      Height = 25
      Caption = 'Desligar servidor'
      TabOrder = 1
      OnClick = btnDesligarClick
    end
    object edtPort: TEdit
      Left = 132
      Top = 28
      Width = 156
      Height = 27
      NumbersOnly = True
      TabOrder = 2
      Text = '9000'
    end
    object edtUltimoIdMsg: TEdit
      Left = 520
      Top = 28
      Width = 57
      Height = 27
      NumbersOnly = True
      TabOrder = 3
      Text = '0'
    end
  end
end
