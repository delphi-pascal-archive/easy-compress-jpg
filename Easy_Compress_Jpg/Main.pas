////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                    E A S Y    C O M P R E S S     J P G                    //
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
//                                                                            //
//   Please read very carefully the WARNING located at the beginning of the   //
//   implementation block concerning EXIFTOOL before trying to compile !      //
//   IF YOU DO NOT, YOU'LL CERTAINLY GET AN ERROR                             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, ShellCtrls, XPMan, Types,
  ShellAPI, FileCtrl, Math, Jpeg, OleCtrls, StrUtils, DateUtils, Zip, SfxUtils, IniFiles;
type
  TMainForm = class(TForm)
    Panel_Parameters: TGroupBox;
    Panel_Files: TGroupBox;
    Panel_Compression: TGroupBox;
    Panel_Destination: TGroupBox;
    Btn_CloseApp: TBitBtn;
    Btn_AboutApp: TBitBtn;
    Btn_BeginCompression: TBitBtn;
    Btn_AddFile: TBitBtn;
    Btn_DeleteFile: TBitBtn;
    Btn_ViewFile: TBitBtn;
    CompressionRate: TTrackBar;
    RBtn_KeepOGSize: TRadioButton;
    RBtn_ChangeOGSize: TRadioButton;
    RBtn_ModifiedSize: TRadioGroup;
    RBtn_OverwriteFiles: TRadioButton;
    RBtn_CreateNewFolder: TRadioButton;
    RBtn_CreateZIPFile: TRadioButton;
    CBox_CreateBackup: TCheckBox;
    RBtn_KeepAllMetadata: TRadioButton;
    RBtn_RemoveAllMetadata: TRadioButton;
    CBox_ChangeDateData: TCheckBox;
    FilesSelectedDate: TDateTimePicker;
    CBox_AddCopyright: TCheckBox;
    CopyrightText: TEdit;
    Btn_ChangeCopyrightTextFormat: TBitBtn;
    PBar_ProgressionStatus: TProgressBar;
    Label_Title1: TLabel;
    Label_Title2: TLabel;
    Label_Advice1: TLabel;
    Label_Advice2: TLabel;
    Label_CompressionRate: TLabel;
    Label_ProgressionStatus: TLabel;
    SaveZIPFileDialog: TSaveDialog;
    CopyrightPositionTL: TShape;
    CopyrightPositionTR: TShape;
    CopyrightPositionBL: TShape;
    CopyrightPositionBR: TShape;
    XPManifest: TXPManifest;
    Label_Title3: TLabel;
    AddImageDialog: TOpenDialog;
    FileList: TListBox;
    BackupPath: TEdit;
    CopyToDirectoryPath: TEdit;
    ExportZipFilePath: TEdit;
    Btn_BrowseBackupPath: TBitBtn;
    Btn_BrowseCopyToDirectoryPath: TBitBtn;
    Btn_BrowseExportZipFilePath: TBitBtn;
    CopyrightFontDialog: TFontDialog;
    SelectedProfile: TComboBox;
    Label_ProfileTitle: TLabel;
    FilesSelectedTime: TDateTimePicker;
    CBox_DeleteThumbnails: TCheckBox;
    CBox_AddGlobalComment: TCheckBox;
    CommentText: TEdit;
    Image1: TImage;
    procedure RBtn_ModifiedSizeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Btn_AboutAppClick(Sender: TObject);
    procedure CBox_AddGlobalCommentClick(Sender: TObject);
    procedure Btn_BeginCompressionClick(Sender: TObject);
    procedure Btn_ChangeCopyrightTextFormatClick(Sender: TObject);
    procedure SelectedProfileChange(Sender: TObject);
    procedure Btn_BrowseExportZipFilePathClick(Sender: TObject);
    procedure Btn_BrowseCopyToDirectoryPathClick(Sender: TObject);
    procedure Btn_BrowseBackupPathClick(Sender: TObject);
    procedure CopyrightPositionMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CBox_AddCopyrightClick(Sender: TObject);
    procedure RBtn_MetadataChoiceClick(Sender: TObject);
    procedure RBtn_DestinationPathChoiceClick(Sender: TObject);
    procedure RBtn_OGSizeChoiceClick(Sender: TObject);
    procedure CompressionRateChange(Sender: TObject);
    procedure Btn_CloseAppClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Btn_ViewFileClick(Sender: TObject);
    procedure Btn_DeleteFileClick(Sender: TObject);
    procedure Btn_AddFileClick(Sender: TObject);
    procedure ChangeControlsDisponibility(EnableControls: boolean);
    procedure FileListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FileListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FileListClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure AddFilesFromPath(Path: string);
    procedure FilesSelectedTimeChange(Sender: TObject);
    procedure LoadProfiles();
    procedure ReadProfile(ProfileIndex: integer);
  private
    { Private Declarations }
    ZipComponent : TZip;
  public
    { Public Declarations }
    procedure DefaultHandler(var msg); override;
  end;



var
  MainForm: TMainForm;

  WM_PARAM_ATOM: cardinal;                //    >    Dynamic Parameters Message Identifier (see project source file "EasyCompressJpg.dpr" for more information)

  ErrorsList: TStringList;                //    >    This List contains all the successive errors the program may encounter when executing. Allows a better Error Display at the end of a process

  JPEGImage1: TJpegImage;                 //    \
  JPEGImage2: TJpegImage;                 //     >-  Image Variables which will be used during the compression process
  BMPTempImage1: TBitmap;                 //    /
  BMPTempImage2: TBitmap;                 //   /

  FIRST_EXECUTION: boolean = true;        //    \
  PROFILE_APPLYING: boolean = false;      //     >-   Execution Control Flags
  IS_PROCESSING_IMAGES: boolean = false;  //    /
  ABORT_REQUESTED: boolean = false;       //   /


  APP_PATH: string;                       //    \
  EXIFTOOL_PATH: string;                  //     >-   Commonly used Paths
  TEMP_PATH: string;                      //    /
  PROFILES_CFGFILE: string;               //   /

implementation

uses Error, About, Preview;

