unit Main;


interface


uses

     //--------------------------------------自编单元-----------------------------------------------
     SysVars,

     teUnit,


     //--------------------------------------第三方-------------------------------------------------
     JsonDataObjects,

     //
     SynEdit, SynEditHighlighter,SynEditCodeFolding, SynHighlighterJSON,

     //
     mxClickSplitter,

     //-------------------------------------系统自带------------------------------------------------
     Forms,SysUtils, System.ImageList, Vcl.Dialogs, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.ComCtrls, Vcl.ToolWin,
     Vcl.ExtCtrls, System.Classes, Vcl.StdCtrls, Vcl.Samples.Spin;

type
  TMainForm = class(TForm)
    OpenDialog: TOpenDialog;
    ImageList_ToolBar: TImageList;
    Panel_ToolBar: TPanel;
    ToolBar: TToolBar;
    ToolButton_Open: TToolButton;
    ToolButton1: TToolButton;
    ToolButton_Save: TToolButton;
    ToolButton_Expand: TToolButton;
    ToolButton_Collapse: TToolButton;
    ToolButton_Up: TToolButton;
    ToolButton_Down: TToolButton;
    ToolButton_Help: TToolButton;
    MainMenu: TMainMenu;
    MenuItem_File: TMenuItem;
    MenuItem_New: TMenuItem;
    MenuItem_OpenProject: TMenuItem;
    MenuItem_Save: TMenuItem;
    N2: TMenuItem;
    MenuItem_Exit: TMenuItem;
    MenuItem_Edit: TMenuItem;
    MenuItem_GenerateCurr: TMenuItem;
    MenuItem_RefreshTree: TMenuItem;
    N10: TMenuItem;
    MenuItem_ExpandAll: TMenuItem;
    MenuItem_ShrinkAll: TMenuItem;
    MenuItem_Option: TMenuItem;
    MenuItem_Help: TMenuItem;
    MenuItem_HomePage: TMenuItem;
    N3: TMenuItem;
    MenuItem_About: TMenuItem;
    PopupMenu_TreeView: TPopupMenu;
    N18: TMenuItem;
    PopMenu_Copy: TMenuItem;
    PopMenu_Paste: TMenuItem;
    PopMenu_Delete: TMenuItem;
    ToolButton_NewProject: TToolButton;
    StatusBar: TStatusBar;
    ToolButton7: TToolButton;
    N20: TMenuItem;
    Delete1: TMenuItem;
    Panel_Left: TPanel;
    TreeView: TTreeView;
    SaveDialog: TSaveDialog;
    PopMenu_Cut: TMenuItem;
    N4: TMenuItem;
    PopMenu_SetRoot: TMenuItem;
    Cut1: TMenuItem;
    mxClickSplitter1: TmxClickSplitter;
    mxClickSplitter_Left: TmxClickSplitter;
    Panel_LeftBottom: TPanel;
    ImageList_TextModes: TImageList;
    N5: TMenuItem;
    PopMenu_tkinterwindow: TMenuItem;
    Panel_Client: TPanel;
    SynEdit: TSynEdit;
    SynJSONSyn: TSynJSONSyn;
    procedure PopMenu_DeleteClick(Sender: TObject);
    procedure TreeViewCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure PopMenu_CopyClick(Sender: TObject);
    procedure PopMenu_PasteClick(Sender: TObject);
    procedure MenuItem_ExpandAllClick(Sender: TObject);
    procedure MenuItem_CloseAllClick(Sender: TObject);
    procedure MenuItem_ExpandSelClick(Sender: TObject);
    procedure PopupMenu_TreeViewPopup(Sender: TObject);
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem_ExitClick(Sender: TObject);
    procedure TreeViewClick(Sender: TObject);
    procedure ToolButton_ExpandClick(Sender: TObject);
    procedure ToolButton_CollapseClick(Sender: TObject);
    procedure ToolButton_UpClick(Sender: TObject);
    procedure ToolButton_DownClick(Sender: TObject);
    procedure ToolButton_SaveClick(Sender: TObject);
    procedure ToolButton_OpenClick(Sender: TObject);
    procedure PopMenu_CutClick(Sender: TObject);
    procedure ToolButton_NewProjectClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
     private
          iMoveX         : Integer;
          iMoveY         : Integer;
          bIsCreating    : Boolean;          //标志是否正在生成树的,用于控制节点转换时是否绘制流程图
          bClose         : Boolean;
          bDelete        : Boolean;
          gtnCurNode     : TTreeNode;        //鼠标按下时的树节点，用于右键选中
          //
          gsDragSrcText  : string;           //待复制/剪切节点的Text
          gsDragSrcMode  : string;           //待复制/剪切节点的类型
          //
          gjoCopy        : TJsonObject;      //待复制/剪切节点构成的XML
          gjoCopySource  : TJsonObject;      //复制为nil，剪切时为源节点
          //
          procedure PopItem_ModuleClick(Sender: TObject);
          procedure PropertyChange(Sender: TObject);
          procedure ShowNodeProperty(ANode:TJsonObject);
          procedure SaveNodeProperty;
     public

          //
          procedure SetUpDownEnable(ANode:TTreeNode);
     end;

