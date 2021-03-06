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
     Graphics,
     Vcl.ExtCtrls, System.Classes, Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Buttons, FloatSpinEdit;

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
    Cut1: TMenuItem;
    mxClickSplitter1: TmxClickSplitter;
    mxClickSplitter_Left: TmxClickSplitter;
    Panel_LeftBottom: TPanel;
    Panel_Client: TPanel;
    SynJSONSyn: TSynJSONSyn;
    FontDialog: TFontDialog;
    Memo_Code: TMemo;
    ImageList_TextModes: TImageList;
    procedure PopMenu_DeleteClick(Sender: TObject);
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
    procedure ToolButton_NewProjectClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure TreeViewStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
     private
          bIsCreating    : Boolean;          //标志是否正在生成树的,用于控制节点转换时是否绘制流程图
          //
          gjoCopy        : TJsonObject;      //待复制/剪切节点构成的XML
          gjoCopySource  : TJsonObject;      //复制为nil，剪切时为源节点
          gtnDragSource  : TTreeNode;
          //
          procedure AddModule(Sender: TObject);
     public

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
     Memo_Code.Lines.Text   := gjoProject.ToUtf8JSON(False);

     //设置已修改标识
     gbModified     := True;
end;

//------------------------------显示节点的属性----------------------------------------------------//


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
               oPopItem.OnClick         := AddModule;
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
     //
     tnNode    : TTreeNode;
     tnNew     : TTreeNode;
     //
     iIndex    : Integer;
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
               teSetUpDownEnable(tnNew,ToolButton_Down,ToolButton_Up);
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
               teSetUpDownEnable(tnNew,ToolButton_Down,ToolButton_Up);
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
               teSetUpDownEnable(tnNew,ToolButton_Down,ToolButton_Up);
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
               teSetUpDownEnable(tnNew,ToolButton_Down,ToolButton_Up);
          end;
     end;
     TreeView.Items.EndUpdate;
     bIsCreating    := False;

     //
     Memo_Code.Lines.Text   := gjoProject.ToUtf8JSON(False);

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
     //
     tnNode    : TTreeNode;
     //
     joNode    : TJsonObject;
     joModule  : TJsonObject;
     joSelMdl  : TJsonObject; //current node -> module
     jaAlwSib  : TJsonArray;  //allow sibling
     jaAlwChd  : TJsonArray;  //allow child
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

procedure TMainForm.TreeViewStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
     gtnDragSource  := TreeView.Selected;
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
     teSetUpDownEnable(Node,ToolButton_Down,ToolButton_Up);
     //显示详细信息
     teShowNodeProperty(teTreeToJson(Node),TreeView,Panel_LeftBottom);

end;

procedure TMainForm.TreeViewClick(Sender: TObject);
var
     tnNode    : TTreeNode;
begin

Exit;
     try
          tnNode    := TreeView.Selected;
          if tnNode= nil then Exit;

          //
          teShowNodeProperty(teTreeToJson(tnNode),TreeView,Panel_LeftBottom);


          //
          Memo_Code.Lines.Text    := gjoProject.ToString;

     except
     end;
end;

procedure TMainForm.TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
     joSource  : TJsonObject;
     joDest    : TJsonObject;
     joParSrc  : TJsonObject;
     joParDest : TJsonObject;

     //
     sNameSrc  : string;
     sNameDest : string;
     //
     tnDest    : TTreeNode;
     tnTemp    : TTreeNode;

     //
     iIdSrc    : Integer;
     iIdDest   : Integer;

     //
     oAddMode  : TTEAddMode;
begin
     //
     tnDest    := Treeview.GetNodeAt( X, Y );
     if tnDest = nil then begin
          Exit;
     end;

     if joSource = gjoProject then begin
          Exit;
     end;


     //
     joSource  := teTreeToJson(gtnDragSource);
     joDest    := teTreeToJson(tnDest);
     iIdSrc    := gtnDragSource.Index;
     iIdDest   := tnDest.Index;
     joParSrc  := teTreeToJson(gtnDragSource.Parent);  //得到父节点备用
     if tnDest.Level > 0 then begin
          joParDest := teTreeToJson(tnDest.Parent);
     end else begin
          joParDest := nil
     end;

     if joDest = nil then begin
          Exit;
     end;

     //
     sNameSrc  := joSource.S['name'];
     sNameDest := joDest.S['name'];

     //检查父子关系（父节点不能拖动到子节点,也就是不能：gtnDragSource是tnDest的祖先）
     if tnDest.Level>gtnDragSource.Level then begin
          tnTemp    := tnDest;
          while tnTemp.Level >= gtnDragSource.Level do begin
               if tnTemp = gtnDragSource then begin
                    Exit;
               end else begin
                    tnTemp    := tnTemp.Parent;
               end;
          end;
     end;

     //
     oAddMode  := teGetAddMode(sNameSrc,sNameDest);
     //
     bIsCreating    := True;
     case oAddMode of
          amNone : begin

          end;
          amNextSibling : begin    //拖动到当前节点的后面
               if tnDest.getNextSibling<>nil then begin
                    //移动树节点
                    gtnDragSource.MoveTo(tnDest.getNextSibling,naInsert);

                    //创建新JSON节点
                    joParDest.A['items'].InsertObject(iIdDest+1).FromUtf8JSON(joSource.ToUtf8JSON);

                    //删除旧JSON节点
                    joParSrc.A['items'].Delete(iIdSrc);
               end else begin
                    //移动树节点
                    gtnDragSource.MoveTo(tnDest,naAdd);

                    //创建新JSON节点
                    joParDest.A['items'].AddObject.FromUtf8JSON(joSource.ToUtf8JSON);

                    //删除旧JSON节点
                    joParSrc.A['items'].Delete(iIdSrc);
               end;
          end;

          amOptionalSibling : begin     //作为当前的sibling, 如果当前节点为第一子固定节点, 则位置为下一个;如果当前为最后固定节点,则为倒数第二个
               if tnDest.Index = 0 then begin     //当前节点为第一子固定节点
                    //移动树节点
                    if tnDest.getNextSibling<>nil then begin
                         gtnDragSource.MoveTo(tnDest.getNextSibling,naInsert);
                    end else begin
                         gtnDragSource.MoveTo(tnDest,naAdd);
                    end;

                    //创建新JSON节点
                    joParDest.A['items'].InsertObject(1).FromUtf8JSON(joSource.ToUtf8JSON);

                    //删除旧JSON节点
                    joParSrc.A['items'].Delete(iIdSrc);
               end else begin      //当前为最后固定节点
                    //移动树节点
                    gtnDragSource.MoveTo(tnDest,naInsert);

                    //创建新JSON节点
                    joParDest.A['items'].InsertObject(iIdDest).FromUtf8JSON(joSource.ToUtf8JSON);

                    //删除旧JSON节点
                    joParSrc.A['items'].Delete(iIdSrc);
               end;
          end;
          amLastChild : begin
               //移动树节点
               gtnDragSource.MoveTo(tnDest,naAddChild);

               //创建新JSON节点
               joDest.A['items'].AddObject.FromUtf8JSON(joSource.ToUtf8JSON);

               //删除旧JSON节点
               joParSrc.A['items'].Delete(iIdSrc);
          end;
          amPrevLastChild : begin
               //移动树节点
               gtnDragSource.MoveTo(tnDest.GetLastChild,naInsert);

               //创建新JSON节点
               joDest.A['items'].InsertObject(tnDest.Count-2).FromUtf8JSON(joSource.ToUtf8JSON);

               //删除旧JSON节点
               joParSrc.A['items'].Delete(iIdSrc);
          end;
     end;
     //
     bIsCreating    := False;
     //
     gtnDragSource.Selected   := True;
     Memo_Code.Lines.Text := gjoProject.ToJSON(False);