{$R *.dfm}



  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
  //                                                                          //
  //                                   //\\                                   //
  //                                  //  \\                                  //
  //                                 //    \\                                 //
  //                                //      \\                                //
  //                               //   ##   \\                               //
  //                              //    ##    \\                              //
  //                             //     ##     \\                             //
  //                            //      ##      \\                            //
  //                           //       ##       \\                           //
  //                          //                  \\                          //
  //                         //         @@         \\                         //
  //                        //          @@          \\                        //
  //                       //                        \\                       //
  //                      <<-=-=-=-=-=-=--=-=-=-=-=-=->>                      //
  //                                                                          //
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
  // WARNING  --  WARNING  --  WARNING  --  WARNING  --  WARNING  --  WARNING //
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
  //                                                                          //
  //      TWO EXTERNAL FILES ARE REQUIRED FOR A CORRECT PROGRAM EXECUTION :   //
  //           "EXIFTOOL.EXE" AND "ZIPDLL.DLL"                                //
  //      THEY ARE NORMALLY INCLUDED IN TWO RESOURCE FILES :                  //
  //           "EXIFTOOL.RES" AND "ZIPDLL.RES"                                //
  //                                                                          //
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
  //                                                                          //
  //  According to the distribution source from which you retrieved           //
  //  this program, the resource file "EXIFTOOL.RES" may be provided OR NOT   //                                               
  //                                                                 ^^^^^^   //
  //  In order to know if you are missing it or not, look for a file called   //
  //  "EXIFTOOL.RES" in the same directory as the project file.               //
  //                                                                          //
  //  If you find it, you're lucky and you can compile the application now!   //
  //                                                                          //
  //  If you don't find it DON'T WORRY and DON'T PANIC ! I'll help you!  :)   //
  //                                                                          //
  //  > Download ExifTool from the Internet :                                 //
  //    http://www.sno.phy.queensu.ca/~phil/exiftool/                         //
  //    ( here is a direct link for the version # 7.40 :                      //
  //      http://www.sno.phy.queensu.ca/~phil/exiftool/exiftool-7.40.zip      //
  //      but you should always get the lastest one of course )               //
  //                                                                          //
  //  > Unzip the ZipFile. You should get one file called "exiftool(-k).exe"  //
  //                                                                          //
  //  > Rename it "exiftool.exe"                                              //
  //                                                                          //
  //  > Then you have two different ways of pulling through :                 //
  //                                                                          //
  //    # On the one hand, the easier way :                                   //
  //      Copy the file to the application's execution directory.             //
  //      Remove the line "  {$R External_Resources\EXIFTOOL.RES}  "          //
  //      from the source code (you'll find it at the end of this warning)    //
  //      Compile the program now !                                           //
  //      In the future, you'll have to provide two files if you want to      //
  //      deploy the application on another computer :                        //
  //        [the application executable] AND [exiftool.exe]                   //
  //                                                                          //
  //    # On the other hand, the more convenient method for the future :      //
  //      Copy the file to the directory "External_Resources\EXIFTOOL\"       //
  //      Then compile the Resource Script "External_Resources\EXIFTOOL.RC"   //
  //      with Borland Resource Compiler                                      //
  //          Command line sample :                                           //
  //          brcc32 "C:\...\External_Resources\EXIFTOOL.RC"                  //
  //      The file "External_Resources\EXIFTOOL.RES" must have been created   //
  //      You can compile the program now !                                   //
  //      In the future, you will only need to provide the application        //
  //      executable to deploy the entire application on another computer.    //
  //                                                                          //
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
  // WARNING  --  WARNING  --  WARNING  --  WARNING  --  WARNING  --  WARNING //
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
  //                                                                          //
  // This resource file contains the "exiftool.exe" executable (EXIFTOOL)     //
  // which allows Metadata Processing                                         //
  //                                                                          //
                      {$R External_Resources\EXIFTOOL.RES}
  //                                                                          //
  //   ( YOU MAY REMOVE THIS LINE IF YOU USE EXIFTOOL AS AN EXTERNAL FILE )   //
  //                                                                          //
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
  //                                                                          //
  // This resource file contains the "ZipDll.dll" library (TZIP Component)    //
  // which allows ZIP Compression                                             //
  //                                                                          //
                        {$R External_Resources\ZIPDLL.RES}
  //                                                                          //
  //                  ( D O    N O T    R E M O V E    I T )                  //
  //                                                                          //
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//





//============================================================================//
//                      AUXILARY FUNCTIONS & PROCEDURES                       //
//============================================================================//
// Launches a process and wait until it ends
function LaunchAndWait(CommandLine: String; WShowWin: Word): Boolean;
var
  StartInfo   : TStartupInfo;
  ProcessInfo : TProcessInformation;
  Ended       : Boolean;
