unit teUnit;

interface

uses
     //
     SysVars,

     //
     JsonDataObjects,
     FloatSpinEdit,

     //
     Windows,
     Forms,SysUtils, System.ImageList, Vcl.Dialogs, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.ComCtrls, Vcl.ToolWin,
     Graphics, Vcl.ExtCtrls, System.Classes, Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Buttons;


type
     TTEAddMode = (
          amNone,
          amNextSibling,      //移动或新增到当前节点的下一兄弟节点
          amOptionalSibling,  //如果当前节点为第一子固定节点, 则位置为下一个;如果当前为最后固定节点,则为倒数第二个
          amLastChild,        //移动或新增到当前节点的最后子节点
          amPrevLastChild     //移动或新增到当前节点的非最后子节点
          );

const
     __OnlyChild         = 'only child';          //不允许有兄弟模块,只有孩子
     __SiblingAndChild   = 'sibling and child';   //允许有兄弟和孩子
     __FixedChild        = 'fixed child';         //只有固定的孩子
     __OptionalChild     = 'optional child';      //有固定的孩子和可选的孩子
     __AsFixedChild      = 'as fixed child';      //是父亲的固定孩子,还可以有的兄弟
     __AsOptionalChild   = 'as optional child';   //作为可选的孩子，配合parent使用
     __NoChild           = 'no child';            //不能拥有孩子

const
     _Caption       = 'caption';

const
     _ShowDebug     = True;

//
function  teTreeToJson(ANode:TTreeNode):TJsonObject;                  //从树节点，得到相应的Json节点
function  teInModules(AName:string;AArray:TJsonArray):Boolean;        //判断当前name是否在JSON数组中 is AName is Array
function  teInNames(AName:string;AArray:array of string):Boolean;     //判断当前name是否在string数组中 is AName is strings
function  teFindModule(AName:string):TJsonObject;                     //根据name,得到模块JSON  Find Module by name
function  teGetAddMode(ASource,ADest: String): TTEAddMode;            //根据两个模块名称,得到添加的模式   Get the Add mode
procedure teJsonToTree(TV:TTreeView);                                 //根据JSON生成树 create tree from json
procedure teAddChild(ATNode:TTreeNode;AJNode:TJsonObject);            //
function  teColorToArray(AColor:TColor):TJsonArray;                   //
function  teArrayToColor(AArray:TJsonArray):TColor;
function  teFontToJson(AFont:TFont):TJsonObject;
function  teJsonToFont(AFont:TFont;AJson:TJsonObject):Integer;
procedure teSaveNodeProperty(ANode:TJsonObject; APanel:TFlowPanel);
procedure teShowNodeProperty(ANode: TJsonObject;APanel:TFlowPanel);
procedure teSetUpDownEnable(ANode:TTreeNode;ADown,AUp:TToolButton);
procedure teMoveTreeNodeUp(ANode:TTreeNode);
procedure teMoveTreeNodeDown(ANode:TTreeNode);
procedure teInitProject;                                              //初始化工程
procedure teShowMsg(AString:String);                                  //调试时显示对话框
procedure teAddModule(ANode:TTreeNode;AModuleIndex:Integer);          //在ANode节点上添加 序号为AModuleIndex的模块


//根据模块名称, 设置图标(需要根据需要自行修改)
function teGetModuleImageIndex(AName : string) : Integer;


implementation

uses
    Main;

function GetMaxContrastColor(C: TColor): TColor;
var
  R, G, B, Brightness: Integer;
begin
  // 获取颜色的 RGB 分量
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);

  // 计算亮度
  Brightness := Round(0.299 * R + 0.587 * G + 0.114 * B);

  // 根据亮度返回对比度最大的颜色
  if Brightness > 128 then
    Result := clBlack  // 如果颜色较亮，则返回黑色
  else
    Result := clWhite; // 如果颜色较暗，则返回白色
end;

