unit SysVars;
{
本单元包含系统全部的全局变量
}

//{$DEFINE ISOEM}

interface

uses
     //自编模块

     //
     JsonDataObjects,

     //
     Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, ExtCtrls, StdCtrls, ComCtrls, Buttons, ImgList, ToolWin,
     Math, Spin, IniFiles, Grids, ExtDlgs,  Menus;


var
     //
     gsMainDir      : string;           //init path 系统的初始运行目录
     gsFileName     : string = '';      //save file

     //
     gjoModules     : TJsonObject;      //modules for add
     gjoProject     : TJsonObject;      //current project



     //
     gbModified     : Boolean = False;  //文件是否已被修改



 
implementation



end.