begin
  FillChar(StartInfo,SizeOf(StartInfo),#0);
  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.dwFlags:=STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow:=WShowWin;
  if CreateProcess(nil, PChar(CommandLine), nil, nil, False, 0, nil, nil, StartInfo,ProcessInfo) then begin
    Ended := False;
    repeat
      case WaitForSingleObject(ProcessInfo.hProcess, 200) of
        WAIT_OBJECT_0: Ended := True;
        WAIT_TIMEOUT : ;
      end;
      Application.ProcessMessages;
    until Ended;
    result := true;
  end else result := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
// Deletes a directory, even if it contains some files
function DeleteDirectory(Path: string): Boolean;
var 
  fos: TSHFileOpStruct;
begin
  Path := ExcludeTrailingPathDelimiter(Path);
  ZeroMemory(@fos, SizeOf(fos));
  with fos do begin
    wFunc := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(Path + #0);
  end;
  Result := (0=ShFileOperation(fos));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
// Changes a file CreationDate, LastModifiedDate, LastAccessedDate data
function CorruptFileDateTime(const FileName: string; NewDate: TDateTime): boolean;
var
  fHandle : integer;
  Succeed : boolean;
  FinalDate, TempFileTime : TFileTime;
  TempSystemTime : TSystemTime;
begin
  fHandle := FileOpen(FileName, fmShareDenyWrite or fmOpenWrite);
  if fHandle < 0 then Succeed := false
  else begin
    DecodeDateTime(NewDate, TempSystemTime.wYear, TempSystemTime.wMonth, TempSystemTime.wDay,
                   TempSystemTime.wHour, TempSystemTime.wMinute, TempSystemTime.wSecond, TempSystemTime.wMilliSeconds);
    SystemTimeToFileTime(TempSystemTime, TempFileTime);
    LocalFileTimeToFileTime(TempFileTime, FinalDate);
    Succeed := SetFileTime(fHandle, @FinalDate, @FinalDate, @FinalDate);
    FileClose(fHandle);
  end;
  Result := Succeed;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
// Extracts a FileName without any extension
function ExtractFileNameOnly(FileName:TFileName): TFileName;
var
  ExtensionPart : TFileName;
  ExtensionLength : Integer;
begin
 FileName := ExtractFileName(FileName);
 ExtensionPart := ExtractFileExt(FileName);
 ExtensionLength := Length(ExtensionPart);
 Delete(FileName, Length(FileName)-ExtensionLength+1,ExtensionLength);
 Result:=FileName;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
// Returns an available FileName (not used yet by any file) in a chosen directory
function FindAvailableFileName(Directory, FileName, FileExtension: string): string;
var
  FileDuplicationChars : string;
  FileDuplicationIndex : integer;
begin
  // WARNING : The "FileName" parameter MUST NOT contain any extension info
  // WARNING : The "FileExtension" parameter MUST include the '.' (dot sign)
  Directory := IncludeTrailingPathDelimiter(Directory);

  if FileExists(Directory + FileName + FileExtension) then begin
    FileDuplicationIndex := 2;
    FileDuplicationChars := ' ('+IntToStr(FileDuplicationIndex)+')';
    while FileExists(Directory + FileName + FileDuplicationChars + FileExtension) do begin
      Inc(FileDuplicationIndex);
      FileDuplicationChars := ' ('+IntToStr(FileDuplicationIndex)+')';
    end;
  end else FileDuplicationChars := '';

  result := Directory + FileName + FileDuplicationChars + FileExtension;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
// Returns a string of random [0-9] [a-z] [A-Z] chars
function RandomString(GeneratedStringLength: integer): string;
var
  i: integer;
  BaseChars, TempStr: string;
begin
  BaseChars := 'abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'; // Available Chars (they need to be compatible with a FileName)
  for i:=0 to GeneratedStringLength-1 do TempStr := TempStr + BaseChars[Random(61)+1];
  result := TempStr;
end;
//============================================================================//











//============================================================================//
//                      FILE LIST MANAGEMENT PROCEDURES                       //
//============================================================================//
// Procedures Concerning Buttons Management
procedure TMainForm.Btn_AddFileClick(Sender: TObject);
var
  i: integer;
begin
 if AddImageDialog.Execute then begin
   ErrorsList := TStringList.Create;
   ErrorsList.Clear;
   for i:=0 to AddImageDialog.Files.Count-1 do begin
     if FileExists(AddImageDialog.Files[i]) then FileList.Items.Add(AddImageDialog.Files[i]);
   end;
   if (ErrorsList.Text<>'') then begin
     ErrorForm.Caption := 'Erreur dans l''ajout de certains fichiers';
     ErrorForm.ErrorTitleMsg.Caption := 'Certains fichiers n''ont pas pu être ajoutés à la liste des images à compresser'+#13+'car leur format n''est pas pris en charge (extensions acceptées : jpg, jpeg, bmp):';
     ErrorForm.FilesConcernedMemo.Lines := ErrorsList;
     ErrorForm.ShowModal;
   end;
   ErrorsList.Free;
 end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.AddFilesFromPath(Path: string);
var
  SearchInfo: TSearchRec;
begin
  // If the selected location designs a file
  if FileExists(Path) then begin
    if (UpperCase(ExtractFileExt(Path)) = '.JPG')
       or (UpperCase(ExtractFileExt(Path)) = '.JPEG')
       or (UpperCase(ExtractFileExt(Path)) = '.BMP')
       then FileList.Items.Add(Path)
    else ErrorsList.Add(Path);
    exit;
  end;
  // If the selected location designs a directory
  Path := IncludeTrailingPathDelimiter(Path);
  if DirectoryExists(Path) then begin
    if FindFirst(Path+'*.*',faAnyFile,SearchInfo)=0 then begin
      repeat
        if (SearchInfo.Name[1]<>'.') then
          AddFilesFromPath(Path+SearchInfo.FindData.cFileName);
      until FindNext(SearchInfo)<>0;
      FindClose(SearchInfo);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_DeleteFileClick(Sender: TObject);
begin
  FileList.DeleteSelected;
  Btn_DeleteFile.Enabled := false;
  Btn_ViewFile.Enabled := false;
  FileList.ItemIndex:=-1;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_ViewFileClick(Sender: TObject);
begin
  // Preview of the focused image
  if FileList.ItemIndex = -1 then exit;
  DisplayForm.LoadPreview(FileList.Items[FileList.ItemIndex]);
end;
//============================================================================//
// Procedures Concerning ListBox Management and Selected Files
procedure TMainForm.FileListClick(Sender: TObject);
begin
  Btn_DeleteFile.Enabled := (FileList.SelCount <> 0);
  Btn_ViewFile.Enabled := (FileList.SelCount <> 0);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.FileListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  // For a better rendering, the FileName only is displayed in the ListBox
  if odSelected in State then begin
    FileList.Canvas.Brush.Color := clInfoBk;
    FileList.Canvas.FillRect(Rect);
  end else begin
    FileList.Canvas.Brush.Color := clWhite;
    FileList.Canvas.FillRect(Rect);
  end;
  FileList.Canvas.Font.Name := 'Tahoma';
  FileList.Canvas.Font.Size := 7;
  FileList.Canvas.Font.Color := clblack;
  FileList.Canvas.TextOut(Rect.Left+2, Rect.Top, ExtractFileName(FileList.Items[Index]));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.FileListKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if (Key=VK_DELETE) then Btn_DeleteFileClick(nil);
  if (Key=VK_INSERT) then Btn_AddFileClick(nil);
  if (Key=VK_RETURN) then Btn_ViewFileClick(nil);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.DefaultHandler(var msg);
var
  ReceivedParam: PChar;
  ReceivedAtom: atom;
  params: TStringList;
  i, NumberOfFiles: integer;
  StrFileName : string;
  FileName : array[0..255] of char;
begin
  inherited DefaultHandler(Msg);
  if IS_PROCESSING_IMAGES then exit; // Prevent from any addition of files during a compression process

  // Files Shell Selection Management
  if TMessage(msg).Msg = WM_PARAM_ATOM then begin
    ReceivedAtom := TMessage(msg).wParam; // The received parameter is located in wParam
    GetMem(ReceivedParam, 256);
    try
      GlobalGetAtomName(ReceivedAtom, ReceivedParam, 256); // Text Decode
      try
        params := TStringList.Create;
        ErrorsList := TStringList.Create;
        try
          params.Clear;
          params.Add(ReceivedParam);
          ErrorsList.Clear;
          for i := 0 to params.Count-1 do AddFilesFromPath(params[i]); // Calling for recursive addition procedure
          if (ErrorsList.Text<>'') then begin
            ErrorForm.Caption := 'Erreur dans l''ajout de certains fichiers';
            ErrorForm.ErrorTitleMsg.Caption := 'Certains fichiers n''ont pas pu être ajoutés à la liste des images à compresser'+#13+'car leur format n''est pas pris en charge (extensions acceptées : jpg, jpeg, bmp):';
            ErrorForm.FilesConcernedMemo.Lines := ErrorsList;
            ErrorForm.ShowModal;
          end;
        finally ErrorsList.Free; params.Free; end;
      finally GlobalDeleteAtom(ReceivedAtom); end;
    finally FreeMem(ReceivedParam); end;
  end;
  // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
  // Files Drag'n Drop Management
  if TMessage(msg).Msg=WM_DROPFILES then begin
    NumberOfFiles := DragQueryFile(TMessage(msg).wParam, $FFFFFFFF, FileName, sizeof(FileName));
    ErrorsList := TStringList.Create;
    ErrorsList.Clear;
    for i := 0 to NumberOfFiles-1 do
    begin
      DragQueryFile(TMessage(msg).wParam, i, FileName, sizeof(FileName));
      StrFileName := FileName;
      AddFilesFromPath(StrFileName); // Calling for recursive addition procedure
    end;
    if (ErrorsList.Text<>'') then begin
      ErrorForm.Caption := 'Erreur dans l''ajout de certains fichiers';
      ErrorForm.ErrorTitleMsg.Caption := 'Certains fichiers n''ont pas pu être ajoutés à la liste des images à compresser'+#13+'car leur format n''est pas pris en charge (extensions acceptées : jpg, jpeg, bmp):';
      ErrorForm.FilesConcernedMemo.Lines := ErrorsList;
      ErrorForm.ShowModal;
    end;
    ErrorsList.Free;
  end;


end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  if not FIRST_EXECUTION then exit
  else FIRST_EXECUTION := false;
  // Parameters Management .....................................................
  WM_PARAM_ATOM := RegisterWindowMessage('WM_PARAM_ATOM');
  if ParamCount = 0 then exit;
  ErrorsList := TStringList.Create;
  try
    ErrorsList.Clear;
    for i := 1 to ParamCount do AddFilesFromPath(ParamStr(i)); // Calling for recursive addition procedure
    if (ErrorsList.Text<>'') then begin
      ErrorForm.Caption := 'Erreur dans l''ajout de certains fichiers';
      ErrorForm.ErrorTitleMsg.Caption := 'Certains fichiers n''ont pas pu être ajoutés à la liste des images à compresser'+#13+'car leur format n''est pas pris en charge (extensions acceptées : jpg, jpeg, bmp):';
      ErrorForm.FilesConcernedMemo.Lines := ErrorsList;
      ErrorForm.ShowModal;
    end;
  finally ErrorsList.Free; end;
end;
//============================================================================//











//============================================================================//
//             PROCEDURES RELATED WITH GRAPHICAL USER INTERFACE               //
//============================================================================//
// Compression Options Panel
procedure TMainForm.CompressionRateChange(Sender: TObject);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
  Label_CompressionRate.Caption := IntToStr(CompressionRate.Position);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.RBtn_OGSizeChoiceClick(Sender: TObject);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
  RBtn_ModifiedSize.Enabled := RBtn_ChangeOGSize.Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.RBtn_ModifiedSizeClick(Sender: TObject);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
end;//============================================================================//
// Destination Options Panel
procedure TMainForm.RBtn_DestinationPathChoiceClick(Sender: TObject);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
  CBox_CreateBackup.Enabled := RBtn_OverwriteFiles.Checked;
  BackupPath.Enabled := CBox_CreateBackup.Checked and RBtn_OverwriteFiles.Checked;
  Btn_BrowseBackupPath.Enabled := CBox_CreateBackup.Checked and RBtn_OverwriteFiles.Checked;
  CopyToDirectoryPath.Enabled := RBtn_CreateNewFolder.Checked;
  Btn_BrowseCopyToDirectoryPath.Enabled := RBtn_CreateNewFolder.Checked;
  ExportZipFilePath.Enabled := RBtn_CreateZIPFile.Checked;
  Btn_BrowseExportZipFilePath.Enabled := RBtn_CreateZIPFile.Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_BrowseBackupPathClick(Sender: TObject);
var
  SelectedPath: string;
begin
  SelectedPath := BackupPath.Text;
  {$IFDEF VER170} // This overloaded version of SelectDirectory has been introduced in Delphi2005 - This allows Directory Creation inside the Dialog Box and other nice things...
  if not SelectDirectory('Sélectionnez l''emplacement de Destination de la Copie de Sauvegarde', '', SelectedPath, [sdNewUI, sdNewFolder, sdShowEdit, sdValidateDir, sdShowShares], nil) then exit;
  {$ELSE}
  if not SelectDirectory('Sélectionnez l''emplacement de Destination de la Copie de Sauvegarde', '', SelectedPath) then exit;
  {$ENDIF}
  BackupPath.Text := IncludeTrailingPathDelimiter(SelectedPath);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_BrowseCopyToDirectoryPathClick(Sender: TObject);
var
  SelectedPath: string;
begin
  SelectedPath := CopyToDirectoryPath.Text;
  {$IFDEF VER170} // This overloaded version of SelectDirectory has been introduced in Delphi2005 - This allows Directory Creation inside the Dialog Box and other nice things...
  if not SelectDirectory('Sélectionnez l''emplacement de Destination des Images', '', SelectedPath, [sdNewUI, sdNewFolder, sdShowEdit, sdValidateDir, sdShowShares], nil) then exit;
  {$ELSE}
  if not SelectDirectory('Sélectionnez l''emplacement de Destination des Images', '', SelectedPath) then exit;
  {$ENDIF}
  CopyToDirectoryPath.Text := IncludeTrailingPathDelimiter(SelectedPath);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_BrowseExportZipFilePathClick(Sender: TObject);
begin
  SaveZIPFileDialog.FileName := ExportZipFilePath.Text;
  if not SaveZIPFileDialog.Execute then exit;
  ExportZipFilePath.Text := SaveZIPFileDialog.FileName;
end;
//============================================================================//
// Metadata and Misc Options Panel
procedure TMainForm.RBtn_MetadataChoiceClick(Sender: TObject);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
  CBox_ChangeDateData.Enabled := RBtn_RemoveAllMetadata.Checked;
  CBox_DeleteThumbnails.Enabled := RBtn_RemoveAllMetadata.Checked;
  FilesSelectedDate.Enabled := CBox_ChangeDateData.Checked and RBtn_RemoveAllMetadata.Checked;
  FilesSelectedTime.Enabled := CBox_ChangeDateData.Checked and RBtn_RemoveAllMetadata.Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.CBox_AddCopyrightClick(Sender: TObject);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
  CopyrightText.Enabled := CBox_AddCopyright.Checked;
  Btn_ChangeCopyrightTextFormat.Enabled := CBox_AddCopyright.Checked;

  if CBox_AddCopyright.Checked then begin

    Label_Title3.Font.Color := clBlack;

    // Determines the location of the Copyright inlay
    if CopyrightPositionTL.Tag=0 then begin
      CopyrightPositionTL.Cursor := crHandPoint; CopyrightPositionTL.Brush.Color := clWhite;
    end else begin
      CopyrightPositionTL.Cursor := crArrow; CopyrightPositionTL.Brush.Color := clRed;
    end;

    if CopyrightPositionBL.Tag=0 then begin
      CopyrightPositionBL.Cursor := crHandPoint; CopyrightPositionBL.Brush.Color := clWhite;
    end else begin
      CopyrightPositionBL.Cursor := crArrow; CopyrightPositionBL.Brush.Color := clRed;
    end;

    if CopyrightPositionTR.Tag=0 then begin
      CopyrightPositionTR.Cursor := crHandPoint; CopyrightPositionTR.Brush.Color := clWhite;
    end else begin
      CopyrightPositionTR.Cursor := crArrow; CopyrightPositionTR.Brush.Color := clRed;
    end;

    if CopyrightPositionBR.Tag=0 then begin
      CopyrightPositionBR.Cursor := crHandPoint; CopyrightPositionBR.Brush.Color := clWhite;
    end else begin
      CopyrightPositionBR.Cursor := crArrow; CopyrightPositionBR.Brush.Color := clRed;
    end;

  end else begin

    Label_Title3.Font.Color := clMedGray;
    CopyrightPositionTL.Brush.Color := clBtnFace;  CopyrightPositionTR.Brush.Color := clBtnFace;
    CopyrightPositionBL.Brush.Color := clBtnFace;  CopyrightPositionBR.Brush.Color := clBtnFace;

    CopyrightPositionTL.Cursor := crArrow;  CopyrightPositionTR.Cursor := crArrow;
    CopyrightPositionBL.Cursor := crArrow;  CopyrightPositionBR.Cursor := crArrow;

  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.CopyrightPositionMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
  if not CBox_AddCopyright.Checked then exit;
  CopyrightPositionTL.Tag := 0;  CopyrightPositionTR.Tag := 0;
  CopyrightPositionBL.Tag := 0;  CopyrightPositionBR.Tag := 0;
  (Sender as TShape).Tag := 1;
  CBox_AddCopyrightClick(nil);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.CBox_AddGlobalCommentClick(Sender: TObject);
begin
  if not PROFILE_APPLYING then SelectedProfile.ItemIndex := 0;
  CommentText.Enabled := CBox_AddGlobalComment.Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_ChangeCopyrightTextFormatClick(Sender: TObject);
begin
  CopyrightFontDialog.Execute;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.FilesSelectedTimeChange(Sender: TObject);
begin
  // Allow the use of a single component for all DateTime handling
  FilesSelectedDate.Time := FilesSelectedTime.Time;
end;
//============================================================================//
// Profiles Management
procedure TMainForm.LoadProfiles;
var
  NumberOfProfiles, DefaultIndex, i: integer;
  TempProfileName: string;
begin
  // Initialization
  SelectedProfile.Items.Text := 'Personnalisé...';
  if not FileExists(PROFILES_CFGFILE) then begin
    SelectedProfile.ItemIndex := 0;
    exit;
  end;
  
  // Lists all available profiles from the configuration file
  with TIniFile.Create(PROFILES_CFGFILE) do try

    // Header Check
    if (ReadString('HEADER','ID','error')<>'17D5B2702D39F1A6C1E3ACEDAE99CC45') then exit;

    // Determines how many profiles are available
    NumberOfProfiles := ReadInteger('HEADER','NumberOfProfiles_int',0);
    if NumberOfProfiles<=0 then begin
      SelectedProfile.ItemIndex := 0;
      exit;
    end;

    for i:=1 to NumberOfProfiles do begin
      // If the name is incorrect, or if the field is missing (missing Section too?)
      TempProfileName := ReadString('PROFILE'+IntToStr(i),'Name_str','');
      if TempProfileName='' then TempProfileName:='Profil Inconnu';
      SelectedProfile.Items.Add(TempProfileName);
    end;

    // Default Profile Loading
    DefaultIndex := ReadInteger('HEADER','DefaultProfile_int',0);
    if (DefaultIndex>0) and (DefaultIndex<SelectedProfile.Items.Count) then SelectedProfile.ItemIndex := DefaultIndex
    else SelectedProfile.ItemIndex := 0;
    ReadProfile(SelectedProfile.ItemIndex);
    
  finally
    Free;
  end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.ReadProfile(ProfileIndex: integer);
var
  ProfileID: string;
  TempRate: integer;
begin
  if (ProfileIndex=-1) or (ProfileIndex=0) then exit;
  if not FileExists(PROFILES_CFGFILE) then begin
    LoadProfiles;
    exit;
  end;

  with TIniFile.Create(PROFILES_CFGFILE) do try

    // Header Check
    if ReadString('HEADER','ID','error')<>'17D5B2702D39F1A6C1E3ACEDAE99CC45' then exit;
    ProfileID := 'PROFILE'+IntToStr(ProfileIndex);
    
    // Section Check
    if not SectionExists(ProfileID) then begin
      LoadProfiles;
      exit;
    end;

    PROFILE_APPLYING := true;

    // Profile Reading
    TempRate := ReadInteger(ProfileID,'Compression_Rate_int',80);
    if (TempRate>0) and (TempRate<=100) then CompressionRate.Position := TempRate
    else CompressionRate.Position := 80;
    if ReadBool(ProfileID,'Compression_ReduceSize_bool',false) then begin
      RBtn_ChangeOGSize.Checked := true;
      RBtn_ModifiedSize.ItemIndex := ReadInteger(ProfileID,'Compression_NewSizeIndex_int',2);
    end else RBtn_KeepOGSize.Checked := true;
    case ReadInteger(ProfileID,'Destination_Index_int',0) of
      1:  RBtn_CreateNewFolder.Checked := true;
      2:  RBtn_CreateZIPFile.Checked := true;
     {0:} else begin
            RBtn_OverwriteFiles.Checked := true;
            CBox_CreateBackup.Checked := ReadBool(ProfileID,'Destination_MakeBackup_bool',false);
          end;
    end;
    if ReadBool(ProfileID,'Metadata_DeleteMetadata_bool',false) then begin
      RBtn_RemoveAllMetadata.Checked := true;
      CBox_DeleteThumbnails.Checked := ReadBool(ProfileID,'Metadata_DeleteThumbnails_bool',false);
      if ReadBool(ProfileID,'Metadata_ChangeDate_bool',false) then begin
        CBox_ChangeDateData.Checked := true;
        FilesSelectedDate.Date := ReadDate(ProfileID,'Metadata_NewDate_date',now);
        FilesSelectedTime.Time := ReadTime(ProfileID,'Metadata_NewTime_time',now);
      end else CBox_ChangeDateData.Checked := false;
    end else RBtn_KeepAllMetadata.Checked := true;
    if ReadBool(ProfileID,'Metadata_AddComment_bool',false) then begin
      CBox_AddGlobalComment.Checked := true;
      CommentText.Text := ReadString(PRofileID,'Metadata_Comment_str','');
    end else CBox_AddGlobalComment.Checked := false;
    if ReadBool(ProfileID,'Metadata_AddCopyright_bool',false) then begin
      CBox_AddCopyright.Checked := true;
      CopyrightText.Text := ReadString(PRofileID,'Metadata_Copyright_str','© Copyright ');
      case ReadInteger(ProfileID,'Metadata_CopyrightPosition_int',4) of
        // 1=TopLeft, 2=TopRight, 3=BottomLeft, 4=BottomRight
        1:  CopyrightPositionMouseUp(CopyrightPositionTL, mbLeft, [], 1, 1);
        2:  CopyrightPositionMouseUp(CopyrightPositionTR, mbLeft, [], 1, 1);
        3:  CopyrightPositionMouseUp(CopyrightPositionBL, mbLeft, [], 1, 1);
       {4:} else CopyrightPositionMouseUp(CopyrightPositionBR, mbLeft, [], 1, 1);
      end;
      CopyrightFontDialog.Font.Name := ReadString(ProfileID,'Metadata_CopyrightFontName_str','Tahoma');
      // FontName Validity Check :
      if (Screen.Fonts.IndexOf(CopyrightFontDialog.Font.Name) = -1) or (CopyrightFontDialog.Font.Name='') then CopyrightFontDialog.Font.Name:='Tahoma';
      try CopyrightFontDialog.Font.Size := ReadInteger(ProfileID,'Metadata_CopyrightFontSize_int',10);
      except CopyrightFontDialog.Font.Size := 10 end;
      try CopyrightFontDialog.Font.Color := StringToColor(ReadString(ProfileID,'Metadata_CopyrightFontColor_cl','clBlack'));
      except CopyrightFontDialog.Font.Color := clBlack end;
      CopyrightFontDialog.Font.Style := [];
      if ReadBool(ProfileID,'Metadata_CopyrightFontStyleBold_bool',true) then CopyrightFontDialog.Font.Style := CopyrightFontDialog.Font.Style + [fsBold];
      if ReadBool(ProfileID,'Metadata_CopyrightFontStyleItalic_bool',false) then CopyrightFontDialog.Font.Style := CopyrightFontDialog.Font.Style + [fsItalic];
      if ReadBool(ProfileID,'Metadata_CopyrightFontStyleUnderline_bool',false) then CopyrightFontDialog.Font.Style := CopyrightFontDialog.Font.Style + [fsUnderline];
      if ReadBool(ProfileID,'Metadata_CopyrightFontStyleStrikeOut_bool',false) then CopyrightFontDialog.Font.Style := CopyrightFontDialog.Font.Style + [fsStrikeOut];
    end else CBox_AddCopyright.Checked := false;

  finally
    Free;
    PROFILE_APPLYING := false;
  end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.SelectedProfileChange(Sender: TObject);
begin
  ReadProfile(SelectedProfile.ItemIndex);
end;
//============================================================================//
// General Behaviour
procedure TMainForm.ChangeControlsDisponibility(EnableControls: boolean);
begin
  // Disable Controls during a Compression Process / Enable them after
  Panel_Files.Enabled := EnableControls;
  Panel_Parameters.Enabled := EnableControls;
  Panel_Destination.Enabled := EnableControls;
  Panel_Compression.Enabled := EnableControls;
  SelectedProfile.Enabled := EnableControls;
  Btn_BeginCompression.Enabled := EnableControls;

  if EnableControls then Btn_CloseApp.Caption := 'Quitter'
  else Btn_CloseApp.Caption := 'Annuler';

  Application.ProcessMessages;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_CloseAppClick(Sender: TObject);
begin
  // EXIT/CANCEL Button Management
  if not IS_PROCESSING_IMAGES then Application.Terminate
  else ABORT_REQUESTED := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.Btn_AboutAppClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;
//============================================================================//










//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM//
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM//
//                            COMPRESSION PROCESS                             //
//WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW//
//WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW//
procedure TMainForm.Btn_BeginCompressionClick(Sender: TObject);
var
  i,j: integer;
  FileName, FinalDestinationFileName, FinalDestinationPath, OriginalFileExtension, ZIPFileName,
  BackupDestinationFileName, BackupDestinationPath, MetaDataSourceFileName: string; // Some FileNames and Paths
  xOG, yOG, xRED, yRED, tmp: integer; // Original and Reducted Dimensions
  xratio, yratio, finalratio: extended; // ratios used in the reduction of the file dimensions
  xText, yText: integer; // Copyright Position
  FieldsCorrectlyCompleted, IsCorrectlyLoaded, IsCorrectlySaved, IsLandscapeFormat: boolean; // Some Execution Flags
  BMPTempImage3 : TBitmap; // allow the Resize Method
  FormattedNewFileDateTime: string; // String used during a file DateTime Corruption
  ZIPPendingFiles: TStringList; // List of all the files awaiting to be compressed in a ZIP file
begin




  //////////////////////////////////////////////////////////////////////////////
  // INITIAL COMPLETION CHECKING : SOURCE & DESTINATION FIELDS .................
  if FileList.Items.Count=0 then begin
    MessageBoxA(Handle,Pchar('Aucun fichier n''a été sélectionné.'+#13+'Le processus ne peut pas continuer.'),Pchar('Erreur'), MB_ICONSTOP + MB_SYSTEMMODAL + MB_SETFOREGROUND + MB_TOPMOST);
    exit;
  end;

  if ( (RBtn_OverwriteFiles.Checked)  and (CBox_CreateBackup.Checked) and (BackupPath.Text='') )
  or ( (RBtn_CreateNewFolder.Checked) and (CopyToDirectoryPath.Text='') )
  or ( (RBtn_CreateZIPFile.Checked)   and (ExportZipFilePath.Text  ='') ) then begin
    MessageBoxA(Handle,Pchar('L''emplacement de destination sélectionné pour les fichiers compressés n''est pas valide.'+#13+'Le processus ne peut pas continuer.'),Pchar('Erreur'), MB_ICONSTOP + MB_SYSTEMMODAL + MB_SETFOREGROUND + MB_TOPMOST);
    exit;
  end;
  //////////////////////////////////////////////////////////////////////////////


  //----------------------------------------------------------------------------


  //////////////////////////////////////////////////////////////////////////////
  // PROCEDURE INITIALIZATION ..................................................
  Label_ProgressionStatus.Caption := 'Initialisation du processus de compression...';
  ChangeControlsDisponibility(false);

  IS_PROCESSING_IMAGES := true;
  ABORT_REQUESTED := false;

  PBar_ProgressionStatus.Position := 0;
  PBar_ProgressionStatus.Max := FileList.Count;
  Application.ProcessMessages;

  ErrorsList := TStringList.Create;
  ErrorsList.Clear;
  //////////////////////////////////////////////////////////////////////////////


  //----------------------------------------------------------------------------


  //////////////////////////////////////////////////////////////////////////////
  // DIRECTORIES MANAGING ......................................................
  if RBtn_OverwriteFiles.Checked then begin
    // "Overwrite Files" Selected
    // Backup Creation Process -  Any individual path information will be discarded due to the risk of going over the 255 chars allowed for each filename
    if CBox_CreateBackup.Checked then begin
      BackupDestinationPath := BackupPath.Text;
    end else begin // Even if it was not requested by the user, we need to do a copy of the file in order to be able to transfert its metadata to the new one if it's necessary
      BackupDestinationPath := TEMP_PATH;
    end;
  end else begin
    // "Copy Files" or "Create Zip" Selected (common process, only the destination path changes now)
    if RBtn_CreateNewFolder.Checked then begin
      FinalDestinationPath := IncludeTrailingPathDelimiter(CopyToDirectoryPath.Text);
    end else if RBtn_CreateZIPFile.Checked then begin // Creation of a Temporary Folder which will contain all the files before ZIP compression
      ZIPFileName := ExportZipFilePath.Text;
      ZIPPendingFiles := TStringList.Create;
      ZIPPendingFiles.Clear;
      // The addition of a random string is quite necessary in the next step :
      // In fact, if the process restarts with exactly the same parameters,
      // and if the program has not been able to delete the "$temp$\xxx" folder
      // before the new execution, the final files will be named differently!
      FinalDestinationPath := TEMP_PATH + ExtractFileNameOnly(ZIPFileName) + RandomString(10);
    end;
  end;
  //////////////////////////////////////////////////////////////////////////////




  //############################################################################
  // MAIN LOOP ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  FOR i := 0 TO FileList.Count-1 DO BEGIN



            ////////////////////////////////////////////////////////////////////
            // TEST OF ANY PENDING ABORTION REQUEST ............................
            if ABORT_REQUESTED then begin
              Label_ProgressionStatus.Caption := 'Annulation en cours...';
              Application.ProcessMessages;
              for j := i to FileList.Count-1 do ErrorsList.Add(FileList.Items[j]+' : Traitement annulé par l''utilisateur.');
              Break; // Compression Process Abort : Whole Set of Pictures
            end;
            ////////////////////////////////////////////////////////////////////


            //------------------------------------------------------------------


            ////////////////////////////////////////////////////////////////////
            // PRELIMINARY TEST : FILE ACCESS ..................................
            FileName := FileList.Items[i];
            Label_ProgressionStatus.Caption := 'Traitement du fichier '+ExtractFileName(FileName);
            Application.ProcessMessages;
            if not FileExists(FileName) then begin
              ErrorsList.Add(FileName+' : le fichier n''est pas accessible, il a peut-être été supprimé.');
              Continue; // Compression Process Abort : Next Picture
            end;
            ////////////////////////////////////////////////////////////////////


            //------------------------------------------------------------------


            ////////////////////////////////////////////////////////////////////
            // FILE LOADING ....................................................
            IsCorrectlyLoaded := true;
            try
              if (UpperCase(ExtractFileExt(FileName))='.JPEG') or (UpperCase(ExtractFileExt(FileName))='.JPG') then begin
                JPEGImage1.LoadFromFile(FileName); // File loading
                Application.ProcessMessages;
                BMPTempImage1.Assign(JPEGImage1);
              end else if (UpperCase(ExtractFileExt(FileName))='.BMP') then begin
                BMPTempImage1.LoadFromFile(FileName); // File loading
              end;
              // Errors occur working with JPEG files when
              // ( Image.Height <= 1 )  OR  ( Image.Width < 1 )
              // Notice the slightly different operators!
              // If ( Image.Height = 1 ), an error will occur later in this program due to a limitation of the ScanLine method used to read Bitmap Data
              if ((BMPTempImage1.Height<=1) or (BMPTempImage1.Width=0)) then IsCorrectlyLoaded := false;
            except
              IsCorrectlyLoaded := false;
            end;
            if not IsCorrectlyLoaded then begin
              ErrorsList.Add(FileName+' : le format du fichier ne convient pas à l''exécution de ce processus, il peut être corrompu.');
              Continue; // Compression Process Abort : Next Picture
            end;
            ////////////////////////////////////////////////////////////////////


            //------------------------------------------------------------------


            ////////////////////////////////////////////////////////////////////
            // BITMAP REDUCTION IF REQUIRED ....................................
            if RBtn_ChangeOGSize.Checked then begin
              xOG := BMPTempImage1.Width; yOG := BMPTempImage1.Height;

              if xOG>=yOG then IsLandscapeFormat:=true // Landscape format
              else begin // Portrait Format : (x;y) Size Inversion
                IsLandscapeFormat := false;
                tmp := xOG;   xOG := yOG;   yOG := tmp; // Exchange xOG and yOG values
              end;

              xRED:=0; yRED:=0; // <-- Only to avoid Compiler Warnings, no practical use
              case RBtn_ModifiedSize.ItemIndex of // Dimensions for Default Ratios Calculation
               0:begin   xRED:=640;    yRED:=480;   end;
               1:begin   xRED:=800;    yRED:=600;   end;
               2:begin   xRED:=1024;   yRED:=768;   end;
               3:begin   xRED:=1280;   yRED:=1024;  end;
               4:begin   xRED:=1600;   yRED:=1200;  end;
               5:begin   xRED:=2048;   yRED:=1536;  end;
              end;
              xratio:=(100*xRED)/xOG;  yratio:=(100*yRED)/yOG;

              if (xratio>=100) and (yratio>=100) then BMPTempImage2.Assign(BMPTempImage1) // No Image Reduction : Direct Assignation
              else begin
                finalratio := MinValue([xratio, yratio]); // Image Reduction : Selection of the lowest ratio
                if not IsLandscapeFormat then begin
                  tmp := xOG;   xOG := yOG;   yOG := tmp; // Re-Exchange xOG and yOG values
                end;
                xRED := round(xOG*finalratio/100);   yRED := round(yOG*finalratio/100);

                // The following tests prevent us from beeing in the same situation as above ( "FILE LOADING" Section )
                if xRED=0 then xRED := 1;            if yRED<=1 then yRED := 2;

                BMPTempImage3 := TBitmap.Create;
                try
                  BMPTempImage3.Width := xRED;
                  BMPTempImage3.Height := yRED;
                  BMPTempImage3.PixelFormat := BMPTempImage1.PixelFormat;
                  SetStretchBltMode(BMPTempImage3.Canvas.Handle, HALFTONE); // Halftone is used for a better output image quality
                  StretchBlt(BMPTempImage3.Canvas.Handle, 0, 0, xRED, yRED, BMPTempImage1.Canvas.Handle, 0, 0, xOG, yOG, SRCCOPY);
                  BMPTempImage2.Width := xRED;
                  BMPTempImage2.Height := yRED;
                  BMPTempImage2.PixelFormat := BMPTempImage1.PixelFormat;
                  BMPTempImage2.Assign(BMPTempImage3);
                finally
                  BMPTempImage3.Free;
                end;

             end;
            end else begin
              BMPTempImage2.Assign(BMPTempImage1); // No Image Reduction Required : Direct Assignation
            end;
            ////////////////////////////////////////////////////////////////////


            //------------------------------------------------------------------


            ////////////////////////////////////////////////////////////////////
            // COPYRIGHT INLAY IF REQUIRED .....................................
            if CBox_AddCopyright.Checked then begin
              BMPTempImage2.Canvas.Brush.Style := BsClear;
              BMPTempImage2.Canvas.Font := CopyrightFontDialog.Font;
              xText:=30; yText:=30; // <-- Only to avoid Compiler Warnings, no practical use
              if CopyrightPositionTL.Tag=1 then begin
                xText := 30;
                yText := 30;
              end else if CopyrightPositionBL.Tag=1 then begin
                xText := 30;
                yText := BMPTempImage2.Height-(BMPTempImage2.Canvas.TextHeight(CopyrightText.Text)+30);
              end else if CopyrightPositionTR.Tag=1 then begin
                xText := BMPTempImage2.Width-(BMPTempImage2.Canvas.TextWidth(CopyrightText.Text)+30);
                yText := 30;
              end else if CopyrightPositionBR.Tag=1 then begin
                xText := BMPTempImage2.Width-(BMPTempImage2.Canvas.TextWidth(CopyrightText.Text)+30);
                yText := BMPTempImage2.Height-(BMPTempImage2.Canvas.TextHeight(CopyrightText.Text)+30);
              end;
              BMPTempImage2.Canvas.TextOut(xText, yText, CopyrightText.Text);
            end;
            ////////////////////////////////////////////////////////////////////


            //------------------------------------------------------------------


            ////////////////////////////////////////////////////////////////////
            // FILE SAVING .....................................................
            if RBtn_OverwriteFiles.Checked then begin
              // "Overwrite Files" Selected
              OriginalFileExtension := ExtractFileExt(FileName);
              ForceDirectories(BackupDestinationPath);
              BackupDestinationFileName := FindAvailableFileName(BackupDestinationPath, ExtractFileNameOnly(FileName), OriginalFileExtension);
              if not CopyFile(PChar(FileName),PChar(BackupDestinationFileName),true) then begin
                ErrorsList.Add(FileName+' : le fichier n''a pas pu être sauvegardé correctement. Il n''a donc pas été modifié.');
                Continue; // Compression Process Abort : Next Picture
              end;
              // File Overwrite
              if (OriginalFileExtension='.jpeg') then RenameFile(FileName,ChangeFileExt(FileName,'.jpg'));
              Application.ProcessMessages;
              FinalDestinationFileName := ChangeFileExt(FileName,'.jpg');
            end else begin
              // "Copy Files" or "Create Zip" Selected (common process)
              ForceDirectories(FinalDestinationPath);
              Application.ProcessMessages;
              FinalDestinationFileName := FindAvailableFileName(FinalDestinationPath, ExtractFileNameOnly(FileName), '.jpg');
            end;

            // COMMON COMPRESSION & SAVING PROCESS
            IsCorrectlySaved := true;
            JPEGImage2 := TJpegImage.Create;
            try
              try
                JPEGImage2.Assign(BMPTempImage2);
                Application.ProcessMessages;
                JPEGImage2.CompressionQuality := CompressionRate.Position;
                JPEGImage2.Compress;
                JPEGImage2.SaveToFile(FinalDestinationFileName);
              except
                IsCorrectlySaved:= false;
              end;
            finally
              JPEGImage2.Free;
            end;
            if not IsCorrectlySaved then begin
              ErrorsList.Add(FileName+' : le fichier n''a pas pu être compressé. Erreur lors de l''enregistrement.');
              Continue; // Compression Process Abort : Next Picture
            end;

            if (RBtn_OverwriteFiles.Checked) and (OriginalFileExtension='.bmp') then DeleteFile(FileName); // If the Original File was a Bitmap File, it has not been overwritten yet if it was required, so we need to delete it now
            if RBtn_CreateZIPFile.Checked then ZIPPendingFiles.Add(FinalDestinationFileName); // Add the file name to the ZIP pending list if required. Note : there is a compiler warning on this line, that's because the ZIPPendingFiles StringList is created inside a test structure. No need to worry! 

            Application.ProcessMessages;
            ////////////////////////////////////////////////////////////////////


            //------------------------------------------------------------------


            ////////////////////////////////////////////////////////////////////
            // METADATA PROCESSING .............................................

            // Determines the source of the metadata transfert
            if RBtn_OverwriteFiles.Checked then MetaDataSourceFileName:=BackupDestinationFileName
            else MetaDataSourceFileName := FileName;
            // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            if RBtn_KeepAllMetadata.Checked then begin
              LaunchAndWait('"'+EXIFTOOL_PATH+'" -TagsFromFile "'+MetaDataSourceFileName+'" -all:all "'+FinalDestinationFileName+'" -P -q -m -overwrite_original',SW_HIDE);
              Application.ProcessMessages;
            end;
            // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            if CBox_AddGlobalComment.Checked then begin
              // Notice here the "-L" parameter, which allows to write special chars in this section
              LaunchAndWait('"'+EXIFTOOL_PATH+'" -UserComment="'+CommentText.Text+'" -XPComment="'+CommentText.Text+'" -xmp:UserComment="'+CommentText.Text+'" -Comment="'+CommentText.Text+'" "'+FinalDestinationFileName+'" -P -q -m -L -overwrite_original',SW_HIDE);
              Application.ProcessMessages;
            end;
            // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            if CBox_AddCopyright.Checked then begin // In addition to the copyright bitmap inlay
              // Notice here too the "-L" parameter, which allows to write special chars in this section
              LaunchAndWait('"'+EXIFTOOL_PATH+'" -Copyright="'+CopyrightText.Text+'" "'+FinalDestinationFileName+'" -P -q -m -L -overwrite_original',SW_HIDE);
              Application.ProcessMessages;
            end;
            // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            if RBtn_RemoveAllMetadata.Checked then begin
              if not CBox_DeleteThumbnails.Checked then begin
                // We need to insert back the thumbnail in the new image file
                LaunchAndWait('"'+EXIFTOOL_PATH+'" -TagsFromFile "'+MetaDataSourceFileName+'" -ThumbnailImage "'+FinalDestinationFileName+'" -P -q -m -overwrite_original',SW_HIDE);
                Application.ProcessMessages;
              end;
              // + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
              if (RBtn_RemoveAllMetadata.Checked) and (CBox_ChangeDateData.Checked) then begin
                // Metadata DateTime Corruption - This must be the Last Modification done on the file !
                FormattedNewFileDateTime := FormatDateTime('yyyy:mm:dd hh:mm:ss', FilesSelectedDate.DateTime);
                LaunchAndWait('"'+EXIFTOOL_PATH+'" -DateTimeOriginal="'+FormattedNewFileDateTime+'" '
                                                 +'-CreateDate="'+FormattedNewFileDateTime+'Z" '
                                                 +'-MetadataDate="'+FormattedNewFileDateTime+'Z" '
                                                 +'-ModifyDate="'+FormattedNewFileDateTime+'" '
                                                 +'"'+FinalDestinationFileName+'" -P -q -m -overwrite_original',SW_HIDE);
                Application.ProcessMessages;
                // File DateTime Corruption (CreationDate, LastModifiedDate, LastAccessedDate)
                CorruptFileDateTime(FinalDestinationFileName, FilesSelectedDate.DateTime);
              end;
            end;
            ////////////////////////////////////////////////////////////////////


            //------------------------------------------------------------------


            ////////////////////////////////////////////////////////////////////
            // DELETION OF TEMPORARY FILES .....................................
            if (RBtn_OverwriteFiles.Checked) and (not CBox_CreateBackup.Checked) then DeleteFile(BackupDestinationFileName);
            ////////////////////////////////////////////////////////////////////



    PBar_ProgressionStatus.Position := i+1;

  END;
  //############################################################################



  //////////////////////////////////////////////////////////////////////////////
  // ZIP FOLDER CREATION IF REQUIRED ...........................................
  if (RBtn_CreateZIPFile.Checked) and (not ABORT_REQUESTED) then begin

    if FileExists(ZIPFileName) and (not DeleteFile(ZIPFileName)) then begin
      ErrorsList.Add('ERREUR FATALE : LA CREATION DU DOSSIER ZIP A ECHOUE ('+ExtractFileName(ZIPFileName)+')');
      ErrorsList.Add('VERIFIEZ QUE L''EMPLACEMENT DE DESTINATION EST DISPONIBLE EN ECRITURE');
      ABORT_REQUESTED := false;
    end else begin

      ZipComponent := TZip.create(self);
      try
        try
          ZipComponent.FileName := ZIPFileName;
          if CBox_AddGlobalComment.Checked then ZipComponent.ZipComment := CommentText.Text
          else ZipComponent.ZipComment := '';
          ZipComponent.FileSpecList := ZipPendingFiles;
          ZipComponent.AddOptions := [aoUpdate];
          // We check how many files were added successfully. If it does not match the number of selected files, there has been an error
          if (ZipComponent.Add <> ZipPendingFiles.Count) then begin
            if ZipComponent.Cancelled then begin
              ABORT_REQUESTED := true;
              ErrorsList.Add(ZIPFileName+' : la création du fichier ZIP a été annulée par l''utilisateur.');
            end else begin
              ABORT_REQUESTED := false;
              ErrorsList.Add('Certains fichiers n''ont pas pu être ajoutés au dossier ZIP "'+ExtractFileName(ZIPFileName)+'"');
              ErrorsList.Add('Vérifiez que l''emplacement de destination est disponible en écriture et que les fichiers temporaires n''ont pas été altérés.');
            end;
          end;
        except
          ErrorsList.Add('ERREUR FATALE : LA CREATION DU DOSSIER ZIP A ECHOUE ('+ExtractFileName(ZIPFileName)+')');
          ErrorsList.Add('VERIFIEZ QUE L''EMPLACEMENT DE DESTINATION EST DISPONIBLE EN ECRITURE');
          ABORT_REQUESTED := false;
        end;
      finally
        ZipComponent.Free;
      end;
      // ZIP DateTime Information Corruption if required
      if CBox_ChangeDateData.Checked then CorruptFileDateTime(ZIPFileName, FilesSelectedDate.DateTime);

    end;  
  end;
  //////////////////////////////////////////////////////////////////////////////


  //----------------------------------------------------------------------------


  //////////////////////////////////////////////////////////////////////////////
  // Compression Process Abortion Signal Management
  if ABORT_REQUESTED then begin

    PBar_ProgressionStatus.Position := PBar_ProgressionStatus.Max;
    Label_ProgressionStatus.Caption := 'Procédure annulée par l''utilisateur';
    Application.ProcessMessages;
    ErrorForm.Caption := 'Procédure annulée par l''utilisateur';
    if RBtn_OverwriteFiles.Checked then ErrorForm.ErrorTitleMsg.Caption := 'Certains fichiers n''ont pas été compressés'+#13+'Les fichiers déjà traités ne seront pas restaurés.'
    else ErrorForm.ErrorTitleMsg.Caption := 'Certains fichiers n''ont pas été compressés'+#13+'Les fichiers déjà traités ne seront pas supprimés de la destination';
    ErrorForm.FilesConcernedMemo.Lines := ErrorsList;
    ErrorForm.ShowModal;

    // Reset all parameters, free resources
    IS_PROCESSING_IMAGES := false;
    ABORT_REQUESTED := false;
    ChangeControlsDisponibility(true);
    if RBtn_CreateZIPFile.Checked then ZipPendingFiles.Free;
    ErrorsList.Free;
    Application.ProcessMessages;
    DeleteDirectory(TEMP_PATH);
    Application.ProcessMessages;
    exit;
  end else begin
    Btn_CloseApp.Caption := 'Annulation'#10#13'Impossible';
    Btn_CloseApp.Enabled := false;
  end;
  //////////////////////////////////////////////////////////////////////////////


  //----------------------------------------------------------------------------


  //////////////////////////////////////////////////////////////////////////////
  // Compression Process Success Signal Management
  PBar_ProgressionStatus.Position := PBar_ProgressionStatus.Max;
  // Potential Errors Processing
  if (ErrorsList.Text<>'') then begin
    Label_ProgressionStatus.Caption := 'Compression terminée avec des erreurs';
    Application.ProcessMessages;
    ErrorForm.Caption := 'Erreur dans la compression certains fichiers';
    ErrorForm.ErrorTitleMsg.Caption := 'Certains fichiers n''ont pas pu être compressés correctement'+#13+'Vérifiez leur format et leur accessibilité :';
    ErrorForm.FilesConcernedMemo.Lines := ErrorsList;
    ErrorForm.ShowModal;
  end else begin
    Label_ProgressionStatus.Caption := 'Compression terminée avec succès';
    Application.ProcessMessages;
    MessageBoxA(MainForm.Handle,Pchar('Tous les fichiers ont été compressés avec succès'),Pchar('Compression Terminée'),MB_ICONINFORMATION + MB_SYSTEMMODAL + MB_SETFOREGROUND + MB_TOPMOST);
  end;

  // Reset all parameters, free resources
  IS_PROCESSING_IMAGES := false;
  Btn_CloseApp.Enabled := true;
  ChangeControlsDisponibility(true);
  Btn_CloseApp.Enabled := true;
  if RBtn_CreateZIPFile.Checked then ZipPendingFiles.Free;
  ErrorsList.Free;
  Application.ProcessMessages;
  DeleteDirectory(TEMP_PATH);
  Application.ProcessMessages;


end;
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM//
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM//
//                        END OF COMPRESSION PROCESS                          //
//WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW//
//WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW//















//============================================================================//
//     PROCEDURES RELATED WITH APPLICATION INITIALIZATION / FINALIZATION      //
//============================================================================//
procedure TMainForm.FormCreate(Sender: TObject);
var
  RES: TResourceStream;
begin
  DragAcceptFiles(FileList.Handle, true); // Allows Drag'n Drop procedures
  FilesSelectedDate.Date := now;
  FilesSelectedTime.Time := now;

  APP_PATH := IncludeTrailingPAthDelimiter(ExtractFilePath(Application.ExeName));
  EXIFTOOL_PATH := APP_PATH+'exiftool.exe';
  TEMP_PATH := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + '$temp$\';
  PROFILES_CFGFILE := APP_PATH+'CompressionProfiles.jcfg';

  if not FileExists(EXIFTOOL_PATH) then begin
    try
      RES := TResourceStream.Create(0, 'EXIFTOOL', 'EXEFILE');
      try
        RES.SaveToFile(EXIFTOOL_PATH);
        Application.ProcessMessages;
      finally
        RES.Free;
      end;
    except
      MessageBoxA(0,Pchar('Une erreur s''est produite pendant l''initialisation du programme, qui empêche son exécution.'+#13+'Le fichier "exiftool.exe" n''a pas été trouvé dans le dossier de l''application et n''a pas pu être recréé.'),Pchar('Erreur'), MB_ICONSTOP + + MB_ICONINFORMATION + MB_SYSTEMMODAL + MB_SETFOREGROUND + MB_TOPMOST);
      Application.Terminate;
    end;
  end;

  if not FileExists(APP_PATH+'ZipDll.dll') then begin
    try
      RES := TResourceStream.Create(0, 'ZIPDLL', RT_RCDATA);
      try
        RES.SaveToFile(APP_PATH+'ZipDll.dll');
        Application.ProcessMessages;
      finally
        RES.Free;
      end;
    except
      MessageBoxA(0,Pchar('Une erreur s''est produite pendant l''initialisation du programme, qui empêche son exécution.'+#13+'Le fichier "ZipDll.dll" n''a pas été trouvé dans le dossier de l''application et n''a pas pu être recréé.'),Pchar('Erreur'), MB_ICONSTOP + + MB_ICONINFORMATION + MB_SYSTEMMODAL + MB_SETFOREGROUND + MB_TOPMOST);
      Application.Terminate;
    end;
  end;

  LoadProfiles();
  
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if IS_PROCESSING_IMAGES then CanClose:=false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
initialization
  Randomize; // Necessary for the RandomString() function
  JPEGImage1 := TJpegImage.Create;
  BMPTempImage1 := TBitmap.Create;
  BMPTempImage2 := TBitmap.Create;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
finalization
  BMPTempImage2.Free;
  BMPTempImage1.Free;
  JPEGImage1.Free;
  Application.ProcessMessages;
  DeleteDirectory(TEMP_PATH);
end.
