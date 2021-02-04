unit Mdl_OPProcess;

interface

uses Windows, Mdl_ConstVariable, Mdl_SomeFunction;

Procedure VIC_ZwTerminateProcess(PID: DWord); stdcall;
Procedure VIC_ZwOpenProcess(PID: DWord); stdcall;

implementation

uses mrVic;

Procedure VIC_ZwTerminateProcess(PID: DWord); stdcall;
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
    ioSucc:= DeviceIoControl(
      hDev,
      VICCTL_TP,
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

Procedure VIC_ZwOpenProcess(PID: DWord); stdcall;
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
    ioSucc:= DeviceIoControl(
      hDev,
      VICCTL_OP,
      @inBuf,
      SizeOf(inBuf),
      @outBuf,
      SizeOf(outBuf),
      dwReturned,
      NIL);
    VICBox('PID[%d] -> Handle = 0x%0.8x',[PID,outBuf]);
    CloseHandle(hDev);
  except
    CloseHandle(hDev);
  end;
end;

end.