function teGetModuleImageIndex(AName : string) : Integer;
begin
    Result  := 0;
    if AName = 'root' then begin
        Result    := 1;
    end else if AName = 'environment' then begin
        Result    := 2;
    end else if AName = 'planes' then begin
        Result    := 2;
    end else if AName = 'plane' then begin
        Result    := 3;
    end else if AName = 'threats' then begin
        Result    := 3;
    end else if AName = 'threat' then begin
        Result    := 4;
    end else if AName = 'route' then begin
        Result    := 4;
    end else if AName = 'devices' then begin
        Result    := 4;
    end else if AName = 'point' then begin
        Result    := 5;
    end else begin
        Result  := 0;
    end;
end;


procedure teShowMsg(AString:String);
begin
     if _ShowDebug then begin
          ShowMessage(AString);
     end;
end;

procedure LabelFontClick(Self: TObject; Sender: TObject);     //label font
var
    oLabel          : TLabel;
    oFontDialog     : TFontDialog;
begin
    //取得各控件
    oLabel              := TLabel(Sender);
    oFontDialog         := TFontdialog.Create(oLabel.Owner);
    oFontDialog.Font    := oLabel.Font;
    oFontDialog.Execute;
    //

    //更新当前font节点属性为当前属性
    oLabel.Font  := oFontDialog.Font;

    //
    oFontDialog.destroy;
end;

procedure LabelColorClick(Self: TObject; Sender: TObject);     //label font
var
    oLabel          : TLabel;
    oColorDialog    : TColorDialog;
begin
    //取得各控件
    oLabel              := TLabel(Sender);
    oColorDialog        := TColordialog.Create(oLabel.Owner);
    oColorDialog.Color  := oLabel.Color;
    oColorDialog.Execute;
    //

    //更新当前Color节点属性为当前属性
    oLabel.Color  := oColorDialog.Color;

    //
    oColorDialog.destroy;
end;


procedure  teInitProject;
var
     iChild    : Integer;
     iProp     : Integer;
     joModule  : TJsonObject;
     jaProps   : TJsonArray;
     joProp    : TJsonObject;
     sName     : string;
begin
     try
          //创建根节点
          gjoProject     := TJsonObject.Create;
          gjoProject.S['_m_']     := gjoModules.A['items'][0].S['_m_'];
          gjoProject.A['items']    := TJsonArray.Create;

          //添加属性
          joModule  := gjoModules.A['items'][0];
          jaProps   := joModule.A['property'];
          for iProp := 0 to jaProps.Count-1 do begin
               joProp    := jaProps.O[iProp];
               //
               with gjoProject do begin
                    if joProp.S['type'] = 'string' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'source' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'memo' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'integer' then begin
                         I[joProp.S['_m_']] := joProp.I['default'];
                    end else if joProp.S['type'] = 'boolean' then begin
                         B[joProp.S['_m_']] := joProp.B['default'];
                    end else if joProp.S['type'] = 'list' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'color' then begin
                         A[joProp.S['_m_']] := TJsonArray.Create;
                         A[joProp.S['_m_']].FromUtf8JSON(joProp.A['default'].ToUtf8JSON);
                    end else if joProp.S['type'] = 'font' then begin
                         O[joProp.S['_m_']] := TJsonObject.Create;
                         if joProp.Contains('default') then begin
                              O[joProp.S['_m_']].FromUtf8JSON(joProp.O['default'].ToUtf8JSON);
                         end;
                    end else if joProp.S['type'] = 'float' then begin
                         F[joProp.S['_m_']] := joProp.F['default'];
                    end;
               end;
          end;

          //添加子块
          for iChild := 0 to gjoModules.A['items'][0].A['child'].Count-1 do begin
               sName     := gjoModules.A['items'][0].A['child'].S[iChild];
               joModule  := teFindModule(sName);
               //
               jaProps   := joModule.A['property'];
               for iProp := 0 to jaProps.Count-1 do begin
                    joProp    := jaProps.O[iProp];
                    with gjoProject.A['items'].AddObject do begin
                         S['_m_'] := sName;
                         //
                         if joProp.S['type'] = 'string' then begin
                              S[joProp.S['_m_']] := joProp.S['default'];
                         end else if joProp.S['type'] = 'source' then begin
                              S[joProp.S['_m_']] := joProp.S['default'];
                         end else if joProp.S['type'] = 'memo' then begin
                              S[joProp.S['_m_']] := joProp.S['default'];
                         end else if joProp.S['type'] = 'integer' then begin
                              I[joProp.S['_m_']] := joProp.I['default'];
                         end else if joProp.S['type'] = 'boolean' then begin
                              B[joProp.S['_m_']] := joProp.B['default'];
                         end else if joProp.S['type'] = 'list' then begin
                              S[joProp.S['_m_']] := joProp.S['default'];
                         end else if joProp.S['type'] = 'color' then begin
                              A[joProp.S['_m_']] := TJsonArray.Create;
                              A[joProp.S['_m_']].FromUtf8JSON(joProp.A['default'].ToUtf8JSON);
                         end else if joProp.S['type'] = 'font' then begin
                              O[joProp.S['_m_']] := TJsonObject.Create;
                              if joProp.Contains('default') then begin
                                   O[joProp.S['_m_']].FromUtf8JSON(joProp.O['default'].ToUtf8JSON);
                              end;
                         end else if joProp.S['type'] = 'float' then begin
                              F[joProp.S['_m_']] := joProp.F['default'];
                         end;
                    end;
               end;
          end;
     except
          teShowMsg('Error when teInitProject!');

     end;
