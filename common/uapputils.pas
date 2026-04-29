unit uapputils;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Hash, System.NetEncoding,
  System.JSON, Data.DB, System.TypInfo, uappdefines;

function GenerateGUID: string;
function HashPassword(const APassword: string): string;
function VerifyPassword(const APassword, AHash: string): Boolean;
function JSONEscape(const S: string): string;
function JSONUnescape(const S: string): string;
function VarToJSONStr(const V: Variant): string;
function VarToJSONValue(const V: Variant): TJSONValue;
function JSONToVar(const J: TJSONValue): Variant;
function IsValidJSON(const S: string): Boolean;
function VarIsNullOrEmpty(const V: Variant): Boolean;
function VarToStrDef(const V: Variant; const ADefault: string): string;
function VarToIntDef(const V: Variant; ADefault: Integer): Integer;
function DataTypeToString(ADataType: TFieldType): string;
function StringToDataType(const S: string): TFieldType;
function ControlTypeToString(AType: TControlType): string;
function StringToControlType(const S: string): TControlType;
function GetDefaultValueForType(ADataType: TFieldType): Variant;
function SafeLoadStr(const J: TJSONObject; const Key, ADefault: string): string;
function SafeLoadInt(const J: TJSONObject; const Key: string; ADefault: Integer): Integer;
function SafeLoadBool(const J: TJSONObject; const Key: string; ADefault: Boolean): Boolean;
function VariantStreamToBase64(AStream: TStream): string;

implementation

function GenerateGUID: string;
var
  G: TGUID;
begin
  CreateGUID(G);
  Result := LowerCase(GUIDToString(G).Replace('{', '').Replace('}', '').Replace('-', ''));
end;

function HashPassword(const APassword: string): string;
begin
  Result := THashSHA2.GetHashString(APassword + 'framework3tier_salt', SHA256);
end;

function VerifyPassword(const APassword, AHash: string): Boolean;
begin
  Result := SameText(HashPassword(APassword), AHash);
end;

