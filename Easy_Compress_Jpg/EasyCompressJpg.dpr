////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                   E A S Y    C O M P R E S S    J P G                      //
//                                                                            //
//                                Version 4.0                                 //
//                              Nicolas PAGLIERI                              //
//                                                                            //
//                               www.ni69.info                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            delphifr.com : ni69                             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

program EasyCompressJpg;

uses
  Windows, SysUtils, Classes, Forms, Messages, // Mandatory for the parameterss processing
  Main in 'Main.pas' {MainForm},
  Preview in 'Preview.pas' {DisplayForm},
  Error in 'Error.pas' {ErrorForm},
  About in 'About.pas' {AboutForm},
  SfxUtils in 'TZIP\SfxUtils.pas',
  Zip in 'TZIP\Zip.pas',
  ZipDlls in 'TZIP\ZipDlls.pas';

var
 ClassName : Array[0..255] of char;
 WM_PARAM_ATOM : integer;
 result : integer;
 h: THandle;
 Param_Atom: Atom;
 nb : integer;

{$R EasyCompressJpg.res}

begin
  // This Code Snippet allows the application to recieve parameters even if it's already running
  // (a shell extension use for example)
  Application.Initialize;
  Application.Title := 'Starting EasyCompressJpg...';
  GetClassName(Application.handle, ClassName, 254);
  result := FindWindow(ClassName, 'EasyCompressJpg version 4.0 par Nicolas Paglieri');
  h := FindWindow(nil,'EasyCompressJpg version 4.0 par Nicolas Paglieri');
  if result <> 0 then begin
    // The window already exists, so the program is already running
    // Registration of the Message which will be sent
    WM_PARAM_ATOM := RegisterWindowMessage('WM_PARAM_ATOM');
    // If there is a least one parameter, it is sent to the existing application
    if ParamCount > 0 then begin
      for nb := 1 to ParamCount do begin
        Param_Atom := GlobalAddAtom(PChar(ParamStr(nb)));
        SendMessage(h, WM_PARAM_ATOM, Param_Atom, 0);
      end;
    end;
    // Focuses the existing application
    ShowWindow(result, SW_RESTORE);
    SetForegroundWindow(result);
    // Then this process terminates
    Application.Terminate;
  end else begin
    // Otherwise, it's the first time the application is launched : Standard Loading
    Application.Title := 'EasyCompressJpg version 4.0 par Nicolas Paglieri';
    Application.CreateForm(TMainForm, MainForm);
    Application.CreateForm(TErrorForm, ErrorForm);
    Application.CreateForm(TAboutForm, AboutForm);
    Application.CreateForm(TDisplayForm, DisplayForm);
    Application.Run;
  end;
end.