end;



procedure teAddModule(ANode:TTreeNode;AModuleIndex:Integer);
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
               S['_m_']      := AjoModule.S['_m_'];
               //add property
               for iProp := 0 to AjoModule.A['property'].Count-1 do begin
                    joProp    := AjoModule.A['property'][iProp];
                    if joProp.S['type'] = 'string' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'source' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'memo' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'integer' then begin
                         I[joProp.S['_m_']] := joProp.I['default'];
                    end else if joProp.S['type'] = 'boolean' then begin
                         B[joProp.S['_m_']] := joProp.B['default'];
                    end else if joProp.S['type'] = 'list' then begin
                         S[joProp.S['_m_']] := joProp.S['default'];
                    end else if joProp.S['type'] = 'color' then begin
                         A[joProp.S['_m_']] := TJsonArray.Create;
                         A[joProp.S['_m_']].FromUtf8JSON(joProp.A['default'].ToUtf8JSON);
                    end else if joProp.S['type'] = 'font' then begin
                         O[joProp.S['_m_']] := TJsonObject.Create;
                         if joProp.Contains('default') then begin
                              O[joProp.S['_m_']].FromUtf8JSON(joProp.O['default'].ToUtf8JSON);
                         end;
                    end else if joProp.S['type'] = 'float' then begin
                         F[joProp.S['_m_']] := joProp.F['default'];
                    end;

                    //get text of new node
                    if joProp.S['_m_'] = _Caption then begin
                         sCaption  := joProp.S['default'];
                    end;
               end;

          end;

          //new tree node
          tnNew     := TTreeView(ANode.TreeView).Items.AddChild(AtnParent,sCaption);
          tnNew.MakeVisible;

          //设置图标
          with tnNew do begin
               ImageIndex     := teGetModuleImageIndex(AjoModule.S['_m_']);
               SelectedIndex  := ImageIndex;
          end;

          //
          if AIndex <> -1 then begin
               if AtnParent.Count>AIndex then begin
                    if tnNew <>  AtnParent.Item[AIndex] then begin
                         tnNew.MoveTo(AtnParent.Item[AIndex],naInsert);
                    end;
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
     try
          //得到当前工程节点get json node from treenode
          joCur     := teTreeToJson(ANode);

          //
          joSelMdl  := teFindModule(joCur.S['_m_']);

          //get the module jsonobject 得到模块节点
          joModule  := gjoModules.A['items'][AModuleIndex];

          //get the new type : child/sibling
          oAddMode  := teGetAddMode(joModule.S['_m_'], joSelMdl.S['_m_']);

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




          //
          gbModified     := True;
     except
          teShowMsg('Error when teAddModule!');

     end;
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
     try
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
          if ANode <> tnPrev then begin
               ANode.MoveTo(tnPrev,naInsert);
          end;

     except
          teShowMsg('Error when teMoveTreeNodeUp!');

     end;
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
     try
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
          if tnNext <> ANode then begin
               tnNext.MoveTo(ANode,naInsert);
          end;

     except
          teShowMsg('Error when teMoveTreeNodeDown!');

     end;
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
          sName     := joNode.S['_m_'];
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
                    joMdlPrev := teFindModule(joPrev.S['_m_']);
                    //
                    sModePrev := joMdlPrev.S['mode'];
                    AUp.Enabled    := _GetB(sModePrev);
               end;
          end else begin
               if (tnPrev = nil) then begin
                    AUp.Enabled    := False;
                    //
                    joNext    := teTreeToJson(tnNext);
                    joMdlNext := teFindModule(joNext.S['_m_']);
                    //
                    sModeNext := joMdlNext.S['mode'];
                    ADown.Enabled  := _GetB(sModeNext);
               end else begin
                    //
                    joNext    := teTreeToJson(tnNext);
                    joMdlNext := teFindModule(joNext.S['_m_']);
                    //
                    sModeNext := joMdlNext.S['mode'];
                    ADown.Enabled  := _GetB(sModeNext);
                    //
                    joPrev    := teTreeToJson(tnPrev);
                    joMdlPrev := teFindModule(joPrev.S['_m_']);
                    //
                    sModePrev := joMdlPrev.S['mode'];
                    AUp.Enabled    := _GetB(sModePrev);
               end;
          end;
     except
          teShowMsg('Error when teSetUpDownEnable!');

     end;
