object DmDados: TDmDados
  OnCreate = DataModuleCreate
  Height = 314
  Width = 449
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=C:\Users\Junior\Desktop\TrabFinalDelphi\BD\DADOS.FDB'
      'Protocol=TCPIP'
      'Server=127.0.0.1'
      'Port=3050'
      'User_Name=sysdba'
      'Password=masterkey'
      'DriverID=FB')
    Connected = True
    LoginPrompt = False
    Left = 157
    Top = 72
  end
end
