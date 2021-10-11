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

unit Preview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Jpeg, Buttons;

type
  TDisplayForm = class(TForm)
    Panel_DisplayImage: TPanel;
    DisplayImage: TImage;
    Panel_DisplaySettings: TGroupBox;
    RBtn_ShowOriginalImage: TRadioButton;
    RBtn_ShowPreviewImage: TRadioButton;
    CompressionRate: TTrackBar;
    Label_CompressionRate: TLabel;
    Label_Advice2: TLabel;
    Label_Advice1: TLabel;
    Label_Title1: TLabel;
    ZoomFactorIndex: TTrackBar;
    Label_Title2: TLabel;
    Label_ZoomFactor: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RefreshAdvice_Label: TLabel;
    RefreshAdvice_Fond: TShape;
    RefreshAdvice_Image: TImage;
    ProcessingFile_Image: TImage;
    Label_OriginalFileSize: TLabel;
    Label_CompressedFileSize: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CompressionRateChange(Sender: TObject);
    procedure RefreshDisplay(Sender: TObject);
    procedure ZoomFactorIndexChange(Sender: TObject);
    procedure LoadPreview(FileName: string);
  private
    { Déclarations privées }
    function GetZoomFactorFromIndex(Index: integer): integer;
  public
    { Déclarations publiques }
  end;

var
  DisplayForm: TDisplayForm;
  CursorStartPosX, CursorStartPosY : integer;

  CURRENTLY_DISPLAYED_FILE_NAME : string;              //   \
  CURRENTLY_USED_COMPRESSION_RATE : integer;           //    >- Stored pieces of Info
  CURRENTLY_DETERMINED_COMPRESSED_FILE_SIZE : string;  //   /

implementation

uses Main;

{$R *.dfm}

     

//============================================================================//
//                               INITIALIZATION                               //
//============================================================================//
procedure TDisplayForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered := true;
  Panel_DisplayImage.DoubleBuffered := true;
end;
//============================================================================//











//============================================================================//
//                 ZOOM, IMAGE TRANSLATION, COMPRESSION RATE                  //
//============================================================================//
function TDisplayForm.GetZoomFactorFromIndex(Index: integer): integer;
begin
  case Index of
    1: result:=12;
    2: result:=25;
    3: result:=50;
    5: result:=200;
    6: result:=400;
    7: result:=800;
  else result:=100;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TDisplayForm.ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CursorStartPosY := Y;
  CursorStartPosX := X;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TDisplayForm.ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  // Translation Management
  if (ssLeft in Shift) then begin
    DisplayImage.Top  := DisplayImage.Top  - (CursorStartPosY-Y);
    DisplayImage.Left := DisplayImage.Left - (CursorStartPosX-X);
    // Correct Positionning
    if DisplayImage.Top  < Panel_DisplayImage.Height - DisplayImage.Height then DisplayImage.Top  := Panel_DisplayImage.Height - DisplayImage.Height;
    if DisplayImage.Left < Panel_DisplayImage.Width  - DisplayImage.Width  then DisplayImage.Left := Panel_DisplayImage.Width  - DisplayImage.Width;
    if DisplayImage.Top  > 0 then DisplayImage.Top  := 0;
    if DisplayImage.Left > 0 then DisplayImage.Left := 0;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TDisplayForm.ZoomFactorIndexChange(Sender: TObject);
var
  ZoomFactor: integer;
begin
  ZoomFactor := GetZoomFactorFromIndex(ZoomFactorIndex.Position);
  Label_ZoomFactor.Caption := IntToStr(ZoomFactor)+'%';

  // Zoom Adaptation
  DisplayImage.Height := round((ZoomFactor*DisplayImage.Picture.Height)/100);
  DisplayImage.Width := round((ZoomFactor*DisplayImage.Picture.Width)/100);
  if (DisplayImage.Height + DisplayImage.Top)  < Panel_DisplayImage.Height then DisplayImage.Top  := (Panel_DisplayImage.Height - DisplayImage.Height);
  if (DisplayImage.Width  + DisplayImage.Left) < Panel_DisplayImage.Width then DisplayImage.Left := (Panel_DisplayImage.Width  - DisplayImage.Width);
  if DisplayImage.Top  > 0 then DisplayImage.Top := 0;
  if DisplayImage.Left > 0 then DisplayImage.Left := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - //
procedure TDisplayForm.CompressionRateChange(Sender: TObject);
var
  AdviceControlsAvailability: boolean;
begin
  Label_CompressionRate.Caption := IntToStr(CompressionRate.Position);

  AdviceControlsAvailability := (CURRENTLY_USED_COMPRESSION_RATE<>CompressionRate.Position) and RBtn_ShowPreviewImage.Checked;
  RefreshAdvice_Image.Visible := AdviceControlsAvailability;
  RefreshAdvice_Label.Visible := AdviceControlsAvailability;
  RefreshAdvice_Fond.Visible := AdviceControlsAvailability;

  if not AdviceControlsAvailability then
    Label_CompressedFileSize.Caption := CURRENTLY_DETERMINED_COMPRESSED_FILE_SIZE
  else Label_CompressedFileSize.Caption := '( ??? Ko )';

end;
//============================================================================//











