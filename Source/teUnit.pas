unit teUnit;

interface

uses
     //
     SysVars,

     //
     JsonDataObjects,

     //
     //SynEdit, SynEditHighlighter,SynEditCodeFolding, SynHighlighterJSON,

     //
     Windows,
     Forms,SysUtils, System.ImageList, Vcl.Dialogs, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.ComCtrls, Vcl.ToolWin,
     Graphics, Vcl.ExtCtrls, System.Classes, Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Buttons, FloatSpinEdit;

type
     TTEAddMode = (
          amNone,
          amNextSibling,      //移动或新增到当前节点的下一兄弟节点
          amOptionalSibling,  //如果当前节点为第一子固定节点, 则位置为下一个;如果当前为最后固定节点,则为倒数第二个
          amLastChild,        //移动或新增到当前节点的最后子节点
          amPrevLastChild     //移动或新增到当前节点的非最后子节点
          );
type
     TEventHandlers = class { 建一个虚拟类}
          procedure PropertyChange(Sender: TObject);
     end;

const
     __OnlyChild         = 'only child';          //不允许有兄弟模块,只有孩子
     __SiblingAndChild   = 'sibling and child';   //允许有兄弟和孩子
     __FixedChild        = 'fixed child';         //只有固定的孩子
     __OptionalChild     = 'optional child';      //有固定的孩子和可选的孩子
     __AsFixedChild      = 'as fixed child';      //是父亲的固定孩子,还可以有的兄弟
     __AsOptionalChild   = 'as optional child';   //作为可选的孩子，配合parent使用
     __NoChild           = 'no child';            //不能拥有孩子

//
function  teTreeToJson(ANode:TTreeNode):TJsonObject;                            //从树节点，得到相应的Json节点
function  teInModules(AName:string;AArray:TJsonArray):Boolean;                  //is AName is Array
function  teInNames(AName:string;AArray:array of string):Boolean;               //is AName is strings
function  teModuleNameToImageIndex(AName:string):Integer;                       //Module name to ImageIndex
function  teFindModule(AName:string):TJsonObject;                               //Find Module by name
function  teGetAddMode(ASource,ADest: String): TTEAddMode;                      //Get the Add mode
procedure teJsonToTree(TV:TTreeView);                                           //create tree from json
procedure teAddChild(TV:TTreeView;ATNode:TTreeNode;AJNode:TJsonObject);         //
function  teColorToArray(AColor:TColor):TJsonArray;    //
function  teArrayToColor(AArray:TJsonArray):TColor;
function  teFontToJson(AFont:TFont):TJsonObject;
function  teJsonToFont(AFont:TFont;AJson:TJsonObject):Integer;
procedure teSaveNodeProperty(ATV:TTreeView;APanel:TPanel);
procedure teShowNodeProperty(ANode: TJsonObject;ATV:TTreeView;APanel:TPanel);
procedure teSetUpDownEnable(ANode:TTreeNode;ADown,AUp:TToolButton);
procedure teMoveTreeNodeUp(ANode:TTreeNode);
procedure teMoveTreeNodeDown(ANode:TTreeNode);
procedure teAddModule(ANode:TTreeNode;AIndex:Integer);


var
     EvHandler : TEventHandlers;



implementation

uses
     Main;

function  teCanMoveTo(ASource,ADest:TJsonObject):TTEAddMode;                    //是否可以移动Source到ADest
var
     joSource  : TJsonObject;
     joDest    : TJsonObject;
     joMdlSrc  : TJsonObject;
     joMdlDest : TJsonObject;
begin

end;

