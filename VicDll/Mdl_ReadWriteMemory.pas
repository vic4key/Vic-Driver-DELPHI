unit Mdl_ReadWriteMemory;

interface

uses Windows, Mdl_ConstVariable, Mdl_SomeFunction;

type
	LDEV_MEMORY_STRUCT = record
		dwPID: DWord;
		dwBaseAddress: DWord;
		lpBuffer: Pointer;
		nSize: DWord;
	end;

Procedure VIC_ReadMemory(_PID: DWord; _lpAddress: DWord; _lpBuffer: Pointer; _dwSize: DWord); stdcall;

implementation

uses mrVic;

Procedure VIC_ReadMemory(_PID: DWord; _lpAddress: DWord; _lpBuffer: Pointer; _dwSize: DWord); stdcall;
var InputMemStruct: LDEV_MEMORY_STRUCT;
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
    ZeroMemory(@InputMemStruct,SizeOf(InputMemStruct));
    with InputMemStruct do
    begin
      dwPID:= _PID;
      dwBaseAddress:= _lpAddress;
      lpBuffer:= _lpBuffer;
      nSize:= _dwSize;
    end;
    ioSucc:= DeviceIoControl(
      hDev,
      VICCTL_RPM,
      @InputMemStruct,
      SizeOf(InputMemStruct),
      @InputMemStruct,
      SizeOf(InputMemStruct),
      dwReturned,
      NIL);
    CloseHandle(hDev);
  except
    CloseHandle(hDev);
  end;
end;

end.