end;

procedure teShowNodeProperty(ANode: TJsonObject;APanel:TFlowPanel);
var
    iProp       : Integer;
    iCtrl       : Integer;
    iItem       : Integer;
    //
    joProp      : TJsonObject;
    joModule    : TJsonObject;
    //
    oPanel      : TPanel;
    oLabel      : TLabel;
    oCheck      : TCheckBox;
    oLabelProp  : TLabel;
    oSpinEdit   : TSpinEdit;
    oEdit       : TEdit;
    oMemo       : TMemo;
    oCheckBox   : TCheckBox;
    oComboBox   : TComboBox;
    oColorBox   : TColorBox;
    oSpeedBtn   : TSpeedButton;
    oFloatSE    : TFloatSpinEdit;
    //
    bFoundSrc   : Boolean;     //found source property
    tM          : TMethod;      //用于指定事件
begin
    try

        //如果当前节点为nil,则退出
        if ANode = nil then begin
            Exit;
        end;

        //
        joModule  := teFindModule(ANode.S['_m_']);

        //显示属性
        bFoundSrc := False;
        for iProp := 0 to joModule.A['property'].Count-1 do begin
            //属性json节点
            joProp    := joModule.A['property'][iProp];
            //属性的外框
            oPanel    := TPanel(APanel.Controls[iProp]);
            //属性名称
            oLabel    := TLabel(oPanel.Controls[0]);

            //属性值
            if joProp.S['type'] = 'boolean' then begin
                oCheck  := TCheckBox(oPanel.Controls[2]);
                if ANode.Contains(joProp.S['_m_']) then begin
                    oCheck.Checked  := ANode.B[joProp.S['_m_']];
                end else begin
                    if joProp.Contains('default') then begin
                        oCheck.Checked  := joProp.B['default'];
                    end else begin
                        oCheck.Checked  := False;
                    end;
                end;
            end else if joProp.S['type'] = 'color' then begin
                oLabelProp          := TLabel(oPanel.Controls[2]);
                if ANode.Contains(joProp.S['_m_']) then begin
                    oLabelProp.Color    := teArrayToColor(ANode.A[joProp.S['_m_']]);
                end else begin
                    oLabelProp.Color    := RGB(254,254,254);
                end;
                oLabelProp.Transparent  := False;
                //
                tM.Code             := @LabelColorClick;
                tM.Data             := Pointer(325); // 随便取的数
                oLabelProp.OnClick  := TNotifyEvent(tM);
            end else if joProp.S['type'] = 'string' then begin
                oEdit          := TEdit(oPanel.Controls[2]);
                oEdit.Text     := ANode.S[joProp.S['_m_']];
            end else if joProp.S['type'] = 'memo' then begin
                oMemo          := TMemo(oPanel.Controls[2]);
                oMemo.Text     := ANode.S[joProp.S['_m_']];
            end else if joProp.S['type'] = 'integer' then begin
                oEdit          := TEdit(oPanel.Controls[2]);
                if ANode.Contains(joProp.S['_m_']) then begin
                    oEdit.Text  := IntToStr(ANode.I[joProp.S['_m_']]);
                end else begin
                    oEdit.Text  := '';
                end;
            end else if joProp.S['type'] = 'source' then begin
                oMemo       := TMemo(oPanel.Controls[2]);
                oMemo.Text  := ANode.S[joProp.S['_m_']];
            end else if joProp.S['type'] = 'boolean' then begin
                oCheckBox           := TCheckBox(oPanel.Controls[2]);
                oCheckBox.Checked   := ANode.B[joProp.S['_m_']];
            end else if joProp.S['type'] = 'list' then begin
                oComboBox           := TComboBox(oPanel.Controls[2]);
                oComboBox.ItemIndex := oComboBox.Items.IndexOf(ANode.S[joProp.S['_m_']]);  //HERE! IndexOfName not work correct!
            end else if joProp.S['type'] = 'font' then begin
                oLabelProp  := TLabel(oPanel.Controls[2]);
                oLabelProp.Transparent  := False;
                teJsonToFont(oLabelProp.Font,ANode.O[joProp.S['_m_']]);
                oLabelProp.Color    := GetMaxContrastColor(oLabelProp.font.Color);
                //
                tM.Code             := @LabelFontClick;
                tM.Data             := Pointer(325); // 随便取的数
                oLabelProp.OnClick  := TNotifyEvent(tM);
            end else if joProp.S['type'] = 'float' then begin
                oEdit          := TEdit(oPanel.Controls[2]);
                if ANode.Contains(joProp.S['_m_']) then begin
                    oEdit.Text  := FloatToStr(ANode.F[joProp.S['_m_']]);
                end else begin
                    oEdit.Text  := '';
                end;
                //oFloatSE           := TFloatSpinEdit(oPanel.Controls[2]);
                //oFloatSE.Value     := ANode.F[joProp.S['_m_']];
            end;
        end;

    except
        teShowMsg('Error when teShowNodeProperty!');

    end;