end;

procedure TMainForm.TreeViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
     joSource  : TJsonObject;
     joDest    : TJsonObject;
     //
     sNameSrc  : string;
     sNameDest : string;
     //
     tnDest    : TTreeNode;
     tnTemp    : TTreeNode;
begin
     //
     tnDest    := Treeview.GetNodeAt( X, Y );
     if tnDest = nil then begin
          Accept    := False;
          Exit;
     end;
     if joSource = gjoProject then begin
          Accept    := False;
          Exit;
     end;

     //
     joSource  := teTreeToJson(gtnDragSource);
     joDest    := teTreeToJson(tnDest);

     if joDest = nil then begin
          Accept    := False;
          Exit;
     end;

     //
     sNameSrc  := joSource.S['name'];
     sNameDest := joDest.S['name'];

     //检查父子关系（父节点不能拖动到子节点,也就是不能：gtnDragSource是tnDest的祖先）
     if tnDest.Level>gtnDragSource.Level then begin
          tnTemp    := tnDest;
          while tnTemp.Level >= gtnDragSource.Level do begin
               if tnTemp = gtnDragSource then begin
                    Accept    := False;
                    Exit;
               end else begin
                    tnTemp    := tnTemp.Parent;
               end;
          end;
     end;

     //
     Accept    := teGetAddMode(sNameSrc,sNameDest) <> amNone;
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
begin
     teMoveTreeNodeUp(TreeView.Selected);
     //
     teSetUpDownEnable(TreeView.Selected,ToolButton_Down,ToolButton_Up);
     //
     Memo_Code.Lines.Text   := gjoProject.ToUtf8JSON(False);
end;

procedure TMainForm.ToolButton_DownClick(Sender: TObject);
begin
     //
     teMoveTreeNodeDown(TreeView.Selected);
     //
     teSetUpDownEnable(TreeView.Selected,ToolButton_Down,ToolButton_Up);
     //
     Memo_Code.Lines.Text   := gjoProject.ToUtf8JSON(False);
end;


procedure TMainForm.ToolButton_SaveClick(Sender: TObject);
begin
     teSaveNodeProperty(TreeView,Panel_LeftBottom);

     //
     if gsProjectName = '' then begin
          if SaveDialog.Execute then begin
               gsProjectName  := SaveDialog.FileName;
               gjoProject.SaveToFile(SaveDialog.FileName,False);
               gsProjectName  := SaveDialog.FileName;
               //设置为未修改状态
               gbModified     := False;
          end ;
     end else begin
          gjoProject.SaveToFile(gsProjectName,False);
          //设置为未修改状态
          gbModified     := False;
     end;

end;

procedure TMainForm.ToolButton_OpenClick(Sender: TObject);
var
     iRes      : Integer;
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
          gsProjectName  := OpenDialog.FileName;

          //根据XML创建树
          bIsCreating    := True;
          teJsonToTree(TreeView);
          bIsCreating    := False;
          //
          TreeView.Items[0].Expand(False);
          TreeView.Items[0].Selected    := True;

          //一些必要的工作
          gjoCopySource  := nil;   //清空

          //
          Memo_Code.Lines.Text   := gjoProject.ToUtf8JSON(False);

          //设置为未修改状态
          gbModified     := False;
     end;
end;



procedure TMainForm.ToolButton_NewProjectClick(Sender: TObject);
var
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
     Memo_Code.Lines.Text   := '';

     //
     gsProjectName  := '';
     gbModified     := False;

end;

procedure TMainForm.AddModule(Sender: TObject);
begin
     teAddModule(TreeView.Selected,TMenuItem(Sender).MenuIndex);
     //
     Memo_Code.Lines.Text   := gjoProject.ToJSON(False);
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


end.

