unit UShadowHook;

interface

uses Windows, nt_status, ntoskrnl, fcall, macros, KernelUtils, VarConstGlobal;

type TNtUserDestroyWindow = Function(hWnd: HWND): NTSTATUS; stdcall;

var
  PNtUserDestroyWindow: TNtUserDestroyWindow;
  pCsrssEP: Pointer;

const dwIndex = 355; // XP

Procedure VIC_HookNtUserDestroyWindow; stdcall;
Procedure VIC_UnHookNtUserDestroyWindow; stdcall;
Function GetCsrssPID: DWord; stdcall;

implementation

uses vicseh;
{$I vicdeh.pas}

Function KeAttachProcess(pEPROCESS: Pointer): NTSTATUS; stdcall; external NtKernel name '_KeAttachProcess';
Function KeDetachProcess: NTSTATUS; stdcall; external NtKernel name '_KeDetachProcess';
Function PsGetCurrentProcess: Pointer; stdcall; external NtKernel name '_PsGetCurrentProcess';

Function GetCsrssPID: DWord; stdcall;
// Start Sub functions;
Function GetNextFLink(addrThisFlink: DWord): DWord; stdcall;
asm
  pushf
  pushad
  mov eax,addrThisFlink
  mov eax,dword ptr ds:[eax]
  mov Result,eax
  popad
  popf
end;

Function GetNextBLink(addrThisBlink: DWord): DWord; stdcall;
asm
  pushf
  pushad
  mov eax,addrThisBlink
  mov eax,dword ptr ds:[eax+4]
  mov Result,eax
  popad
  popf
end;

Function GetDWordFileName(addrThisFlink: DWord): DWord; stdcall;
asm
  pushf
  pushad
  mov eax,addrThisFlink
  sub eax,88h
  add eax,174h
  mov eax,dword ptr ds:[eax]
  mov Result,eax
  popad
  popf
end;

Function GetPIDFromFlink(addrThisFlink: DWord): DWord; stdcall;
asm
  pushf
  pushad
  mov eax,addrThisFlink
  sub eax,88h
  add eax,84h
  mov eax,dword ptr ds:[eax]
  mov Result,eax
  popad
  popf
end;
// End Sub functions;
const
  tcsrss  = $73727363; // s.s.r.s.c
  tsystem = $74737953; // m.e.t.s.y.S
  endlist = $FFFFFFFF;
var addrFlink, dwFileName, first: DWord;
label _seh;
begin
  {$I vic.try}
  Result:= 0;
	addrFlink:= DWord(PsGetCurrentProcess) + $88;
	dwFileName:= GetDWordFileName(addrFlink);
  first:= dwFileName;
	repeat
		if (dwFileName = tcsrss) then
    begin
			Result:= GetPIDFromFlink(addrFlink);
      if (first = tsystem) then Break;
    end;
		if (first = tsystem) then addrFlink:= GetNextFLink(addrFlink) // If -> System [ntkrnlpa.exe]
    else addrFlink:= GetNextBLink(addrFlink); // If -> My process;
		dwFileName:= GetDWordFileName(addrFlink);
  until (dwFileName = endlist);
  {$I vic.except}
end;

Function VIC_NtUserDestroyWindowNew(hWnd: HWND): NTSTATUS; stdcall;
begin
  DbgPrint('VIC: - NtUserDestroyWindow(%0.8xh)' + CRLF,hWnd);
  Result:= PNtUserDestroyWindow(hWnd);
end;

Procedure VIC_HookNtUserDestroyWindow; stdcall;
label _seh;
begin
  if (NtUDWHooked = False) then
  begin
    {$I vic.try}
    status:= PsLookupProcessByProcessId(GetCsrssPID,pCsrssEP); // Need attach process csrss.exe to hookin shadow.
    //DbgPrint('VIC: - PsLookupProcessByProcessId -> %0.8x' + CRLF,status);
    status:= KeAttachProcess(pCsrssEP);
    //DbgPrint('VIC: - KeAttachProcess -> %0.8x' + CRLF,status);
    DisableProtection;
    //ILHook(SystemServiceShadowOrd(dwIndex),@VIC_NtUserDestroyWindowNew,@PNtUserDestroyWindow);
    PNtUserDestroyWindow:= TNtUserDestroyWindow(
      InterlockedExchange(
        SystemServiceShadowIndex(dwIndex),
        DWord(@VIC_NtUserDestroyWindowNew)));
    EnableProtection;
    status:= KeDetachProcess;
    //DbgPrint('VIC: - KeDetachProcess -> %0.8x' + CRLF,status);
    NtUDWHooked:= True;
    DbgPrint('VIC: - NtUserDestroyWindow -> Hooked' + CRLF);   
    {$I vic.except}
  end;
end;

Procedure VIC_UnHookNtUserDestroyWindow; stdcall;
label _seh;
begin
  if (NtUDWHooked = True) then
  begin
    {$I vic.try}
    status:= PsLookupProcessByProcessId(GetCsrssPID,pCsrssEP); // Need attach process csrss.exe to hookin shadow.
    //DbgPrint('VIC: - PsLookupProcessByProcessId -> %0.8x' + CRLF,status);
    status:= KeAttachProcess(pCsrssEP);
    //DbgPrint('VIC: - KeAttachProcess -> %0.8x' + CRLF,status);
    DisableProtection;
    //ILUnHook(@PNtUserDestroyWindow);
    PNtUserDestroyWindow:= TNtUserDestroyWindow(
      InterlockedExchange(
        SystemServiceShadowIndex(dwIndex),
        DWord(@PNtUserDestroyWindow)));
    EnableProtection;
    status:= KeDetachProcess;
    //DbgPrint('VIC: - KeDetachProcess -> %0.8x' + CRLF,status);
    NtUDWHooked:= False;
    DbgPrint('VIC: - NtUserDestroyWindow -> UnHooked' + CRLF);
    {$I vic.except}
  end;
end;

end.
