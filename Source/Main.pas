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


     //-------------------------------------系统自带------------------------------------------------
     Forms,SysUtils, System.ImageList, Vcl.Dialogs, Vcl.Menus, Vcl.ImgList, Vcl.Controls, Vcl.ComCtrls, Vcl.ToolWin,
     Graphics, Windows,
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
    N20: TMenuItem;
    Delete1: TMenuItem;
    TreeView: TTreeView;
    SaveDialog: TSaveDialog;
    PopMenu_Cut: TMenuItem;
    Cut1: TMenuItem;
    SynJSONSyn: TSynJSONSyn;
    FontDialog: TFontDialog;
    ImageList_TreeView: TImageList;
    Splitter1: TSplitter;
    PageControl1: TPageControl;
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
    procedure MenuItem_SaveClick(Sender: TObject);
     private
          bIsCreating    : Boolean;          //标志是否正在生成树的,用于控制节点转换时是否绘制流程图
          //
          gjoCopy        : TJsonObject;      //待复制/剪切节点构成的XML
          gjoCopySource  : TJsonObject;      //复制为nil，剪切时为源节点
          gtnDragSource  : TTreeNode;
          //
          procedure AddModule(Sender: TObject);
          procedure OnPropertyChange(Sender: TObject);
     public

     end;

var
     MainForm       : TMainForm;




implementation





{$R *.dfm}
procedure TMainForm.OnPropertyChange(Sender: TObject);
var
     tnNode    : TTreeNode;
     joNode    : TJsonObject;
begin
     try
          //
          tnNode    := TreeView.Selected;
          if tnNode = nil then begin
               Exit;
          end;
          //
          joNode    := teTreeToJson(tnNode);

          //
          if Sender.ClassType = TSpeedButton then begin
               if FontDialog.Execute then begin
                    TSpeedButton(Sender).Font     := FontDialog.Font;
               end;
          end;

          //
          //teSaveNodeProperty(joNode,ScrollBox_Property);

          //
          tnNode.Text    := '[' + joNode.s['type'] + '] '+joNode.S[_Caption];

          //
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);
     except
          teShowMsg('Error when OnPropertyChange!');

     end;
end;


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
     try
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
          joModule  := teFindModule(joNode.S['_m_']);

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
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);

          //设置已修改标识
          gbModified     := True;
     except
          teShowMsg('Error when PopMenu_DeleteClick!');

     end;
end;

//------------------------------显示节点的属性----------------------------------------------------//


