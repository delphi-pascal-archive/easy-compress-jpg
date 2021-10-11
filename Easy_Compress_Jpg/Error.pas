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

unit Error;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TErrorForm = class(TForm)
    ErrorTitleMsg: TLabel;
    FilesConcernedMemo: TMemo;
    CloseBtn: TBitBtn;
    ClipboardCopyBtn: TBitBtn;
    procedure ClipboardCopyBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  ErrorForm: TErrorForm;

implementation

{$R *.dfm}

procedure TErrorForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TErrorForm.ClipboardCopyBtnClick(Sender: TObject);
begin
  FilesConcernedMemo.SelectAll;
  FilesConcernedMemo.CopyToClipboard;
  FilesConcernedMemo.SelStart:=0;
end;

end.
