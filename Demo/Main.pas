unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, SomeFunctions;

type
  TForm1 = class(TForm)
    Button1: TButton;
    XPManifest1: TXPManifest;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    GroupBox2: TGroupBox;
    ComboBox1: TComboBox;
    rfList: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Button10: TButton;
    procedure Button10Click(Sender: TObject);
    procedure rfListClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  MyProcList: TstringList;
  Loopin: Boolean = False;

const nDLL = 'NativeDll.dll';

implementation

uses mrVic;

Function GetEditInt(TBox: TEdit): Integer; stdcall;
begin
  Result:= StrToInt(TBox.Text);
end;

Procedure VIC_LoadDriver; stdcall; far; external nDLL;
Procedure VIC_UnLoadDriver; stdcall; far; external nDLL;
Procedure VIC_ZwOpenProcess(PID: DWord); stdcall; far; external nDLL;
Procedure VIC_ZwTerminateProcess(PID: DWord); stdcall; far; external nDLL;
Procedure VIC_Protect(PID: DWord); stdcall; far; external nDLL;
Procedure VIC_UnProtect(PID: DWord); stdcall; far; external nDLL;
Procedure VIC_Hide(PID: DWord); stdcall; far; external nDLL;
Procedure VIC_UnHide(PID: DWord); stdcall; far; external nDLL;
Procedure VIC_Hide2(PID: DWord); stdcall; far; external nDLL
Procedure VIC_HookRW(lpIndexRpm, lpIndexWpm: DWord); stdcall; far; external nDLL;
Procedure VIC_UnHookRW(lpIndexRpm, lpIndexWpm: DWord); stdcall; far; external nDLL;
Procedure VIC_ReadMemory(_PID: DWord; _lpAddress: DWord; _lpBuffer: Pointer; _dwSize: DWord); stdcall;  far; external nDLL;

Procedure RefreshList; stdcall;
var i: Integer;
begin
  if (Loopin = False) then
  begin
    Loopin:= True;
    MyProcList.Clear;
    try
      GetProcessList(MyProcList);
      if (MyProcList = NIL) then Exit;
      Form1.Combobox1.Clear;
      for i:= 1 to MyProcList.Count - 1 do
        Form1.Combobox1.Items.Add(MyProcList.Strings[i]);
    except
      MyProcList.Free;
    end;
    Loopin:= False;
  end;
end;

{$R *.dfm}

procedure TForm1.rfListClick(Sender: TObject);
begin
  Edit1.Text:= '';
  RefreshList;
end;

procedure TForm1.Button10Click(Sender: TObject);
var Buffer: DWord;
begin
  VIC_ReadMemory(GetEditInt(Edit1),$400000,@Buffer,4);
  VICBox('DWord at 400000h is: %0.8xh',[Buffer]);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if (Edit1.Text = '') then
  begin
    VICBox('Enter the pid of the process...');
    Exit;
  end;
  VIC_ZwTerminateProcess(GetEditInt(Edit1));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if (Edit1.Text = '') then
  begin
    VICBox('Enter the pid of the process...');
    Exit;
  end;
  VIC_Protect(GetEditInt(Edit1));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if (Edit1.Text = '') then
  begin
    VICBox('Enter the pid of the process...');
    Exit;
  end;
  VIC_UnProtect(GetEditInt(Edit1));
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if (Edit1.Text = '') then
  begin
    VICBox('Enter the pid of the process...');
    Exit;
  end;
  VIC_Hide(GetEditInt(Edit1));
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if (Edit1.Text = '') then
  begin
    VICBox('Enter the pid of the process...');
    Exit;
  end;
  VIC_UnHide(GetEditInt(Edit1));
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if (Edit1.Text = '') then
  begin
    VICBox('Enter the pid of the process...');
    Exit;
  end;
  VIC_ZwOpenProcess(GetEditInt(Edit1));
end;

procedure TForm1.Button7Click(Sender: TObject);
var sysrpm, syswpm: DWord;
begin
  sysrpm:= GetSyscallNumber('ntdll','ZwReadVirtualMemory');
  syswpm:= GetSyscallNumber('ntdll','ZwWriteVirtualMemory');
  VIC_HookRW(sysrpm,syswpm);
end;

procedure TForm1.Button8Click(Sender: TObject);
var sysrpm, syswpm: DWord;
begin
  sysrpm:= GetSyscallNumber('ntdll','ZwReadVirtualMemory');
  syswpm:= GetSyscallNumber('ntdll','ZwWriteVirtualMemory');
  VIC_UnHookRW(sysrpm,syswpm);
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  if (Edit1.Text = '') then
  begin
    VICBox('Enter the pid of the process...');
    Exit;
  end;
  VIC_Hide2(GetEditInt(Edit1));
end;

procedure TForm1.ComboBox1Select(Sender: TObject);
begin
  Edit1.Text:= '';
  Edit1.Text:= IntToStr(GetPIDFromLineList(ComboBox1.Text));
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key In ['0'..'9',#8]) then
  begin
    Key:= #0;
    Beep;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  VIC_LoadDriver;
  MyProcList:= TStringList.Create;
  RefreshList;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  VIC_UnLoadDriver;
end;

end.
