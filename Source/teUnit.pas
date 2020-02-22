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
     __OnlyChild         = 'only child';          //不允许有兄弟模块,只有孩子
     __SiblingAndChild   = 'sibling and child';   //允许有兄弟和孩子
     __FixedChild        = 'fixed child';         //只有固定的孩子
     __OptionalChild     = 'optional child';      //有固定的孩子和可选的孩子
     __AsFixedChild      = 'as fixed child';      //是父亲的固定孩子,还可以有的兄弟
     __AsOptionalChild   = 'as optional child';   //作为可选的孩子，配合parent使用
     __NoChild           = 'no child';            //不能拥有孩子

//
function  teTreeToJson(ANode:TTreeNode):TJsonObject;       //从树节点，得到相应的Json节点
function  teInModules(AName:string;AArray:TJsonArray):Boolean;
function  teInNames(AName:string;AArray:array of string):Boolean;
function  teModuleNameToImageIndex(AName:string):Integer;
function  teFindModule(AName:string):TJsonObject;
function  teGetAddMode(ASource,ADest: String): TTEAddMode;
procedure teJsonToTree(TV:TTreeView);
procedure teAddChild(TV:TTreeView;ATNode:TTreeNode;AJNode:TJsonObject);


implementation




//
function  teTreeToJson(ANode:TTreeNode):TJsonObject;       //从树节点，得到相应的Json节点
var
     iIDs      : array of Integer; //用于保存Index序列
     //
     I,J,iHigh : Integer;
begin
     //默认
     Result    := nil;

     //得到Index序列
     SetLength(iIDs,0);
     while ANode.Level>0 do begin
          SetLength(iIDs,Length(iIDs)+1);
          iIDs[High(iIDs)]    := ANode.Index;
          //
          ANode     := ANode.Parent;
     end;

     //得到节点
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
//主要用于取得new/drag/paste/cut时的方式
//ADest为当前已有的 或拖放 或paste/cut目标的节点
//ASource为新增的节点 或被拖放 或paste/cut前已复制的节点
var
     iCurMode  : Integer;
     bCtrl     : Boolean;
     bShift    : Boolean;
     //
     joSource  : TJsonObject;
     joDest    : TJsonObject;
     jaAlwSib  : TJsonArray;
     jaAlwChd  : TJsonArray;

     //
     sModeSrc  : string;
     sModeDest : string;
     sNameSrc  : string;
     sNameDest : string;
begin

     //获得当前键盘状态
     bCtrl     := ((integer(GetKeyState(VK_Control))and integer($80))<>0);
     bShift    := ((integer(GetKeyState(VK_Shift))and integer($80))<>0);

     //
     joSource  := teFindModule(ASource);
     joDest    := teFindModule(ADest);
     jaAlwSib  := joDest.A['allowsibling'];
     jaAlwChd  := joDest.A['allowchild'];

     //
     sModeSrc  := joSource.S['mode'];
     sModeDest := joDest.S['mode'];
     sNameSrc  := joSource.S['name'];
     sNameDest := joDest.S['name'];


     //
     //设置默认返回值 default result
     Result    := amNone;
     if sModeDest = __OnlyChild then begin
          Result    := amLastChild;
     end else if sModeDest = __SiblingAndChild then begin
          if (sModeSrc = __AsFixedChild) or (sModeSrc = __AsOptionalChild) then begin
               Result    := amNone;
          end else begin
               if teInModules(sNameSrc,jaAlwChd) then begin
                    if not teInModules(sNameSrc,jaAlwSib) then begin
                         Result    := amLastChild;
                         Exit;
                    end;
               end;
               if teInModules(sNameSrc,jaAlwSib) then begin
                    if not teInModules(sNameSrc,jaAlwChd) then begin
                         Result    := amNextSibling;
                         Exit;
                    end;
               end;
               if bCtrl then begin
                    Result    := amNextSibling;
               end else begin
                    Result    := amLastChild;
               end;
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

procedure teAddChild(TV:TTreeView;ATNode:TTreeNode;AJNode:TJsonObject);
var
     ssName    : string;
     ssMode    : string;
     //
     jjModule  : TJsonObject;
     jjItem    : TJsonObject;
     //
     iiItem    : Integer;
     //
     tnChild   : TTreeNode;
begin
     ssName    := AJNode.S['name'];
     jjModule  := teFindModule(ssName);
     //
     ATNode.Text    := AJNode.S['caption'];
     ATNode.ImageIndex        := teModuleNameToImageIndex(ssName);
     ATNode.SelectedIndex     := ATNode.ImageIndex;

     //
     for iiItem := 0 to AJNode.A['items'].Count-1 do begin
          jjItem    := AJNode.A['items'][iiItem];
          tnChild   := TV.Items.AddChild(ATNode,jjItem.S['caption']);
          //
          teAddChild(TV,tnChild,jjItem);
     end;
end;

procedure teJsonToTree(TV:TTreeView);

begin
     TV.Items[0].DeleteChildren;
     teAddChild(TV,TV.Items[0],gjoProject);
end;

end.
