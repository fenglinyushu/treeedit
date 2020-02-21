program TreeEditor;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  teUnit in 'teUnit.pas',
  SysVars in 'SysVars.pas',
  About in 'About.pas' {Form_About};

{$R *.res}

begin
     Application.Initialize;

     //
     Application.CreateForm(TMainForm, MainForm);
  //
     Application.Run;
end.
