unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdURI, IdHTTP,
  IdIOHandler, IdIOHandlerSocket, IdSSLOpenSSL, XPMan, ExtCtrls,
  Mask, System.StrUtils,
  ComCtrls, Vcl.Grids, HTTPApp,
  ShellAPI, AsgLinks, AsgListb, Vcl.Menus,
  Vcl.Buttons, Parsing, IdCookieManager, IdIntercept, IdCompressionIntercept,
  AdvObj, BaseGrid, AdvGrid, SBStrUtils, IdGlobal, AdvPageControl, dateutils,
  frmctrllink, HtmlTable, RegularExpressions;

type
  TfrmMain = class(TForm)
    IdHTTP1: TIdHTTP;
    idntfrz1: TIdAntiFreeze;
    idckmngr1: TIdCookieManager;
    pm1: TPopupMenu;
    E1: TMenuItem;
    P1: TMenuItem;
    pgctrl1: TAdvPageControl;
    tbsht1ClearAccs: TAdvTabSheet;
    tbsht2Frozens: TAdvTabSheet;
    pnl1: TPanel;
    chk1: TCheckBox;
    edt1: TEdit;
    Grid: TAdvStringGrid;
    Grid1Frozens: TAdvStringGrid;
    pm2: TPopupMenu;
    mnic1: TMenuItem;
    mniE2: TMenuItem;
    N1: TMenuItem;
    S1: TMenuItem;
    H1: TMenuItem;
    N2: TMenuItem;
    frmcntrldtlnk1: TFormControlEditLink;
    Gridph: TAdvStringGrid;
    mmo1: TMemo;
    mnit1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GridCheckBoxClick(Sender: TObject; ACol, ARow: Integer;
      State: Boolean);
    procedure GridGetEditorType(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TEditorType);
    procedure E1Click(Sender: TObject);
    procedure GridCanEditCell(Sender: TObject; ARow, ACol: Integer;
      var CanEdit: Boolean);
    procedure P1Click(Sender: TObject);
    procedure Grid1FrozensClipboardPaste(Sender: TObject; var Allow: Boolean);
    procedure Grid1FrozensClipboardBeforePasteCell(Sender: TObject;
      ACol, ARow: Integer; var Value: string; var Allow: Boolean);
    procedure Grid1FrozensClipboardPasteDone(Sender: TObject;
      CellRect: TGridRect);
    procedure Grid1FrozensClipboardAfterPasteCell(Sender: TObject;
      ACol, ARow: Integer; Value: string);
    procedure mnic1Click(Sender: TObject);
    procedure mniE2Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Grid1FrozensCanEditCell(Sender: TObject; ARow, ACol: Integer;
      var CanEdit: Boolean);
    procedure H1Click(Sender: TObject);
    procedure Grid1FrozensGetEditorType(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TEditorType);
    procedure frmcntrldtlnk1SetEditorValue(Sender: TObject;
      Grid: TAdvStringGrid; AValue: string);
    procedure GridphButtonClick(Sender: TObject; ACol, ARow: Integer);
    procedure frmcntrldtlnk1GetEditorValue(Sender: TObject;
      Grid: TAdvStringGrid; var AValue: string);
    procedure mnit1Click(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure tbsht2FrozensShow(Sender: TObject);
    procedure Grid1FrozensGetDisplText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
  private
    procedure ClearIP(Acc, Contract: string);
    procedure ClearContracts(Acc, Date: string);
    procedure ClearAccount(Acc, Contract: string);
    procedure ClearIF(S: string);
    procedure GetInfo(cid: string);
    procedure PostingToForum(S, abon, abonurl: string; i: Integer);
    procedure ClearSelectedAccs(cid: string);
    procedure CloseService(S: string; i: Integer);
    procedure UnFreeze(cid: string);
    procedure logInForum();
    procedure GoToLink(S: string);
    procedure ForzenGetNumberPhone(i: Integer; url: string; var S: string);
    procedure CloseAllServices(cid: string);
    procedure ClearFromList;
    function GetLastContractLink(Acc: string): string;
    procedure console(str: string);
    procedure FilterTable;
    procedure SetCheckBox;
    procedure GetAccs(S: string);
    procedure abortLoadingAccs;
    procedure LoadingAccs;
    function isNumber(S: string): string;
    function isCityCode(S: string): Boolean;
    procedure InsertFrozen;
    function isPhone(S: string): Boolean;
    function isComment(S: string): Boolean;
    function GetPhoneString(S: string): String;
    function clearParenthesis(S: string): string;
    function replaceDoubleSpace(S: string): string;
  public
  end;

var
  frmMain: TfrmMain;
  list: TStringList;
  table: THTMLTable;

implementation

{$R *.dfm}

function TfrmMain.GetLastContractLink(Acc: string): string;
const
  contracts = DYATEL + 'contracts/search.cgi?sid_mask=%5e';
var
  url: string;
  S: string;
  lastContract: string;
begin
  url := contracts + Acc + '%24';
  S := IdHTTP1.Get(url);
  if IdHTTP1.Response.Location.IsEmpty then
  begin
    lastContract := pars(S, 'bold" href="', '">').trim;
    if lastContract.contains('service.cgi?sid=') then
      Result := DYATEL + 'contracts/edit/' + lastContract;
  end
  else
    Result := DYATEL + 'contracts/edit/' + IdHTTP1.Response.Location;;
end;

procedure TfrmMain.console(str: string);
begin
  mmo1.Lines.Add(str);
end;

procedure TfrmMain.FilterTable;
var
  FilterStr: string;
begin
  table.Grid.SplitAllCells;
  with table.Grid.Filter.Add do
  begin
    FilterStr := '!*stat &!*mail &!*dial';
    Condition := FilterStr;
    data := fcNormal;
    Column := 2;
    CaseSensitive := False;
  end;
  table.Grid.FilterActive := true;
end;

procedure TfrmMain.SetCheckBox;
begin
  Grid.AddCheckBoxColumn(0, False);
  Grid.AddCheckBoxColumn(1, False);
  Grid.AddCheckBoxColumn(2, False);
  Grid.AddCheckBoxColumn(3, False);
  Grid.AddCheckBoxColumn(5, False);
  Grid.AddCheckBoxColumn(6, False);
  Grid.AddCheckBoxColumn(7, False);
end;

procedure TfrmMain.tbsht2FrozensShow(Sender: TObject);
begin
  Grid1Frozens.SetFocus;
end;

procedure TfrmMain.GetAccs(S: string);
begin
  table.TableID := 1;
  table.GetDom(S);
  table.Grid.Filter.Clear;
  table.ParseHTMLTableCells(ttInnerText, nil);
  FilterTable;
end;

procedure TfrmMain.abortLoadingAccs;
begin
  Grid.ClearNormalCells;
  Grid.RowCount := 2;
  ShowMessage('ADSL aккануты в договоре не найдены');
end;

procedure TfrmMain.LoadingAccs;
begin
  Grid.RowCount := table.Grid.RowCount;
  Grid.Cols[0].Text := table.Grid.Cols[0].Text;
  SetCheckBox;
  Grid.AutoSizeCol(0);
  Grid.SetFocus;
end;

procedure TfrmMain.ClearContracts(Acc, Date: string);
var
  Sid: string;
  cid: string;
  sdate: string;
  ip: string;
  url: string;
  S: string;
  ContractLink: string;
begin
  ContractLink := GetLastContractLink(Acc);
  if ContractLink.IsEmpty then
  begin
    console('Не найден откртый обсчет');
  end
  else
  begin
    S := IdHTTP1.Get(ContractLink);
    Sid := 'sid=' + pars(S, 'sid=', '"');
    cid := 'cid=' + pars(S, 'cid=', '"');
    sdate := 'sdate=' + pars(S, 'sdate" value="', '"');
    ip := pars(S, 'ip)</td>', '');
    ip := pars(ip, '</a> ', '<');
    with list do
    begin
      Add(Sid);
      Add(cid);
      Add('type=abon');
      Add('name=' + Acc);
      Add('svc=ll');
      Add(sdate);
      Add('edate=' + Date);
      Add('stamp_4=' + Date);
      Add('stamp_5=' + Date);
      Add('stamp_6=' + Date);
      Add('stamp_7=' + Date);
      Add('stamp_8=' + Date);
      Add('stamp_10=' + Date);
      Add('submit=' + 'Post!');
    end;
    url := DYATEL + 'contracts/edit/service.cgi?' + Sid;
    try
      IdHTTP1.Post(url, list);
    except
    end;
    list.Clear;
    console('Обсчёт - почищен.');
  end;
end;

procedure TfrmMain.edt1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    edt1.Text := trim(edt1.Text);
    GetInfo(edt1.Text);
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(list);
  FreeAndNil(table);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  url: string;
begin
  logInForum;
  table := THTMLTable.Create(Form1);
end;

procedure TfrmMain.Grid1FrozensCanEditCell(Sender: TObject; ARow, ACol: Integer;
  var CanEdit: Boolean);
begin
  CanEdit := False;
  if Grid1Frozens.RowCount > 2 then
    if ACol = 1 then
      if Grid1Frozens.IsNode(Grid1Frozens.RealRow) = False then
        CanEdit := true;
  if ACol = 3 then
    CanEdit := true
end;

procedure TfrmMain.Grid1FrozensClipboardAfterPasteCell(Sender: TObject;
  ACol, ARow: Integer; Value: string);
var
  i: Integer;
begin
  Grid1Frozens.RowCount := Grid1Frozens.RowCount - 1;
end;

procedure TfrmMain.Grid1FrozensClipboardBeforePasteCell(Sender: TObject;
  ACol, ARow: Integer; var Value: string; var Allow: Boolean);
begin
  if Value.contains(SSWeb) then
  begin
    if ACol <> 1 then
    begin
      Grid1Frozens.Cells[1, ARow] := Value;
      Value := '';
    end;
  end
  else
  begin
    Allow := False;
    Value := '';
  end;
end;

procedure TfrmMain.Grid1FrozensClipboardPaste(Sender: TObject;
  var Allow: Boolean);
begin
  Grid1Frozens.ClearNormalCells;
  Grid1Frozens.RemoveRows(1, Grid1Frozens.RowCount - 2);
end;

procedure TfrmMain.Grid1FrozensClipboardPasteDone(Sender: TObject;
  CellRect: TGridRect);
begin
  InsertFrozen;
end;

procedure TfrmMain.Grid1FrozensGetDisplText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
  if ACol = 3 then
    Value := Value.Replace(#13#10, ', ')
end;

procedure TfrmMain.Grid1FrozensGetEditorType(Sender: TObject; ACol, ARow: Integer;
  var AEditor: TEditorType);
begin
  if ACol = 3 then
    AEditor := edCustom;
  Grid1Frozens.EditLink := frmcntrldtlnk1;
end;

procedure TfrmMain.GridCanEditCell(Sender: TObject; ARow, ACol: Integer;
  var CanEdit: Boolean);
var
  State: Boolean;
begin
  case ACol of
    4:
      begin
        Grid.GetCheckBoxState(3, ARow, State);
        if State then
          CanEdit := true
        else
          CanEdit := False;
      end;
    8:
      begin
        Grid.GetCheckBoxState(7, ARow, State);
        if State then
          CanEdit := true
        else
          CanEdit := False;
      end;
  end;
end;

procedure TfrmMain.GridCheckBoxClick(Sender: TObject; ACol, ARow: Integer;
  State: Boolean);
var
  i: Integer;
begin
  case ACol of
    0:
      begin
        if State = true then
        begin
          for i := 1 to Grid.ColCount - 1 do
            Grid.SetCheckBoxState(i, ARow, true);
          Grid.dates[4, ARow] := Grid.DateTimePicker.Date;
        end
        else
        begin
          for i := 1 to Grid.ColCount - 1 do
            Grid.SetCheckBoxState(i, ARow, False);
          Grid.Cells[4, ARow] := '';
        end;
      end;
    3:
      begin
        if State then
          Grid.dates[ACol + 1, ARow] := Grid.DateTimePicker.Date
        else
          Grid.Cells[4, ARow] := '';
      end;
    7:
      begin
        if State then
          Grid.dates[ACol + 1, ARow] := Grid.DateTimePicker.Date
        else
          Grid.Cells[8, ARow] := '';
      end;
  end;
end;

procedure TfrmMain.GridGetEditorType(Sender: TObject; ACol, ARow: Integer;
  var AEditor: TEditorType);
var
  State: Boolean;
begin
  case ACol of
    4, 8:
      begin
        AEditor := edDateEdit;
        Grid.DateTimePicker.Format := 'dd.MM.yyyy';
      end;
    9:
      begin
        AEditor := edComboEdit;
        Grid.ClearComboString;
        Grid.AddComboString('На основании завяления от ' + DateToStr(Date));
        Grid.AddComboString('Переход на другого провайдера');
      end;
  end;
end;

procedure TfrmMain.GridphButtonClick(Sender: TObject; ACol, ARow: Integer);
var
  phone: string;
begin
  if ACol = 1 then
  begin
    phone := Gridph.Cells[0, ARow];
    if phone.contains('(4832)') then
      phone := phone.Replace('(4832)', '');
    phone := pars(phone, '', ' - ');
    phone := 'SIP:' + '9' + phone;
    ShellExecute(Handle, 'open', PWideChar(phone), nil, nil, SW_RESTORE);
  end;
end;

procedure TfrmMain.H1Click(Sender: TObject);
var
  i: Integer;
  State: Boolean;
  cid: string;
  day: string;
  Acc: string;
  url: string;
  S: string;
begin
  day := DateToStr(StartOfTheMonth(Date));
  for i := 1 to Grid1Frozens.RowCount - 1 do
  begin
    if Grid1Frozens.IsNode(i) = true then
      cid := Grid1Frozens.Cells[1, i];
    if Grid1Frozens.IsChecked(1, i) = true then
    begin
      url := SSWeb + 'auth.cgi?cid=' + cid;
      S := IdHTTP1.Get(url);
      Acc := Grid1Frozens.Cells[1, i];
      UnFreeze(cid);
      ClearContracts(Grid1Frozens.Cells[1, i], day);
      ClearIP(Acc, cid);
      ClearIF(S);
      ClearAccount(Acc, cid)
    end;
  end;
end;

procedure TfrmMain.E1Click(Sender: TObject);
begin
  ClearSelectedAccs(trim(edt1.Text));
end;

procedure TfrmMain.ClearIP(Acc, Contract: string);
var
  ip: string;
  url: string;
  State: Boolean;
begin
  url := AUTHCGI + 'cid=' + Contract + ';sid=' + Acc;
  ip := IdHTTP1.Get(url);
  ip := pars(ip, '"ip" value="', '"');
  if ip.contains('0.0.0.0') then
    console('IP в аккаунте Не найден')
  else
    with list do
    begin
      Add('address=' + ip);
      Add('old_descr=' + Acc);
      Add('desc=' + Acc);
      Add('delete=Clear!');
      url := DYATEL + 'ip-nets/edit/address.cgi';
      try
        IdHTTP1.Post(url, list);
        console(ip + ' - Почищен.');
      except
        console('ip в распределении пуст');
      end;
    end;
end;

procedure TfrmMain.chk1Click(Sender: TObject);
begin
  edt1.Enabled := False;
  GetInfo(edt1.Text);
  edt1.Enabled := true;
end;

procedure TfrmMain.ClearAccount(Acc, Contract: string);
var
  State: Boolean;
  url: string;
  S: string;
  phone: string;
begin
  begin
    url := AUTHCGI + 'cid=' + Contract + ';sid=' + Acc;
    S := IdHTTP1.Get(url);
    phone := pars(S, 'name="adsl_phone" size="10" value="', '">');
    with list do
    begin
      Add('multi_edit=1');
      Add('cid=' + Contract);
      Add('sid=' + ReplaceText(Acc, '%40', '@'));
      Add('typ_adsl=1');
      Add('ip=0.0.0.0');
      Add('routes=');
      Add('snmp_if_no=');
      Add('adsl_phone=' + phone);
      Add('note=');
      Add('confirm=1');
    end;
    try
      IdHTTP1.Post(SSWeb + 'auth.cgi', list);
      console('Аккаунт ' + Acc + ' - Почищен.');
    finally
      list.Clear;
    end;
  end;
end;

procedure TfrmMain.ClearIF(S: string);
begin
  if not S.contains('agent_id=') then
    console('Интерфейс пуст')
  else
  begin
    with list do
    begin
      Add('agent_id=' + pars(S, 'agent_id=', '#'));
      Add('if_no=' + pars(S, '#if', '"'));
      Add('stamp=' + FormatDateTime('dd/mm/yy', Date));
      Add('descr=');
      Add('add=' + '1');
      try
        IdHTTP1.Post(Stats + 'manual-descr.cgi', list);
        console('Запись на интерфейсе почищена.');
      except
      end;
    end;
  end;
  list.Clear;
end;

procedure TfrmMain.GetInfo(cid: string);
var
  url: string;
begin
  cid := AnsiUpperCase(cid.trim);
  if not cid.IsEmpty then
  begin
    url := AUTHCGI + 'cid=' + cid;
    if chk1.Checked then
      url := url + '&active=on';
    GetAccs(IdHTTP1.Get(url));
    if (table.Grid.RowCount = 1) or (table.TableCount = 2) then
      abortLoadingAccs
    else
      LoadingAccs;
  end;
end;

procedure TfrmMain.P1Click(Sender: TObject);
begin
  CloseAllServices(edt1.Text);
end;

procedure TfrmMain.PostingToForum(S, abon, abonurl: string; i: Integer);
var
  p: string;
  phone: string;
  Text: string;
  url: string;
begin
  p := pars(S, Grid.Cells[0, i], '');
  p := pars(p, 'тел.&nbsp;', #$A#9#9);
  phone := p.Replace('-', '');
  if phone.IsEmpty then
    console('Номер телефона в аккаунте ADSL не найден')
  else
  begin
    Text := 'В расскрос: ';
    Text := Text + '[b]' + p + '[/b] - ' + abon;
    Text := Text + ' [url=' + abonurl + ']' + edt1.Text + '[/url]';
    case phone.ToInteger of
      294000 .. 295999, 600000 .. 609999:
        begin
          list.Add('t=7979');
          list.Add('subject=RE: ПЕРЕКРОСЫ ШЧ 2017');
          list.Add('message=' + Text);
        end;
      300000 .. 599999, 630000 .. 999999:
        begin
          list.Add('t=7978');
          list.Add('subject=RE: ПЕРЕКРОССЫ РТ 2017');
          list.Add('message=' + Text);
        end;
    end;
    with list do
    begin
      Add('addbbcode18=#444444');
      Add('addbbcode20=12');
      Add('mode=reply');
      Add('post=Отправить');
    end;
    url := 'http://supp.bryansk.me/posting.php';
    IdHTTP1.Post(url, list, IndyTextEncoding(1251));
    list.Clear;
    console('Запись в форуме - создана');
  end
end;

procedure TfrmMain.ClearSelectedAccs(cid: string);
var
  url: string;
  S: string;
  abon: string;
  abonurl: string;
  i: Integer;
  isCheck: Boolean;
begin
  list.Clear;
  url := AUTHCGI + 'cid=' + cid;
  S := IdHTTP1.Get(url);
  abon := pars(S, '<br>', '</h2>');
  abon.Replace('&quot;', '"');
  abon.Replace('&#39;', '"');
  abonurl := url;
  for i := 1 to Grid.RowCount - 1 do
  begin
    if Grid.GetCheckBoxState(3, i, isCheck) then
      if isCheck then
        ClearContracts(Grid.Cells[0, i], Grid.Cells[4, i]);
    if Grid.GetCheckBoxState(2, i, isCheck) then
      if isCheck then
        ClearIP(Grid.Cells[0, i], cid);
    if Grid.GetCheckBoxState(1, i, isCheck) then
      if isCheck then
        ClearIF(S);
    if Grid.GetCheckBoxState(6, i, isCheck) then
      if isCheck then
        PostingToForum(S, abon, abonurl, i);
    if Grid.GetCheckBoxState(5, i, isCheck) then
      if isCheck then
        ClearAccount(Grid.Cells[0, i], cid);
  end;
  console('Готово.');
  console(DupeString('—', 60));
end;

procedure TfrmMain.CloseService(S: string; i: Integer);
var
  State: Boolean;
  url: string;
begin
  if Grid.GetCheckBoxState(7, i, State) then
    if State then
    begin
      if S.contains('(заморожен)') = true then
      begin
        UnFreeze(edt1.Text);
        url := ServicesCgi + 'cid=' + edt1.Text + ';active=1';
        S := IdHTTP1.Get(url);
      end;
    end;
end;

procedure TfrmMain.UnFreeze(cid: string);
var
  url: string;
begin
  with list do
  begin
    Add('cid=' + cid);
    Add('confirm=1');
    url := UnfreezeCGI;
    IdHTTP1.Post(url, list);
    list.Clear;
  end;
end;

procedure TfrmMain.logInForum();
var
  url: string;
begin
end;

procedure TfrmMain.GoToLink(S: string);
var
  i: Integer;
begin
  if Grid1Frozens.Cells[1, Grid1Frozens.Row] <> '' then
  begin
    i := Grid1Frozens.Row;
    while Grid1Frozens.IsNode(i) <> true do
    begin
      i := i - 1;
    end;
    S := SSWeb + S + '.cgi?cid=' + Grid1Frozens.Cells[1, i];
    ShellExecute(Handle, 'open', PWideChar(S), nil, nil, SW_NORMAL);
  end;
end;

procedure TfrmMain.ForzenGetNumberPhone(i: Integer; url: string; var S: string);
var
  buf: string;
  phoneString: string;
  cityCode: string;
  comment: string;
begin
  url := url.Replace('auth', 'contract');
  S := IdHTTP1.Get(url);
  S := pars(S, 'C phone', ''#10'').trim;
  S := S.Replace('</span>', '');
  S := S.Replace(';', ' ');
  S := S.Replace(',', ' ');
  S := replaceDoubleSpace(S);
  Grid1Frozens.Cells[3, i] := GetPhoneString(S);
end;

function TfrmMain.GetPhoneString(S: string): String;
var
  buf: string;
  temp: string;
  phoneString: string;
  comment: string;
  Phones: TStringList;
begin
  Phones := TStringList.Create;
  S := S + ' ';
  temp := S;
  while (temp.contains('(')) or (temp.contains(')')) = true do
  begin
    buf := pars(temp, '(', ')').trim;
    temp := pars(temp, '(' + buf + ')', '');
    if not isCityCode('(' + buf + (')')) then
    begin
      buf := buf.Replace('(', '');
      buf := buf.Replace(')', '');
      S := S.Replace('(' + buf + ')', buf);
    end;
  end;
  while not S.IsEmpty do
  begin
    buf := pars(S, '', ' ').trim;
    if isCityCode(buf) then
    begin
      S := pars(S, ' ', '');
      phoneString := buf + ' ';
      buf := pars(S, '', ' ').trim;
    end;
    if isPhone(buf) then
    begin
      phoneString := phoneString + buf;
      S := pars(S, ' ', '');
      buf := pars(S, '', ' ').trim;
    end;
    while isComment(buf) = true do
    begin
      if S.IsEmpty then
        break;
      buf := clearParenthesis(buf);
      buf := buf.Replace('-', ' ');
      comment := comment + ' ' + buf;
      comment := replaceDoubleSpace(comment);
      S := pars(S, ' ', '');
      buf := pars(S, '', ' ').trim;
    end;
    if not comment.IsEmpty then
      phoneString := phoneString + ' - ' + comment.trim;
    Phones.Add(phoneString);
    phoneString := '';
    comment := '';
  end;
  Result := Phones.Text.trim;
  FreeAndNil(Phones);
end;

function TfrmMain.replaceDoubleSpace(S: string): string;
begin
  while S.contains('  ') do
    S := S.Replace('  ', ' ');
  Result := S;
end;

function TfrmMain.clearParenthesis(S: string): string;
begin
  S := S.Replace('(', '');
  Result := S.Replace(')', '')
end;

function TfrmMain.isComment(S: string): Boolean;
var
  cityCode, phone: Boolean;
begin
  cityCode := isCityCode(S);
  phone := isPhone(S);
  Result := not(cityCode or phone);
end;

function TfrmMain.isPhone(S: string): Boolean;
begin
  S := S.Replace('-', '');
  S := S.Replace(' ', '');
  if S.Length >= 6 then
    Result := IsNumeric(S);
end;

function TfrmMain.isCityCode(S: string): Boolean;
begin
  if S.contains('(') or S.contains(')') then
    Result := IsNumeric(pars(S, '(', ')').Replace(' ', ''))
end;

procedure TfrmMain.InsertFrozen;
var
  i: Integer;
  cid: string;
  url: string;
  S: string;
  S1: string;
  s2: string;
begin
  Grid1Frozens.BeginUpdate;
  i := 0;
  repeat
    i := i + 1;
    if Grid1Frozens.Cells[1, i].contains('cid') = true then
    begin
      Grid1Frozens.AddNode(i, 1);
      cid := 'cid=' + pars(Grid1Frozens.Cells[1, i], 'cid=', '');
      url := AUTHCGI + cid;
      ForzenGetNumberPhone(i, url, S);
      S := IdHTTP1.Get(url);
      Grid1Frozens.Cells[1, i] := pars(S, '>Аккаунты договора', '(').TrimLeft;
      Grid1Frozens.Cells[2, i] := pars(S, '<br>', '</h2>')
        .Replace('&quot;', '"');
      if Pos('sid=', S) <> 0 then
      begin
        S := pars(S, '?cid=', '</table>');
        S1 := S;
        repeat
          s2 := pars(S1, ';sid=', '"');
          S1 := pars(S, 'sid=' + s2, '');
          S1 := pars(S1, '</a></td>', '');
          if Pos('Выделенка', pars(S1, 'title="', '</span>')) <> 0 then
          begin
            S1 := Grid1Frozens.Cells[1, i];
            Grid1Frozens.InsertChildRow(i);
            Grid1Frozens.Cells[1, i + 1] := s2;
            Grid1Frozens.AddCheckBox(1, i + 1, False, False);
          end;
        until Pos('</a></td>', S1) = 0;
      end;
    end;
  until i = Grid1Frozens.RowCount - 1;
  Grid1Frozens.EndUpdate;
end;

function TfrmMain.isNumber(S: string): string;
var
  ResString: string;
  i: Integer;
begin
  for i := 1 to S.Length do
  begin
    if (Ansistring(S)[i] in ['0' .. '9']) then
      ResString := ResString + S[i];
  end;
  Result := ResString.trim;
end;

function GetPhoneNumber(S: string): string;
var
  ResString: string;
  i: Integer;
begin
  for i := 1 to S.Length do
  begin
    if not(Ansistring(S)[i] in ['А' .. 'Я', 'а' .. 'я', 'A' .. 'Z', 'a' .. 'z',
      '(', ')']) then
      ResString := ResString + S[i];
  end;
  Result := ResString.trim;
end;

procedure TfrmMain.CloseAllServices(cid: string);
var
  url: string;
begin
  UnFreeze(cid);
  with list do
  begin
    Add('action=close-all');
    Add('cid=' + cid);
    Add('mon=' + FormatDateTime('yyyymm', Date));
    Add('confirm=1');
  end;
  url := SSWeb + 'services.cgi';
  IdHTTP1.Post(url, list);
  list.Clear;
end;

procedure TfrmMain.ClearFromList;
var
  AbonList: TStringList;
  i: Integer;
  cid: string;
begin
  AbonList := TStringList.Create;
  AbonList.LoadFromFile('C:\AbonList.txt');
  for i := 0 to AbonList.Count - 1 do
  begin
    try
      cid := AbonList.Strings[i];
      GetInfo(cid);
      Grid.SetCheckBoxState(1, 1, true);
      Grid.SetCheckBoxState(2, 1, true);
      Grid.SetCheckBoxState(3, 1, true);
      Grid.SetCheckBoxState(5, 1, true);
      Grid.Cells[4, 1] := '01.07.2017';
      CloseAllServices(cid);
      ClearSelectedAccs(cid);
      Application.ProcessMessages;
    except
      console(cid + ' - check');
    end;
  end;
  FreeAndNil(AbonList);
end;

procedure TfrmMain.frmcntrldtlnk1GetEditorValue(Sender: TObject;
  Grid: TAdvStringGrid; var AValue: string);
begin
  AValue := Gridph.Cols[0].Text.trim;
end;

procedure TfrmMain.frmcntrldtlnk1SetEditorValue(Sender: TObject;
  Grid: TAdvStringGrid; AValue: string);
var
  S, phone: string;
  i: Integer;
begin
  Gridph.ControlLook.NoDisabledButtonLook := true;
  S := AValue;
  Gridph.ClearAll;
  Gridph.RowCount := 10;
  Gridph.Cols[0].Text := S;
  for i := Gridph.LastRow downto 0 do
    if Gridph.Cells[0, i].Length = 0 then
      Gridph.RemoveRows(i, 1);
  for i := 0 to Gridph.LastRow do
    Gridph.AddButton(1, i, 60, 26, 'Call', haCenter, vaFull);
  Gridph.AutoSize := true;
  Gridph.Height := 25 * Gridph.RowCount;
end;

procedure TfrmMain.mnic1Click(Sender: TObject);

begin
  GoToLink('auth');
end;

procedure TfrmMain.mniE2Click(Sender: TObject);
begin

  GoToLink('services');
end;

procedure TfrmMain.mnit1Click(Sender: TObject);
begin
  ClearFromList;
end;

procedure TfrmMain.N1Click(Sender: TObject);
begin
  GoToLink('saldo');
end;

end.
