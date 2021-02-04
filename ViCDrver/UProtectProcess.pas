unit UProtectProcess;

interface

uses nt_status, ntoskrnl, fcall, macros, native, NtoskrnlCustom, KernelUtils, VarConstGlobal, InlineHook;

type TZwOpenProcess = Function(ProcessHandle: PHandle; DesiredAccess: TAccessMask; ObjectAttributes: PObjectAttributes; ClientId: PClientId): NTSTATUS; stdcall;

var PZwOpenProcess: TZwOpenProcess;

Procedure VIC_HookZwOpenProcess;
Procedure VIC_UnHookZwOpenProcess;

implementation

Function ZwOpenProcessNew(ProcessHandle: PHandle; DesiredAccess: TAccessMask; ObjectAttributes: PObjectAttributes; ClientId: PClientId): NTSTATUS; stdcall;
const STATUS_ACCESS_DENIED = $C0000022;
begin
  if (ClientId.UniqueProcess = PID) then
  begin
    Result:= STATUS_ACCESS_DENIED;
    DbgPrint('VIC: - PID[%d] Access is denied' + CRLF,PID);
  end
  else Result:= PZwOpenProcess(ProcessHandle, DesiredAccess, ObjectAttributes, ClientId);
end;

Procedure VIC_HookZwOpenProcess;
begin
  if (IsOPHooked = False) then
  begin
    DisableProtection;
    ILHook(GetImportFunAddr(@ZwOpenProcess),@ZwOpenProcessNew,@PZwOpenProcess);
    (*
    PZwOpenProcess:= TZwOpenProcess(
      InterlockedExchange(
        SystemServiceName(GetImportFunAddr(@ZwOpenProcess)),
        DWord(@ZwOpenProcessNew)));
    *)
    EnableProtection;
    IsOPHooked:= True;
  end;
end;

Procedure VIC_UnHookZwOpenProcess;
begin
  if (IsOPHooked = True) then         
  begin
    DisableProtection;
    ILUnHook(@PZwOpenProcess);
    (*
    PZwOpenProcess:= TZwOpenProcess(
      InterlockedExchange(
        SystemServiceName(GetImportFunAddr(@ZwOpenProcess)),
        DWord(@PZwOpenProcess)));
    *)
    EnableProtection;
    IsOPHooked:= False;
  end;
end;

end.