end;


procedure teSaveNodeProperty(ANode:TJsonObject; APanel:TFlowPanel);
var
    //
    iProp       : Integer;
    //
    joProp      : TJsonObject;
    joModule    : TJsonObject;

    //
    oPanel      : TPanel;
    oEdit       : TEdit;
    oLabelProp  : TLabel;
    oMemo       : TMemo;
    oSpinEdit   : TSpinEdit;
    oCheckBox   : TCheckBox;
    oComboBox   : TComboBox;
    oColorBox   : TColorBox;
    oSpeedBtn   : TSpeedButton;
    oFloatSE    : TFloatSpinEdit;
    //
    sDebug      : string;
    sType       : string;
    sName       : string;
begin
     try

          //取得当前模块
          joModule  := teFindModule(ANode.S['_m_']);

          //
          for iProp := 0 to APanel.ControlCount-1 do begin
               //取得当前属性JSON
               joProp    := joModule.A['property'][iProp];

               //取得属性类型和名称
               sType    := joProp.S['type'];
               sName    := joProp.S['_m_'];

               //取得面板
               oPanel    := TPanel(APanel.Controls[iProp]);

               //
               if sType = 'boolean' then begin
                    oCheckBox     := TCheckBox(oPanel.Controls[2]);
                    ANode.B[sName]    := oCheckBox.Checked;
               end else if sType = 'color' then begin
                    oLabelProp  := TLabel(oPanel.Controls[2]);
                    if oLabelProp.Color = RGB(254,254,254) then begin
                        ANode.Remove(sName);
                    end else begin
                        ANode.A[sName].FromUtf8JSON(teColorToArray(oLabelProp.Color).ToUtf8JSON(False));
                    end;
               end else if sType = 'float' then begin
                    oEdit     := TEdit(oPanel.Controls[2]);
                    if oEdit.Text = '' then begin
                        if ANode.Contains(sName) then begin
                            ANode.Remove(sName);
                        end;
                    end else begin
                        ANode.F[sName]    := StrToFloatDef(oEdit.Text,0);
                    end;
               end else if sType = 'font' then begin
                    oSpeedBtn := TSpeedButton(oPanel.Controls[2]);
                    ANode.O[sName]    := TJsonObject.Create;
                    ANode.O[sName].FromUtf8JSON(teFontToJson(oSpeedBtn.Font).ToUtf8JSON(False));
               end else if sType = 'integer' then begin
                    oEdit     := TEdit(oPanel.Controls[2]);
                    if oEdit.Text = '' then begin
                        if ANode.Contains(sName) then begin
                            ANode.Remove(sName);
                        end;
                    end else begin
                        ANode.I[sName]    := StrToIntDef(oEdit.Text,0);
                    end;
               end else if sType = 'list' then begin
                    oComboBox := TComboBox(oPanel.Controls[2]);
                    ANode.S[sName]    := oComboBox.Text;
               end else if sType = 'memo' then begin
                    oMemo     := TMemo(oPanel.Controls[2]);
                    ANode.S[sName]    := oMemo.Text;
               end else if sType = 'source' then begin
                    oMemo  := TMemo(oPanel.Controls[2]);
                    ANode.S[sName]    := oMemo.Text;
               end else if sType = 'string' then begin
                    oEdit     := TEdit(oPanel.Controls[2]);
                    ANode.S[sName]    := oEdit.Text;

               end;

               //更新树节点显示
               if joProp.S['_m_'] = _Caption then begin
                    //ATV.Selected.Text   := ANode.S[_Caption];
               end;
          end;

     except
          teShowMsg('Error when teSaveNodeProperty!');

     end;
