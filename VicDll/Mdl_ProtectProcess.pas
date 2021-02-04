unit Mdl_ProtectProcess;

interface

uses Windows, WinSvc, Mdl_ConstVariable, Mdl_SomeFunction;

Procedure VIC_Protect(PID: DWord); stdcall;
Procedure VIC_UnProtect(PID: DWord); stdcall;

implementation

uses mrVic;

Procedure VIC_Protect(PID: DWord); stdcall;
begin
  hDev:= CreateFileA(
    StrToPac('\\.\' + Copy(nFile,1,Length(nFile) - 4)),
    GENERIC_READ + GENERIC_WRITE,
    0,NIL,OPEN_EXISTING,0,0);
  if (hDev = INVALID_HANDLE_VALUE) then Exit;
  try
    inBuf:= PID;
    IoSucc:= DeviceIoControl(
      hDev,
      VICCTL_PRT,
      @inBuf,
      SizeOf(inBuf),
      @outBuf,
      SizeOf(outBuf),
      dwReturned,
      NIL);
    CloseHandle(hDev);
  except
    CloseHandle(hDev);
  end;
end;

Procedure VIC_UnProtect(PID: DWord); stdcall;
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
    inBuf:= PID;
    IoSucc:= DeviceIoControl(
      hDev,
      VICCTL_UNPRT,
      @inBuf,
      SizeOf(inBuf),
      @outBuf,
      SizeOf(outBuf),
      dwReturned,
      NIL);
    CloseHandle(hDev);
  except
    CloseHandle(hDev);
  end;
end;

end.
