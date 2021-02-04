library NativeDll;

uses
  Windows,
  SysUtils,
  Classes,
  WinSvc,
  mrVic,
  ViCDrvUnit in 'ViCDrvUnit.pas',
  Mdl_ProtectProcess in 'Mdl_ProtectProcess.pas',
  Mdl_HideProcess in 'Mdl_HideProcess.pas',
  Mdl_ConstVariable in 'Mdl_ConstVariable.pas',
  Mdl_HookRWProcess in 'Mdl_HookRWProcess.pas',
  Mdl_OPProcess in 'Mdl_OPProcess.pas',
  Mdl_SomeFunction in 'Mdl_SomeFunction.pas',
  Mdl_ReadWriteMemory in 'Mdl_ReadWriteMemory.pas';

exports
  VIC_LoadDriver,
  VIC_UnLoadDriver,
  VIC_ZwOpenProcess,
  VIC_ZwTerminateProcess,
  VIC_Protect,
  VIC_UnProtect,
  VIC_Hide,
  VIC_UnHide,
  VIC_Hide2,
  VIC_HookRW,
  VIC_UnHookRW,
  VIC_ReadMemory;
end.

