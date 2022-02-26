unit countform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Timer1: TTimer;
    shutdown: TCheckBox;
    Periodic: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    period:TTime;
    procedure StartCountdown;
  end;

var
  Form1: TForm1;
  TargetTime:TTime;
  CriticalTime:TTime;
  lastFlashed:integer;

implementation

{$R *.dfm}

uses MMSystem;

procedure TForm1.Button1Click(Sender: TObject);
begin
  StartCountdown;
end;

function WindowsExit(RebootParam: Longword): Boolean;
var
   TTokenHd: THandle;
   TTokenPvg: TTokenPrivileges;
   cbtpPrevious: DWORD;
   rTTokenPvg: TTokenPrivileges;
   pcbtpPreviousRequired: DWORD;
   tpResult: Boolean;
const
   SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
   if Win32Platform = VER_PLATFORM_WIN32_NT then
   begin
     tpResult := OpenProcessToken(GetCurrentProcess(),
       TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
       TTokenHd) ;
     if tpResult then
     begin
       tpResult := LookupPrivilegeValue(nil,
                                        SE_SHUTDOWN_NAME,
                                        TTokenPvg.Privileges[0].Luid) ;
       TTokenPvg.PrivilegeCount := 1;
       TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
       cbtpPrevious := SizeOf(rTTokenPvg) ;
       pcbtpPreviousRequired := 0;
       if tpResult then
         Windows.AdjustTokenPrivileges(TTokenHd,
                                       False,
                                       TTokenPvg,
                                       cbtpPrevious,
                                       rTTokenPvg,
                                       pcbtpPreviousRequired) ;
     end;
   end;
   Result := ExitWindowsEx(RebootParam, 0) ;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
  var TimeLeft:TTime;
  secs:integer;
begin
  TimeLeft:=TargetTime-Now;
  if TimeLeft < 0 then begin
    Timer1.Enabled:=false;
    Caption:=TimeToStr(0);
    Application.Title:=Caption;
    //MessageBeep(MB_ICONEXCLAMATION);
    sndPlaySound('C:\Windows\Media\Windows Background.wav',SND_NODEFAULT Or SND_ASYNC);
    if shutdown.Checked then WindowsExit(EWX_SHUTDOWN);
    if Periodic.checked then begin
      TargetTime:=TargetTime+period;
      Timer1.Enabled:=true;
    end;
    exit;
  end;
  Caption:=TimeToStr(TimeLeft);
  if TimeLeft<CriticalTime then begin
    secs:=StrToInt(FormatDateTime('s',TimeLeft));
    if secs<>lastFlashed then begin
      FlashWindow(Application.Handle,true);
      lastFlashed:=secs;
    end;
  end;
  Application.Title:=Caption;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CriticalTime:=StrToTime('0:00:09');
  if (ParamCount>=1) and (ParamStr(1)='-s') then shutdown.Checked:=true;
  if ParamCount>=2 then begin
    Edit1.Text:=ParamStr(2);
    StartCountdown;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Timer1.Enabled:=false;
end;

procedure TForm1.StartCountdown;
begin
  period:=StrToTime(Edit1.Text);
  TargetTime:=Now+period;
  Timer1.Enabled:=true;
end;

end.
