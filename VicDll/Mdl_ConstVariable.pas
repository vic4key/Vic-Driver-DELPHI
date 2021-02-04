unit Mdl_ConstVariable;

interface

uses Windows, SysUtils, WinSvc;

var
  lpTemp: PAnsiChar;
  svStatus: _SERVICE_STATUS;
  svStart, IoSucc, IsTopped: Boolean;
  IsLoaded: Boolean   = False;
  IsUnLoaded: Boolean = False;
  Scm, hSv, hDev, inBuf, outBuf, dwReturned: DWord;

const
  nFile: String = 'ViCDrver.sys';
  METHOD_BUFFERED   = 0;
  FILE_ANY_ACCESS   = 0;
  FILE_READ_ACCESS  = 1;
  FILE_WRITE_ACCESS = 2;
  FILE_DEVICE_UNKNOWN: DWord = $22;

implementation

end.
