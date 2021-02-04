unit ViCDrvUnit;

interface

uses Windows, SysUtils, WinSvc, Mdl_ConstVariable, Mdl_SomeFunction;

Procedure VIC_LoadDriver; stdcall;
Procedure VIC_UnLoadDriver; stdcall;

implementation

uses mrVic;

Procedure VIC_LoadDriver; stdcall;
begin
  if (FileExists(GetCurrentDir + '\' + nFile) = False) then Exit;
  Scm:= OpenSCManager(NIL,NIL,SC_MANAGER_ALL_ACCESS);
  if (Scm = 0) then Exit;
  hSv:= CreateServiceA(
    Scm,
    StrToPac(nFile + ' - [' + FormatDateTime('hh:mm:ss',Now) + ']'),
    StrToPac(nFile + ' - [' + FormatDateTime('hh:mm:ss - dd/mm/yyyy',Now) + ']'),
    SERVICE_ALL_ACCESS,
    SERVICE_KERNEL_DRIVER,
    SERVICE_DEMAND_START,
    SERVICE_ERROR_IGNORE,
    StrToPac(GetCurrentDir + '\' + nFile),
    NIL,NIL,NIL,NIL,NIL);
  if (hSv = 0) then
  begin
    CloseServiceHandle(Scm);
    Exit;
  end;
  svStart:= StartServiceA(hSv,0,lpTemp);
  if (svStart = False) then
  begin
    DeleteService(hSv);
    CloseServiceHandle(Scm);
    Exit;
  end;
  // Calculation the I/O Control Code.
  CalcCtrlCode;
end;

Procedure VIC_UnLoadDriver; stdcall;
begin
  IsTopped:= ControlService(hSv,SERVICE_CONTROL_STOP,svStatus);
  if (hDev <> 0) then CloseHandle(hDev);
  if (hSv <> 0) then DeleteService(hSv);
  if (Scm <> 0) then CloseServiceHandle(Scm);
end;

end.
