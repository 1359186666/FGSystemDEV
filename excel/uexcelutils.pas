unit uexcelutils;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, Datasnap.DBClient,
  Winapi.ActiveX, System.Win.ComObj, Vcl.Forms;

type
  TExcelUtils = class
  public
    class procedure DataSetToExcel(ADataSet: TDataSet; const AFileName: string;
      ATitle: string = '');
    class procedure ExcelToDataSet(ADataSet: TClientDataSet; const AFileName: string;
      ASheetIndex: Integer = 1; AStartRow: Integer = 2);
    class function CanUseExcel: Boolean;
  end;

implementation

class function TExcelUtils.CanUseExcel: Boolean;
var
  Excel: OleVariant;
begin
  Result := False;
  try
    CoInitialize(nil);
    Excel := CreateOleObject('Excel.Application');
    Excel.Quit;
    Excel := Unassigned;
    Result := True;
  except
  end;
end;

class procedure TExcelUtils.DataSetToExcel(ADataSet: TDataSet;
  const AFileName: string; ATitle: string);
var
  Excel, Workbook, Worksheet: OleVariant;
  I, J, RowOffset: Integer;
  SavePath: string;
begin
  if not ADataSet.Active then Exit;
  if not CanUseExcel then
    raise Exception.Create('Excel is not installed');

  CoInitialize(nil);
  try
    Excel := CreateOleObject('Excel.Application');
    Excel.Visible := False;
    Excel.DisplayAlerts := False;

    Workbook := Excel.Workbooks.Add;
    Worksheet := Workbook.Worksheets[1];

    // title
    if ATitle <> '' then
    begin
      Worksheet.Range['A1', Chr(Ord('A') + ADataSet.Fields.Count - 1) + '1'].Merge;
      Worksheet.Cells[1, 1] := ATitle;
      Worksheet.Cells[1, 1].Font.Bold := True;
      Worksheet.Cells[1, 1].HorizontalAlignment := 3;
      RowOffset := 3;
    end
    else
      RowOffset := 1;

    // header
    for J := 0 to ADataSet.Fields.Count - 1 do
    begin
      if not ADataSet.Fields[J].Visible then Continue;
      Worksheet.Cells[RowOffset, J + 1] := ADataSet.Fields[J].DisplayLabel;
      Worksheet.Cells[RowOffset, J + 1].Font.Bold := True;
    end;

    // data
    ADataSet.DisableControls;
    try
      ADataSet.First;
      Inc(RowOffset);
      while not ADataSet.Eof do
      begin
        for J := 0 to ADataSet.Fields.Count - 1 do
        begin
          if not ADataSet.Fields[J].Visible then Continue;
          if not ADataSet.Fields[J].IsNull then
            Worksheet.Cells[RowOffset, J + 1] := ADataSet.Fields[J].Value;
        end;
        ADataSet.Next;
        Inc(RowOffset);
      end;
    finally
      ADataSet.EnableControls;
    end;

    // auto fit
    Worksheet.Columns.AutoFit;

    SavePath := AFileName;
    if not SavePath.EndsWith('.xlsx', True) and not SavePath.EndsWith('.xls', True) then
      SavePath := SavePath + '.xlsx';

    Workbook.SaveAs(SavePath, 51);
    Workbook.Close;
  finally
    Excel.Quit;
    Excel := Unassigned;
    CoUninitialize;
  end;
end;

class procedure TExcelUtils.ExcelToDataSet(ADataSet: TClientDataSet;
  const AFileName: string; ASheetIndex: Integer; AStartRow: Integer);
var
  Excel, Workbook, Worksheet: OleVariant;
  RowIdx, ColIdx: Integer;
  MaxRow, MaxCol: Integer;
  FieldName: string;
  CellVal: Variant;
begin
  if not ADataSet.Active then Exit;
  if not FileExists(AFileName) then
    raise Exception.CreateFmt('File not found: %s', [AFileName]);
  if not CanUseExcel then
    raise Exception.Create('Excel is not installed');

  CoInitialize(nil);
  try
    Excel := CreateOleObject('Excel.Application');
    Excel.Visible := False;
    Excel.DisplayAlerts := False;

    Workbook := Excel.Workbooks.Open(AFileName);
    Worksheet := Workbook.Worksheets[ASheetIndex];

    MaxRow := Worksheet.UsedRange.Rows.Count;
    MaxCol := Worksheet.UsedRange.Columns.Count;

    ADataSet.DisableControls;
    try
      for RowIdx := AStartRow to MaxRow do
      begin
        ADataSet.Append;
        for ColIdx := 1 to MaxCol do
        begin
          FieldName := VarToStr(Worksheet.Cells[AStartRow - 1, ColIdx]);
          if ADataSet.FindField(FieldName) <> nil then
          begin
            CellVal := Worksheet.Cells[RowIdx, ColIdx];
            if not VarIsNull(CellVal) and not VarIsEmpty(CellVal) then
              ADataSet.FieldByName(FieldName).Value := CellVal;
          end;
        end;
        ADataSet.Post;
      end;
    finally
      ADataSet.EnableControls;
    end;

    Workbook.Close(False);
  finally
    Excel.Quit;
    Excel := Unassigned;
    CoUninitialize;
  end;
end;

end.
