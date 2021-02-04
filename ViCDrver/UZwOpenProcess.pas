unit UZwOpenProcess;

interface

uses nt_status, ntoskrnl, fcall, macros, native, NtoskrnlCustom, KernelUtils, VarConstGlobal;

Function VIC_ZwOpenProcess(PID: DWord): THandle; stdcall;

implementation

Function VIC_ZwOpenProcess(PID: DWord): THandle; stdcall;
var
  ProcessHandle: THandle;
  ClientId: CLIENT_ID;
  ObjectAttributes: OBJECT_ATTRIBUTES;
const PROCESS_ALL_ACCESS: DWord = $001F0FFF;
begin
  Result:= 0;
  with ObjectAttributes do
  begin
    Length:= SizeOf(OBJECT_ATTRIBUTES);
    RootDirectory:= 0;
    ObjectName:= NIL;
    Attributes:= 0;
    SecurityDescriptor:= NIL;
    SecurityQualityOfService:= NIL;
  end;
  with ClientId do
  begin
    UniqueProcess:= PID;
    UniqueThread:= 0;
  end;
  if (ZwOpenProcess(@ProcessHandle,PROCESS_ALL_ACCESS,@ObjectAttributes,@ClientId) <> 0) then
    DbgPrint('VIC: - ZwOpenProcess: -> Failed' + CRLF)
  else Result:= ProcessHandle;
end;

end.
