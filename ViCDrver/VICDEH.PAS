Function DefaultExceptionHandler(
  pExcept: PEXCEPTION_RECORD;
  pFrame: DWord;
  pContext: PCONTEXT;
  pDispatch: DWord): DWord; stdcall;
var typeExcept: PAnsiChar;
begin
  case pExcept^.ExceptionCode of
    $C0000005: typeExcept:= 'Access violation';
    $C0000006: typeExcept:= 'In page error';
    $C0000017: typeExcept:= 'No memory';
    $C000001D: typeExcept:= 'Illegal instruction';
    $C0000025: typeExcept:= 'Non-continuable exception';
    $C0000026: typeExcept:= 'Invalid disposition';
    $C000008C: typeExcept:= 'Array bounds exceeded';
    $C000008D: typeExcept:= 'Fload denormal operation';
    $C000008E: typeExcept:= 'Float device by zero';
    $C000008F: typeExcept:= 'Float inexact result';
    $C0000090: typeExcept:= 'Float invalid operation';
    $C0000091: typeExcept:= 'Float overflow';
    $C0000092: typeExcept:= 'Float stack Check';
    $C0000093: typeExcept:= 'Float underflow';
    $C0000094: typeExcept:= 'Integer divide by zero';
    $C0000095: typeExcept:= 'Integer overflow';
    $C0000096: typeExcept:= 'Privileged instruction';
    $C00000FD: typeExcept:= 'Stack overflow';
    $C000013A: typeExcept:= 'Control C exit';
    $80000001: typeExcept:= 'Violation of a guard page in memory';
    $80000003: typeExcept:= 'Breakpoint occurred';
    $80000004: typeExcept:= 'Single step during debugging';
    else typeExcept:= 'unknown';
  end;
  DbgPrint(
    'SEH: An exception %0.8xh (%s) at %0.8xh'#13#10,
    pExcept^.ExceptionCode,
    typeExcept,
    DWord(pExcept^.ExceptionAddress));
  asm
    lea eax,pSEH
    push (TSEH ptr ds:[eax]).safe_eip
    push (TSEH ptr ds:[eax]).return_esp
    push (TSEH ptr ds:[eax]).return_ebp
    mov eax,pContext
    pop (CONTEXT ptr ds:[eax])._ebp
    pop (CONTEXT ptr ds:[eax])._esp
    pop (CONTEXT ptr ds:[eax])._eip
  end;
  Result:= 0;
end;
