unit vicseh;

(*

uses vicseh;
{$I vicdeh.pas}

label _seh;

{$I vic.try}

{$I vic.except}

*)

interface

uses Windows;

const
  MAXIMUM_SUPPORTED_EXTENSION = 512;
  SIZE_OF_80387_REGISTERS = 80;

type
  PFLOATING_SAVE_AREA = ^FLOATING_SAVE_AREA;
  FLOATING_SAVE_AREA = packed record  {sizeof = 070h}
	  ControlWord: DWord;     {0000h}
	  StatusWord: DWord;      {0004h}
	  TagWord: DWord;         {0008h}
	  ErrorOffset: DWord;     {000Ch}
	  ErrorSelector: DWord;   {0010h}
	  DataOffset: DWord;      {0014h}
	  DataSelector: DWord;    {0018h}
	  RegisterArea: array[0..SIZE_OF_80387_REGISTERS - 1] of Byte; {001Ch}
	  Cr0NpxState: DWord;     {006Ch}
  end;

  PCONTEXT = ^CONTEXT;
  CONTEXT = packed record
	  ContextFlags: DWord;    {0000h}

	  _Dr0: DWord;          {0004h}
	  _Dr1: DWord;          {0008h}
	  _Dr2: DWord;          {000Ch}
	  _Dr3: DWord;          {0010h}
	  _Dr6: DWord;          {0014h}
	  _Dr7: DWord;          {0018h}

	  FloatSave: FLOATING_SAVE_AREA; {001Ch}

	  _SegGs: DWord;        {008Ch}
	  _SegFs: DWord;        {0090h}
	  _SegEs: DWord;        {0094h}
	  _SegDs: DWord;        {0098h}

	  _edi: DWord;          {009Ch}
	  _esi: DWord;          {00A0h}
	  _ebx: DWord;          {00A4h}
	  _edx: DWord;          {00A8h}
	  _ecx: DWord;          {00ACh}
	  _eax: DWord;          {00B0h}

	  _ebp:    DWord;       {00B4h}
	  _eip:    DWord;       {00B8h}
	  _SegCs:  DWord;       {00BCh  MUST BE SANITIZED}
	  _eFlags: DWord;       {00C0h  MUST BE SANITIZED}
	  _esp:    DWord;       {00C4h}
	  _SegSs:  DWord;       {00C8h}

	  ExtendedRegisters: array[0..MAXIMUM_SUPPORTED_EXTENSION - 1] of Byte; {00CCh}
  end;

  TSEH = record
    safe_eip: DWord;
    return_esp: DWord;
    return_ebp: DWord;
  end;

var pSEH: TSEH;

implementation

end.