var
     MainForm       : TMainForm;





implementation



{$R *.dfm}


procedure TMainForm.PopMenu_DeleteClick(Sender: TObject);
var
     //
     joNode    : TJsonObject;
     joModule  : TJsonObject;
     joParent  : TJsonObject;
     //
     tnNode    : TTreeNode;
     tnPar     : TTreeNode;
begin
     //得到相应的树节点
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          ShowMessage('Please selected a node at first!');
          Exit;
     end;
     joNode    := teTreeToJson(tnNode);

     //<异常检查
     //检查节点不能为nil
     if joNode=nil then begin
          ShowMessage('Please selected a node at first!');
          Exit;
     end;

     //不允许删除根节点
     if tnNode.Level = 0 then begin
          ShowMessage('Cannot delete the root node!');
          Exit;
     end;

     //不允许删除一些特定节点
     joModule  := teFindModule(joNode.S['name']);

     if teInNames(joModule.S['mode'],['only child','as fixed child','as optional child']) then begin
          ShowMessage('Cannot delete the neccessary node!');
          Exit;
     end;
     //>


     //确认删除
     if MessageDlg(#13+'Are you really want to delete the node named "' +tnNode.Text+'" ?'+#13,
               mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
     begin
          Exit;
     end;

     //删除json节点
     joParent  := teTreeToJson(tnNode.Parent);
     joParent.A['items'].Delete(tnNode.Index);

     //删除树节点， 并设其父节点为当前节点
     tnPar     := tnNode.Parent;
     tnPar.Selected   := True;
     tnNode.Destroy;

     //
     SynEdit.Text   := gjoProject.ToJSON(False);

     //设置已修改标识
     gbModified     := True;
end;

//------------------------------显示节点的属性----------------------------------------------------//
procedure TMainForm.ShowNodeProperty(ANode: TJsonObject);
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
     oSynEdit  : TSynEdit;
     oCheckBox : TCheckBox;
     oComboBox : TComboBox;
     //
     bFoundSrc : Boolean;     //found source property
begin
     //Clear All components of Panel_LeftBottom
     for iCtrl := Panel_LeftBottom.ControlCount-1 downto 0 do begin
          Panel_LeftBottom.Controls[iCtrl].Destroy;
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
          oPanel    := TPanel.Create(self);
          oPanel.Parent       := Panel_LeftBottom;
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
               oEdit.OnChange := PropertyChange;
          end else if joProp.S['type'] = 'integer' then begin
               oSpinEdit           := TSpinEdit.Create(oPanel);
               oSpinEdit.Parent    := oPanel;
               oSpinEdit.Align     := alClient;
               oSpinEdit.Value     := ANode.I[joProp.S['name']];
               oSpinEdit.OnChange  := PropertyChange;
          end else if joProp.S['type'] = 'source' then begin
               oSynEdit       := TSynEdit.Create(oPanel);
               oSynEdit.Parent:= oPanel;
               oSynEdit.Align := alClient;
               oSynEdit.Text  := ANode.S[joProp.S['name']];
               oSynEdit.OnChange   := PropertyChange;
               oSynEdit.Gutter.Visible  := False;
               //
               bFoundSrc := True;
               oPanel.Align   := alClient;
          end else if joProp.S['type'] = 'boolean' then begin
               oCheckBox           := TCheckBox.Create(oPanel);
               oCheckBox.Parent    := oPanel;
               oCheckBox.Align     := alClient;
               oCheckBox.Checked   := ANode.B[joProp.S['name']];
               oCheckBox.OnClick   := PropertyChange;
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
               oComboBox.ItemIndex := joProp.I['default'];
               oComboBox.OnChange  := PropertyChange;
          end;
     end;

end;


procedure TMainForm.TreeViewCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
var
     tnRoot    : TTreeNode;
     xnCur     : TJsonObject;
begin
Exit;
{
     //如果当前节点禁用,则显示禁用图标
     xnCur     := GetXMLNodeFromTreeNode(Node);
     if xnCur=nil then begin
          //ShowMessage(Node.Text);
          Exit;
     end;
     if xnCur.HasAttribute('Enabled') then begin
          if not xnCur.Attributes['Enabled'] then begin
               Node.StateIndex     := 12;
          end else begin
               Node.StateIndex     := -1;
          end;
     end else begin
          Node.StateIndex     := -1;
     end;
     //end;
}
end;

procedure TMainForm.TreeViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
     tnTar     : TTreeNode;
     tnSrc     : TTreeNode;
     //
     xnTar     : TJsonObject;
     xnSrc     : TJsonObject;
     //
     iTarMode  : Integer;
     iSrcMode  : Integer;
     //
     bParent   : Boolean;
     xnNode    : TJsonObject;

     I,iMode   : Integer;
     Node      : TTreeNode;
     TarNode   : TTreeNode;
     SrcNode   : TTreeNode;
     iSrcID    : Integer;
begin
     try
{
          //得到相应树节点
          tnSrc     := TreeView.Selected;         //得到源节点
          tnTar     := TreeView.GetNodeAt(X,Y);   //得到目的节点
          if (tnSrc=nil)or(tnTar=nil) then begin
               Accept    := False;
               Exit;   //异常处理
          end;

          //得到XML节点
          xnSrc     := GetXMLNodeFromTreeNode(gxdXML,tnSrc);
          xnTar     := GetXMLNodeFromTreeNode(gxdXML,tnTar);
          if (xnSrc=nil)or(xnTar=nil) then begin
               Accept    := False;
               Exit;   //异常处理
          end;
          iSrcMode  := xnSrc.Attributes['Mode'];
          iTarMode  := xnTar.Attributes['Mode'];


          //-------------------------源和目的的类型处理------------------------------------------------//
          //默认可以
          Accept    := True;
          //不能拖动特殊节点
          if InModes(iSrcMode,[]) then begin
               Accept    := False;
               Exit;
          end;

          //不能拖动父节点子节点
          bParent   := False;
          xnNode    := xnTar;
          while True do begin
               if xnNode=xnSrc then begin
                    bParent   := True;
                    Break;
               end else begin
                    xnNode    := xnNode.ParentNode;
                    if xnNode=nil then begin
                         Break;
                    end;
               end;
          end;
          if bParent then begin
               Accept    := False;
               Exit;
          end;

}

     except
     end;
end;

procedure TMainForm.TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
     tnTar     : TTreeNode;
     tnSrc     : TTreeNode;
     //
     xnTar     : TJsonObject;
     xnSrc     : TJsonObject;
     xnNew     : TJsonObject;
     iIndex    : Integer;

begin
{
     //得到相应树节点
     tnSrc     := TreeView.Selected;         //得到源节点
     tnTar     := TreeView.GetNodeAt(X,Y);   //得到目的节点
     if (tnSrc=nil)or(tnTar=nil) then Exit;   //异常处理

     //得到XML节点
     xnSrc     := GetXMLNodeFromTreeNode(gxdXML,tnSrc);
     xnTar     := GetXMLNodeFromTreeNode(gxdXML,tnTar);
     if (xnSrc=nil)or(xnTar=nil) then Exit;   //异常处理


     //取得拖动节点的模式
     //rDragMode := GetNewMode(xnSrc.Attributes['Mode'],xnTar.Attributes['Mode']);

     case rDragMode.AddMode of
          nmChild : begin     //成为子项
               if MessageDlg('Do you really want to move node '+#13+#13+'['+tnSrc.Text+']'+#13+#13+' inside '+#13+#13
                         +'['+tnTar.Text+']'+'?',
                         mtConfirmation, [mbYes, mbNo], 0) = mrYes then
               begin
                    //更改XML
                    xnNew     := xnTar.AddChild(xnSrc.NodeName);
                    CopyXMLNode(xnSrc,xnNew);
                    iIndex    := GetXMLNodeIndex(xnSrc);
                    xnSrc.ParentNode.ChildNodes.Delete(iIndex);

                    //更改TreeView
                    TreeView.Items.BeginUpdate;
                    tnSrc.MoveTo(tnTar,naAddChild);
                    TreeView.Items.EndUpdate;
               end;
          end;
          nmAppend : begin    //同级
               if MessageDlg('Do you really want to move node  '+#13+#13+'"'+tnSrc.Text+'"'+#13+#13+' after '+#13+#13
                         +'['+tnTar.Text+']'+' ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
               begin
                    //拖动XML节点
                    iIndex    := GetXMLNodeIndex(xnTar);
                    xnNew     := xnTar.ParentNode.AddChild(xnSrc.NodeName,iIndex+1);
                    CopyXMLNode(xnSrc,xnNew);
                    iIndex    := GetXMLNodeIndex(xnSrc);
                    xnSrc.ParentNode.ChildNodes.Delete(iIndex);

                    //拖动树节点
                    TreeView.Items.BeginUpdate;
                    if tnTar.getNextSibling=nil then begin
                         tnSrc.MoveTo(tnTar.Parent,naAddChild);
                    end else begin
                         tnSrc.MoveTo(tnTar.getNextSibling,naInsert);
                    end;
                    TreeView.Items.EndUpdate;
               end;
          end;
          nmInsert : begin    //在目的节点前插入
               if MessageDlg('Do you really want to move node '+#13+#13+'['+tnSrc.Text+']'+#13+#13+' before '+#13+#13
                         +'['+tnTar.Text+']'+'?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
               begin
                    //拖动XML节点
                    iIndex    := GetXMLNodeIndex(xnTar);
                    xnNew     := xnTar.ParentNode.AddChild(xnSrc.NodeName,iIndex);
                    CopyXMLNode(xnSrc,xnNew);
                    iIndex    := GetXMLNodeIndex(xnSrc);
                    xnSrc.ParentNode.ChildNodes.Delete(iIndex);

                    //拖动树节点
                    TreeView.Items.BeginUpdate;
                    tnSrc.MoveTo(tnTar,naInsert);
                    TreeView.Items.EndUpdate;
               end;
          end;
     end;
     //
     UpdateChart;
     //
     gbModified     := True;
}
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
     iPage     : Integer;
     iItem     : Integer;
     //
     oPopItem  : TMenuItem;
     //
     joModule  : TJsonObject;
     joProperty: TJsonObject;
begin
     gsMainDir := ExtractFilePath(Application.ExeName);




     //=================================start json =================================================

     //Load modules json for popmenu of treeview
     gjoModules     := TJsonObject.Create;
     gjoModules.LoadFromFile(gsMainDir+'modules.json');
     for iItem := 0 to gjoModules.A['items'].Count-1 do begin
          joModule  := gjoModules.A['items'][iItem];
          //
          oPopItem  := TMenuItem.Create(PopupMenu_TreeView);
          PopupMenu_TreeView.Items.Add(oPopItem);
          oPopItem.MenuIndex       := iItem;
          oPopItem.AutoHotkeys     := maManual;
          oPopItem.Caption         := joModule.S['name'];
          if  joModule.S['name']<>'-' then begin
               oPopItem.OnClick         := PopItem_ModuleClick;
          end;
     end;

     //
     gjoProject     := TJsonObject.Create;
     gjoProject.S['name']     := 'root';
     gjoProject.A['items']    := TJsonArray.Create;

     //
     TreeView.Items[0].ImageIndex       := teModuleNameToImageIndex('file');
     TreeView.Items[0].SelectedIndex    := TreeView.Items[0].ImageIndex
end;

procedure TMainForm.PopItem_ModuleClick(Sender: TObject);
     procedure _AddNode(AtnParent:TTreeNode;AIndex:Integer;AjoModule:TJsonObject);
     var
          joParent  : TJsonObject;
          joNew     : TJsonObject;
          joChild0  : TJsonObject;
          joChild1  : TJsonObject;
          joChild2  : TJsonObject;
          jaParent  : TJsonArray;
          joProp    : TJsonObject;
          //
          tnNew     : TTreeNode;
          tnChild0  : TTreeNode;
          tnChild1  : TTreeNode;
          tnChild2  : TTreeNode;

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
                    end else if joProp.S['type'] = 'integer' then begin
                         I[joProp.S['name']] := joProp.I['default'];
                    end else if joProp.S['type'] = 'boolean' then begin
                         B[joProp.S['name']] := joProp.B['default'];
                    end;

                    //get text of new node
                    if joProp.S['name'] = 'caption' then begin
                         sCaption  := joProp.S['default'];
                    end;
               end;

          end;

          //new tree node
          tnNew     := TreeView.Items.AddChild(AtnParent,sCaption);
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
     joMdlPar  : TJsonObject; //
     tnCur     : TTreeNode;
     tnParent  : TTreeNode;

     //
     sMode     : string;
     //0: as sibling, 1:as child, 3:as sibling(not last), 4: as optional child (not first, not last)
     oAddMode  : TTEAddMode;     //

begin
     //get current treeview node 得到当前树节点
     tnCur     := TreeView.Selected;
     if tnCur = nil then begin
          Exit;
     end;

     //get json node from treenode 得到当前工程节点
     joCur     := teTreeToJson(tnCur);

     //
     joSelMdl  := teFindModule(joCur.S['name']);

     //get the module jsonobject 得到模块节点
     joModule  := gjoModules.A['items'][TMenuItem(Sender).MenuIndex];

     //get the new type : child/sibling
     oAddMode  := teGetAddMode(joModule.S['name'], joSelMdl.S['name']);

     //
     case oAddMode of
          amNextSibling : begin //
               tnParent  := tnCur.Parent;
               _AddNode(tnParent,tnCur.Index+1,joModule);
               tnParent.Item[tnCur.Index+1].Selected := True;
          end;
          amLastChild : begin //
               _AddNode(tnCur,-1,joModule);
               tnCur.Item[tnCur.Count-1].Selected := True;
          end;
          amOptionalSibling : begin //
               tnParent  := tnCur.Parent;
               if tnCur.Index = 0 then begin
                    _AddNode(tnParent,1,joModule);
                    tnParent.Item[1].Selected := True;
               end else begin
                    _AddNode(tnParent,tnCur.Index,joModule);
                    tnParent.Item[tnCur.Index-1].Selected := True;
               end;
          end;
          amPrevLastChild : begin //3: as optional child (not first, not last)
               _AddNode(tnCur,tnCur.Count-1,joModule);
               tnCur.Item[tnCur.Count-2].Selected := True;
          end;
     end;
     gbModified     := True;
     //
     SynEdit.Text   := gjoProject.ToJSON(False);
end;

procedure TMainForm.PopMenu_CopyClick(Sender: TObject);
var
     joNode    : TJsonObject;
begin
     if TreeView.Selected = nil then begin
          ShowMessage('Please selected a node at first!');
          Exit;
     end;

     joNode    := teTreeToJson(TreeView.Selected);

     //
     if joNode=nil then begin
          ShowMessage('Please selected a node at first!');
          Exit;
     end;


     //将源节点保存到XML中
     gjoCopy   := TJsonObject.Create;
     gjoCopy.FromJSON(joNode.ToString);

     //
     gjoCopySource  := joNode;

     //
     PopMenu_Paste.Enabled    := gjoCopy<>nil;

end;

procedure TMainForm.PopMenu_PasteClick(Sender: TObject);
var
     bAllow    : Boolean;
     //
     tnNode    : TTreeNode;
     tnNew     : TTreeNode;
     //
     iIndex    : Integer;
     iNewMode  : Integer;
     //
     joNode    : TJsonObject;
     joNew     : TJsonObject;
     joParent  : TJsonObject;
     //
     oAddMode  : TTEAddMode;
begin
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          Exit;
     end;
     joNode    := teTreeToJson(tnNode);

     //得到当前节点的Index
     iIndex    := tnNode.Index;


     //
     TreeView.Items.BeginUpdate;
     bIsCreating    := True;
     oAddMode  := teGetAddMode(gjoCopy.S['name'],joNode.S['name']);
     case oAddMode of
          amNone : begin
               ShowMessage('Cannot paste node here!');
          end;
          amNextSibling : begin    //追加模式
               joParent  := teTreeToJson(tnNode.Parent);
               joNew     := joParent.A['items'].InsertObject(tnNode.Index+1);
               joNew.FromJSON(gjoCopy.ToString);
               //
               tnNew     := TreeView.Items.AddChild(tnNode.Parent,joNew.S['caption']);
               tnNew.ImageIndex    := teModuleNameToImageIndex(gjoCopy.S['name']);
               tnNew.SelectedIndex := tnNew.ImageIndex;
               tnNew.Selected      := True;
               //调整位置
               if tnNode.Index <> tnNode.Parent.Count-1 then begin
                    tnNew.MoveTo(tnNode.Parent.Item[tnNode.Index+1],naInsert);
               end;
               //
               teAddChild(TreeView,tnNew,joNew);
               //
               SetUpDownEnable(tnNew);
          end;
          amOptionalSibling : begin
               //
               if tnNode.Index = 0 then begin
                    joParent  := teTreeToJson(tnNode.Parent);
                    joNew     := joParent.A['items'].InsertObject(1);
                    joNew.FromJSON(gjoCopy.ToString);
                    //
                    tnNew     := TreeView.Items.AddChild(tnNode.Parent,joNew.S['caption']);
                    tnNew.ImageIndex    := teModuleNameToImageIndex(gjoCopy.S['name']);
                    tnNew.SelectedIndex := tnNew.ImageIndex;
                    tnNew.Selected      := True;
                    //
                    tnNew.MoveTo(tnNode.Parent.Item[tnNode.Index+1],naInsert);
               end else begin
                    joParent  := teTreeToJson(tnNode.Parent);
                    joNew     := joParent.A['items'].InsertObject(tnNode.Index);
                    joNew.FromJSON(gjoCopy.ToString);
                    //
                    tnNew     := TreeView.Items.AddChild(tnNode.Parent,joNew.S['caption']);
                    tnNew.ImageIndex    := teModuleNameToImageIndex(gjoCopy.S['name']);
                    tnNew.SelectedIndex := tnNew.ImageIndex;
                    tnNew.Selected      := True;
                    //调整位置
                    tnNew.MoveTo(tnNode,naInsert);
               end;
               //
               teAddChild(TreeView,tnNew,joNew);
               //
               SetUpDownEnable(tnNew);
          end;
          amLastChild : begin
               joNew     := joNode.A['items'].AddObject;
               joNew.FromJSON(gjoCopy.ToString);
               //
               tnNew     := TreeView.Items.AddChild(tnNode,joNew.S['caption']);
               tnNew.ImageIndex    := teModuleNameToImageIndex(gjoCopy.S['name']);
               tnNew.SelectedIndex := tnNew.ImageIndex;
               tnNew.Selected      := True;
               //
               teAddChild(TreeView,tnNew,joNew);
               //
               SetUpDownEnable(tnNew);
          end;
          amPrevLastChild : begin
               joNew     := joNode.A['items'].AddObject;
               joNew.FromJSON(gjoCopy.ToString);
               //
               tnNew     := TreeView.Items.AddChild(tnNode,joNew.S['caption']);
               tnNew.ImageIndex    := teModuleNameToImageIndex(gjoCopy.S['name']);
               tnNew.SelectedIndex := tnNew.ImageIndex;
               tnNew.Selected      := True;
               //调整位置
               tnNew.MoveTo(tnNode.Item[tnNode.Count-1],naInsert);
               //
               teAddChild(TreeView,tnNew,joNew);
               //
               SetUpDownEnable(tnNew);
          end;
     end;
     TreeView.Items.EndUpdate;
     bIsCreating    := False;

     //
     SynEdit.Text   := gjoProject.ToJSON(False);

     //设置已修改标识
     gbModified     := True;

end;

procedure TMainForm.MenuItem_ExpandAllClick(Sender: TObject);
begin
     if TreeView.Items.Count>0 then begin
          TreeView.Items.BeginUpdate;
          TreeView.Items[0].Expand(True);
          TreeView.Items.EndUpdate;
     end;
end;

procedure TMainForm.MenuItem_CloseAllClick(Sender: TObject);
begin
     if TreeView.Items.Count>0 then begin
          TreeView.Items.BeginUpdate;
          TreeView.Items[0].Collapse(True);
          TreeView.Items[0].Expand(False);
          TreeView.Items.EndUpdate;
     end;
end;

procedure TMainForm.MenuItem_ExpandSelClick(Sender: TObject);
begin
     if TreeView.Selected<>nil then begin
          TreeView.Items.BeginUpdate;
          TreeView.Selected.Expand(True);
          TreeView.Items.EndUpdate;
     end;
end;

procedure TMainForm.PopupMenu_TreeViewPopup(Sender: TObject);
var
     iModule   : Integer;
     //
     sName     : string;
     sMode     : string;
     sParent   : string;
     //
     tnNode    : TTreeNode;
     //
     joNode    : TJsonObject;
     joParent  : TJsonObject;
     joModule  : TJsonObject;
     joSelMdl  : TJsonObject; //current node -> module
     jaAlwSib  : TJsonArray;  //allow sibling
     jaAlwChd  : TJsonArray;  //allow child
     //
     bTmp      : Boolean;
begin

     //get selected treenode
     if TreeView.Selected = nil then begin
          TreeView.Items[0].Selected    := True;
     end;
     tnNode    := TreeView.Selected ;

     //get current project jsonnode
     joNode    := teTreeToJson(tnNode);
     if joNode = nil then begin
          Exit;
     end;
     sName     := joNode.S['name'];
     joSelMdl  := teFindModule(sName);
     jaAlwSib  := joSelMdl.A['allowsibling'];
     jaAlwChd  := joSelMdl.A['allowchild'];

     //Dynamic hide/view the module menuitem 动态菜单处理
     for iModule := 0 to gjoModules.A['items'].Count-1 do begin
          joModule  := gjoModules.A['items'][iModule];
          PopupMenu_TreeView.Items[iModule].Visible    :=
               (teInModules(joModule.S['name'],jaAlwSib)) or (teInModules(joModule.S['name'],jaAlwChd));
     end;

end;


procedure TMainForm.TreeViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
     tnNode    : TTreeNode;
begin
     //右键直接选择节点
     tnNode     := TreeView.GetNodeAt(X, Y);
     if tnNode<>nil then begin
          tnNode.Selected := True;
     end;
end;

procedure TMainForm.MenuItem_ExitClick(Sender: TObject);
begin
     Close;
end;
procedure TMainForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
     if bIsCreating then begin
          Exit;
     end;
     //
     SetUpDownEnable(Node);
     //显示详细信息
     ShowNodeProperty(teTreeToJson(Node));

end;

procedure TMainForm.TreeViewClick(Sender: TObject);
var
     tnNode    : TTreeNode;
     xnNode    : TJsonObject;
begin

Exit;
     try
          tnNode    := TreeView.Selected;
          if tnNode= nil then Exit;

          //得到XML节点
          //xnNode   := GetXMLNodeFromTreeNode(gxdXML,tnNode);

          //检测
          if xnNode=nil then begin
               ShowMessage('Error because GetXMLNodeFromTreeNode return nil when TreeViewChange');
               Exit;
          end;



          //
          //ShowNodeProperty(xnNode);


          //
          SynEdit.Text    := gjoProject.ToString;

     except
     end;
end;

procedure TMainForm.ToolButton_ExpandClick(Sender: TObject);
begin
     if TreeView.Selected<>nil then begin
          TreeView.Items.BeginUpdate;
          TreeView.Selected.Expand(True);
          TreeView.Selected.MakeVisible;
          TreeView.Items.EndUpdate;
     end;
end;

procedure TMainForm.ToolButton_CollapseClick(Sender: TObject);
begin
     if TreeView.Selected<>nil then begin
          TreeView.Selected.Collapse(True);
     end;

end;

procedure TMainForm.ToolButton_UpClick(Sender: TObject);
var
     tnNode    : TTreeNode;
     iIndex    : Integer;
     xnNew     : TJsonObject;
     xnNode    : TJsonObject;
begin
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          Exit;
     end;
     xnNode    := teTreeToJson(TreeView.Selected);
     //
     if xnNode=nil then begin
          Exit;
     end;

     //
     if xnNode=gjoProject then begin
          Exit;
     end;
     //if xnNode=xnNode.ParentNode.ChildNodes.First then begin
     //     Exit;
     //end;

     //XML节点上移
{
     iIndex    := GetXMLNodeIndex(xnNode);
     xnNew     := xnNode.ParentNode.AddChild(xnNode.NodeName,iIndex-1);
     CopyXMLNode(xnNode,xnNew);
     xnNode.ParentNode.ChildNodes.Delete(iIndex+1);
     xnNode   := xnNew;
     //xnNode.ParentNode.ChildNodes.ReplaceNode(xnNode.PreviousSibling,xnNode);
     //xnNode.ParentNode.ChildNodes.Insert(iIndex-1,xnNode);

     //树节点上移
     TreeView.OnCustomDrawItem     := nil;
     tnNode.MoveTo(tnNode.getPrevSibling,naInsert);
     TreeView.OnCustomDrawItem     := TreeViewCustomDrawItem;
}
     //
     SetUpDownEnable(tnNode);
end;

procedure TMainForm.ToolButton_DownClick(Sender: TObject);
var
     tnNode    : TTreeNode;
     xnNew     : TJsonObject;
     iIndex    : Integer;
     xnNode    : TJsonObject;
begin
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          Exit;
     end;
     xnNode    := teTreeToJson(TreeView.Selected);
{
     //
     if xnNode=gxdXML.DocumentElement then begin
          Exit;
     end;
     if xnNode=xnNode.ParentNode.ChildNodes.Last then begin
          Exit;
     end;
     //XML节点下移
     iIndex    := GetXMLNodeIndex(xnNode);
     xnNew     := xnNode.ParentNode.AddChild(xnNode.NodeName,iIndex+2);  //在新位置生成新节点
     CopyXMLNode(xnNode,xnNew);   //复制源节点的属性和子节点
     xnNode.ParentNode.ChildNodes.Delete(iIndex);     //删除源节点
     xnNode   := xnNew; //设置新节点为当前节点

     //
     if tnNode.getNextSibling.getNextSibling<>nil then begin
          tnNode.MoveTo(tnNode.getNextSibling.getNextSibling,naInsert);
     end else begin
          tnNode.MoveTo(tnNode.getNextSibling,naAdd);
     end;
     //
     xnNode   := teTreeToJson(gxdXML,tnNode);
}
     //
     SetUpDownEnable(tnNode);

end;



procedure TMainForm.ToolButton_SaveClick(Sender: TObject);
begin
     SaveNodeProperty;

     //
     if gsFileName = '' then begin
          if SaveDialog.Execute then begin
               gsFileName     := SaveDialog.FileName;
               gjoProject.SaveToFile(SaveDialog.FileName,False);
               gsFileName     := SaveDialog.FileName;
               //设置为未修改状态
               gbModified     := False;
          end ;
     end else begin
          gjoProject.SaveToFile(gsFileName,False);
          //设置为未修改状态
          gbModified     := False;
     end;

end;

procedure TMainForm.ToolButton_OpenClick(Sender: TObject);
var
     iRes      : Integer;
     I         : Integer;
     xnNode    : TJsonObject;
begin
     //退出时如果当前文档已修改，则提示是否保存/取消退出
     if gbModified then begin
          iRes := MessageDlg('The file has been modified, do you save it ?',mtConfirmation,[mbYes,mbNO,mbCancel],0);
          Case iRes of
               mrYes : begin
                    ToolButton_Save.OnClick(Self);
               end;
               mrCancel : begin
                    Exit;
               end;
          end;
     end;

     if OpenDialog.Execute then begin
          gjoProject     := TJsonObject.Create;
          gjoProject.LoadFromFile(OpenDialog.FileName);
          //
          gsFileName     := OpenDialog.FileName;

          //根据XML创建树
          bIsCreating    := True;
          teJsonToTree(TreeView);
          bIsCreating    := False;
          //
          TreeView.Items[0].Expand(False);
          TreeView.Items[0].Selected    := True;
          iMoveX    := -9999;
          iMoveY    := 0;

          //一些必要的工作
          gjoCopySource  := nil;   //清空

          //
          SynEdit.Text   := gjoProject.ToJSON(False);

          //设置为未修改状态
          gbModified     := False;
     end;
end;

procedure TMainForm.SaveNodeProperty;
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
     oSpinEdit : TSpinEdit;
     oSynEdit  : TSynEdit;
     oCheckBox : TCheckBox;
     oComboBox : TComboBox;
begin
     //get current selected treenode
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          Exit;
     end;

     //get current project json node
     joNode    := teTreeToJson(tnNode);

     //
     joModule  := teFindModule(joNode.S['name']);

     //
     for iProp := 0 to Panel_LeftBottom.ControlCount-1 do begin
          joProp    := joModule.A['property'][iProp];
          //
          oPanel    := TPanel(Panel_LeftBottom.Controls[iProp]);
          if joProp.S['type'] = 'string' then begin
               oEdit     := TEdit(oPanel.Controls[1]);
               joNode.S[joProp.S['name']]    := oEdit.Text;
          end else if joProp.S['type'] = 'source' then begin
               oSynEdit  := TSynEdit(oPanel.Controls[1]);
               joNode.S[joProp.S['name']]    := oSynEdit.Text;
          end else if joProp.S['type'] = 'integer' then begin
               oSpinEdit     := TSpinEdit(oPanel.Controls[1]);
               joNode.I[joProp.S['name']]    := oSpinEdit.Value;
          end else if joProp.S['type'] = 'boolean' then begin
               oCheckBox     := TCheckBox(oPanel.Controls[1]);
               joNode.B[joProp.S['name']]    := oCheckBox.Checked;
          end else if joProp.S['type'] = 'list' then begin
               oComboBox := TComboBox(oPanel.Controls[1]);
               joNode.S[joProp.S['name']]    := oComboBox.Text;
          end;

          //更新树节点显示
          if joProp.S['name'] = 'caption' then begin
               TreeView.Selected.Text   := joNode.S['caption'];
          end;
     end;

     //
     SynEdit.Text   := gjoProject.ToJSON(False);
end;

procedure TMainForm.SetUpDownEnable(ANode:TTreeNode);
var
     sName     : string;
     sNameNext : string;
     sNamePrev : string;
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
               ToolButton_Down.Enabled  := False;
               ToolButton_Up.Enabled    := False;
          end else begin
               ToolButton_Down.Enabled  := False;
               //
               joPrev    := teTreeToJson(tnPrev);
               joMdlPrev := teFindModule(joPrev.S['name']);
               //
               sModePrev := joMdlPrev.S['mode'];
               ToolButton_Up.Enabled    := _GetB(sModePrev);
          end;
     end else begin
          if (tnPrev = nil) then begin
               ToolButton_Up.Enabled    := False;
               //
               joNext    := teTreeToJson(tnNext);
               joMdlNext := teFindModule(joNext.S['name']);
               //
               sModeNext := joMdlNext.S['mode'];
               ToolButton_Down.Enabled  := _GetB(sModeNext);
          end else begin
               //
               joNext    := teTreeToJson(tnNext);
               joMdlNext := teFindModule(joNext.S['name']);
               //
               sModeNext := joMdlNext.S['mode'];
               ToolButton_Down.Enabled  := _GetB(sModeNext);
               //
               joPrev    := teTreeToJson(tnPrev);
               joMdlPrev := teFindModule(joPrev.S['name']);
               //
               sModePrev := joMdlPrev.S['mode'];
               ToolButton_Up.Enabled    := _GetB(sModePrev);
          end;
     end;


{
     //
     case _M(AXNode) of
          rtIF_Yes,rtIF_Else,rtCase_Default,rtTry_Except,rtTry_Else : begin
               ToolButton_Up.Enabled    := False;
               ToolButton_Down.Enabled  := False;
          end;
          rtIF_ElseIf : begin
               ToolButton_Up.Enabled    := _M(AXNode.PreviousSibling) = rtIF_ElseIF;
               ToolButton_Down.Enabled  := _M(AXNode.NextSibling) = rtIF_ElseIF;
          end;
     else
          ToolButton_Up.Enabled    := AXNode.PreviousSibling <> nil;
          ToolButton_Down.Enabled  := AXNode.NextSibling <> Nil;
     end;
}
end;

procedure TMainForm.PopMenu_CutClick(Sender: TObject);
var
     tnNode    : TTreeNode;
     xnNode    : TJsonObject;
begin
     gbModified     := True;
{
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          Exit;
     end;
     xnNode    := teTreeToJson(gxdXML,TreeView.Selected);

     //
     if xnNode=nil then begin
          ShowMessage('Please selected a node at first!');
          Exit;
     end;

     giSourceMode        := xnNode.Attributes['Mode'];
     gxnCopySource       := xnNode;

     //
     if xnNode=gxdXML.DocumentElement then begin
          ShowMessage('Connot cut the root node!');
          Exit;
     end else begin
          //将源节点保存到XML中
          gxdCopy.ChildNodes.Clear;
          gxdCopy.AddChild('Cut');
          CopyXMLNode(xnNode,gxdCopy.DocumentElement);
     end;

}
end;



procedure TMainForm.ToolButton_NewProjectClick(Sender: TObject);
var
     xnNew     : TJsonObject;
     iRes      : Integer;
begin
     if gbModified then begin
          iRes := MessageDlg('The file has been modified, do you save it ?',mtConfirmation,[mbYes,mbNO,mbCancel],0);
          case iRes of
               mrYes : begin
                    ToolButton_Save.OnClick(Self);
               end;
               mrCancel : begin
                    Exit;
               end;
          end;
     end;

     //
     //
     gjoProject     := TJsonObject.Create;
     gjoProject.S['name']     := 'root';
     gjoProject.A['items']    := TJsonArray.Create;

     //
     TreeView.Items[0].DeleteChildren;
     TreeView.Items[0].Text   := '';

     //
     SynEdit.Text   := '';

     //
     gsFileName     := '';
     gbModified     := False;

end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
     iRes : Integer;
begin
     //退出时如果当前文档已修改，则提示是否保存/取消退出
     if gbModified then begin
          iRes := MessageDlg('The file has been modified, do you save it ?',mtConfirmation,[mbYes,mbNO,mbCancel],0);
          Case iRes of
               mrYes : begin
                    ToolButton_Save.OnClick(Self);
               end;
               mrCancel : begin
                    CanClose  := False;
               end;
          end;
     end;

end;

procedure TMainForm.PropertyChange(Sender: TObject);
begin
     SaveNodeProperty;
     gbModified     := True;
end;

end.