end;


function  teFontToJson(AFont:TFont):TJsonObject;
begin
    try

        Result  := TJsonObject.Create;
        Result.S['name']    := AFont.Name;
        Result.I['size']    := AFont.Size;
        Result.A['color']   := TJsonArray.Create;
        Result.A['color'].FromUtf8JSON(teColorToArray(AFont.Color).ToUtf8JSON(False));
        Result.I['b']       := Integer(fsBold in AFont.Style);
        Result.I['i']       := Integer(fsItalic in AFont.Style);
        Result.I['u']       := Integer(fsUnderline in AFont.Style);
        Result.I['s']       := Integer(fsStrikeOut in AFont.Style);
    except
        teShowMsg('Error when teFontToJson!');
    end;
end;

function  teJsonToFont(AFont:TFont;AJson:TJsonObject):Integer;
begin
    try
        Result    := 0;
        //
        if AJson = nil then begin
            Exit;
        end;

        if AJson.Contains('name') then begin
            AFont.Name     := AJson.S['name'];
        end;
        if AJson.Contains('color') then begin
            AFont.color    := teArrayToColor(AJson.A['color']);
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

    except
    teShowMsg('Error when teJsonToFont!');

    end;
end;
function  teColorToArray(AColor:TColor):TJsonArray;    //
begin
    try
        Result    := TJsonArray.Create;
        Result.add(GetRValue(ColorToRGB(AColor)));
        Result.add(GetGValue(ColorToRGB(AColor)));
        Result.add(GetBValue(ColorToRGB(AColor)));

    except
        Result  := TJsonArray.Create;
        Result.Add(128);
        Result.Add(128);
        Result.Add(128);
        //teShowMsg('Error when teColorToArray!');

    end;
