unit URWVM;

interface

uses
  nt_status, ntoskrnl, fcall, macros, native, NtoskrnlCustom, KernelUtils, VarConstGlobal;
(*
type
  TRPM = packed record
    _dwPID: DWord;
    _dwAddress: DWord;
    _lpBuffer: Pointer;    
    _nSize: DWord;
  end;
*)
Function VIC_ReadProcessMemory(rIn: TRpm): NTSTATUS; stdcall;

implementation

uses vicseh;
{$I vicdeh.pas}

type
  _MEMORY_CACHING_TYPE_ORIG =
  (
   MmFrameBufferCached = 2,
   _MEMORY_CACHING_TYPE_ORIG_TO32BIT = MaxLongint
  );
  MEMORY_CACHING_TYPE_ORIG = _MEMORY_CACHING_TYPE_ORIG;

  _MEMORY_CACHING_TYPE =
  (
   MmNonCached = Byte(FALSE),
   MmCached = Byte(TRUE),
   MmWriteCombined = Byte(MmFrameBufferCached),
   MmHardwareCoherentCached,
   MmNonCachedUnordered,
   MmUSWCCached,
   MmMaximumCacheType,
   _MEMORY_CACHING_TYPE_TO32BIT = MaxLongint 
  );

Function KeStackAttachProcess(
  Process: PVOID;
  ApcState: PKAPC_STATE): NTSTATUS; stdcall; external NtKernel name '_KeStackAttachProcess';
Function KeUnstackDetachProcess(
  ApcState: PKAPC_STATE): NTSTATUS; stdcall; external NtKernel name '_KeUnstackDetachProcess';
Function MmMapIoSpace(
  PhysicalAddress: PHYSICAL_ADDRESS;
  NumberOfBytes: DWord;
  CacheEnable: _MEMORY_CACHING_TYPE): Pointer; stdcall; external NtKernel name '_MmMapIoSpace';
Procedure MmUnmapIoSpace(
  BaseAddress: Pointer;
  NumberOfBytes: DWord); stdcall; external NtKernel name '_MmUnmapIoSpace';

Function VIC_ReadProcessMemory(rIn: TRpm): NTSTATUS; stdcall;
var
  status: NTSTATUS;
  pPE: Pointer;
  apcSt: KAPC_STATE;
  PhysAddr: PHYSICAL_ADDRESS;
  MapAddr: Pointer;
  readBuff: Pointer;
label _seh;
begin
  Result:= STATUS_UNSUCCESSFUL;

  status:= PsLookupProcessByProcessId(rIn._dwPID,pPE);
  DbgPrint('VIC: PsLookupProcessByProcessId: %x'^J,status);

  if (NTSTATUS(status) = STATUS_SUCCESS) then
  begin
  
    RtlZeroMemory(@apcSt,SizeOf(apcSt));
    status:= KeStackAttachProcess(pPE,@apcSt);
    DbgPrint('VIC: KeStackAttachProcess: %x'^J,status);

    PhysAddr:= MmGetPhysicalAddress(Ptr(rIn._dwAddress));
    DbgPrint('VIC: MmGetPhysicalAddress: %x'^J,PhysAddr);

    MapAddr:= MmMapIoSpace(PhysAddr,rIn._nSize,MmNonCached);
    DbgPrint('VIC: MmMapIoSpace: %x'^J,MapAddr);

    readBuff:= ExAllocatePool(NonPagedPool,rIn._nSize);
    DbgPrint('VIC: ExAllocatePool: Done'^J);

    if MmIsAddressValid(MapAddr)
    and MmIsAddressValid(Pointer(DWord(MapAddr) + rIn._nSize - 1))then
    begin
      {$I vic.try}
      RtlCopyMemory(readBuff,Pointer(MapAddr),rIn._nSize);
      DbgPrint('VIC: Return -> %0.8x'^J,DWord(Pointer(DWord(readBuff))^));
      {$I vic.except}
    end;
    
    ExFreePool(readBuff);
    DbgPrint('VIC: ExFreePool: Done'^J);

    MmUnmapIoSpace(MapAddr,rIn._nSize);
    DbgPrint('VIC: MmUnmapIoSpace: Done'^J);

    status:= KeUnstackDetachProcess(@apcSt);
    DbgPrint('VIC: KeUnstackDetachProcess: %x'^J,status);
  end;
end;

end.
