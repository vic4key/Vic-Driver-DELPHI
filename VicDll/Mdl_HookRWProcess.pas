unit Mdl_HookRWProcess;

interface

uses Windows, SysUtils, WinSvc, Mdl_SomeFunction, Mdl_ConstVariable;

type
  TIndexRW = record
    _IndexRpm: DWord;
    _IndexWpm: DWord;
  end;

var IndexRW: TIndexRW;

Procedure VIC_HookRW(lpIndexRpm, lpIndexWpm: DWord); stdcall;
Procedure VIC_UnHookRW(lpIndexRpm, lpIndexWpm: DWord); stdcall;

implementation

uses mrVic;

Procedure VIC_HookRW(lpIndexRpm, lpIndexWpm: DWord); stdcall;
var ioBuf: TIndexRW;
begin
  hDev:= CreateFileA(
    StrToPac('\\.\' + Copy(nFile,1,Length(nFile) - 4)),
    GENERIC_READ + GENERIC_WRITE,
    0,
    NIL,
    OPEN_EXISTING,
    0,
    0);
  if (hDev = INVALID_HANDLE_VALUE) then Exit;
  try
    ZeroMemory(@ioBuf,SizeOf(ioBuf));
    ioBuf._IndexRpm:= lpIndexRpm;
    ioBuf._IndexWpm:= lpIndexWpm;
    IoSucc:= DeviceIoControl(
      hDev,
      VICCTL_HOOKRW,
      @ioBuf,
      SizeOf(ioBuf),
      @ioBuf,
      SizeOf(ioBuf),
      dwReturned,
      NIL);
    CloseHandle(hDev);
  except
    CloseHandle(hDev);
  end;
end;

Procedure VIC_UnHookRW(lpIndexRpm, lpIndexWpm: DWord); stdcall;
var _ioBuf: TIndexRW;
begin
  hDev:= CreateFileA(
    StrToPac('\\.\' + Copy(nFile,1,Length(nFile) - 4)),
    GENERIC_READ + GENERIC_WRITE,
    0,
    NIL,
    OPEN_EXISTING,
    0,
    0);
  if (hDev = INVALID_HANDLE_VALUE) then Exit;
  try
    _ioBuf._IndexRpm:= lpIndexRpm;
    _ioBuf._IndexWpm:= lpIndexWpm;
    IoSucc:= DeviceIoControl(
      hDev,
      VICCTL_UNHOOKRW,
      @_ioBuf,
      SizeOf(_ioBuf),
      @_ioBuf,
      SizeOf(_ioBuf),
      dwReturned,
      NIL);
    CloseHandle(hDev);
  except
    CloseHandle(hDev);
  end;
end;

end.
