program Editor;

{%File 'vic.try'}
{%File 'vic.except'}

uses
  SysUtils,
  ViCDrver in 'ViCDrver.pas',
  UProtectProcess in 'UProtectProcess.pas',
  UZwOpenProcess in 'UZwOpenProcess.pas',
  VarConstGlobal in 'VarConstGlobal.pas',
  UZwTerminateProcess in 'UZwTerminateProcess.pas',
  UHookZwRWVM in 'UHookZwRWVM.pas',
  UCtrlCode in 'UCtrlCode.pas',
  vicseh in 'vicseh.pas',
  vicdeh in 'vicdeh.pas',
  UShadowHook in 'UShadowHook.pas',
  UHiddenProcess in 'UHiddenProcess.pas',
  InlineHook in 'InlineHook.pas',
  URWVM in 'URWVM.pas';

begin
  { TODO -oUser -cConsole Main : Insert code here }
end.