end;

function  teArrayToColor(AArray:TJsonArray):TColor;
begin
     try
          Result    := clNone;

          //
          if AArray = nil then begin
               Exit;
          end;
          if AArray.Count<>3 then begin
               Exit;
          end;

          Result    := AArray.I[0] + AArray.I[1] shl 8 + AArray.I[2] shl 16;
     except
          teShowMsg('Error when teArrayToColor!');

     end;

end;
//
function  teTreeToJson(ANode:TTreeNode):TJsonObject;       //从树节点，得到相应的Json节点
var
     iIDs      : array of Integer; //用于保存Index序列
     //
     I,J,iHigh : Integer;
begin
     try
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
     except
          teShowMsg('Error when teTreeToJson!');

     end;
end;


function  teInModules(AName:string;AArray:TjsonArray):Boolean;
var
     I         : Integer;
begin
     try
          Result    := False;
          for I := 0 to AArray.Count-1 do begin
               if AArray.S[I] = AName then begin
                    Result    := True;
                    Break;
               end;
          end;
     except
          teShowMsg('Error when teInModules!');

     end;
end;

function  teInNames(AName:string;AArray:array of string):Boolean;
var
     I         : Integer;
begin
     try
          Result    := False;
          for I := 0 to High(AArray) do begin
               if AArray[I] = AName then begin
                    Result    := True;
                    Break;
               end;
          end;
     except
          teShowMsg('Error when teInNames!');

     end;
end;


function  teFindModule(AName:string):TJsonObject;
var
     iModule   : Integer;
begin
     try
          Result    := nil;
          for iModule := 0 to gjoModules.A['items'].Count-1 do begin
               if gjoModules.A['items'][iModule].S['_m_'] = AName then begin
                    Result    := gjoModules.A['items'][iModule];
                    Break;
               end;
          end;

          //
          if Result = nil then begin
               ShowMessage('Error when teFindModule : '+AName);
          end;
     except
          teShowMsg('Error when teFindModule!');

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
     try

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
          sNameSrc  := joSource.S['_m_'];
          sNameDest := joDest.S['_m_'];


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

     except
          teShowMsg('Error when teGetAddMode!');

     end;
end;

procedure teAddChild(ATNode:TTreeNode;AJNode:TJsonObject);
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
     try
          ssName    := AJNode.S['_m_'];
          jjModule  := teFindModule(ssName);
          //
          ATNode.Text    := '[' + ssName + '] '+AJNode.S[_Caption];

          //
          ATNode.ImageIndex     := teGetModuleImageIndex(ssName);
          ATNode.SelectedIndex     := ATNode.ImageIndex;


          //
          for iiItem := 0 to AJNode.A['items'].Count-1 do begin
               jjItem    := AJNode.A['items'][iiItem];
               tnChild   := TTreeView(ATNode.TreeView).Items.AddChild(ATNode,jjItem.S[_Caption]);
               //
               teAddChild(tnChild,jjItem);
          end;
     except
          teShowMsg('Error when teAddChild!');

     end;
end;

procedure teJsonToTree(TV:TTreeView);

begin
     try
          TV.Items[0].DeleteChildren;
          teAddChild(TV.Items[0],gjoProject);
     except
          teShowMsg('Error when teJsonToTree!');

     end;
end;

end.
