(*******************************************)
(*	Name: ViCDriver                        *)
(*	Type: Driver | Sub System              *)
(*	Author: vic4key                        *)
(*	Mail: vic4key@gmail.com                *)
(*	Website: reaonline.net | cin1team.biz  *)
(*******************************************)
unit ViCDrver;

interface

uses
  nt_status, ntoskrnl, fcall, macros, native, NtoskrnlCustom, KernelUtils,
  VarConstGlobal, UZwOpenProcess, UZwTerminateProcess, UProtectProcess,
  UHiddenProcess, UHookZwRWVM, UCtrlCode, UShadowHook, URWVM;

Function _DriverEntry(DriverObject: PDriverObject; RegistryPath: PUnicodeString): NTSTATUS; stdcall;

const DriverName = 'ViCDrver';

implementation

uses vicseh;
{$I vicdeh.pas}

Procedure DriverUnload(DriverObject: PDriverObject); stdcall;
var _SymbolicLinkName: TUnicodeString;
begin
  VIC_UnHookZwReadVirtualMemory;
  VIC_UnHookZwWriteVirtualMemory;
  VIC_UnHookZwOpenProcess;
  VIC_UnHookZwQuerySystemInformation;
  RtlInitUnicodeString(@_SymbolicLinkName,PWideChar('\DosDevices\' + DriverName));
  status:= IoDeleteSymbolicLink(@_SymbolicLinkName);
  if (NTSTATUS(status) <> STATUS_SUCCESS) then
    DbgPrint('VIC: DriverUnload: IoDeleteSymbolicLink -> False [%0.8x]' + CRLF,status);
  IoDeleteDevice(DriverObject^.DeviceObject);
  DbgPrint('VIC: + VIC DRIVER UNLOADED +' + CRLF);
end;

Function VIC_OnCreate(DeviceObject: pDeviceObject; Irp: PIRP): NTSTATUS; stdcall;
begin
  DbgPrint('VIC: ---------------------' + CRLF);
  //DbgPrint('VIC: + DriverOnCreate' + CRLF);
  Irp^.IoStatus.Status:= STATUS_SUCCESS;
  Irp^.IoStatus.Information:= 0;
  IoCompleteRequest(Irp,IO_NO_INCREMENT);
  Result:= STATUS_SUCCESS;
end;

Function VIC_OnClose(DeviceObject: pDeviceObject; Irp: PIRP): NTSTATUS; stdcall;
begin
  Irp^.IoStatus.Status:= STATUS_SUCCESS;
  Irp^.IoStatus.Information:= 0;
  IoCompleteRequest(Irp,IO_NO_INCREMENT);
  Result:= STATUS_SUCCESS;
  //DbgPrint('VIC: + DriverOnClose' + CRLF);
  DbgPrint('VIC: ---------------------' + CRLF);
end;

Function VIC_OnIoDevControl(DeviceObject: pDeviceObject; Irp: PIRP): NTSTATUS; stdcall;
var
  status: NTSTATUS;
  pSysBuf: Pointer;
  IrpStack: PIO_STACK_LOCATION;
  dwBytesReturned, dwIoControlCode: DWord;
begin
  //DbgPrint('VIC: + DriverOnIoDevControl' + CRLF);
  status:= STATUS_SUCCESS;
  dwBytesReturned:= 0;
  IrpStack:= IoGetCurrentIrpStackLocation(Irp);
  dwIoControlCode:= IrpStack^.Parameters.DeviceIoControl.IoControlCode;
  pSysBuf:= Irp^.AssociatedIrp.SystemBuffer;

  // Calculation the I/O Control Code.
  CalcCtrlCode;

  // Use ZwOpenProcess;
  if (dwIoControlCode = VICCTL_OP) then
  begin
    PID:= DWord(pSysBuf^);
    //VIC_HookNtUserDestroyWindow;
    DWord(pSysBuf^):= VIC_ZwOpenProcess(PID);
    dwBytesReturned:= SizeOf(PID);
    DbgPrint('VIC: - PID[%d] -> Openned' + CRLF,PID);
  end else

  // Use ZwTerminateProcess;
  if (dwIoControlCode = VICCTL_TP) then
  begin
    PID:= DWord(pSysBuf^);
    //VIC_UnHookNtUserDestroyWindow;
    VIC_ZwTerminateProcess(PID);
    dwBytesReturned:= 0;
    DbgPrint('VIC: - PID[%d] -> Terminated' + CRLF,PID);
  end else

  // Hook ZwOpenProcess to protect my process;
  if (dwIoControlCode = VICCTL_PRT) then
  begin
    PID:= DWord(pSysBuf^);
    VIC_HookZwOpenProcess;
    dwBytesReturned:= 0;   
    DbgPrint('VIC: - PID[%d] -> Protected' + CRLF,PID);
  end else

  // UnHook ZwOpenProcess to unprotect my process;
  if (dwIoControlCode = VICCTL_UNPRT) then
  begin
    PID:= DWord(pSysBuf^);
    VIC_UnHookZwOpenProcess;
    dwBytesReturned:= 0;
    DbgPrint('VIC: - PID[%d] -> UnProtected' + CRLF,PID);
  end else

  // Hook ZwQuerySystemInformation to hidden my process;
  if (dwIoControlCode = VICCTL_HIDE) then
  begin
    PID:= DWord(pSysBuf^);
    VIC_HookZwQuerySystemInformation;
    dwBytesReturned:= 0;
    DbgPrint('VIC: - PID[%d] -> Hidden' + CRLF,PID);
  end else

  // UnHook ZwQuerySystemInformation to unhidden my process;
  if (dwIoControlCode = VICCTL_UNHIDE) then
  begin
    PID:= DWord(pSysBuf^);
    VIC_UnHookZwQuerySystemInformation;
    dwBytesReturned:= 0;
    DbgPrint('VIC: - PID[%d] -> UnHidden' + CRLF,PID);
  end else

  // Del the List Entry to hidden my process;
  if (dwIoControlCode = VICCTL_HIDE2) then
  begin
    PID:= DWord(pSysBuf^);
    PID:= VIC_LEHiddenProcess(PID);
    dwBytesReturned:= 0;
    DbgPrint('VIC: - PID[%d] -> Hidden/UnHidden type 2' + CRLF,PID);
  end else

  // Hook NtRead/NtWriteVirtualMemory;
  if (dwIoControlCode = VICCTL_HOOKRW) then
  begin
    RtlZeroMemory(@xvm,sizeof(xvm));
    xvm:= TIndexRW(pSysBuf^);
    if (xvm.IndexRpm <> 0) and (xvm.IndexWpm <> 0) then
    begin
      VIC_HookZwReadVirtualMemory;
      VIC_HookZwWriteVirtualMemory;
      dwBytesReturned:= SizeOf(xvm);
      DbgPrint('VIC: - RVM[%x] - WVM[%x] -> R/W Hooked' + CRLF,xvm.IndexRpm,xvm.IndexWpm);
    end;
  end else

  // UnHook NtRead/NtWriteVirtualMemory;
  if (dwIoControlCode = VICCTL_UNHOOKRW) then
  begin
    RtlZeroMemory(@xvm,sizeof(xvm));
    xvm:= TIndexRW(pSysBuf^);
    if (xvm.IndexRpm <> 0) and (xvm.IndexWpm <> 0) then
    begin
      VIC_UnHookZwReadVirtualMemory;
      VIC_UnHookZwWriteVirtualMemory;
      dwBytesReturned:= SizeOf(xvm);
      DbgPrint('VIC: - RVM[%x] - WVM[%x] -> R/W UnHooked' + CRLF,xvm.IndexRpm,xvm.IndexWpm);
    end;
  end else

  // Read Memory;
  if (dwIoControlCode = VICCTL_RPM) then
  begin
    RtlZeroMemory(@rInput,SizeOf(rInput));
    rInput:= _TRPM(pSysBuf^);
    DbgPrint(
      'VIC: PID: %d | Address: %0.8x | Buffer: %0.8x | Size: %d'^J,
      rInput._dwPID,
      rInput._dwAddress,
      rInput._lpBuffer,
      rInput._nSize);
    VIC_ReadProcessMemory(rInput);
    TRpm(pSysBuf^):= rInput;
    dwBytesReturned:= SizeOf(rInput);
  end;

  status:= STATUS_INVALID_DEVICE_REQUEST;
  Irp^.IoStatus.Status:= status;
  Irp^.IoStatus.Information:= dwBytesReturned;
  IoCompleteRequest(Irp,IO_NO_INCREMENT);
  Result:= status;
end;

Function _DriverEntry(DriverObject: PDriverObject; RegistryPath: PUnicodeString): NTSTATUS; stdcall;
var
  DeviceName: TUnicodeString;
  DeviceObject: pDeviceObject;
label _seh;
begin
  DbgPrint('(******************************************)' + CRLF);
  DbgPrint('(* Name: ViCDrver.sys                     *)' + CRLF);
  DbgPrint('(* Type: Driver | Sub System              *)' + CRLF);
  DbgPrint('(* Compiler: Embarcadero Delphi x86 22.0  *)' + CRLF);
  DbgPrint('(* Author: vic4key                        *)' + CRLF);
  DbgPrint('(* Mail: vic4key@gmail.com                *)' + CRLF);
  DbgPrint('(* Website: cin1team.biz | reaonline.net  *)' + CRLF);
  DbgPrint('(******************************************)' + CRLF);
  DbgPrint('VIC: + VIC DRIVER LOADED +');
  RtlInitUnicodeString(@DeviceName,PWideChar('\Device\' + DriverName));
  RtlInitUnicodeString(@SymbolicLinkName,PWideChar('\DosDevices\' + DriverName));
  status:= IoCreateDevice(DriverObject,0,@DeviceName,FILE_DEVICE_UNKNOWN,0,False,@DeviceObject);
  if (NTSTATUS(status) = STATUS_SUCCESS) then
  begin
	  status:= IoCreateSymbolicLink(@SymbolicLinkName,@DeviceName);
    if (NTSTATUS(status) = STATUS_SUCCESS) then
    begin
      DriverObject^.MajorFunction[IRP_MJ_CREATE]:= @VIC_OnCreate;
      DriverObject^.MajorFunction[IRP_MJ_DEVICE_CONTROL]:= @VIC_OnIoDevControl;
	    DriverObject^.MajorFunction[IRP_MJ_CLOSE]:= @VIC_OnClose;
      DriverObject^.DriverUnload:= @DriverUnload;
	    status:= STATUS_SUCCESS;
    end
    else
    begin
      DbgPrint('VIC: - IoCreateSymbolicLink: Failed' + CRLF);
      status:= IoDeleteSymbolicLink(@SymbolicLinkName);
    end;
  end else DbgPrint('VIC: - IoCreateDevice: Failed' + CRLF);
  Result:= status;
  {$I vic.try}
  //DbgPrint('%d',DWord(Pointer(DWord(PsGetCurrentProcess) + $84)^));
  {$I vic.except}
end;

end.