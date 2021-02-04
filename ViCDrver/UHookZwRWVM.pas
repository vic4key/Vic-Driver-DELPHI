unit UHookZwRWVM;

interface

uses nt_status, ntoskrnl, fcall, macros, native, NtoskrnlCustom, KernelUtils, VarConstGlobal;

type
  TZwReadVirtualMemory = Function
  (
    hProcess: THandle;
    lpBaseAddress: Pointer;
    lpBuffer: Pointer;
    nSize: DWord;
    var dwNumberOfBytesRead: DWord
  ): NTSTATUS; stdcall;
  
  TZwWriteVirtualMemory = Function
  (
    hProcess: THandle;
    lpBaseAddress: Pointer;
    lpBuffer: Pointer;
    nSize: DWord;
    var dwNumberOfBytesRead: DWord
  ): NTSTATUS; stdcall;

var
  PZwReadVirtualMemory:  TZwReadVirtualMemory;
  PZwWriteVirtualMemory: TZwWriteVirtualMemory;

Procedure VIC_HookZwReadVirtualMemory;
Procedure VIC_UnHookZwReadVirtualMemory;
Procedure VIC_HookZwWriteVirtualMemory;
Procedure VIC_UnHookZwWriteVirtualMemory;

implementation

uses vicseh;
{$I vicdeh.pas}

Function VIC_ZwReadVirtualMemoryNew(
  hProcess: THandle;
  lpBaseAddress: Pointer;
  lpBuffer: Pointer;
  nSize: DWord;
  var dwNumberOfBytesRead: DWord): NTSTATUS; stdcall;
label _seh;
begin
  {$I vic.try}
  DbgPrint(
    'ViC - ZwReadVirtualMemory(Address: %0.8xh; Buffer: %0.8xh; Size: %0.8xh)' + CRLF,
    lpBaseAddress,
    lpBuffer,
    nSize);
  Result:= PZwReadVirtualMemory(hProcess,lpBaseAddress,lpBuffer,nSize,dwNumberOfBytesRead);
  {$I vic.except}
end;

Function VIC_ZwWriteVirtualMemoryNew(
  hProcess: THandle;
  lpBaseAddress: Pointer;
  lpBuffer: Pointer;
  nSize: DWord;
  var dwNumberOfBytesRead: DWord): NTSTATUS; stdcall;
label _seh;
begin
  {$I vic.try}
  Result:= PZwWriteVirtualMemory(hProcess,lpBaseAddress,lpBuffer,nSize,dwNumberOfBytesRead);
  DbgPrint(
    'ViC - ZwWriteVirtualMemory(Address: %0.8xh; Buffer: %0.8xh; Size: %0.8xh)' + CRLF,
    lpBaseAddress,
    lpBuffer,
    nSize);
  {$I vic.except}
end;

Procedure VIC_HookZwReadVirtualMemory;
label _seh;
begin
  if (IsRVMHooked = False) then
  begin
    {$I vic.try}
    DisableProtection;
    PZwReadVirtualMemory:= TZwReadVirtualMemory(
      InterlockedExchange(
        SystemServiceIndex(xvm.IndexRpm),
        DWord(@VIC_ZwReadVirtualMemoryNew)));
    EnableProtection;
    IsRVMHooked:= True;
    {$I vic.except}
  end;
end;

Procedure VIC_UnHookZwReadVirtualMemory;
label _seh;
begin
  if (IsRVMHooked = True) then
  begin
    {$I vic.try}
    DisableProtection;
    PZwReadVirtualMemory:= TZwReadVirtualMemory(
      InterlockedExchange(
        SystemServiceIndex(xvm.IndexRpm),
        DWord(@PZwReadVirtualMemory)));
    EnableProtection;
    IsRVMHooked:= False;
    {$I vic.except}
  end;
end;

Procedure VIC_HookZwWriteVirtualMemory;
label _seh;
begin
  {$I vic.try}
  if (IsWVMHooked = False) then
  begin
    DisableProtection;
    PZwWriteVirtualMemory:= TZwWriteVirtualMemory(
      InterlockedExchange(
        SystemServiceIndex(xvm.IndexWpm),
        DWord(@VIC_ZwWriteVirtualMemoryNew)));
    EnableProtection;
    IsWVMHooked:= True;
  end;
  {$I vic.except}
end;

Procedure VIC_UnHookZwWriteVirtualMemory;
label _seh;
begin
  if (IsWVMHooked = True) then
  begin
    {$I vic.try}
    DisableProtection;
    PZwWriteVirtualMemory:= TZwWriteVirtualMemory(
      InterlockedExchange(
        SystemServiceIndex(xvm.IndexWpm),
        DWord(@PZwWriteVirtualMemory)));
    EnableProtection;
    IsWVMHooked:= False;
    {$I vic.except}
  end;
end;

end.
