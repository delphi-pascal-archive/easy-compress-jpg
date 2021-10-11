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

unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, jpeg, ExtCtrls, ShellAPI;

type
  TAboutForm = class(TForm)
    Lbl_WebLink_ni69: TLabel;
    Img_Fond: TImage;
    Lbl_Author: TLabel;
    Lbl_Auxilary: TLabel;
    Lbl_WebLink_ExifTool: TLabel;
    Lbl_WebLink_TZIP: TLabel;
    Lbl_Firm: TLabel;
    Lbl_Copyright: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Lbl_WebLinksMouseLeave(Sender: TObject);
    procedure Lbl_WebLinksMouseEnter(Sender: TObject);
    procedure Lbl_WebLink_TZIPClick(Sender: TObject);
    procedure Lbl_WebLink_ExifToolClick(Sender: TObject);
    procedure Lbl_WebLink_ni69Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.Lbl_WebLink_ni69Click(Sender: TObject);
begin
  ShellExecute(0,nil,'http://www.ni69.info',nil,nil,SW_SHOW);
end;

procedure TAboutForm.Lbl_WebLink_ExifToolClick(Sender: TObject);
begin
  ShellExecute(0,nil,'http://www.sno.phy.queensu.ca/~phil/exiftool/',nil,nil,SW_SHOW);
end;

procedure TAboutForm.Lbl_WebLink_TZIPClick(Sender: TObject);
begin
  ShellExecute(0,nil,'http://www.angusj.com/delphi/',nil,nil,SW_SHOW);
end;

procedure TAboutForm.Lbl_WebLinksMouseEnter(Sender: TObject);
begin
  (Sender as TLabel).Font.Color := clRed;
  (Sender as TLabel).Font.Style := [fsUnderline, fsBold];
end;

procedure TAboutForm.Lbl_WebLinksMouseLeave(Sender: TObject);
begin
  (Sender as TLabel).Font.Color := clBlack;
  (Sender as TLabel).Font.Style := [fsBold];
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key=VK_ESCAPE) or (Key=VK_RETURN) then close; 
end;

end.
