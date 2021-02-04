unit UCtrlCode;

interface

uses Windows, nt_status, Macros;

var
  VICCTL_TP:       DWord = 0;
  VICCTL_OP:       DWord = 0;
  VICCTL_PRT:      DWord = 0;
  VICCTL_UNPRT:    DWord = 0;
  VICCTL_HIDE2:    DWord = 0;
  VICCTL_HIDE:     DWord = 0;
  VICCTL_UNHIDE:   DWord = 0;
  VICCTL_HOOKRW:   DWord = 0;
  VICCTL_UNHOOKRW: DWord = 0;
  VICCTL_RPM:      DWord = 0;

Procedure CalcCtrlCode;

implementation

Function CalCode(codeCtrl: DWord): DWord; stdcall;
begin
  Result:= CTL_CODE(FILE_DEVICE_UNKNOWN,codeCtrl,METHOD_BUFFERED,FILE_ANY_ACCESS);
end;

Procedure CalcCtrlCode;
begin
  // All the I/O Control Code to uses.
  VICCTL_TP:=        CalCode($800); // ZwTerminateProcess
  VICCTL_OP:=        CalCode($801); // ZwOpenProcess
  VICCTL_PRT:=       CalCode($802); // Hook ZwOP
  VICCTL_UNPRT:=     CalCode($803); // UnHook ZwOP
  VICCTL_HIDE:=      CalCode($804); // Hook ZwQSI
  VICCTL_UNHIDE:=    CalCode($805); // UnHook ZwQSI
  VICCTL_HOOKRW:=    CalCode($806); // Hook RPM/WPM
  VICCTL_UNHOOKRW:=  CalCode($807); // UnHook RPM/WPM
  VICCTL_HIDE2:=     CalCode($808); // Hook ZwQSI
  VICCTL_RPM:=       CalCode($809);
end;

end.
