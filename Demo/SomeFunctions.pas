unit SomeFunctions;

interface

uses Windows, SysUtils, PsAPI, TlHelp32, Classes, mrVic;

Function GetSyscallNumber(lpNameModule, lpNameOfFunction: PAnsiChar): DWord; stdcall;
Procedure GetProcessList(var List: TstringList);
Function GetPIDFromLineList(str: String): DWord; stdcall;

implementation

Function GetSyscallNumber(lpNameModule, lpNameOfFunction: PAnsiChar): DWord; stdcall;
var
  hMdl: HModule;
  pFunction: Pointer;
begin
  hMdl:= GetModuleHandleA(lpNameModule);
  pFunction:= GetProcAddress(hMdl,lpnameOfFunction);
  Result:= DWord(Pointer(DWord(pFunction) + 1)^);
end;

Procedure CreateWin9xProcessList(List: TstringList);
var
  hSnapShot: THandle;
  ProcInfo: TProcessEntry32;
begin
  if (List = NIL) then Exit;
  hSnapShot:= CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS,0);
  if (hSnapShot <> THandle(-1)) then
  begin
    ProcInfo.dwSize:= SizeOf(ProcInfo);
    if (Process32First(hSnapshot,ProcInfo)) then
    begin
      List.Add(ProcInfo.szExeFile);
      while (Process32Next(hSnapShot,ProcInfo)) do
        List.Add(Format('<%d> %s',[ProcInfo.th32ProcessID,ExtractFileName(ProcInfo.szExeFile)]));
    end;
    CloseHandle(hSnapShot);
  end;
end;

Procedure CreateWinNTProcessList(List: TstringList);
var
  PIDArray: array [0..1023] of DWord;
  cb, dwPID: DWord;
  i: Integer;
  ProcCount: Integer;
  hMod: HModule;
  hProcess: THandle;
  ModuleName: array [0..300] of Char;
begin
  if (List = NIL) then Exit;
  EnumProcesses(@PIDArray,SizeOf(PIDArray),cb);
  ProcCount:= cb div SizeOf(DWORD);
  for i:= 0 to ProcCount - 1 do // i = 0 -> System (ntkrnlpa.exe);
  begin
    hProcess:= OpenProcess(
      PROCESS_QUERY_INFORMATION or
      PROCESS_VM_READ,
      False,
      PIDArray[i]);
    dwPID:= PIDArray[i];
    if (hProcess <> 0) then
    begin
      EnumProcessModules(hProcess,@hMod,SizeOf(hMod),cb);
      GetModuleFilenameEx(hProcess,hMod,ModuleName,SizeOf(ModuleName));
      List.Add(Format('<%d> %s',[dwPID,ExtractFileName(ModuleName)]));
      CloseHandle(hProcess);
    end;
  end;
end;

Procedure GetProcessList(var List: TstringList);
var ovi: TOSVersionInfo;
begin
  if (List = NIL) then Exit;
  ovi.dwOSVersionInfoSize:= SizeOf(TOSVersionInfo);
  GetVersionEx(ovi);
  case ovi.dwPlatformId of
    VER_PLATFORM_WIN32_WINDOWS: CreateWin9xProcessList(List);
    VER_PLATFORM_WIN32_NT: CreateWinNTProcessList(List);
  end
end;

Function GetPIDFromLineList(str: String): DWord; stdcall;
var b: Integer;
begin
  b:= Pos('>',str);
  Result:= StrToInt(Copy(str,2,(b - 2)));
end;

end.
