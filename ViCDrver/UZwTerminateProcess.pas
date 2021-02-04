unit UZwTerminateProcess;

interface

uses
  Windows, nt_status, ntoskrnl, fcall, macros, native, NtoskrnlCustom,
  KernelUtils, UZwOpenProcess, VarConstGlobal;

Procedure VIC_ZwTerminateProcess(PID: DWord); stdcall;

implementation

Procedure VIC_ZwTerminateProcess(PID: DWord); stdcall;
var hProcess: THandle;
begin
  hProcess:= VIC_ZwOpenProcess(PID);
  if (ZwTerminateProcess(hProcess,0) <> 0) then DbgPrint('VIC: - ZwTerminateProcess: -> Failed' + CRLF)
  else ZwClose(DWord(hProcess));
end;

end.
