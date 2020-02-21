unit teUnit;

interface

uses
     //
     SysVars,

     //
     JsonDataObjects,

     //
     Messages, Windows,Dialogs,
     SysUtils,ComCtrls;

type
     TTEAddMode = (amNone, amNextSibling, amOptionalSibling, amLastChild, amPrevLastChild);

const
     __OnlyChild         = 'only child';          //���������ֵ�ģ��,ֻ�к���
     __SiblingAndChild   = 'sibling and child';   //�������ֵܺͺ���
     __FixedChild        = 'fixed child';         //ֻ�й̶��ĺ���
     __OptionalChild     = 'optional child';      //�й̶��ĺ��ӺͿ�ѡ�ĺ���
     __AsFixedChild      = 'as fixed child';      //�Ǹ��׵Ĺ̶�����,�������е��ֵ�
     __AsOptionalChild   = 'as optional child';   //��Ϊ��ѡ�ĺ��ӣ����parentʹ��
     __NoChild           = 'no child';            //����ӵ�к���

//
function  teTreeToJson(ANode:TTreeNode):TJsonObject;       //�����ڵ㣬�õ���Ӧ��Json�ڵ�
function  teInModules(AName:string;AArray:TJsonArray):Boolean;
function  teInNames(AName:string;AArray:array of string):Boolean;
function  teModuleNameToImageIndex(AName:string):Integer;
function  teFindModule(AName:string):TJsonObject;
function  teGetAddMode(ASource,ADest: String): TTEAddMode;

//
function  isCtrlDown: Boolean;

implementation




//
function  teTreeToJson(ANode:TTreeNode):TJsonObject;       //�����ڵ㣬�õ���Ӧ��Json�ڵ�
var
     iIDs      : array of Integer; //���ڱ���Index����
     //
     I,J,iHigh : Integer;
begin
     //Ĭ��
     Result    := nil;

     //�õ�Index����
     SetLength(iIDs,0);
     while ANode.Level>0 do begin
          SetLength(iIDs,Length(iIDs)+1);
          iIDs[High(iIDs)]    := ANode.Index;
          //
          ANode     := ANode.Parent;
     end;

     //�õ��ڵ�
     Result    := gjoProject;
     for I:=High(iIDs) downto 0 do begin
          Result    := Result.A['items'][iIDs[I]];
     end;
end;


function  teInModules(AName:string;AArray:TjsonArray):Boolean;
var
     I         : Integer;
begin
     Result    := False;
     for I := 0 to AArray.Count-1 do begin
          if AArray.S[I] = AName then begin
               Result    := True;
               Break;
          end;
     end;
end;

function  teInNames(AName:string;AArray:array of string):Boolean;
var
     I         : Integer;
begin
     Result    := False;
     for I := 0 to High(AArray) do begin
          if AArray[I] = AName then begin
               Result    := True;
               Break;
          end;
     end;
end;

function  teModuleNameToImageIndex(AName:string):Integer;
const
     miiFile        = 0;
     miiFunction    = 1;
     miiBlock       = 2;
     miiCode        = 3;
     miiSet         = 4;
     miiIf          = 5;
     miiTrue        = 6;
     miiElif        = 7;
     miiElse        = 8;
     miiFor         = 9;
     miiWhile       = 10;
     miiBreak       = 11;
     miiContinue    = 12;
     miiTry         = 13;
     miiExcept      = 14;
     miiClass       = 15;
begin
     Result    := 0;
     if AName = 'file' then begin
          Result    := miiFile;
     end else if AName = 'function' then begin
          Result    := miiFunction;
     end else if AName = 'set' then begin
          Result    := miiSet;
     end else if AName = 'if' then begin
          Result    := miiIf;
     end else if AName = 'elif' then begin
          Result    := miiElif;
     end else if AName = 'if_yes' then begin
          Result    := miiTrue;
     end else if AName = 'if_else' then begin
          Result    := miiElse;
     end else if AName = 'code' then begin
          Result    := miiCode;
     end else if AName = 'for' then begin
          Result    := miiFor;
     end else if AName = 'while' then begin
          Result    := miiWhile;
     end else if AName = 'try' then begin
          Result    := miiTry;
     end else if AName = 'try_except' then begin
          Result    := miiExcept;
     end else if AName = 'try_else' then begin
          Result    := miiElse;
     end else if AName = 'try_body' then begin
          Result    := miiBlock;
     end else if AName = 'block' then begin
          Result    := miiBlock;
     end else if AName = 'break' then begin
          Result    := miiBreak;
     end else if AName = 'continue' then begin
          Result    := miiContinue;
     end else if AName = 'class' then begin
          Result    := miiClass;
     end;