procedure TMainForm.FormCreate(Sender: TObject);
var
    iPage       : Integer;
    iItem       : Integer;
    iProp       : Integer;
    iCtrl       : Integer;
    iList       : Integer;
    //
    sType       : String;
    //
    joModule    : TJsonObject;
    joProp      : TJsonObject;
    //
    oPopItem    : TMenuItem;
    oTab        : TTabSheet;
    oFlowPanel  : TFlowPanel;
    oPanel      : TPanel;
    oLabel      : TLabel;
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
        LockWindowUpdate(Handle);
        //
        gsMainDir := ExtractFilePath(Application.ExeName);

        //=================================start json =================================================

        //载入模块JSON,并生成菜单 Load modules json for popmenu of treeview
        gjoModules     := TJsonObject.Create;
        gjoModules.LoadFromFile(gsMainDir+'modules.json');
        for iItem := 0 to gjoModules.A['items'].Count-1 do begin
            //得到模块JSON节点
            joModule  := gjoModules.A['items'][iItem];

            //生成右键菜单
            oPopItem  := TMenuItem.Create(PopupMenu_TreeView);
            PopupMenu_TreeView.Items.Add(oPopItem);
            oPopItem.MenuIndex       := iItem;
            oPopItem.AutoHotkeys     := maManual;
            oPopItem.Caption         := joModule.S['_m_'];
            if  joModule.S['_m_']<>'-' then begin
                oPopItem.OnClick         := AddModule;
            end;

            //
            oTab := TTabSheet.Create(self);
            with oTab do begin

                TabVisible  := False;
                PageControl := PageControl1;
                Caption     := joModule.S['_m_'];
                //
                oFlowPanel  := TFlowPanel.Create(self);
                oFlowPanel.Parent   := oTab;
                oFlowPanel.Align    := alClient;
                oFlowpanel.Color    := clWhite;
                oFlowPanel.BevelOuter   := bvNone;

                //
                //add width, source

                for iProp := 0 to joModule.A['property'].Count-1 do begin
                    joProp  := joModule.A['property'][iProp];
                    //
                    sType   := joProp.S['type'];

                    //属性的外框
                    oPanel              := TPanel.Create(nil);
                    oPanel.Parent       := oFlowPanel;
                    if joProp.Contains('width') then begin
                        oPanel.Width    := joProp.I['width'];
                    end else begin
                        oPanel.Width    := 400;
                        if sType = 'string' then begin
                            oPanel.Width    := 400;
                        end else if sType = 'memo' then begin
                            oPanel.Width    := 400;
                        end else if sType = 'integer' then begin
                            oPanel.Width    := 200;
                        end else if sType = 'source' then begin
                        end else if sType = 'boolean' then begin
                            oPanel.Width    := 200;
                        end else if sType = 'list' then begin
                        end else if sType = 'color' then begin
                            oPanel.Width    := 200;
                        end else if sType = 'font' then begin
                            oPanel.Width    := 200;
                        end else if sType = 'float' then begin
                            oPanel.Width    := 200;
                        end;
                    end;
                    oPanel.AlignWithMargins := True;
                    oPanel.Margins.SetBounds(0,3,0,3);
                    if bFoundSrc then begin
                        //oPanel.Align   := alBottom;
                        //oPanel.Top     := 9999;
                    end;
                    oPanel.Height       := 30;
                    oPanel.BorderWidth  := 0;
                    oPanel.BevelOuter   := bvNone;
                    if joProp.Contains('height') then begin
                        oPanel.Height       := joProp.I['height'];
                    end;

                    //属性名称
                    oLabel    := TLabel.Create(oPanel);
                    oLabel.Parent       := oPanel;
                    oLabel.Align        := alLeft;
                    oLabel.Layout       := tlCenter;
                    oLabel.AutoSize     := False;
                    oLabel.Width        := 120;
                    oLabel.Alignment    := taRightJustify;
                    oLabel.AlignWithMargins := True;
                    oLabel.Margins.Right    := 8;

                    if joProp.Contains('caption') then begin
                        oLabel.Caption      := joProp.S['caption'];
                    end else begin
                        oLabel.Caption      := joProp.S['_m_'];
                    end;

                    //属性值
                    if joProp.S['type'] = 'boolean' then begin
                        oCheckBox           := TCheckBox.Create(oPanel);
                        oCheckBox.Parent    := oPanel;
                        oCheckBox.Align     := alClient;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oCheckBox.ShowHint  := True;
                            oCheckBox.Hint      := joProp.S['hint'];
                        end;
                    end else if joProp.S['type'] = 'color' then begin
                        oLabelProp          := TLabel.Create(oPanel);
                        oLabelProp.Parent       := oPanel;
                        oLabelProp.Align        := alClient;
                        oLabelprop.Caption      := '';
                        oLabelProp.Layout       := tlcenter;
                        oLabelprop.Alignment    := taCenter;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oLabelProp.ShowHint  := True;
                            oLabelProp.Hint      := joProp.S['hint'];
                        end;
                        //赋默认值
                        if joProp.Contains('default') then begin
                            oLabelprop.Color    := teArrayToColor(joProp.A['default']);
                        end;
                    end else if joProp.S['type'] = 'float' then begin
                        oEdit          := TEdit.Create(oPanel);
                        oEdit.Parent   := oPanel;
                        oEdit.Align    := alClient;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oEdit.ShowHint  := True;
                            oEdit.Hint      := joProp.S['hint'];
                        end;
                    end else if joProp.S['type'] = 'integer' then begin
                        oEdit          := TEdit.Create(oPanel);
                        oEdit.Parent   := oPanel;
                        oEdit.Align    := alClient;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oEdit.ShowHint  := True;
                            oEdit.Hint      := joProp.S['hint'];
                        end;
                    end else if joProp.S['type'] = 'font' then begin
                        oLabelProp              := TLabel.Create(oPanel);
                        oLabelProp.Parent       := oPanel;
                        oLabelProp.Align        := alClient;
                        oLabelprop.Caption      := '中';
                        oLabelProp.Layout       := tlcenter;
                        oLabelprop.Alignment    := taCenter;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oLabelProp.ShowHint  := True;
                            oLabelProp.Hint      := joProp.S['hint'];
                        end;
                    end else if joProp.S['type'] = 'list' then begin
                        oComboBox           := TComboBox.Create(oPanel);
                        oComboBox.Parent    := oPanel;
                        oComboBox.Align     := alClient;
                        for iList := 0 to joProp.A['lists'].Count-1 do begin
                             oComboBox.Items.Add(joProp.A['lists'].S[iList]);
                        end;
                        if joProp.B['fixed'] then begin
                             oComboBox.Style     := csDropDownList;
                        end;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oComboBox.ShowHint  := True;
                            oComboBox.Hint      := joProp.S['hint'];
                        end;
                    end else if joProp.S['type'] = 'memo' then begin
                        oMemo               := TMemo.Create(oPanel);
                        oMemo.Parent        := oPanel;
                        oMemo.Align         := alClient;
                        oMemo.ScrollBars    := ssBoth;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oMemo.ShowHint  := True;
                            oMemo.Hint      := joProp.S['hint'];
                        end;
                    end else if joProp.S['type'] = 'source' then begin
                        oMemo               := TMemo.Create(oPanel);
                        oMemo.Parent        := oPanel;
                        oMemo.Align         := alClient;
                        oMemo.ScrollBars    := ssBoth;
                        //
                        bFoundSrc := True;
                        oPanel.Align   := alClient;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oMemo.ShowHint  := True;
                            oMemo.Hint      := joProp.S['hint'];
                        end;
                    end else if joProp.S['type'] = 'string' then begin
                        oEdit          := TEdit.Create(oPanel);
                        oEdit.Parent   := oPanel;
                        oEdit.Align    := alClient;
                        if joProp.Contains('readonly') then begin
                            oEdit.ReadOnly  := joProp.B['readonly'];
                        end;
                        //显示提示
                        if joProp.Contains('hint') then begin
                            oEdit.ShowHint  := True;
                            oEdit.Hint      := joProp.S['hint'];
                        end;
                    end;

                    //
                    if joProp.Contains('readonly') then begin
                        TEdit(oPanel.Controls[1]).ReadOnly  := joProp.b['readonly'];
                    end;
                end;
            end;
        end;
        //
        Caption   := gjoModules.S['caption'];

        //
        teInitProject;

        //
        teJsonToTree(TreeView);

        //
        TreeView.Items[0].Expand(False);
        //
        LockWindowUpdate(0);
    except
        teShowMsg('Error when FormCreate!');

    end;