function JSONEscape(const S: string): string;
begin
  Result := StringReplace(S, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #9, '\t', [rfReplaceAll]);
end;

function JSONUnescape(const S: string): string;
begin
  Result := StringReplace(S, '\"', '"', [rfReplaceAll]);
  Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);
  Result := StringReplace(Result, '\n', #10, [rfReplaceAll]);
  Result := StringReplace(Result, '\r', #13, [rfReplaceAll]);
  Result := StringReplace(Result, '\t', #9, [rfReplaceAll]);
end;

function VarToJSONStr(const V: Variant): string;
begin
  if VarIsNull(V) or VarIsEmpty(V) then
    Result := 'null'
  else if VarType(V) in [varSmallint, varInteger, varShortInt, varByte,
    varWord, varLongWord, varInt64, varUInt64] then
    Result := IntToStr(V)
  else if VarType(V) in [varSingle, varDouble, varCurrency] then
    Result := FloatToStr(V)
  else if VarIsType(V, varBoolean) then
    Result := LowerCase(BoolToStr(V, True))
  else if VarIsStr(V) then
    Result := '"' + JSONEscape(VarToStr(V)) + '"'
  else
    Result := '"' + JSONEscape(VarToStr(V)) + '"';
end;

function VarToJSONValue(const V: Variant): TJSONValue;
begin
  if VarIsNull(V) or VarIsEmpty(V) then
    Result := TJSONNull.Create
  else if VarType(V) in [varSmallint, varInteger, varShortInt, varByte,
    varWord, varLongWord, varInt64, varUInt64] then
    Result := TJSONNumber.Create(Integer(V))
  else if VarType(V) in [varSingle, varDouble, varCurrency] then
    Result := TJSONNumber.Create(Double(V))
  else if VarIsType(V, varBoolean) then
    Result := TJSONBool.Create(Boolean(V))
  else
    Result := TJSONString.Create(VarToStr(V));
end;

function JSONToVar(const J: TJSONValue): Variant;
begin
  if J = nil then
    Result := Null
  else if J is TJSONNull then
    Result := Null
  else if J is TJSONString then
    Result := TJSONString(J).Value
  else if J is TJSONNumber then
  begin
    if Pos('.', TJSONNumber(J).ToString) > 0 then
      Result := TJSONNumber(J).AsDouble
    else
      Result := TJSONNumber(J).AsInt64;
  end
  else if J is TJSONBool then
    Result := TJSONBool(J).AsBoolean
  else
    Result := J.ToString;
end;

function IsValidJSON(const S: string): Boolean;
var
  V: TJSONValue;
begin
  V := nil;
  try
    V := TJSONObject.ParseJSONValue(S);
    Result := V <> nil;
  except
    Result := False;
  end;
  V.Free;
end;

function VarIsNullOrEmpty(const V: Variant): Boolean;
begin
  Result := VarIsNull(V) or VarIsEmpty(V) or (VarIsStr(V) and (VarToStr(V) = ''));
end;

function VarToStrDef(const V: Variant; const ADefault: string): string;
begin
  if VarIsNull(V) or VarIsEmpty(V) then
    Result := ADefault
  else
    Result := VarToStr(V);
end;

function VarToIntDef(const V: Variant; ADefault: Integer): Integer;
begin
  if VarIsNull(V) or VarIsEmpty(V) then
    Result := ADefault
  else
    Result := StrToIntDef(VarToStr(V), ADefault);
end;

function DataTypeToString(ADataType: TFieldType): string;
begin
  Result := GetEnumName(TypeInfo(TFieldType), Ord(ADataType));
end;

function StringToDataType(const S: string): TFieldType;
var
  Val: Integer;
begin
  Val := GetEnumValue(TypeInfo(TFieldType), S);
  if Val >= 0 then
    Result := TFieldType(Val)
  else
    Result := ftString;
end;

function ControlTypeToString(AType: TControlType): string;
begin
  Result := GetEnumName(TypeInfo(TControlType), Ord(AType));
end;

function StringToControlType(const S: string): TControlType;
var
  Val: Integer;
begin
  Val := GetEnumValue(TypeInfo(TControlType), S);
  if Val >= 0 then
    Result := TControlType(Val)
  else
    Result := ctDBEdit;
end;

function GetDefaultValueForType(ADataType: TFieldType): Variant;
begin
  case ADataType of
    ftString, ftWideString, ftFixedChar, ftWideMemo, ftMemo: Result := '';
    ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint: Result := 0;
    ftFloat, ftCurrency, ftBCD, ftFMTBcd: Result := 0.0;
    ftBoolean: Result := False;
    ftDate, ftTime, ftDateTime: Result := Now;
    ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob: Result := Null;
  else
    Result := Null;
  end;
end;

function SafeLoadStr(const J: TJSONObject; const Key, ADefault: string): string;
var
  Val: TJSONValue;
begin
  Val := J.GetValue(Key);
  if (Val <> nil) and not (Val is TJSONNull) then
    Result := Val.Value
  else
    Result := ADefault;
end;

function SafeLoadInt(const J: TJSONObject; const Key: string; ADefault: Integer): Integer;
var
  Val: TJSONValue;
begin
  Val := J.GetValue(Key);
  if (Val <> nil) and (Val is TJSONNumber) then
    Result := TJSONNumber(Val).AsInt
  else
    Result := ADefault;
end;

function SafeLoadBool(const J: TJSONObject; const Key: string; ADefault: Boolean): Boolean;
var
  Val: TJSONValue;
begin
  Val := J.GetValue(Key);
  if (Val <> nil) and (Val is TJSONBool) then
    Result := TJSONBool(Val).AsBoolean
  else
    Result := ADefault;
end;

function VariantStreamToBase64(AStream: TStream): string;
var
  MS: TMemoryStream;
  Bytes: TBytes;
begin
  AStream.Position := 0;
  MS := TMemoryStream.Create;
  try
    AStream.Position := 0;
    MS.CopyFrom(AStream, AStream.Size);
    SetLength(Bytes, MS.Size);
    MS.Position := 0;
    MS.ReadBuffer(Bytes[0], MS.Size);
    Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
  finally
    MS.Free;
  end;
end;

end.
