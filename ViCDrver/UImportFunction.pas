unit UImportFunction;

interface

uses nt_status, ntoskrnl, native, winioctl, fcall, macros, VarConstGlobal;

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

const ntoskrnl = 'ntoskrnl';

Function KeStackAttachProcess(Process: PVOID; ApcState: PKAPC_STATE): NTSTATUS; stdcall;
Function KeUnstackDetachProcess(ApcState: PKAPC_STATE): NTSTATUS; stdcall;
(*
Function MmMapIoSpace(PhysicalAddress: PHYSICAL_ADDRESS; NumberOfBytes: ULONG; CacheEnable: _MEMORY_CACHING_TYPE): Pointer; stdcall;
Procedure MmUnmapIoSpace(BaseAddress: Pointer; NumberOfBytes: ULONG); stdcall;
Function PsGetProcessImageFileName(Process: PVOID): PUCHAR; stdcall;
Function KeGetCurrentThread: PKThread; stdcall;
Function PsGetCurrentThread: PEThread; stdcall;
Function PsGetCurrentProcessId: HANDLE; stdcall;
Procedure ObDereferenceObject(MyObject: PVOID); stdcall;
Function PsTerminateSystemThread(ExitStatus: NTSTATUS): NTSTATUS; stdcall;
*)
implementation

Function KeStackAttachProcess(Process: PVOID; ApcState: PKAPC_STATE): NTSTATUS; stdcall; external ntoskrnl name '_KeStackAttachProcess';
Function KeUnstackDetachProcess(ApcState: PKAPC_STATE): NTSTATUS; stdcall; external ntoskrnl name '_KeUnstackDetachProcess';
(*
Function MmMapIoSpace(PhysicalAddress: PHYSICAL_ADDRESS; NumberOfBytes: ULONG; CacheEnable: _MEMORY_CACHING_TYPE): Pointer; stdcall; external ntoskrnl name '_MmMapIoSpace';
Procedure MmUnmapIoSpace(BaseAddress: Pointer; NumberOfBytes: ULONG); stdcall; external ntoskrnl name '_MmUnmapIoSpace';
Function PsGetProcessImageFileName(Process: PVOID): PUCHAR; stdcall; external ntoskrnl name '_PsGetProcessImageFileName';
Function KeGetCurrentThread: PKThread; stdcall; external ntoskrnl name '_KeGetCurrentThread';
Function PsGetCurrentThread: PEThread; stdcall; external ntoskrnl name '_PsGetCurrentThread';
Function PsGetCurrentProcessId: HANDLE; stdcall; external ntoskrnl name '_PsGetCurrentProcessId';
Procedure ObDereferenceObject(MyObject: PVOID); stdcall; external ntoskrnl name '_ObDereferenceObject';
Function PsTerminateSystemThread(ExitStatus: NTSTATUS): NTSTATUS; stdcall; external ntoskrnl name '_PsTerminateSystemThread';
*)

end.