//============================================================================//
//                  PUBLIC PROCEDURE - CALLED FROM MAINFORM                   //
//============================================================================//
procedure TDisplayForm.LoadPreview(FileName: string);
begin
  CURRENTLY_DISPLAYED_FILE_NAME := FileName;
  CURRENTLY_DETERMINED_COMPRESSED_FILE_SIZE := '( ??? Ko )';
  Label_CompressedFileSize.Caption := CURRENTLY_DETERMINED_COMPRESSED_FILE_SIZE;
  RefreshDisplay(MainForm);
end;
//============================================================================//








                                                


//============================================================================//
//           INTERNAL PROCEDURE - UPDATES THE DISPLAYED IMAGE FILE            //
//============================================================================//
procedure TDisplayForm.RefreshDisplay(Sender: TObject);
var
  LoadingFailure : boolean;
  JPEGImg1 : TJpegImage;
  JPEGImg2 : TJpegImage;
  BMPTempImg : TBitmap;
  TempStream : TMemoryStream;
  ImgFile : file of Byte;
begin
// FILE LOADING
  LoadingFailure := false;
  DisplayForm.Cursor := crHourGlass;

  RefreshAdvice_Image.Visible := false;
  RefreshAdvice_Label.Visible := false;
  RefreshAdvice_Fond.Visible := false;
  ProcessingFile_Image.Visible := true;
  Application.ProcessMessages;

  CURRENTLY_USED_COMPRESSION_RATE := CompressionRate.Position;

  if RBtn_ShowOriginalImage.Checked then begin

    // No compression needed here
    try
      DisplayImage.Picture.LoadFromFile(CURRENTLY_DISPLAYED_FILE_NAME);
    except
      MessageBoxA(MainForm.Handle,Pchar('L''image que vous tentez de visualiser est illisible.'+#13+'Le fichier peut avoir été effacé ou être corrompu.'),Pchar('Erreur'),MB_ICONSTOP + MB_SYSTEMMODAL + MB_SETFOREGROUND + MB_TOPMOST);
      LoadingFailure := true;
    end;
    if LoadingFailure then begin
      if not (Sender = MainForm) then Close;
      DisplayForm.Cursor := crDefault;
      exit;
    end;

  end else begin

    // The ImageFile needs to be transformed to fit the requirements
    try
      JPEGImg1 := TJpegImage.Create;
      BMPTempImg := TBitmap.Create;
      JPEGImg2 := TJpegImage.Create;
      TempStream := TMemoryStream.Create;
      try
        if (UpperCase(ExtractFileExt(CURRENTLY_DISPLAYED_FILE_NAME))='.JPEG') or (UpperCase(ExtractFileExt(CURRENTLY_DISPLAYED_FILE_NAME))='.JPG') then begin
          JPEGImg1.LoadFromFile(CURRENTLY_DISPLAYED_FILE_NAME); // File loading
          Application.ProcessMessages;
          BMPTempImg.Assign(JPEGImg1);
        end else if (UpperCase(ExtractFileExt(CURRENTLY_DISPLAYED_FILE_NAME))='.BMP') then begin
          BMPTempImg.LoadFromFile(CURRENTLY_DISPLAYED_FILE_NAME); // File loading
        end;
        JPEGImg2.Assign(BMPTempImg);
        Application.ProcessMessages;
        JPEGImg2.CompressionQuality:= CompressionRate.Position;
        JPEGImg2.Compress;
        JPEGImg2.SaveToStream(TempStream);
        TempStream.Position:=0;
        JPEGImg2.LoadFromStream(TempStream);
        CURRENTLY_DETERMINED_COMPRESSED_FILE_SIZE := '( '+Inttostr(TempStream.Size div 1024)+' Ko )';
        Label_CompressedFileSize.Caption := CURRENTLY_DETERMINED_COMPRESSED_FILE_SIZE;
        DisplayImage.Picture.Assign(JPEGImg2);
      finally
        TempStream.Free;
        JPEGImg2.Free;
        BMPTempImg.Free;
        JPEGImg1.Free;
      end;
    except
      MessageBoxA(MainForm.Handle,Pchar('La compression de l''image que vous tentez de visualiser est impossible.'+#13+'Le fichier peut avoir été effacé ou être corrompu.'),Pchar('Erreur'),MB_ICONSTOP + MB_SYSTEMMODAL + MB_SETFOREGROUND + MB_TOPMOST);
      LoadingFailure := true;
    end;
    if LoadingFailure then begin
      if not (Sender = MainForm) then Close;
      DisplayForm.Cursor := crDefault;
      exit;
    end;

  end;

  DisplayForm.Cursor := crDefault;
  ProcessingFile_Image.Visible := false;

  if (Sender = MainForm) then begin
    AssignFile(ImgFile, CURRENTLY_DISPLAYED_FILE_NAME);
    Reset(ImgFile);
    Label_OriginalFileSize.Caption := '( '+Inttostr(FileSize(ImgFile) div 1024)+' Ko )';
    CloseFile(ImgFile);
    // RESTORE DISPLAY SETTINGS
    DisplayImage.Width := DisplayImage.Picture.Width;
    DisplayImage.Height := DisplayImage.Picture.Height;
    DisplayImage.Top := 0;
    DisplayImage.Left := 0;
    ZoomFactorIndex.Position := 4; // Original Image Size
    ShowModal;
  end;

end;
//============================================================================//



end.