end;

function  teFindModule(AName:string):TJsonObject;
var
     iModule   : Integer;
begin
     Result    := nil;
     for iModule := 0 to gjoModules.A['items'].Count-1 do begin
          if gjoModules.A['items'][iModule].S['name'] = AName then begin
               Result    := gjoModules.A['items'][iModule];
               Break;
          end;
     end;

     //
     if Result = nil then begin
          ShowMessage('Error when teFindModule : '+AName);
     end;
end;



function teGetAddMode(ASource,ADest: String): TTEAddMode;
//��Ҫ����ȡ��new/drag/paste/cutʱ�ķ�ʽ
//ADestΪ��ǰ���е� ���Ϸ� ��paste/cutĿ��Ľڵ�
//ASourceΪ�����Ľڵ� ���Ϸ� ��paste/cutǰ�Ѹ��ƵĽڵ�
var
     iCurMode  : Integer;
     bCtrl     : Boolean;
     bShift    : Boolean;
     //
     joSource  : TJsonObject;
     joDest    : TJsonObject;

     //
     sModeSrc  : string;
     sModeDest : string;
     sNameSrc  : string;
     sNameDest : string;
begin

     //��õ�ǰ����״̬
     bCtrl     := ((integer(GetKeyState(VK_Control))and integer($80))<>0);
     bShift    := ((integer(GetKeyState(VK_Shift))and integer($80))<>0);

     //
     joSource  := teFindModule(ASource);
     joDest    := teFindModule(ADest);

     //
     sModeSrc  := joSource.S['mode'];
     sModeDest := joDest.S['mode'];
     sNameSrc  := joSource.S['name'];
     sNameDest := joDest.S['name'];

     //
     //����Ĭ�Ϸ���ֵ default result
     Result    := amNone;
     if sModeDest = __OnlyChild then begin
          Result    := amLastChild;
     end else if sModeDest = __SiblingAndChild then begin
          if isCtrlDown then begin
               Result    := amNextSibling;
          end else begin
               Result    := amLastChild;
          end;
     end else if sModeDest = __FixedChild then begin
          Result    := amNextSibling;
     end else if sModeDest = __OptionalChild then begin
          if teInModules(sNameDest,joSource.A['parent']) then begin
               Result    := amPrevLastChild;
          end else begin
               Result    := amNextSibling;
          end;
     end else if sModeDest = __AsFixedChild then begin
          if sModeSrc = __AsOptionalChild then begin
               if joDest.A['parent'].S[0] =  joSource.A['parent'].S[0] then begin
                    Result    := amOptionalSibling;
               end else begin
                    Result    := amNone;
               end;
          end else begin
               Result    := amLastChild;
          end;;
     end else if sModeDest = __AsOptionalChild then begin
          if sModeSrc = __AsOptionalChild then begin
               if joDest.A['parent'].S[0] =  joSource.A['parent'].S[0] then begin
                    Result    := amNextSibling;
               end else begin
                    Result    := amNone;
               end;
          end else begin
               Result    := amLastChild;
          end;;
     end else if sModeDest = __NoChild then begin
          Result    := amNextSibling;
     end;
end;



function isCtrlDown: Boolean;
var
     State: TKeyboardState;
begin
     GetKeyboardState(State);
     Result := ((State[VK_CONTROL] and 128) <> 0);
end;

function isShiftDown: Boolean;
var
     State: TKeyboardState;
begin
     GetKeyboardState(State);
     Result := ((State[VK_SHIFT] and 128) <> 0);
end;

function isAltDown: Boolean;
var
     State: TKeyboardState;
begin
     GetKeyboardState(State);
     Result := ((State[VK_MENU] and 128) <> 0);
end;

end.