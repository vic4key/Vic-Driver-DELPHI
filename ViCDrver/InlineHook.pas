unit InlineHook;

interface

uses Windows, ntoskrnl, macros, nt_status, LDasm, KernelUtils;

Function ILHook(TargetProc, NewProc: Pointer; var OldProc: Pointer): Boolean; stdcall;
Function ILUnHook(OldProc: Pointer): Boolean; stdcall;

implementation

uses vicseh;
{$I vicdeh.pas}

Function SaveOldFunction(Proc: PByte; Old: PByte): DWord;
var
 Size: DWord;
 pOpcode: PByte;
 Offset: DWord;
 oPtr: PByte;
begin
  Result:= 0;
  Offset:= DWord(Proc) - DWord(Old);
  oPtr:= Old;
  while (Result < 5) do
  begin
    Size:= SizeOfCode(Proc,@pOpcode);
    RtlCopyMemory(oPtr,Proc,Size);
    if IsRelativeCmd(pOpcode) then
    Inc(pDWord(DWord(pOpcode) - DWord(Proc) + DWord(oPtr) + 1)^,Offset);
    Inc(oPtr,Size);
    Inc(Proc,Size);
    Inc(Result,Size);
  end;
  PByte(DWord(Old) + Result)^:= $E9;
  PDWord(DWord(Old) + Result + 1)^:= Offset - 5;
end;

Function LengthToJump(Src, Dest: DWord): DWord; stdcall;
begin
  if (Dest < Src) then
  begin
    Result:= Src - Dest;
    Result:= $FFFFFFFF - Result;
    Result:= Result - 4;
  end
  else
  begin
    Result:= Dest - Src;
    Result:= Result - 5;
  end;
end;

Function ILHook(TargetProc, NewProc: Pointer; var OldProc: Pointer): Boolean; stdcall;
var
  Address: DWord;
  OldFunction: pointer;
  Proc: pointer;
begin
  Proc:= TargetProc;
  Address:= LengthToJump(DWord(Proc),DWord(NewProc));
  DisableProtection;
  OldFunction:= ExAllocatePool(NonPagedPool,20);
  DWord(OldFunction^):= DWord(Proc);
  PByte(DWord(OldFunction) + 4)^:= SaveOldFunction(Proc,Pointer(DWord(OldFunction) + 5));
  PByte(Proc)^:= $E9;
  PDWord(DWord(Proc) + 1)^:= Address;
  EnableProtection;
  OldProc:= Pointer(DWord(OldFunction) + 5);
  Result:= True;
end;

Function ILUnHook(OldProc: Pointer): Boolean; stdcall;
var
  Proc: PByte;
  pOpcode: PByte;
  size, thisSize: DWord;
  saveSize, Offset: DWord;
begin
  Proc:= Pointer(PDWord(DWord(OldProc) - 5)^);
  saveSize:= PByte(DWord(OldProc) - 1)^;
  DisableProtection;
  RtlCopyMemory(Proc,OldProc,saveSize);
  ThisSize:= 0;
  while (thisSize < saveSize) do
  begin
    Size:= SizeOfCode(Proc,@pOpcode);
    Offset:= 0;
    if IsRelativeCmd(pOpcode) then Dec(PDWord(DWord(pOpcode) + 1)^,Offset);
    Inc(Proc,Size);
    Inc(thisSize,Size);
  end;
  EnableProtection;
  ExFreePool(Ptr(DWord(OldProc) - 5));
  Result:= True;
end;

end.
