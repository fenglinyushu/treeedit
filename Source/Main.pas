unit Main;


interface


uses

     //--------------------------------------�Ա൥Ԫ-----------------------------------------------
     SysVars,

     teUnit,


     //--------------------------------------������-------------------------------------------------
     JsonDataObjects,

     //
     SynEdit, SynEditHighlighter,SynEditCodeFolding, SynHighlighterJSON,

     //
     mxClickSplitter,

     //-------------------------------------ϵͳ�Դ�------------------------------------------------
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
    procedure MenuItem_SearchNextClick(Sender: TObject);
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
          bIsCreating    : Boolean;          //��־�Ƿ�������������,���ڿ��ƽڵ�ת��ʱ�Ƿ��������ͼ
          bClose         : Boolean;
          bDelete        : Boolean;
          gjoCopySource  : TJsonObject;      //����Ϊnil������ʱΪԴ�ڵ�
          gtnCurNode     : TTreeNode;        //��갴��ʱ�����ڵ㣬�����Ҽ�ѡ��
          //
          gsDragSrcText  : string;           //������/���нڵ��Text
          gsDragSrcMode  : string;           //������/���нڵ������
          gjoCopy        : TJsonObject;      //������/���нڵ㹹�ɵ�XML
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
     //
     gsMainDir      : string;      //������Ŀ¼

     //������������л�����ǰ�鿴���Ľڵ�
     gbAutoChange   : Boolean=False;
     giNodeChange   : Integer;

     //
     SearchMode     : Integer=-1;  //���Ҳ�����Ŀ�õı���
     SearchKey      : string='';   //���Ҳ�����Ŀʱ�õĹؼ���

     //
     gbModified     : Boolean = False;  //�ļ��Ƿ��ѱ��޸�

     //
     gsFileName     : string = '';      //��ǰ�ļ���(��ȫ·��)



implementation



{$R *.dfm}


procedure TMainForm.PopMenu_DeleteClick(Sender: TObject);
var
     //
     joNode    : TJsonObject;
     //
     tnNode    : TTreeNode;
     tnPar     : TTreeNode;