end;



procedure TMainForm.PopMenu_CopyClick(Sender: TObject);
var
     joNode    : TJsonObject;
begin
     try
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

     except
          teShowMsg('Error when PopMenu_CopyClick!');

     end;
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
     try
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
          oAddMode  := teGetAddMode(gjoCopy.S['_m_'],joNode.S['_m_']);
          case oAddMode of
               amNone : begin
                    ShowMessage('Cannot paste node here!');
               end;
               amNextSibling : begin    //追加模式
                    joParent  := teTreeToJson(tnNode.Parent);
                    joNew     := joParent.A['items'].InsertObject(tnNode.Index+1);
                    joNew.FromJSON(gjoCopy.ToString);
                    //
                    tnNew     := TreeView.Items.AddChild(tnNode.Parent,joNew.S[_Caption]);
                    tnNew.Selected      := True;
                    //调整位置
                    if tnNode.Index <> tnNode.Parent.Count-1 then begin
                         if tnNew <> tnNode.Parent.Item[tnNode.Index+1] then begin
                              tnNew.MoveTo(tnNode.Parent.Item[tnNode.Index+1],naInsert);
                         end;
                    end;
                    //
                    teAddChild(tnNew,joNew);
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
                         tnNew     := TreeView.Items.AddChild(tnNode.Parent,joNew.S[_Caption]);
                         tnNew.Selected      := True;
                         //
                         if tnNew <> tnNode.Parent.Item[tnNode.Index+1] then begin
                              tnNew.MoveTo(tnNode.Parent.Item[tnNode.Index+1],naInsert);
                         end;
                    end else begin
                         joParent  := teTreeToJson(tnNode.Parent);
                         joNew     := joParent.A['items'].InsertObject(tnNode.Index);
                         joNew.FromJSON(gjoCopy.ToString);
                         //
                         tnNew     := TreeView.Items.AddChild(tnNode.Parent,joNew.S[_Caption]);
                         tnNew.Selected      := True;
                         //调整位置
                         if tnNew <> tnNode then begin
                              tnNew.MoveTo(tnNode,naInsert);
                         end;
                    end;
                    //
                    teAddChild(tnNew,joNew);
                    //
                    teSetUpDownEnable(tnNew,ToolButton_Down,ToolButton_Up);
               end;
               amLastChild : begin
                    joNew     := joNode.A['items'].AddObject;
                    joNew.FromJSON(gjoCopy.ToString);
                    //
                    tnNew     := TreeView.Items.AddChild(tnNode,joNew.S[_Caption]);
                    tnNew.Selected      := True;
                    //
                    teAddChild(tnNew,joNew);
                    //
                    teSetUpDownEnable(tnNew,ToolButton_Down,ToolButton_Up);
               end;
               amPrevLastChild : begin
                    joNew     := joNode.A['items'].AddObject;
                    joNew.FromJSON(gjoCopy.ToString);
                    //
                    tnNew     := TreeView.Items.AddChild(tnNode,joNew.S[_Caption]);
                    tnNew.Selected      := True;
                    //调整位置
                    if tnNew <> tnNode.Item[tnNode.Count-1] then begin
                         tnNew.MoveTo(tnNode.Item[tnNode.Count-1],naInsert);
                    end;
                    //
                    teAddChild(tnNew,joNew);
                    //
                    teSetUpDownEnable(tnNew,ToolButton_Down,ToolButton_Up);
               end;
          end;
          TreeView.Items.EndUpdate;
          bIsCreating    := False;

          //
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);

          //设置已修改标识
          gbModified     := True;

     except
          teShowMsg('Error when PopMenu_PasteClick!');

     end;
