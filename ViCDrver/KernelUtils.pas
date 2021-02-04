unit KernelUtils;

interface

uses nt_status, ntoskrnl;

type
  PServiceDescriptorTable = ^TServiceDescriptorEntry;
  TServiceDescriptorTable = TServiceDescriptorEntry;

  _SERVICE_DESCRIPTOR_TABLE_ = packed record
    ntoskrnlTable: PServiceDescriptorTable; // ntoskrnl.exe. (Native API)
    win32kTable: PServiceDescriptorTable;   // win32k.sys.   (Gdi/User Support)
    Table3: PServiceDescriptorTable;        // Not to used.
    Table4: PServiceDescriptorTable;        // Not to used.
  end;

Function KeAddSystemServiceTable(
  Base: PPointer;
  Count: Pointer;
  Limit: ULONG; Number:
  PAnsiChar; Index: ULONG): Boolean; stdcall; external NtKernel name '_KeAddSystemServiceTable';  
Procedure EnableProtection; assembler;
Procedure DisableProtection; assembler;  
Function GetImportFunctionAddress(lpImportAddr: Pointer): Pointer; stdcall;
Function SystemServiceName(aFunction: Pointer): Pointer; stdcall;
Function SystemServiceIndex(dwIndex: DWord): Pointer; stdcall;
Function SystemServiceShadowIndex(dwIndex: DWord): Pointer; stdcall;
Function FindSSDTShadow: DWord; stdcall;

var uCr0: DWord;

implementation

Procedure DisableProtection; assembler;
asm
  cli
  push eax
  mov eax,cr0
  mov [uCr0],eax
  and eax,not 10000h
  mov cr0,eax
  pop eax
end;

Procedure EnableProtection; assembler;
asm
  push eax
  mov eax,[uCr0]
  mov cr0,eax
  pop eax
  sti
end;

Function GetImportFunctionAddress(lpImportAddr: Pointer): Pointer; stdcall;
begin
  Result:= PPointer(PPointer(DWord(lpImportAddr) + 2)^)^;
end;

Function SystemServiceName(aFunction: Pointer): Pointer; stdcall;
var pKeServiceDescriptorTable: PServiceDescriptorTable;
begin
  pKeServiceDescriptorTable:= GetImportFunctionAddress(@KeServiceDescriptorTable);
  //DbgPrint('VIC: - KeServiceDescriptorTable: %0.8x'#13#10,lpKeServiceDescriptorTable);
  Result:= Pointer(DWord(pKeServiceDescriptorTable^.ServiceTableBase) + (SizeOf(DWord) * PULONG(DWord(aFunction) + 1)^));
end;

Function SystemServiceIndex(dwIndex: DWord): Pointer; stdcall;
var pKeServiceDescriptorTable: PServiceDescriptorTable;
begin
  pKeServiceDescriptorTable:= GetImportFunctionAddress(@KeServiceDescriptorTable);
  //DbgPrint('VIC: - KeServiceDescriptorTable: %0.8x'#13#10,lpKeServiceDescriptorTable);
  Result:= PLONG(PLONG(DWord(pKeServiceDescriptorTable^.ServiceTableBase) + (SizeOf(DWord) * dwIndex)));
end;

Function SystemServiceShadowIndex(dwIndex: DWord): Pointer; stdcall;
var pKeServiceDescriptorTableShadow: PServiceDescriptorTable;
begin
  pKeServiceDescriptorTableShadow:= PServiceDescriptorTable(FindSSDTShadow);
  //DbgPrint('VIC: - KeServiceDescriptorTableShadow: %0.8x'#13#10,lpKeServiceDescriptorTableShadow);
  Result:= PLONG(PLONG(DWord(pKeServiceDescriptorTableShadow^.ServiceTableBase) + (SizeOf(DWord) * dwIndex)));
end;

Function FindSSDTShadow: DWord; stdcall;
var i, addrkasst, nAddr: DWord;
begin
  Result:= 0;
  addrkasst:= DWord(GetImportFunctionAddress(@KeAddSystemServiceTable));
  for i:= 0 to 100 do
  begin
    nAddr:= addrkasst + i;
    if (Word(Pointer(nAddr)^) = $888D) then
    begin
      Result:= DWord(Pointer(nAddr + 2)^) + $10;
      //DbgPrint('VIC: - Found the SSDT Shadow at address: %0.8xh'#13#10,Result);
      Break;
    end;
  end;
  if (Result = 0) then DbgPrint('VIC: - The SSDT Shadow cound not found'#13#10);
end;

end.