begin
     //�õ���Ӧ�����ڵ�
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          ShowMessage('Please selected a node at first!');
          Exit;
     end;
     joNode    := teTreeToJson(tnNode);

     //<�쳣���
     //���ڵ㲻��Ϊnil
     if joNode=nil then begin
          ShowMessage('Please selected a node at first!');
          Exit;
     end;

     //������ɾ�����ڵ�
     if tnNode.Level = 0 then begin
          ShowMessage('Cannot delete the root node!');
          Exit;
     end;

     //������ɾ��һЩ�ض��ڵ�
     if teInNames(joNode.S['name'],['if_Yes','if_else','block','try_body','try_except','try_else']) then begin
          ShowMessage('Cannot delete the neccessary node!');
          Exit;
     end;
     //>


     //ȷ��ɾ��
     if MessageDlg(#13+'Are you really want to delete the node named "' +tnNode.Text+'" ?'+#13,
               mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
     begin
          Exit;
     end;

     //ɾ�����ڵ�
     tnPar     := tnNode.Parent;
     tnPar.Selected   := True;
     tnNode.Destroy;

     //ɾ��XML�ڵ㣬 �����丸�ڵ�Ϊ��ǰ�ڵ�
     joNode.Destroy;

     //�������޸ı�ʶ
     gbModified     := True;
end;

//------------------------------��ʾ�ڵ������----------------------------------------------------//
procedure TMainForm.ShowNodeProperty(ANode: TJsonObject);
var
     iProp     : Integer;
     iCtrl     : Integer;
     //
     joProp    : TJsonObject;
     joModule  : TJsonObject;
     //
     oPanel    : TPanel;
     oLabel    : TLabel;
     oSpin     : TSpinEdit;
     oEdit     : TEdit;
     oSynEdit  : TSynEdit;
     oCheck    : TCheckBox;
     //
     bFoundSrc : Boolean;     //found source property
begin
     //Clear All components of Panel_LeftBottom
     for iCtrl := Panel_LeftBottom.ControlCount-1 downto 0 do begin
          Panel_LeftBottom.Controls[iCtrl].Destroy;
     end;

     //�����ǰ�ڵ�Ϊnil,���˳�
     if ANode = nil then begin
          Exit;
     end;

     //
     joModule  := teFindModule(ANode.S['name']);

     //��ʾ����
     bFoundSrc := False;
     for iProp := 0 to joModule.A['property'].Count-1 do begin
          joProp    := joModule.A['property'][iProp];
          //���Ե����
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
          //��������
          oLabel    := TLabel.Create(oPanel);
          oLabel.Parent       := oPanel;
          oLabel.Align        := alLeft;
          oLabel.Layout       := tlCenter;
          oLabel.AutoSize     := False;
          oLabel.Width        := 100;
          oLabel.Caption      := joProp.S['name'];
          //����ֵ
          if joProp.S['type'] = 'string' then begin
               oEdit          := TEdit.Create(oPanel);
               oEdit.Parent   := oPanel;
               oEdit.Align    := alClient;
               oEdit.Text     := ANode.S[joProp.S['name']];
               oEdit.OnChange := PropertyChange;
          end else if joProp.S['type'] = 'integer' then begin
               oSpin          := TSpinEdit.Create(oPanel);
               oSpin.Parent   := oPanel;
               oSpin.Align    := alClient;
               oSpin.Value    := ANode.I[joProp.S['name']];
               oSpin.OnChange := PropertyChange;
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
               oCheck         := TCheckBox.Create(oPanel);
               oCheck.Parent  := oPanel;
               oCheck.Align   := alClient;
               oCheck.Checked := ANode.B[joProp.S['name']];
               oCheck.OnClick := PropertyChange;
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
     //�����ǰ�ڵ����,����ʾ����ͼ��
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
          //�õ���Ӧ���ڵ�
          tnSrc     := TreeView.Selected;         //�õ�Դ�ڵ�
          tnTar     := TreeView.GetNodeAt(X,Y);   //�õ�Ŀ�Ľڵ�
          if (tnSrc=nil)or(tnTar=nil) then begin
               Accept    := False;
               Exit;   //�쳣����
          end;

          //�õ�XML�ڵ�
          xnSrc     := GetXMLNodeFromTreeNode(gxdXML,tnSrc);
          xnTar     := GetXMLNodeFromTreeNode(gxdXML,tnTar);
          if (xnSrc=nil)or(xnTar=nil) then begin
               Accept    := False;
               Exit;   //�쳣����
          end;
          iSrcMode  := xnSrc.Attributes['Mode'];
          iTarMode  := xnTar.Attributes['Mode'];


          //-------------------------Դ��Ŀ�ĵ����ʹ���------------------------------------------------//
          //Ĭ�Ͽ���
          Accept    := True;
          //�����϶�����ڵ�
          if InModes(iSrcMode,[]) then begin
               Accept    := False;
               Exit;
          end;

          //�����϶����ڵ��ӽڵ�
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
     //�õ���Ӧ���ڵ�
     tnSrc     := TreeView.Selected;         //�õ�Դ�ڵ�
     tnTar     := TreeView.GetNodeAt(X,Y);   //�õ�Ŀ�Ľڵ�
     if (tnSrc=nil)or(tnTar=nil) then Exit;   //�쳣����

     //�õ�XML�ڵ�
     xnSrc     := GetXMLNodeFromTreeNode(gxdXML,tnSrc);
     xnTar     := GetXMLNodeFromTreeNode(gxdXML,tnTar);
     if (xnSrc=nil)or(xnTar=nil) then Exit;   //�쳣����


     //ȡ���϶��ڵ��ģʽ
     //rDragMode := GetNewMode(xnSrc.Attributes['Mode'],xnTar.Attributes['Mode']);

     case rDragMode.AddMode of
          nmChild : begin     //��Ϊ����
               if MessageDlg('Do you really want to move node '+#13+#13+'['+tnSrc.Text+']'+#13+#13+' inside '+#13+#13
                         +'['+tnTar.Text+']'+'?',
                         mtConfirmation, [mbYes, mbNo], 0) = mrYes then
               begin
                    //����XML
                    xnNew     := xnTar.AddChild(xnSrc.NodeName);
                    CopyXMLNode(xnSrc,xnNew);
                    iIndex    := GetXMLNodeIndex(xnSrc);
                    xnSrc.ParentNode.ChildNodes.Delete(iIndex);

                    //����TreeView
                    TreeView.Items.BeginUpdate;
                    tnSrc.MoveTo(tnTar,naAddChild);
                    TreeView.Items.EndUpdate;
               end;
          end;
          nmAppend : begin    //ͬ��
               if MessageDlg('Do you really want to move node  '+#13+#13+'"'+tnSrc.Text+'"'+#13+#13+' after '+#13+#13
                         +'['+tnTar.Text+']'+' ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
               begin
                    //�϶�XML�ڵ�
                    iIndex    := GetXMLNodeIndex(xnTar);
                    xnNew     := xnTar.ParentNode.AddChild(xnSrc.NodeName,iIndex+1);
                    CopyXMLNode(xnSrc,xnNew);
                    iIndex    := GetXMLNodeIndex(xnSrc);
                    xnSrc.ParentNode.ChildNodes.Delete(iIndex);

                    //�϶����ڵ�
                    TreeView.Items.BeginUpdate;
                    if tnTar.getNextSibling=nil then begin
                         tnSrc.MoveTo(tnTar.Parent,naAddChild);
                    end else begin
                         tnSrc.MoveTo(tnTar.getNextSibling,naInsert);
                    end;
                    TreeView.Items.EndUpdate;
               end;
          end;
          nmInsert : begin    //��Ŀ�Ľڵ�ǰ����
               if MessageDlg('Do you really want to move node '+#13+#13+'['+tnSrc.Text+']'+#13+#13+' before '+#13+#13
                         +'['+tnTar.Text+']'+'?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
               begin
                    //�϶�XML�ڵ�
                    iIndex    := GetXMLNodeIndex(xnTar);
                    xnNew     := xnTar.ParentNode.AddChild(xnSrc.NodeName,iIndex);
                    CopyXMLNode(xnSrc,xnNew);
                    iIndex    := GetXMLNodeIndex(xnSrc);
                    xnSrc.ParentNode.ChildNodes.Delete(iIndex);

                    //�϶����ڵ�
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
          sCaption  : string;      //�½ڵ��caption
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
     joSelMdl  : TJsonObject; //��ǰѡ�����ڵ�Ķ�Ӧģ��ڵ�
     joCur     : TJsonObject; //
     joMdlPar  : TJsonObject; //
     tnCur     : TTreeNode;
     tnParent  : TTreeNode;

     //
     sMode     : string;
     //0: as sibling, 1:as child, 3:as sibling(not last), 4: as optional child (not first, not last)
     oAddMode  : TTEAddMode;     //

begin
     //get current treeview node �õ���ǰ���ڵ�
     tnCur     := TreeView.Selected;
     if tnCur = nil then begin
          Exit;
     end;

     //get json node from treenode �õ���ǰ���̽ڵ�
     joCur     := teTreeToJson(tnCur);

     //
     joSelMdl  := teFindModule(joCur.S['name']);

     //get the module jsonobject �õ�ģ��ڵ�
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

     //��Դ�ڵ㱣�浽XML��
     gjoCopy   := TJsonObject.Create;
     gjoCopy.FromJSON(joNode.ToString);


     gjoCopySource  := nil;

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
begin
     tnNode    := TreeView.Selected;
     if tnNode = nil then begin
          Exit;
     end;
     joNode    := teTreeToJson(tnNode);

     //�õ���ǰ�ڵ��Index
     iIndex    := tnNode.Index;

{
     //
     TreeView.Items.BeginUpdate;
     case GetNewMode(gjoCopy.S['name'],joNode.S['name']) of
          pmNext : begin    //׷��ģʽ
               xnNew     := xnNode.ParentNode.AddChild('Temp',iIndex+1);
               //CopyXMLNodeFromText(xnNew,gxdCopy.DocumentElement.XML);
               CopyXMLNode(gxdCopy.DocumentElement,xnNew);
               if rNewMode.Source=1 then begin
                    xnNew.Attributes['Mode']      := rtBlock_Set;
                    xnNew.Attributes['Caption']   := '';
               end;

               //���������³ƿ�����
               ToolButton_Down.Enabled  := xnNew.NextSibling<>nil;
               ToolButton_Up.Enabled    := xnNew.PreviousSibling<>nil;

               //�������ڵ�
               tnNew     := TreeView.Items.Add(tnNode,xnNew.Attributes['Caption']);
               tnNew.ImageIndex    := ModeToImageIndex(xnNew.Attributes['Mode']);
               tnNew.SelectedIndex := tnNew.ImageIndex;
               //����λ��
               if tnNode.getNextSibling<>nil then begin
                    tnNew.MoveTo(tnNode.getNextSibling,naInsert);
               end;
               //����ճ��������XML�ڵ�������
               AddXmlNodeToTV(xnNew,tnNew);
          end;
          nmChild : begin     //�ӿ�ģʽ
               xnNew     := xnNode.AddChild('Temp');
               //CopyXMLNodeFromText(xnNew,gxdCopy.DocumentElement.XML);
               CopyXMLNode(gxdCopy.DocumentElement,xnNew);

               if rNewMode.Source=1 then begin
                    xnNew.Attributes['Mode'] := rtBlock_Set;
                    xnNew.Attributes['Caption']   := '';
               end;

               //���������³ƿ�����
               ToolButton_Down.Enabled  := xnNew.NextSibling<>nil;
               ToolButton_Up.Enabled    := xnNew.PreviousSibling<>nil;


               //�������ڵ�
               tnNew     := TreeView.Items.AddChild(tnNode,xnNew.Attributes['Caption']);
               tnNew.ImageIndex    := ModeToImageIndex(xnNew.Attributes['Mode']);
               tnNew.SelectedIndex := tnNew.ImageIndex;
               //����ճ��������XML�ڵ�������
               AddXmlNodeToTV(xnNew,tnNew);
          end;
          nmInsert : begin    //����ģʽ
               xnNew     := xnNode.ParentNode.AddChild('Temp',iIndex);
               //CopyXMLNodeFromText(xnNew,gxdCopy.DocumentElement.XML);
               CopyXMLNode(gxdCopy.DocumentElement,xnNew);
               if rNewMode.Source=1 then begin
                    xnNew.Attributes['Mode']      := rtBlock_Set;
                    xnNew.Attributes['Caption']   := '';
               end;

               //���������³ƿ�����
               ToolButton_Down.Enabled  := xnNew.NextSibling<>nil;
               ToolButton_Up.Enabled    := xnNew.PreviousSibling<>nil;

               //�������ڵ�
               tnNew     := TreeView.Items.Add(tnNode,xnNew.Attributes['Caption']);
               tnNew.ImageIndex    := ModeToImageIndex(xnNew.Attributes['Mode']);
               tnNew.SelectedIndex := tnNew.ImageIndex;
               //����λ��
               tnNew.MoveTo(tnNode,naInsert);
               //����ճ��������XML�ڵ�������
               AddXmlNodeToTV(xnNew,tnNew);
          end;
     end;
     TreeView.Items.EndUpdate;

     //����Ǽ���,��ɾ���Ͻڵ�
     if gxnCopySource<>nil then begin
          //
          tnNode    := GetTreeNodeFromXMLNode(TreeView,gxnCopySource);
          tnNode.Destroy;

          //ɾ��XML�ڵ�
          iIndex    := GetXMLNodeIndex(gxnCopySource);
          gxnCopySource.ParentNode.ChildNodes.Delete(iIndex);
     end;

     //������ճ���Ľڵ�Ϊ��ǰ�ڵ�
     xnNode   := xnNew;
     tnNode    := GetTreeNodeFromXMLNode(TreeView,xnNode);
     tnNode.MakeVisible;
     
     //
     UpdateChart;
     //�������޸ı�ʶ
     gbModified     := True;
}
end;

procedure TMainForm.MenuItem_SearchNextClick(Sender: TObject);
var
     I    : Integer;
begin
     if SearchMode<0 then begin
          //Form_Search.ShowModal;
     end;
     //
     for I:=TreeView.Selected.AbsoluteIndex+1 to TreeView.Items.Count-1 do begin
          if TreeView.Items[I].ImageIndex=SearchMode then begin
               if (SearchKey='')or(Pos(SearchKey,TreeView.Items[I].Text)>0) then begin
                    TreeView.Items[I].Selected    := True;
                    break;
               end;
          end;
     end; 

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
     jaMenu    : TJsonArray;  //allow module names of current selected module
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
     jaMenu    := joSelMdl.A['menu'];

     //Dynamic hide/view the module menuitem ��̬�˵�����
     for iModule := 0 to gjoModules.A['items'].Count-1 do begin
          joModule  := gjoModules.A['items'][iModule];
          PopupMenu_TreeView.Items[iModule].Visible    := teInModules(joModule.S['name'],jaMenu);
     end;
     Exit;

     if joNode.S['mode'] = 'optional child' then begin
          for iModule := 0 to gjoModules.A['items'].Count-1 do begin
               sMode     := gjoModules.A['items'][iModule].S['mode'];
               bTmp      := not (teInNames(sMode,['only','as fixed child','as optional child']));
               PopupMenu_TreeView.Items[iModule].Visible    := not (teInNames(sMode,['only child','as fixed child','as optional child']));
               if (sMode = 'as optional child') and (teInModules(sName,gjoModules.A['items'][iModule].A['parent'])) then begin
                    PopupMenu_TreeView.Items[iModule].Visible    := True;
               end;
          end;
     end else if (joNode.S['mode'] = 'as optional child') or (joNode.S['mode'] = 'as fixed child') then begin
          sParent   := teFindModule(sName).A['parent'].S[0];
          for iModule := 0 to gjoModules.A['items'].Count-1 do begin
               joModule  := gjoModules.A['items'][iModule];
               sMode     := joModule.S['mode'];
               PopupMenu_TreeView.Items[iModule].Visible    := not (teInNames(sMode,['only child','as fixed child','as optional child']));
               if sMode = 'as optional child' then begin
                    if joModule.Contains('parent') then begin
                         if joModule.A['parent'].Count>0 then begin
                              PopupMenu_TreeView.Items[iModule].Visible    := joModule.A['parent'].S[0]=sParent;
                         end;
                    end;
               end;
          end;
     end else begin
          for iModule := 0 to gjoModules.A['items'].Count-1 do begin
               joModule  := gjoModules.A['items'][iModule];
               sMode     := joModule.S['mode'];
               PopupMenu_TreeView.Items[iModule].Visible    := not (teInNames(sMode,['only child','as fixed child','as optional child']));
               //
               if joModule.Contains('parent') then begin
                    //PopupMenu_TreeView.Items[iModule].Visible    := teInModules(sName,joModule.A['parent']);
               end;

          end;
     end;

     //there have erros when view menu and insert node!

end;


procedure TMainForm.TreeViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
     tnNode    : TTreeNode;
begin
     //�Ҽ�ֱ��ѡ��ڵ�
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
     //��ʾ��ϸ��Ϣ
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

          //�õ�XML�ڵ�
          //xnNode   := GetXMLNodeFromTreeNode(gxdXML,tnNode);

          //���
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

     //XML�ڵ�����
{
     iIndex    := GetXMLNodeIndex(xnNode);
     xnNew     := xnNode.ParentNode.AddChild(xnNode.NodeName,iIndex-1);
     CopyXMLNode(xnNode,xnNew);
     xnNode.ParentNode.ChildNodes.Delete(iIndex+1);
     xnNode   := xnNew;
     //xnNode.ParentNode.ChildNodes.ReplaceNode(xnNode.PreviousSibling,xnNode);
     //xnNode.ParentNode.ChildNodes.Insert(iIndex-1,xnNode);

     //���ڵ�����
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
     //XML�ڵ�����
     iIndex    := GetXMLNodeIndex(xnNode);
     xnNew     := xnNode.ParentNode.AddChild(xnNode.NodeName,iIndex+2);  //����λ�������½ڵ�
     CopyXMLNode(xnNode,xnNew);   //����Դ�ڵ�����Ժ��ӽڵ�
     xnNode.ParentNode.ChildNodes.Delete(iIndex);     //ɾ��Դ�ڵ�
     xnNode   := xnNew; //�����½ڵ�Ϊ��ǰ�ڵ�

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
var
     xnRoot    : TJsonObject;
begin
     SaveNodeProperty;
{
     //
     xnRoot    := gxdXML.DocumentElement;
     xnRoot.Attributes['FileType'] := 'AutoCode';
     xnRoot.Attributes['Language'] := 'Python';
     if not FileExists(gsFileName) then begin
          if SaveDialog.Execute then begin
               gsFileName     := SaveDialog.FileName;
               gxdXML.SaveToFile(SaveDialog.FileName);
               //����Ϊδ�޸�״̬
               gbModified     := False;
          end ;
     end else begin
          gxdXML.SaveToFile(gsFileName);
          //����Ϊδ�޸�״̬
          gbModified     := False;
     end;
}
end;

procedure TMainForm.ToolButton_OpenClick(Sender: TObject);
var
     iRes      : Integer;
     I         : Integer;
     xnNode    : TJsonObject;
begin
     //�˳�ʱ�����ǰ�ĵ����޸ģ�����ʾ�Ƿ񱣴�/ȡ���˳�
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
{
          //����XML
          gxdXML.LoadFromFile(OpenDialog.FileName);
          //
          gsFileName     := OpenDialog.FileName;


          //����Ϊ����ͼ�Ļ��Ƹ��ڵ�
          gxnRootNode    := gxdXML.DocumentElement;
          xnNode        := gxnRootNode;

          //����XML������
          bIsCreating    := True;
          //XmlToTreeView(gxdXML,TreeView);
          bIsCreating    := False;
          //
          TreeView.Items[0].Expand(False);
          TreeView.Items[0].Selected    := True;
          iMoveX    := -9999;
          iMoveY    := 0;

          //һЩ��Ҫ�Ĺ���
          gjoCopySource  := nil;   //���

          //����Ϊδ�޸�״̬
          gbModified     := False;
}
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
          end;

          //�������ڵ���ʾ
          if joProp.S['name'] = 'caption' then begin
               TreeView.Selected.Text   := joNode.S['caption'];
          end;
     end;

     //
     SynEdit.Text   := gjoProject.ToJSON(False);
end;

procedure TMainForm.SetUpDownEnable(ANode:TTreeNode);
begin
     if ANode = nil then begin
          Exit;
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
          //��Դ�ڵ㱣�浽XML��
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

{
     //
     gxdXML.Destroy;
     gxdXML    := TXMLDocument.Create(self);
     gxdXML.Active  := True;
     gxdXML.Version      := '1.0';
     gxdXML.Encoding     := 'UTF-8';
     //���Ӹ��ڵ�
     xnNew     := gxdXML.AddChild('Root');
     xnNew.Attributes['Mode']      := rtFile;
     xnNew.Attributes['BaseWidth'] := 50;
     xnNew.Attributes['BaseHeight']:= 24;
     xnNew.Attributes['SpaceVert'] := 15;
     xnNew.Attributes['SpaceHorz'] := 20;
     xnNew.Attributes['ChartMode'] := cmFlowChart;
     xnNew.Attributes['Caption']   := '';
     xnNew.Attributes['Source']    := 'Newfile.py';
     xnNew.Attributes['Comment']   := '';

     //
     gxnRootNode    := xnNew;
     gbModified     := False;
     gsFileName     := '';

     //
     TreeView.Items[0].DeleteChildren;
     TreeView.Items[0].Text   := 'New file';

     //
     //ShowNodeProperty(xnNew);

     //
     UpdateChart;
}
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
     iRes : Integer;
begin
     //�˳�ʱ�����ǰ�ĵ����޸ģ�����ʾ�Ƿ񱣴�/ȡ���˳�
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
end;

end.