end;

procedure TMainForm.MenuItem_ExpandAllClick(Sender: TObject);
begin
     try
          if TreeView.Items.Count>0 then begin
               TreeView.Items.BeginUpdate;
               TreeView.Items[0].Expand(True);
               TreeView.Items.EndUpdate;
          end;
     except
          teShowMsg('Error when MenuItem_ExpandAllClick!');

     end;
end;

procedure TMainForm.MenuItem_CloseAllClick(Sender: TObject);
begin
     try
          if TreeView.Items.Count>0 then begin
               TreeView.Items.BeginUpdate;
               TreeView.Items[0].Collapse(True);
               TreeView.Items[0].Expand(False);
               TreeView.Items.EndUpdate;
          end;
     except
          teShowMsg('Error when MenuItem_CloseAllClick!');

     end;
end;

procedure TMainForm.MenuItem_ExpandSelClick(Sender: TObject);
begin
     try
          if TreeView.Selected<>nil then begin
               TreeView.Items.BeginUpdate;
               TreeView.Selected.Expand(True);
               TreeView.Items.EndUpdate;
          end;
     except
          teShowMsg('Error when MenuItem_ExpandSelClick!');

     end;
end;

procedure TMainForm.MenuItem_SaveClick(Sender: TObject);
begin
    ToolButton_Save.OnClick(self);
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
     try

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
          sName     := joNode.S['_m_'];
          joSelMdl  := teFindModule(sName);
          jaAlwSib  := joSelMdl.A['allowsibling'];
          jaAlwChd  := joSelMdl.A['allowchild'];

          //Dynamic hide/view the module menuitem 动态菜单处理
          for iModule := 0 to gjoModules.A['items'].Count-1 do begin
               joModule  := gjoModules.A['items'][iModule];
               PopupMenu_TreeView.Items[iModule].Visible    :=
                    (teInModules(joModule.S['_m_'],jaAlwSib)) or (teInModules(joModule.S['_m_'],jaAlwChd));
          end;

     except
          teShowMsg('Error when PopupMenu_TreeViewPopup!');

     end;
end;


procedure TMainForm.TreeViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
     tnNode    : TTreeNode;
begin
     try
          //右键直接选择节点
          tnNode     := TreeView.GetNodeAt(X, Y);
          if tnNode<>nil then begin
               tnNode.Selected := True;
          end;
     except
          teShowMsg('Error when TreeViewMouseDown!');

     end;
