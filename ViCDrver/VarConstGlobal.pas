unit VarConstGlobal;

interface

uses Windows, nt_status, ntoskrnl;

type
  TIndexRW = record
    IndexRpm: DWord;
    IndexWpm: DWord;
  end;

type
  _TRPM = packed record
    _dwPID: DWord;
    _dwAddress: DWord;
    _lpBuffer: Pointer;
    _nSize: DWord;
  end;
  TRpm = _TRPM;

const
  CRLF = #13#10;
  CR   = #13;
  LF   = #10;
  TAB  = #9;
  NULL = #0;

var
  PID: DWord;
  xvm: TIndexRW;
  status: NTSTATUS;
  SymbolicLinkName: TUnicodeString;
  IsOPHooked:   Boolean = False;
  IsRVMHooked:  Boolean = False;
  IsWVMHooked:  Boolean = False;
  HidedProcess: Boolean = False;
  NtUMCHooked:  Boolean = False;
  NtUDWHooked:  Boolean = False;
  IsHidden: Boolean = True;
  rInput: TRpm;

implementation

end.
