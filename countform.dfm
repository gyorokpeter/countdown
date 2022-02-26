object Form1: TForm1
  Left = 192
  Top = 124
  Width = 329
  Height = 139
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 18
    Width = 26
    Height = 13
    Caption = 'Time:'
  end
  object Button1: TButton
    Left = 152
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 232
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 50
    Top = 14
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '0:18:30'
  end
  object shutdown: TCheckBox
    Left = 16
    Top = 48
    Width = 97
    Height = 17
    Caption = 'Shutdown'
    TabOrder = 3
  end
  object Periodic: TCheckBox
    Left = 16
    Top = 69
    Width = 97
    Height = 17
    Caption = 'Periodic'
    TabOrder = 4
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 280
    Top = 8
  end
end