end;

procedure TMainForm.TreeViewStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
     try
          gtnDragSource  := TreeView.Selected;
     except
          teShowMsg('Error when TreeViewStartDrag!');

     end;
end;

procedure TMainForm.MenuItem_ExitClick(Sender: TObject);
begin
     Close;
end;
procedure TMainForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
var
     joNode    : TJsonObject;
     iProp     : Integer;
     joModule  : TJsonObject;
     joProp    : TJsonObject;
     oPanel    : TPanel;
     oControl  : TControl;
begin
    try
          if bIsCreating then begin
               Exit;
          end;

          //锁定屏幕刷新, 以提高速度
          LockWindowUpdate(Handle);

          //设置当前树节点上移和下移的可用性
          teSetUpDownEnable(Node,ToolButton_Down,ToolButton_Up);

          //取得当前树节点的jSOn对象
          joNode    := teTreeToJson(Node);

          //取得对应的模块Module
          joModule  := teFindModule(joNode.S['_m_']);

          //
          for iProp := 0 to PageControl1.PageCount - 1 do begin
              if PageControl1.Pages[iProp].Caption = joNode.S['_m_'] then begin
                  PageControl1.ActivePageIndex          := iProp;
                  PageControl1.Pages[iProp].TabVisible  := True;
              end else begin
                  PageControl1.Pages[iProp].TabVisible  := false;
              end;
          end;

          //显示详细信息
          teShowNodeProperty(joNode,TFlowPanel(PageControl1.ActivePage.Controls[0]));

          //增加信息控件的事件
          for iProp := 0 to joModule.A['property'].Count-1 do begin
               //取得属性json
               joProp    := joModule.A['property'][iProp];
               continue;
               //取得控件
               //oControl  := TPanel(ScrollBox_Property.Controls[iProp]).Controls[1];
               if oControl = nil then begin
                   continue;
               end;
               //
               if joProp.S['type'] = 'string' then begin
                    TEdit(oControl).OnChange := OnPropertyChange;
               end else if joProp.S['type'] = 'memo' then begin
                    TMemo(oControl).OnChange := OnPropertyChange
               end else if joProp.S['type'] = 'integer' then begin
                    TEdit(oControl).OnChange  := OnPropertyChange
               end else if joProp.S['type'] = 'source' then begin
                    TMemo(oControl).OnChange   := OnPropertyChange
               end else if joProp.S['type'] = 'boolean' then begin
                    TCheckBox(oControl).OnClick   := OnPropertyChange
               end else if joProp.S['type'] = 'list' then begin
                    TComboBox(oControl).OnChange  := OnPropertyChange
               end else if joProp.S['type'] = 'color' then begin
                    TColorBox(oControl).OnChange       := OnPropertyChange
               end else if joProp.S['type'] = 'font' then begin
                    TSpeedButton(oControl).OnClick   := OnPropertyChange
               end else if joProp.S['type'] = 'float' then begin
                    TEdit(oControl).OnChange  := OnPropertyChange
               end;
          end;
          LockWindowUpdate(0);

     except
          teShowMsg('Error when TreeViewChange!');

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
     try
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
          sNameSrc  := joSource.S['_m_'];
          sNameDest := joDest.S['_m_'];

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
                         if gtnDragSource <> tnDest.getNextSibling then begin
                              //防止节点插入节点自身前面造成的错误!

                              //
                              if gtnDragSource <> tnDest.getNextSibling then begin
                                   gtnDragSource.MoveTo(tnDest.getNextSibling,naInsert);
                              end;
                         end;

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
                              if gtnDragSource <> tnDest.getNextSibling then begin
                                   gtnDragSource.MoveTo(tnDest.getNextSibling,naInsert);
                              end;
                         end else begin
                              gtnDragSource.MoveTo(tnDest,naAdd);
                         end;

                         //创建新JSON节点
                         joParDest.A['items'].InsertObject(1).FromUtf8JSON(joSource.ToUtf8JSON);

                         //删除旧JSON节点
                         joParSrc.A['items'].Delete(iIdSrc);
                    end else begin      //当前为最后固定节点
                         //移动树节点
                         if gtnDragSource <> tnDest then begin
                              gtnDragSource.MoveTo(tnDest,naInsert);
                         end;

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
                    if gtnDragSource <> tnDest.GetLastChild then begin
                         gtnDragSource.MoveTo(tnDest.GetLastChild,naInsert);
                    end;

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
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);
     except
          teShowMsg('Error when TreeViewDragDrop!');

     end;
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
     try
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
          sNameSrc  := joSource.S['_m_'];
          sNameDest := joDest.S['_m_'];

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
     except
          teShowMsg('Error when TreeViewDragOver!');

     end;
