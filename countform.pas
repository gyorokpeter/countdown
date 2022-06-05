unit countform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ActiveX;

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
    procedure AddCircle(color: TColor);
    procedure RemoveCircle;
    { Private declarations }
  public
    { Public declarations }
    period:TTime;
    procedure StartCountdown;
  end;

  ITaskbarList = interface(IUnknown)
    ['{56FDF342-FD6D-11D0-958A-006097C9A090}']
    function HrInit: HRESULT; stdcall;
    function AddTab(hwnd: HWND): HRESULT; stdcall;
    function DeleteTab(hwnd: HWND): HRESULT; stdcall;
    function ActivateTab(hwnd: HWND): HRESULT; stdcall;
    function SetActiveAlt(hwnd: HWND): HRESULT; stdcall;
  end;

  ITaskbarList2 = interface(ITaskbarList)
    ['{602D4995-B13A-429B-A66E-1935E44F4317}']
    function MarkFullscreenWindow(hwnd: HWND;
      fFullscreen: BOOL): HRESULT; stdcall;
  end;

  THUMBBUTTON = record
    dwMask: DWORD;
    iId: UINT;
    iBitmap: UINT;
    hIcon: HICON;
    szTip: packed array[0..259] of WCHAR;
    dwFlags: DWORD;
  end;
  TThumbButton = THUMBBUTTON;
  PThumbButton = ^TThumbButton;

  ITaskbarList3 = interface(ITaskbarList2)
    ['{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}']
    function SetProgressValue(hwnd: HWND; ullCompleted: UInt64;
      ullTotal: UInt64): HRESULT; stdcall;
    function SetProgressState(hwnd: HWND;
      tbpFlags: Integer): HRESULT; stdcall;
    function RegisterTab(hwndTab: HWND; hwndMDI: HWND): HRESULT; stdcall;
    function UnregisterTab(hwndTab: HWND): HRESULT; stdcall;
    function SetTabOrder(hwndTab: HWND;
      hwndInsertBefore: HWND): HRESULT; stdcall;
    function SetTabActive(hwndTab: HWND; hwndMDI: HWND;
      tbatFlags: Integer): HRESULT; stdcall;
    function ThumbBarAddButtons(hwnd: HWND; cButtons: UINT;
      pButton: PThumbButton): HRESULT; stdcall;
    function ThumbBarUpdateButtons(hwnd: HWND; cButtons: UINT;
      pButton: PThumbButton): HRESULT; stdcall;
    function ThumbBarSetImageList(hwnd: HWND;
      himl: Pointer): HRESULT; stdcall;
    function SetOverlayIcon(hwnd: HWND; hIcon: HICON;
      pszDescription: LPCWSTR): HRESULT; stdcall;
    function SetThumbnailTooltip(hwnd: HWND;
      pszTip: LPCWSTR): HRESULT; stdcall;
    function SetThumbnailClip(hwnd: HWND;
      var prcClip: TRect): HRESULT; stdcall;
  end;

var
  Form1: TForm1;
  TargetTime:TTime;
  CriticalTime:TTime;
  lastFlashed:integer;
  TBL: ITaskbarList3;

const
  CLSID_TaskbarList: TGUID = '{56FDF344-FD6D-11d0-958A-006097C9A090}';
  TBPF_NOPROGRESS    = 0;
  TBPF_INDETERMINATE = $1;
  TBPF_NORMAL        = $2;
  TBPF_ERROR         = $4;
  TBPF_PAUSED        = $8;

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
    if 1=(secs mod 2) then AddCircle(clRed) else AddCircle(clWhite);
    if secs<>lastFlashed then begin
      sndPlaySound('C:\Windows\Media\ding.wav',SND_NODEFAULT Or SND_ASYNC);
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
  RemoveCircle;
end;

procedure TForm1.AddCircle(color:TColor);
  var IconInfo: TIconInfo;
  Bitmap, BitmapMask: TBitmap;
  icon: HIcon;
  x, y: Integer;
begin
  if TBL=nil then exit;
  Bitmap:= TBitmap.Create;
  Bitmap.Width:= 32;
  Bitmap.Height:= 32;

  Bitmap.Canvas.Brush.Color:= clFuchsia;
  Bitmap.Canvas.FloodFill(0, 0, clWhite, fsSurface);
  Bitmap.Canvas.Brush.Color:= color;
  Bitmap.Canvas.Ellipse(4, 4, 28, 28);
  BitmapMask:= TBitmap.Create;
  BitmapMask.Assign(Bitmap);
  for y:= 0 to 31 do
    for x:= 0 to 31 do
      if Bitmap.Canvas.Pixels[x, y] = clFuchsia then
        Bitmap.Canvas.Pixels[x, y]:= clBlack;

  IconInfo.fIcon:= True;
  IconInfo.hbmMask:= BitmapMask.MaskHandle;
  IconInfo.hbmColor:= Bitmap.Handle;
  icon := CreateIconIndirect(IconInfo);
  //Application.Icon.Handle := icon;
  TBL.SetOverlayIcon(Application.Handle,icon,'Foo');
  BitmapMask.Free;
  Bitmap.Free;
end;

procedure TForm1.RemoveCircle;
begin
  TBL.SetOverlayIcon(Application.Handle,0,nil);
end;

begin
  CoInitialize(nil);
  CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC, ITaskbarList3, TBL);
end.
