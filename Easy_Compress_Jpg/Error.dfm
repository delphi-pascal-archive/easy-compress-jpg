object ErrorForm: TErrorForm
  Left = 0
  Top = 0
  Width = 400
  Height = 195
  ActiveControl = CloseBtn
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = 'Erreur : '
  Color = clBtnFace
  Constraints.MinHeight = 195
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -9
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    392
    169)
  PixelsPerInch = 96
  TextHeight = 11
  object ErrorTitleMsg: TLabel
    Left = 8
    Top = 2
    Width = 376
    Height = 36
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'ErrorTitleMsg'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object FilesConcernedMemo: TMemo
    Left = 8
    Top = 40
    Width = 369
    Height = 81
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'FilesConcernedMemo')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object CloseBtn: TBitBtn
    Left = 303
    Top = 128
    Width = 75
    Height = 25
    Cursor = crHandPoint
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'OK'
    TabOrder = 1
    OnClick = CloseBtnClick
  end
  object ClipboardCopyBtn: TBitBtn
    Left = 8
    Top = 128
    Width = 225
    Height = 25
    Cursor = crHandPoint
    Anchors = [akLeft, akBottom]
    Caption = 'Copier le rapport d'#39'erreurs dans le presse-papiers'
    TabOrder = 2
    OnClick = ClipboardCopyBtnClick
    Glyph.Data = {
      16020000424D160200000000000036000000280000000A0000000F0000000100
      180000000000E001000000000000000000000000000000000000FFFFFFFFFFFF
      CAB2A3AC541F9F3A019C3701B77C5ADBDFDEFFFFFFFFFFFF0000FFFFFFCDBDB2
      A33E01B3714BD2C9C1CDBDB2A14210AE653CFFFFFFFFFFFF0000FFFFFFBE8B6A
      B55001BD8969A64101B87D5BCCB3A49F3A01DFE1DFFFFFFF0000FFFFFFA33E01
      BE9177A64101B9856A9C3701E2ECEDA64101D0BFB3FFFFFF0000FFFFFFA33E01
      BE9177A64101D0C0B3993401E2ECEDA64101D0BFB3FFFFFF0000FFFFFFA33E01
      BE9177A64101D0C0B3993401E2ECEDA64101D0BFB3FFFFFF0000FFFFFFA33E01
      BE9177A94401D0C0B3993401E2ECEDA64101D0BFB3FFFFFF0000FFFFFFA33E01
      C09278AC4701D2C0B4993401E4EEEFA64101D2C0B4FFFFFF0000FFFFFFA33E01
      C09278AC4701D2C0B4993401E4EEEFA64101D2C0B4FFFFFF0000FFFFFFA33E01
      C09278AE4A01D2C0B4993401E4EEEFA64101D2C0B4FFFFFF0000FFFFFFC18E6F
      CDB4A5AF4A01D2C0B4993401E4EEEFA64101D2C0B4FFFFFF0000FFFFFFFFFFFF
      FFFFFFB24D01D2C0B4D2C0B4E4EEEFA64101D2C0B4FFFFFF0000FFFFFFFFFFFF
      FFFFFFB34E01C8A896E4EEEFD2C0B4A33E01D7CCC3FFFFFF0000FFFFFFFFFFFF
      FFFFFFBA703DB55001BD753DAB4D10A9521FFFFFFFFFFFFF0000FFFFFFFFFFFF
      FFFFFFDDD9D3BD7A4CB55001B8754CD8CEC4FFFFFFFFFFFF0000}
  end
end
