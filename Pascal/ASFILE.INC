{  ASFILE.INC

   ließt die Parameter von Disk und speichert
   sie wieder ab.
   Erzeugt eine Datei für AutoCAD : SPEKTRUM.CAD,
   die vom Transferprogramm SACAD bearbeitet werden
   kann.

}

var  cad : boolean;

{-----------------------------------------}
{-----  Kosmetik der Ausgaberoutine   ----}
{-----------------------------------------}

procedure tabs(var tabzahl:integer);
begin
  if test then
  begin
    for ij:=1 to tabzahl do write(#196);
    writeln;
  end;
end;

{-----------------------------------------}
{-------  Parameterdatei einlesen   ------}
{-----------------------------------------}

procedure parameter_load;

  { Fehlermeldung: Parameter-Datei nicht in Ordnung }
  procedure file_error;
  begin
  {if ioresult then
    begin
      writeln(#7,#7,#7,meldung_param);
      exit;
    end;}
  end;

begin
  { Parameterdatei einlesen }
  meldung_param:='Parameterdatei SPEKTRUM.PAR nicht in Ordnung !';
  pardatei:='SPEKTRUM.PAR';
  assign(filvar,pardatei);
  reset(filvar);
  readln(filvar);     { Die ersten beiden Zeilen ueberlesen }
  readln(filvar);
  readln(filvar,defaultelement);
  readln(filvar,hfsisotop);
  readln(filvar,defaultvon);
  readln(filvar,defaultnach);
  readln(filvar,ao,au);
  readln(filvar,bo,bu);
  readln(filvar,jo,ju,ikern);
  readln(filvar,swp,hf,isoanzahl);
  for i:=1 to isoanzahl do
    readln(filvar,iso[i],frequ[i],hauf[i]);
  readln(filvar,kommentar);
  close(filvar);
  file_error;
end;

{-----------------------------------------}
{-------  Parameterdatei speichern  ------}
{-----------------------------------------}

procedure parameter_save;
begin
  clrscr;
  gotoxy(1,3);
  write('Letztgltiger Parametersatz wird gespeichert in SPEKTRUM.PAR');
  gotoxy(1,9); write('                                                ');
  gotoxy(1,9);
  write('Kommentar zum Datensatz:');
  gotoxy(1,10);
  for ij:=1 to 80 do write(#205);
  gotoxy(1,12);
  for ij:=1 to 80 do write(#205);
  gotoxy(1,11);
  write(kommentar);
  gotoxy(1,11);
  readln(kom);
  if (kom<>'') then kommentar:=kom;

  pardatei:='SPEKTRUM.PAR';
  assign(filvar,pardatei);
  rewrite(filvar);
  writeln(filvar,'Spektrumparameter: (Element/Hfs-Iso./unt. Zust./ober. Zust./');
  writeln(filvar,'Ao,Au/Bo,Bu/Jo,Ju,I/Schwpkt.,[%],Anz.Iso./Iso.Bez.,Frequ,[%])');
  writeln(filvar,element);
  writeln(filvar,hfsisotop);
  writeln(filvar,vonzustand);
  writeln(filvar,nachzustand);
  writeln(filvar,ao:12:4,au:12:4);
  writeln(filvar,bo:12:4,bu:12:4);
  writeln(filvar,jo:5:1,ju:5:1,ikern:5:1);
  writeln(filvar,swp:12:5,hf:6:2,isoanzahl:4);
  for i:=1 to isoanzahl do
    writeln(filvar,iso[i],' ',frequ[i]:12:4,hauf[i]:6:2);
  writeln(filvar,kommentar);
  close(filvar);
end;

{--------------------------------------}
{-------  Profilparameter lesen  ------}
{--------------------------------------}

procedure profil_parameter_load;
begin
  profildatei:='SPROFIL.PAR';
  assign(filvar,profildatei);
  reset(filvar);
  readln(filvar);
  readln(filvar,untergrund);
  readln(filvar,FWHM);
  readln(filvar,aufloesung);
  close(filvar);
end;

{------------------------------------------}
{-------  Profilparameter schreiben  ------}
{------------------------------------------}

procedure profil_parameter_save;
begin
  gotoxy(1,4);
  write('Letztgültige Profilparameter werden gespeichert in SPROFIL.PAR');
  untergrund:=untergrund-205;
  profildatei:='SPROFIL.PAR';
  assign(filvar,profildatei);
  rewrite(filvar);
  writeln(filvar,'Profilparameter (Untergrund/FWHM/Aufloesung):');
  writeln(filvar,untergrund:4:2);
  writeln(filvar,FWHM:4:2);
  writeln(filvar,aufloesung:4);
  close(filvar);
  if cad then
   begin
     gotoxy(1,5);
     write('Plotkoordinaten für AutoCAD V2.5 ');
     write('werden gespeichert in SPEKTRUM.CAD');
   end;
  gotoxy(1,14);
end;