procedure teAddModule(ANode:TTreeNode;AIndex:Integer);
     procedure _AddNode(AtnParent:TTreeNode;AIndex:Integer;AjoModule:TJsonObject);
     var
          joParent  : TJsonObject;
          joNew     : TJsonObject;
          joProp    : TJsonObject;
          //
          tnNew     : TTreeNode;

          //
          iProp     : Integer;
          iChild    : Integer;

          //
          sCaption  : string;      //新节点的caption
     begin
          //get parent json node
          joParent  := teTreeToJson(AtnParent);

          //new tree node default text
          sCaption  := '';

          //add a new node. AIndex = -1 is lastchild
          if AIndex = -1 then begin
               joNew     := joParent.A['items'].AddObject;
          end else begin
               joNew     := joParent.A['items'].InsertObject(AIndex);
          end;

          //
          with joNew do begin
               S['name']      := AjoModule.S['name'];
               //add property
               for iProp := 0 to AjoModule.A['property'].Count-1 do begin
                    joProp    := AjoModule.A['property'][iProp];
                    if joProp.S['type'] = 'string' then begin
                         S[joProp.S['name']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'source' then begin
                         S[joProp.S['name']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'memo' then begin
                         S[joProp.S['name']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'integer' then begin
                         I[joProp.S['name']] := joProp.I['default'];
                    end else if joProp.S['type'] = 'boolean' then begin
                         B[joProp.S['name']] := joProp.B['default'];
                    end else if joProp.S['type'] = 'list' then begin
                         S[joProp.S['name']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'color' then begin
                         A[joProp.S['name']] := TJsonArray.Create;
                         A[joProp.S['name']].FromUtf8JSON(joProp.A['default'].ToUtf8JSON);
                    end else if joProp.S['type'] = 'font' then begin
                         O[joProp.S['name']] := TJsonObject.Create;
                         if joProp.Contains('default') then begin
                              O[joProp.S['name']].FromUtf8JSON(joProp.O['default'].ToUtf8JSON);
                         end;
                    end else if joProp.S['type'] = 'float' then begin
                         F[joProp.S['name']] := joProp.F['default'];
                    end;

                    //get text of new node
                    if joProp.S['name'] = 'caption' then begin
                         sCaption  := joProp.S['default'];
                    end;
               end;

          end;

          //new tree node
          tnNew     := MainForm.TreeView.Items.AddChild(AtnParent,sCaption);
          tnNew.ImageIndex    := teModuleNameToImageIndex(joNew.S['name']);
          tnNew.SelectedIndex := tnNew.ImageIndex;
          tnNew.MakeVisible;
          //
          if AIndex <> -1 then begin
               if AtnParent.Count>AIndex then begin
                    tnNew.MoveTo(AtnParent.Item[AIndex],naInsert);
               end;
          end;

          //add childs
          for iChild := 0 to AjoModule.A['child'].Count-1 do begin
               _AddNode(tnNew,-1,teFindModule(AjoModule.A['child'].S[iChild]));
          end;
     end;
var
     joModule  : TJsonObject; //
     joSelMdl  : TJsonObject; //当前选择树节点的对应模块节点
     joCur     : TJsonObject; //
     tnParent  : TTreeNode;

     //0: as sibling, 1:as child, 3:as sibling(not last), 4: as optional child (not first, not last)
     oAddMode  : TTEAddMode;     //

begin
     //get current treeview node 得到当前树节点

     //get json node from treenode 得到当前工程节点
     joCur     := teTreeToJson(ANode);

     //
     joSelMdl  := teFindModule(joCur.S['name']);

     //get the module jsonobject 得到模块节点
     joModule  := gjoModules.A['items'][AIndex];

     //get the new type : child/sibling
     oAddMode  := teGetAddMode(joModule.S['name'], joSelMdl.S['name']);

     //
     case oAddMode of
          amNextSibling : begin //
               tnParent  := ANode.Parent;
               _AddNode(tnParent,ANode.Index+1,joModule);
               tnParent.Item[ANode.Index+1].Selected := True;
          end;
          amLastChild : begin //
               _AddNode(ANode,-1,joModule);
               ANode.Item[ANode.Count-1].Selected := True;
          end;
          amOptionalSibling : begin //
               tnParent  := ANode.Parent;
               if ANode.Index = 0 then begin
                    _AddNode(tnParent,1,joModule);
                    tnParent.Item[1].Selected := True;
               end else begin
                    _AddNode(tnParent,ANode.Index,joModule);
                    tnParent.Item[ANode.Index-1].Selected := True;
               end;
          end;
          amPrevLastChild : begin //3: as optional child (not first, not last)
               _AddNode(ANode,ANode.Count-1,joModule);
               ANode.Item[ANode.Count-2].Selected := True;
          end;
     end;
     gbModified     := True;
end;



procedure teMoveTreeNodeUp(ANode:TTreeNode);
var
     tnPrev    : TTreeNode;
     //
     joNode    : TJsonObject;
     joPrev    : TJsonObject;
     joParent  : TJsonObject;
     jaItems   : TJsonArray;
begin
     //<检查异常  check
     if ANode = nil then begin
          Exit;
     end;
     joNode    := teTreeToJson(ANode);
     //
     if joNode=nil then begin
          Exit;
     end;
     //
     if joNode=gjoProject then begin
          Exit;
     end;

     //
     tnPrev    := ANode.getPrevSibling;
     if tnPrev = nil then begin
          Exit;
     end;
     joPrev    := teTreeToJson(tnPrev);
     //
     if joPrev=nil then begin
          Exit;
     end;
     //>

     //Move JsonObject
     joParent  := teTreeToJson(ANode.Parent);
     jaItems   := joParent.A['items'];
     jaItems.InsertObject(ANode.Index-1).FromUtf8JSON(joNode.ToUtf8JSON(true));
     jaItems.Delete(ANode.Index+1);

     //Move TreeNode  树节点上移
     ANode.MoveTo(tnPrev,naInsert);

end;

procedure teMoveTreeNodeDown(ANode:TTreeNode);
var
     tnNext    : TTreeNode;
     //
     joNode    : TJsonObject;
     joNext    : TJsonObject;
     joParent  : TJsonObject;
     jaItems   : TJsonArray;
begin
     //<得到相应的节点, 并检查异常 get the treenode and jsonobjecct, and check
     if ANode = nil then begin
          Exit;
     end;
     joNode    := teTreeToJson(ANode);
     //
     if joNode=nil then begin
          Exit;
     end;
     //
     if joNode=gjoProject then begin
          Exit;
     end;

     //
     tnNext    := ANode.getNextSibling;
     if tnNext = nil then begin
          Exit;
     end;
     joNext    := teTreeToJson(tnNext);
     //
     if joNext=nil then begin
          Exit;
     end;
     //>

     //Move JsonObject
     joParent  := teTreeToJson(ANode.Parent);
     jaItems   := joParent.A['items'];
     jaItems.InsertObject(ANode.Index+2).FromUtf8JSON(joNode.ToUtf8JSON(true));
     jaItems.Delete(ANode.Index);

     //Move TreeNode  树节点下移
     tnNext.MoveTo(ANode,naInsert);

end;



procedure TEventHandlers.PropertyChange(Sender: TObject);
var
     oSpeedBtn : TSpeedButton;
     oFontDlg  : TFontDialog;
begin
     if Sender.ClassType = TSpeedButton then begin
          oSpeedBtn := TSpeedButton(Sender);
          oFontDlg  := TFontDialog.Create(MainForm);
          if oFontDlg.Execute then begin
               oSpeedBtn.Font := oFontDlg.Font;
          end;
     end;
     teSaveNodeProperty(MainForm.TreeView,MainForm.Panel_LeftBottom);
     gbModified     := True;

     //
     //MainForm.SynEdit.Text    := gjoProject.ToUtf8JSON(False);

end;


procedure teSetUpDownEnable(ANode:TTreeNode;ADown,AUp:TToolButton);
var
     sName     : string;
     sMode     : string;
     sModeNext : string;
     sModePrev : string;
     //
     tnNext    : TTreeNode;
     tnPrev    : TTreeNode;
     //
     joNode    : TJsonObject;
     joNext    : TJsonObject;
     joPrev    : TJsonObject;
     //
     joMdlNode : TJsonObject;
     joMdlNext : TJsonObject;
     joMdlPrev : TJsonObject;
     //
     function _GetB(AMode:String):Boolean;
     begin
          Result    := (AMode<>__AsFixedChild)and(AMode<>__AsOptionalChild) and (sMode<>__AsFixedChild)and(sMode<>__AsOptionalChild);
          if (sMode = __AsOptionalChild)and(AMode = __AsOptionalChild) then begin
               Result    := True;
          end;
     end;
begin
     try
          if ANode = nil then begin
               Exit;
          end;

          //
          joNode    := teTreeToJson(ANode);
          sName     := joNode.S['name'];
          joMdlNode := teFindModule(sName);
          sMode     := joMdlNode.S['mode'];

          //
          tnNext    := ANode.getNextSibling;
          tnPrev    := ANode.getPrevSibling;

          //
          if (tnNext = nil) then begin
               if (tnPrev = nil) then begin
                    ADown.Enabled  := False;
                    AUp.Enabled    := False;
               end else begin
                    ADown.Enabled  := False;
                    //
                    joPrev    := teTreeToJson(tnPrev);
                    joMdlPrev := teFindModule(joPrev.S['name']);
                    //
                    sModePrev := joMdlPrev.S['mode'];
                    AUp.Enabled    := _GetB(sModePrev);
               end;
          end else begin
               if (tnPrev = nil) then begin
                    AUp.Enabled    := False;
                    //
                    joNext    := teTreeToJson(tnNext);
                    joMdlNext := teFindModule(joNext.S['name']);
                    //
                    sModeNext := joMdlNext.S['mode'];
                    ADown.Enabled  := _GetB(sModeNext);
               end else begin
                    //
                    joNext    := teTreeToJson(tnNext);
                    joMdlNext := teFindModule(joNext.S['name']);
                    //
                    sModeNext := joMdlNext.S['mode'];
                    ADown.Enabled  := _GetB(sModeNext);
                    //
                    joPrev    := teTreeToJson(tnPrev);
                    joMdlPrev := teFindModule(joPrev.S['name']);
                    //
                    sModePrev := joMdlPrev.S['mode'];
                    AUp.Enabled    := _GetB(sModePrev);
               end;
          end;
     except
          ShowMessage('Error when teSetUpDownEnable!');
     end;
end;

procedure teShowNodeProperty(ANode: TJsonObject;ATV:TTreeView;APanel:TPanel);
var
     iProp     : Integer;
     iCtrl     : Integer;
     iItem     : Integer;
     //
     joProp    : TJsonObject;
     joModule  : TJsonObject;
     //
     oPanel    : TPanel;
     oLabel    : TLabel;
     oSpinEdit : TSpinEdit;
     oEdit     : TEdit;
     oMemo     : TMemo;
     oCheckBox : TCheckBox;
     oComboBox : TComboBox;
     oColorBox : TColorBox;
     oSpeedBtn : TSpeedButton;
     oFloatSE  : TFloatSpinEdit;
     //
     bFoundSrc : Boolean;     //found source property
begin
     //Clear All components of Panel_LeftBottom
     for iCtrl := APanel.ControlCount-1 downto 0 do begin
          APanel.Controls[iCtrl].Destroy;
     end;

     //如果当前节点为nil,则退出
     if ANode = nil then begin
          Exit;
     end;

     //
     joModule  := teFindModule(ANode.S['name']);

     //显示属性
     bFoundSrc := False;
     for iProp := 0 to joModule.A['property'].Count-1 do begin
          joProp    := joModule.A['property'][iProp];
          //属性的外框
          oPanel    := TPanel.Create(nil);
          oPanel.Parent       := APanel;
          oPanel.Align        := alTop;
          oPanel.Top          := 9999;
          if bFoundSrc then begin
               oPanel.Align   := alBottom;
               oPanel.Top     := 9999;
          end;
          oPanel.Height       := 28;
          oPanel.BorderWidth  := 2;
          oPanel.BevelOuter   := bvNone;
          //属性名称
          oLabel    := TLabel.Create(oPanel);
          oLabel.Parent       := oPanel;
          oLabel.Align        := alLeft;
          oLabel.Layout       := tlCenter;
          oLabel.AutoSize     := False;
          oLabel.Width        := 100;
          oLabel.Caption      := joProp.S['name'];
          //属性值
          if joProp.S['type'] = 'string' then begin
               oEdit          := TEdit.Create(oPanel);
               oEdit.Parent   := oPanel;
               oEdit.Align    := alClient;
               oEdit.Text     := ANode.S[joProp.S['name']];
               oEdit.OnChange := EvHandler.PropertyChange;
          end else if joProp.S['type'] = 'memo' then begin
               oMemo          := TMemo.Create(oPanel);
               oMemo.Parent   := oPanel;
               oMemo.Align    := alClient;
               oMemo.Text     := ANode.S[joProp.S['name']];
               oMemo.OnChange := EvHandler.PropertyChange;
               //
               oPanel.Height  := 80;
          end else if joProp.S['type'] = 'integer' then begin
               oSpinEdit           := TSpinEdit.Create(oPanel);
               oSpinEdit.Parent    := oPanel;
               oSpinEdit.Align     := alClient;
               oSpinEdit.Value     := ANode.I[joProp.S['name']];
               oSpinEdit.OnChange  := EvHandler.PropertyChange;
          end else if joProp.S['type'] = 'source' then begin
               oMemo       := TMemo.Create(oPanel);
               oMemo.Parent:= oPanel;
               oMemo.Align := alClient;
               oMemo.Text  := ANode.S[joProp.S['name']];
               oMemo.OnChange   := EvHandler.PropertyChange;
               //
               bFoundSrc := True;
               oPanel.Align   := alClient;
          end else if joProp.S['type'] = 'boolean' then begin
               oCheckBox           := TCheckBox.Create(oPanel);
               oCheckBox.Parent    := oPanel;
               oCheckBox.Align     := alClient;
               oCheckBox.Checked   := ANode.B[joProp.S['name']];
               oCheckBox.OnClick   := EvHandler.PropertyChange;
          end else if joProp.S['type'] = 'list' then begin
               oComboBox           := TComboBox.Create(oPanel);
               oComboBox.Parent    := oPanel;
               oComboBox.Align     := alClient;
               for iItem := 0 to joProp.A['items'].Count-1 do begin
                    oComboBox.Items.Add(joProp.A['items'].S[iItem]);
               end;
               if joProp.B['fixed'] then begin
                    oComboBox.Style     := csDropDownList;
               end;
               oComboBox.ItemIndex := oComboBox.Items.IndexOf(ANode.S[joProp.S['name']]);  //HERE! IndexOfName not work correct!
               oComboBox.OnChange  := EvHandler.PropertyChange;
          end else if joProp.S['type'] = 'color' then begin
               oColorBox           := TColorBox.Create(oPanel);
               oColorBox.Parent    := oPanel;
               oColorBox.Align     := alClient;
               oColorBox.Items.InsertObject(0,'default',TObject($FEFEFE));
               oColorBox.ItemIndex := 0;
               oColorBox.NoneColorColor := clWhite;
               oColorBox.Selected       := teArrayToColor(ANode.A[joProp.S['name']]);
               oColorBox.OnChange       := EvHandler.PropertyChange;
          end else if joProp.S['type'] = 'font' then begin
               oSpeedBtn           := TSpeedButton.Create(oPanel);
               oSpeedBtn.Parent    := oPanel;
               oSpeedBtn.Align     := alClient;
               oSpeedBtn.Caption   := 'Font';
               teJsonToFont(oSpeedBtn.Font,ANode.O[joProp.S['name']]);
               oSpeedBtn.OnClick   := EvHandler.PropertyChange;
          end else if joProp.S['type'] = 'float' then begin
               oFloatSE           := TFloatSpinEdit.Create(oPanel);
               oFloatSE.Parent    := oPanel;
               oFloatSE.Align     := alClient;
               oFloatSE.Value     := ANode.F[joProp.S['name']];
               oFloatSE.OnChange  := EvHandler.PropertyChange;
          end;
     end;

end;


procedure teSaveNodeProperty(ATV:TTreeView;APanel:TPanel);
var
     tnNode    : TTreeNode;
     joNode    : TJsonObject;
     //
     iProp     : Integer;
     //
     joProp    : TJsonObject;
     joModule  : TJsonObject;

     //
     oPanel    : TPanel;
     oEdit     : TEdit;
     oMemo     : TMemo;
     oSpinEdit : TSpinEdit;
     oCheckBox : TCheckBox;
     oComboBox : TComboBox;
     oColorBox : TColorBox;
     oSpeedBtn : TSpeedButton;
     oFloatSE  : TFloatSpinEdit;
     //
     sDebug    : string;
begin
     //get current selected treenode
     tnNode    := ATV.Selected;
     if tnNode = nil then begin
          Exit;
     end;

     //get current project json node
     joNode    := teTreeToJson(tnNode);

     //
     joModule  := teFindModule(joNode.S['name']);

     //
     for iProp := 0 to APanel.ControlCount-1 do begin
          joProp    := joModule.A['property'][iProp];
          //
          oPanel    := TPanel(APanel.Controls[iProp]);
          if joProp.S['type'] = 'string' then begin
               oEdit     := TEdit(oPanel.Controls[1]);
               joNode.S[joProp.S['name']]    := oEdit.Text;
          end else if joProp.S['type'] = 'source' then begin
               oMemo  := TMemo(oPanel.Controls[1]);
               joNode.S[joProp.S['name']]    := oMemo.Text;
          end else if joProp.S['type'] = 'memo' then begin
               oMemo     := TMemo(oPanel.Controls[1]);
               joNode.S[joProp.S['name']]    := oMemo.Text;
          end else if joProp.S['type'] = 'integer' then begin
               oSpinEdit     := TSpinEdit(oPanel.Controls[1]);
               joNode.I[joProp.S['name']]    := oSpinEdit.Value;
          end else if joProp.S['type'] = 'boolean' then begin
               oCheckBox     := TCheckBox(oPanel.Controls[1]);
               joNode.B[joProp.S['name']]    := oCheckBox.Checked;
          end else if joProp.S['type'] = 'list' then begin
               oComboBox := TComboBox(oPanel.Controls[1]);
               joNode.S[joProp.S['name']]    := oComboBox.Text;
          end else if joProp.S['type'] = 'color' then begin
               oColorBox := TColorBox(oPanel.Controls[1]);
               joNode.A[joProp.S['name']]    := TJsonArray.Create;
               joNode.A[joProp.S['name']].FromUtf8JSON(teColorToArray(oColorBox.Selected).ToUtf8JSON(False));
          end else if joProp.S['type'] = 'font' then begin
               oSpeedBtn := TSpeedButton(oPanel.Controls[1]);
               joNode.O[joProp.S['name']]    := TJsonObject.Create;
               joNode.O[joProp.S['name']].FromUtf8JSON(teFontToJson(oSpeedBtn.Font).ToUtf8JSON(False));
          end else if joProp.S['type'] = 'float' then begin
               oFloatSE  := TFloatSpinEdit(oPanel.Controls[1]);
               joNode.F[joProp.S['name']]    := oFloatSE.Value;
          end;

          //更新树节点显示
          if joProp.S['name'] = 'caption' then begin
               ATV.Selected.Text   := joNode.S['caption'];
          end;
     end;

end;


function  teFontToJson(AFont:TFont):TJsonObject;
begin

     Result    := TJsonObject.Create;
     Result.S['name']    := AFont.Name;
     Result.I['size']    := AFont.Size;
     Result.I['b']       := Integer(fsBold in AFont.Style);
     Result.I['i']       := Integer(fsItalic in AFont.Style);
     Result.I['u']       := Integer(fsUnderline in AFont.Style);
     Result.I['s']       := Integer(fsStrikeOut in AFont.Style);
     //Result    := Format('{"name":"%s","size":%d}',[AFont.Name,AFont.Size]);
end;

function  teJsonToFont(AFont:TFont;AJson:TJsonObject):Integer;
begin
     Result    := 0;
     //
     if AJson = nil then begin
          Exit;
     end;

     if AJson.Contains('name') then begin
          AFont.Name     := AJson.S['name'];
     end;
     if AJson.Contains('size') then begin
          AFont.Size     := AJson.I['size'];
     end;
     AFont.Style    := [];
     if AJson.I['b'] = 1 then begin
          AFont.Style    := AFont.Style + [fsBold];
     end;
     if AJson.I['i'] = 1 then begin
          AFont.Style    := AFont.Style + [fsItalic];
     end;
     if AJson.I['u'] = 1 then begin
          AFont.Style    := AFont.Style + [fsUnderline];
     end;
     if AJson.I['s'] = 1 then begin
          AFont.Style    := AFont.Style + [fsStrikeOut];
     end;

end;
function  teColorToArray(AColor:TColor):TJsonArray;    //
begin
     Result    := TJsonArray.Create;
     Result.add(GetRValue(ColorToRGB(AColor)));
     Result.add(GetGValue(ColorToRGB(AColor)));
     Result.add(GetBValue(ColorToRGB(AColor)));

{
     Result    := '['
               +IntToStr(GetRValue(ColorToRGB(AColor)))+','     //R
               +IntToStr(GetGValue(ColorToRGB(AColor)))+','     //G
               +IntToStr(GetBValue(ColorToRGB(AColor)))
               +']';     //B
}
end;

function  teArrayToColor(AArray:TJsonArray):TColor;
begin
     Result    := clNone;

     //
     if AArray = nil then begin
          Exit;
     end;
     if AArray.Count<>3 then begin
          Exit;
     end;

     Result    := AArray.I[0] + AArray.I[1] shl 8 + AArray.I[2] shl 16;

end;
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
     miiFile        = 1;
     miiFunction    = 2;
     miiBlock       = 3;
     miiCode        = 4;
     miiSet         = 5;
     miiIf          = 6;
     miiTrue        = 7;
     miiElif        = 8;
     miiElse        = 9;
     miiFor         = 10;
     miiWhile       = 11;
     miiBreak       = 12;
     miiContinue    = 13;
     miiTry         = 14;
     miiExcept      = 15;
     miiClass       = 16;
     miiTk_Window   = 20;
     miiTk_Label    = 21;
     miiTk_Button   = 22;
     miiTk_Entry    = 23;
     miiTk_Check    = 24;
     miiTk_Radio    = 25;
     miiTk_Listbox  = 26;
     miiTk_Text     = 27;
     miiTk_Scale    = 28;
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
     end else if AName = 'tk_window' then begin
          Result    := miiTk_Window;
     end else if AName = 'tk_label' then begin
          Result    := miiTk_Label;
     end else if AName = 'tk_button' then begin
          Result    := miiTk_Button;
     end else if AName = 'tk_entry' then begin
          Result    := miiTk_Entry;
     end else if AName = 'tk_check' then begin
          Result    := miiTk_Check;
     end else if AName = 'tk_radio' then begin
          Result    := miiTk_Radio;
     end else if AName = 'tk_listbox' then begin
          Result    := miiTk_Listbox;
     end else if AName = 'tk_text' then begin
          Result    := miiTk_Text;
     end else if AName = 'tk_scale' then begin
          Result    := miiTk_Scale;
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
