unit Mdl_RWProcess;

interface

uses Windows, SysUtils, WinSvc, Mdl_ConstVariable, Mdl_SomeFunction;

type
  TStructRPM = packed record
    PID: DWord;
    Address: DWord;
    Size: DWord;
    Buffer: Pointer;
  end;

Procedure VIC_RPMemory(dwPID, lpAddress, dwSize: DWord; var lpBuffer: Pointer); stdcall;

implementation

uses mrVic;

Procedure VIC_RPMemory(dwPID, lpAddress, dwSize: DWord; var lpBuffer: Pointer); stdcall;
var ioBuf: TStructRPM;
begin
  hDev:= CreateFileA(
    StrToPChr('\\.\' + Copy(nFile,1,Length(nFile) - 4)),
    GENERIC_READ + GENERIC_WRITE,
    0,NIL,
    OPEN_EXISTING,
    0,0);
  if (hDev = INVALID_HANDLE_VALUE) then Exit;
  try
    try
      ZeroMemory(@ioBuf,SizeOf(ioBuf));
      with ioBuf do
      begin
        PID:= dwPID;
        Address:= lpAddress;
        Size:= dwSize;
        Buffer:= lpBuffer;
      end;
    except
      VICBox('Exception...');
    end;
    IoSucc:= DeviceIoControl(hDev,VIC_RPM,@ioBuf,SizeOf(ioBuf),@ioBuf,SizeOf(ioBuf),dwReturned,NIL);
    lpBuffer:= ioBuf.Buffer;
    CloseHandle(hDev);
  finally
    CloseHandle(hDev);
  end;
end;

end.
