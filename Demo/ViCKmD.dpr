program ViCKmD;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  SomeFunctions in 'SomeFunctions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