end;

procedure TMainForm.ToolButton_ExpandClick(Sender: TObject);
begin
     try
          if TreeView.Selected<>nil then begin
               TreeView.Items.BeginUpdate;
               TreeView.Selected.Expand(True);
               TreeView.Selected.MakeVisible;
               TreeView.Items.EndUpdate;
          end;
     except
          teShowMsg('Error when ToolButton_ExpandClick!');

     end;
end;

procedure TMainForm.ToolButton_CollapseClick(Sender: TObject);
begin
     try
          if TreeView.Selected<>nil then begin
               TreeView.Selected.Collapse(True);
          end;

     except
          teShowMsg('Error when ToolButton_CollapseClick!');

     end;
end;

procedure TMainForm.ToolButton_UpClick(Sender: TObject);
begin
     try
          teMoveTreeNodeUp(TreeView.Selected);
          //
          teSetUpDownEnable(TreeView.Selected,ToolButton_Down,ToolButton_Up);
          //
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);
     except
          teShowMsg('Error when ToolButton_UpClick!');

     end;
end;

procedure TMainForm.ToolButton_DownClick(Sender: TObject);
begin
     try
          //
          teMoveTreeNodeDown(TreeView.Selected);
          //
          teSetUpDownEnable(TreeView.Selected,ToolButton_Down,ToolButton_Up);
          //
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);
     except
          teShowMsg('Error when ToolButton_DownClick!');

     end;
end;


procedure TMainForm.ToolButton_SaveClick(Sender: TObject);
var
    tnNode      : TTreeNode;
    joNode      : TJsonObject;
    iProp       : integer;
begin
     try
          tnNode    := TreeView.Selected;
          if tnNode = nil then begin
               Exit;
          end;

          //
          joNode    := teTreeToJson(tnNode);

          //
          for iProp := 0 to PageControl1.PageCount - 1 do begin
              if PageControl1.Pages[iProp].Caption = joNode.S['_m_'] then begin
                  PageControl1.ActivePageIndex          := iProp;
                  PageControl1.Pages[iProp].TabVisible  := True;
              end else begin
                  PageControl1.Pages[iProp].TabVisible  := false;
              end;
          end;

          //保存修改
          teSaveNodeProperty(joNode,TFlowPanel(PageControl1.ActivePage.Controls[0]));

          //
          tnNode.Text   := '[' + joNode.s['type'] + '] '+joNode.S['caption'];

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
          //
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);

     except
          teShowMsg('Error when ToolButton_SaveClick!');

     end;
end;

procedure TMainForm.ToolButton_OpenClick(Sender: TObject);
var
     iRes      : Integer;
begin
     try
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
               //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);

               //设置为未修改状态
               gbModified     := False;
          end;
     except
          teShowMsg('Error when ToolButton_OpenClick!');

     end;
end;



procedure TMainForm.ToolButton_NewProjectClick(Sender: TObject);
var
     iRes      : Integer;
begin
     try
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
          gjoProject.S['_m_']     := 'root';
          gjoProject.A['items']    := TJsonArray.Create;

          //
          TreeView.Items[0].DeleteChildren;
          TreeView.Items[0].Text   := '';

          //
          //SynEdit.Lines.Text   := '';

          //
          gsProjectName  := '';
          gbModified     := False;

     except
          teShowMsg('Error when ToolButton_NewProjectClick!');

     end;
end;

procedure TMainForm.AddModule(Sender: TObject);
begin
     try
          teAddModule(TreeView.Selected,TMenuItem(Sender).MenuIndex);
          //
          //SynEdit.Lines.Text     := StringReplace(gjoProject.ToUtf8JSON(False),#9,'    ',[rfReplaceAll]);
     except
          teShowMsg('Error when AddModule!');

     end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
     iRes : Integer;
begin
     try
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

     except
          teShowMsg('Error when FormCloseQuery!');

     end;
end;


end.

