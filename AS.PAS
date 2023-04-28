{   ASPEKTRUM.PAS    ->   ACAD V2.5

    berechnet das HFS-Spektrum eines Elementes in Abhängigkeit
    der A- und B-Faktoren bei bekannten Drehimpulseigenwerten
    ( Ju, Jo, I ) für jeweils den unteren und oberen Zustand.

    Zusätzlich können max. 6 gerade Isotope eingegeben werden.
    Die F-, K-, und Energiewerte W für jeweils den unteren bzw.
    oberen Zustand werden berechnet und ausgegeben.

    Die Linien E(Fo,Fu) lassen sich als einzelne Lorentz- bzw.
    Gaussprofile ausgeben, oder auf Wunsch als Summenprofil am
    Bildschirm oder auf dem Drucker anzeigen.

    Für die Druckerausgabe benötigt man bei der HERCULES-Karte das
    Systemprogramm HGC.COM mit den Optionen (HGC FULL HPRINT).
    Hiernach ist der residente Teil des Print-Screen Hardcopy-
    Programms auf die Grafikseite "umgebogen", und bei drcken der
    tastenkombination <Shift>+<Prnt-Scr>+<n> erscheint ein Hardcopy
    auf dem jeweils angeschlossenem Drucker.
    ( n = 0, Ausdruck der Grafikseite 0 quer im Format DIN A4 )

    Diese Programmversion erzeugt eine Datei SPEKTRUM.CAD aus der
    das Transferprogramm SACAD eine Daten-Austauschdatei SPEKTRUM.DXF
    für AutoCAD (TM) V2.5 erzeugt. Nachdem man AutoCAD aufgerufen hat,
    kann der Benutzer mit dem DXFIN-Befehl das berechnete Spektrum
    laden und nach Belieben editieren... und anschließend ausplotten.

    Für weitere Informationen siehe Datei SPEKTRUM.TXT


    (C) 1986/1987  Institut für Angewandte Physik
                   der Universität Bonn

    Thomas Fabula, Wolfgang Rupprecht

}

program spektrum;

{ Einbinden der GRAPHIX Turbo-Toolbox notwendigen Zeichenroutinen,   }
{ GRAPHIX.SYS angepasst auf Hercules-Grafikkarte (720x348 pixel)     }
{ d.h. zur Installation vorher GRAPHIX.HGH nach GRAPHIX.SYS kopieren.}

{$I typedef.sys}          { System unabhängige Typendefinitionen     }
{$I graphix.sys}          { System abhängige Definitionen & Routinen }
{$I kernel.sys}           { System unabhängige Support Routinen      }

{$I sdeclare.inc}         { Deklarationen (const, type, var)         }
{$I njsymbol.inc}         { Berechnung der nj-Symbole    (T.Brenner) }
{$I realin.inc}           { REAL-Zahl Einleseroutine                 }
{$I asfile.inc}           { Disketten I/O-Routinen für Parameter     }
                          { inkl. AutoCAD Dateigeneration...         }
{$I asparam.inc}          { Parameter editieren                      }
{$I sfunct.inc}           { Programmfunktionen: Drucken,Plotten,etc. }

const acadatname = 'SPEKTRUM.CAD';
var   acad : text;

{------------------------------}
{-----   Lorentzprofil   ------}
{------------------------------}

function lorentz(var energie,e_0,intensy : real) : real;
var zaehler,nenner : real;
begin { lorentz }
  zaehler:=sqr(FWHM);
  nenner:=sqr(energie - e_0);
  nenner:=nenner+0.25*zaehler;
  if (nenner=0) then
    begin
      writeln(#7,#7,#7);
      writeln('Lorentz: Division durch Null');
      halt;
    end { if };
  lorentz:=intensy*zaehler/nenner;
end { lorentz };

{----------------------------}
{-----   Gaussprofil   ------}
{----------------------------}

function gauss(var energie,e_0,intensy : real) : real;
var ar,argum : real;
begin { gauss }
  argum:=abs(energie-e_0);
  if (FWHM=0) then
    begin
      writeln(#7,#7,#7);
      writeln('Gauss:  FWHM = Null');
      halt;
    end { if };
  argum:=argum/FWHM;
  ar:=sqr(argum);
  gauss:=intensy*exp(-ar);   { -ar/2 }
end { gauss };

{-------------------------------------------------}
{-------  Berechnen eines Lorentzprofils  --------}
{-------------------------------------------------}

procedure lorentz_profil(var resonance,inten:real; switchi:boolean);
begin { lorentz_profil }
  ijk:=1;
  ylo:=0;
  xlo:=x_links;
  deltalo:=abs(x_links-x_rechts)/aufloesung;
  { 0        <= Y-Achse <= 1000     }
  { x_links  <  X-Wert  <  x_rechts }
  repeat
    ylo:=0.25*lorentz(xlo,resonance,inten);
    ysum[ijk]:=ysum[ijk]+ylo;  { Aufsummierung des Signals }
    ylo:=untergrund+ylo;
    { Sicherheitsabfrage bzgl. DefineWorld... }
    if (ylo>875) then ylo:=875;
    if switchi then DrawPoint(xlo,ylo);
    xlo:=xlo + deltalo;   { X-Wert erhöhen }
    ijk:=ijk+1;           { Laufindex für Summe erhöhen }
  until (xlo > x_rechts);
end { lorentz_profil };

{-----------------------------------------------}
{-------  Berechnen eines Gaussprofils  --------}
{-----------------------------------------------}

procedure gauss_profil(var resonanc,inte:real; switch:boolean);
begin { gauss_profil }
  ijk:=1;
  if switch then
   begin
     gotoxy(3,23);
     write('Gauss');
     gotoxy(73,2);
     write('Gauss');
   end { if };
  ylo:=0;
  xlo:=x_links;
  deltalo:=abs(x_links-x_rechts)/aufloesung;
  { 0        <= Y-Achse <= 1000     }
  { x_links  <  X-Wert  <  x_rechts }
  repeat
    ylo:=gauss(xlo,resonanc,inte);
    ysum[ijk]:=ysum[ijk]+ylo;  { Aufsummierung des Signals }
    ylo:=untergrund+ylo;
    if switch then DrawPoint(xlo,ylo);
    xlo:=xlo + deltalo;   { X-Wert erhöhen }
    ijk:=ijk+1;           { Laufindex für Summe erhöhen }
  until (xlo > x_rechts);
end { gauss_profil };

{---------------------------------------------}
{-------  Berechnen der Intensitäten  --------}
{-------  Intens(ju,jo,fu,fo,ikern)   --------}
{-------   ber die sechsJ-Symbole    --------}
{---------------------------------------------}

function intens(var juu,joo,fuu,foo,ikernspin : real) : real;
var temp1,temp2,xq : real;
begin { intens }
  temp1:=2*foo+1;
  temp2:=2*fuu+1;
  temp1:=temp1*temp2;
  { SechsJ-Symbole siehe Datei : njsymbol.inc }
  xq:=sechsJ(joo,foo,ikernspin,fuu,juu,1);
  intens:=temp1*xq*xq;
end { intens };


{----------------------------------------------}
{-------  Skalierung der Intensitäten  --------}
{----------------------------------------------}

procedure skal_intensity;
{ Skalierung der Intensitäten, suchen von Int(max) }
label ende;
var   max_intensi,such_intensi : real;
      hfsum                    : real;
      anz                      : integer;
      hfsintens                : array [1..40] of real;
begin { skal_intensity }
  tabs(t);
  writeln('Skalierung der Intensitäten auf 100% ... !');
  max_intensi:=0.001;
  for n:=0 to maxxu do
  begin
    for m:=0 to maxxo do
    begin
      if ( ( fu[n]-fo[m] = 0) or (abs( fu[n] - fo[m]) = 1) ) then
      begin
        {  maximale Linien-Intensitäten  }
        such_intensi:=intens(ju,jo,fu[n],fo[m],ikern)*100;
        if (such_intensi > max_intensi) then max_intensi := such_intensi;
      end { if };
    end { for };
  end { for };
  skal_intensi := 100 / max_intensi;

  { Berechnung der Intensitäten -> Skalierungsfaktor: gint }
  anz:=0;
  for n:=0 to maxxu do
  begin
    for m:=maxxo downto 0 do
    begin
      if ( ( fu[n]-fo[m] = 0) or (abs( fu[n] - fo[m]) = 1) ) then
         begin
           if ( ( fu[n]=0) and (fo[m]=0) ) then goto ende;
           anz:=anz+1;
           hfsintens[anz]:=intens(ju,jo,fu[n],fo[m],ikern)*skal_intensi;
           ende:
         end { if };
    end { for };
  end { for };

  { Summe der Intensitäten = Häufigkeit des ungeraden Isotops: hf }
  hfsum:=0;
  for i:=1 to anz do  hfsum:=hfsum + hfsintens[i];
  { Skalierungsfaktor fr gerade Isotope }
  gint:=hfsum / hf;

end { skal_intensity };


                {--------------------------------------------}
                {--  Abspeichern der berechneten Werte     --}
                {--  Fu(n), Fo(n), Wu(n), Wo(n) und E(n,m) --}
                {--  erfolgt bei der Berechnung...         --}
                {--------------------------------------------}

{-----------------------------------------}
{-------  Berechnen der F-Werte:  --------}
{----   F = I + J , ... , abs(I - J)   ---}
{-----------------------------------------}

procedure berechne_f;
begin { berechne_f }
  { Abspeichern der berechneten Werte }
  if save then
   begin
     writeln('Spektrumdaten werden gespeichert in der Datei : ',datname);
     assign(filvar,datname);
     rewrite(filvar);             { gleichnamige Datei wird überschrieben }
     {  Parameter  }
     writeln(filvar,'Hfs-Spektrumdaten:');
     writeln(filvar,'==================');
     writeln(filvar,'Element   : ',element);
     writeln(filvar,'Uebergang : ',vonzustand,' -> ',nachzustand);
     writeln(filvar);
     writeln(filvar,'Parameter: ',hfsisotop:5);
     writeln(filvar,'----------');
     writeln(filvar,'Ao [MHz] = ',ao:15:6);
     writeln(filvar,'Au [MHz] = ',au:15:6);
     writeln(filvar,'Bo [MHz] = ',bo:15:6);
     writeln(filvar,'Bu [MHz] = ',bu:15:6);
     writeln(filvar,'Ju       = ',ju:10:1);
     writeln(filvar,'Jo       = ',jo:10:1);
     writeln(filvar,'I        = ',ikern:10:1);
     writeln(filvar,'Rel.Hfgk.= ',hf:10:2,' [%]');
     writeln(filvar,'Schwpkt. = ',swp:10:4,' [MHz]');
     writeln(filvar);
     writeln(filvar,'Geradzahlige Isotope:');
     writeln(filvar,'---------------------');
     for i:=1 to isoanzahl do
     begin
       write(filvar,iso[i],' :   Frequ. = ',frequ[i]:15:4,' [MHz]  ');
       writeln(filvar,'(',hauf[i]:5:2,'%)');
     end;
     {  F-Werte  }
     writeln(filvar);
     writeln(filvar,'F-Werte:');
     writeln(filvar,'--------');
   end;
  tabs(t);
  { Berechnung für den unteren Zustand }
  j:=ju;
  if j>=ikern then max:=ikern
  else max:=j;
  maxxu:=trunc(2*max+1+0.1);     { Integerzahl aus Drehimpuls machen }
  maxxu:=maxxu-1;                { und sicher gehen, das nicht       }
  for n:=0 to maxxu do           { abgerundet wird                   }
  begin
    fu[n] := ikern + j - n;
    if test then WRITELN('Fu(',n,') = ',FU[N]:10:1);
    if save then WRITELN(filvar,'Fu(',n,') = ',FU[N]:10:1);
  end { for };
  tabs(t);
  if save then writeln(filvar);
  { Berechnung fr den oberen Zustand }
  j:=jo;
  if j>=ikern then max:=ikern
  else max:=j;
  maxxo:=trunc(2*max+1+0.1);      { Integerzahl aus Drehimpuls machen }
  maxxo:=maxxo-1;
  for n:=0 to maxxo do
  begin
    fo[n] := ikern + j - n;
    if test then WRITELN('Fo(',n,') = ',FO[N]:10:1);
    if save then WRITELN(filvar,'Fo(',n,') = ',FO[N]:10:1);
  end { for };
end { berechne_f };

{-----------------------------------------}
{------  Berechnen der K-Werte:  ---------}
{----  K = F(F+1) - I(I+1) - J(J+1)  -----}
{----        ( Casimir )             -----}
{-----------------------------------------}

procedure berechne_k;
begin { berechne_k }
  {  K-Werte  }
  if save then
    begin
      writeln(filvar);
      writeln(filvar,'K(F)-Werte:');
      writeln(filvar,'-----------');
    end;
  tabs(t);
  { Berechnung für den unteren Zustand }
  for n:=0 to maxxu do
  begin
    j:=ju;
    f:=fu[n];
    ku[n]:=f*(f+1)-ikern*(ikern+1)-j*(j+1);
    if test then writeln('Ku(',fu[n]:3:1,') = ',ku[n]:10:1);
    if save then writeln(filvar,'Ku(',fu[n]:3:1,') = ',ku[n]:10:1);
  end { for };
  tabs(t);
  if save then
   begin
     writeln(filvar);
     writeln(filvar,'K(F)-Werte:');
     writeln(filvar,'-----------');
     writeln(filvar);
   end;
  { Berechnung für den oberen Zustand }
  for n:=0 to maxxo do
  begin
    j:=jo;
    f:=fo[n];
    ko[n]:=f*(f+1)-ikern*(ikern+1)-j*(j+1);
    if test then writeln('Ko(',fo[n]:3:1,') = ',ko[n]:10:1);
    if save then writeln(filvar,'Ko(',fo[n]:3:1,') = ',ko[n]:10:1);
  end { for };
end { berechne_k };

{--------------------  Berechnen der W-Werte:  ------------------------}
{   W = 1/2h ( K*A + (3/4 K(K+1)-I(I+1)J(J+1))*B/(I(2I-1)J(2J-1)) )    }
{                Energiewerte W in [MHz] - Einheiten                   }
{                h  =    Planck'sches Wirkungsquantum                  }
{----------------------------------------------------------------------}
procedure berechne_w;

  function w_zahl(var a,b,k,ij,ji : real):real;
  { Berechnung des HFS-Niveau-Energiewertes }
  var  sum1,zaehler,nenner,wzahl : real;
  begin { w_zahl }
    sum1:=k*a*0.5;
    zaehler:=ij*(ij+1)*ji*(ji+1);
    zaehler:=0.75*k*(k+1)-zaehler;
    if b=0
      then nenner:=1
      else nenner:=2*ij*(2*ij-1)*ji*(2*ji-1);
    { Falls  I,J = 1/2  dann  B = 0 }
    if ( (ij=0.5) or (ji=0.5) )
      then wzahl:=zaehler
      else wzahl:=zaehler*b/nenner;
    w_zahl:=(sum1+wzahl)*h;
  end { w_zahl };

begin { berechne_w }
  {  W-Werte  }
  tabs(t);
  if save then
    begin
      writeln(filvar);
      writeln(filvar,'W(F)-Werte [MHz]:');
      writeln(filvar,'-----------------');
    end;
  { Berechnung für den unteren Zustand  }
  for m:=0 to maxxu do
  begin
    f:=fu[m];
    k:=ku[m];
    wu[m]:=w_zahl(au,bu,k,ikern,ju);
    if test then writeln('Wu(',fu[m]:3:1,') = ',wu[m]:15:6);
    if save then writeln(filvar,'Wu(',fu[m]:3:1,') = ',wu[m]:15:6);
  end { for };
  tabs(t);
  if save then writeln(filvar);
  { Berechnung für den oberen Zustand  }
  for m:=0 to maxxo do
  begin
    f:=fo[m];
    k:=ko[m];
    wo[m]:=w_zahl(ao,bo,k,ikern,jo);
    if test then writeln('Wo(',fo[m]:3:1,') = ',wo[m]:15:6);
    if save then writeln(filvar,'Wo(',fo[m]:3:1,') = ',wo[m]:15:6);
  end { for };
end { berechne_w };

{----------------  Berechnen der Energiezuordnungen  ------------------}
{                  unter Beachtung der Auswahlregeln:                  }
{                                                                      }
{                       delta(F) = 0, +1, -1     und                   }
{                  šbergang F = 0 nach F = 0  verboten                 }
{                                                                      }
{                       Wo(n) - Wu(m)  ==>  E(n,m)                     }
{                Energiewerte W,E in [MHz] - Einheiten                 }
{----------------------------------------------------------------------}
procedure energien_zuordnung;
label ende;
var  ft,iii : integer;
begin { energien_zuordnung }
  {  Energiewerte E(n,m)  }
  if save then
    begin
      writeln(filvar);
      writeln(filvar,'E(Fo,Fu)-Werte [MHz]:');
      writeln(filvar,'---------------------');
    end;
  iii:=0; ft:=46;
  energmin:=10000.0; energmax:=0;
  tabs(ft);
  for n:=0 to maxxu do
  begin
    for m:=0 to maxxo do
    begin
      if ( ( fu[n]-fo[m] = 0) or (abs( fu[n] - fo[m]) = 1) ) then
      begin
        if ( ( fu[n]=0) and (fo[m]=0) ) then goto ende;
        energie[m,n] := wo[m] - wu[n];
        linien_anzahl:=linien_anzahl+1;
        if test then
          write('E(',fo[m]:3:1,',',fu[n]:3:1,') = ',energie[m,n]:15:6);
        {  Linien-Intensitäten  }
        intensi:=skal_intensi*intens(ju,jo,fu[n],fo[m],ikern)*100;
        writeln('   (Int : ',intensi:6:2,'%)');
        {  Aussortieren von Emax und Emin  }
        if energmin >= energie[m,n] then energmin:=energie[m,n]+swp;
        if energmax <= energie[m,n] then energmax:=energie[m,n]+swp;
        if save then
        begin
          write(filvar,'E(',fo[m]:3:1,',',fu[n]:3:1,') = ',energie[m,n]:15:6);
          writeln(filvar,'   (Int : ',intensi:6:2,'%)');
        end;
        ende:
      end { if };
    end { for };
    writeln;
end { for };
  tabs(ft);
  {  Berechnung der Hfs-Aufspaltung  }
  hfsaufsp:=(abs(energmin)+abs(energmax))*0.001;

  if save then
    begin
      writeln(filvar);
      writeln(filvar,'Anzahl Linien   = ',linien_anzahl:3);
      writeln(filvar,'Energie [min]   = ',energmin:15:6,'  [MHz]');
      writeln(filvar,'Energie [max]   = ',energmax:15:6,'  [MHz]');
      writeln(filvar,'Hfs-Aufspaltung = ',hfsaufsp:15:8,'  [GHz]');
      writeln(filvar);
      writeln(filvar,'Kommentar :');
      writeln(filvar,'-----------');
      writeln(filvar,kommentar);
      { Ende des Abspeicherns }
      close(filvar);
    end;

  if test then
    begin
      writeln('Hfs-Aufspaltung   = ',hfsaufsp:15:8,' [GHz]');
      writeln('Anzahl der Linien : ',linien_anzahl:2);
      tabs(ft);
      write('Bitte <RETURN> drücken : ');
      readln(ch);
    end { if };
end { energien_zuordnung };

{----------------------------------------}
{-------   Hfs-Spektrum drucken  --------}
{----------------------------------------}
procedure drucken;
var hc : char;
begin
  gotoxy(62,24); write('<H>ardcopy     : ');
  readln(hc);
  hc:=upcase(hc);
  gotoxy(79,24); write(hc);
  if (hc='H') then hardcopy(FALSE,1);    { TURBO-PASCAL Druckertreiber }
end;

{--------------------------------------}
{-------  Linien aufsummieren  --------}
{--------------------------------------}

procedure summation(var doit:boolean);
{ Aufsummiertes Spektrum einzeichnen }
var  kl     : integer;
     ysumme : real;
     yfirst,ysecond : real;
     ysumacad       : real;
begin { summation }
  if doit then
    begin
      if profil='L' then
      begin
        gotoxy(73,2); write('Lorentz');
      end;
      if profil='G' then
      begin
        gotoxy(73,2); write('Gauss  ');
      end;
      gotoxy(73,3); write('- Summe');
    end { if };
  ylo:=0;
  xlo:=x_links;
  deltalo:=abs(x_links-x_rechts)/aufloesung;
  kl:=1;
  { Spektrumkoordinaten sichern }
  if cad then writeln(acad,'22222');
  repeat
    { Aufsummiertes Signal einzeichnen        }
    ysumme:=untergrund+(ysum[kl]);
    { Kennzeichnen der Punkte die außerhalb liegen... }
    if (ysumme>850) then
      begin
        ysumme:=875;
        DrawPoint(xlo,ysumme);
      end;
    yfirst:=untergrund+ysum[kl];
    ysecond:=untergrund+ysum[kl+1];
  { ACAD-DXF-Datei Spektrum speichern: X-, Y-Koordinaten }
    ysumacad:=ysum[kl]*0.25;
    if cad then writeln(acad,xlo:20:4,ysumacad:20:4);
    { Sicherheitsabfrage bzgl. DefineWorld... }
    if (yfirst  > 850) then yfirst:=850;
    if (ysecond > 850) then ysecond:=850;
    DrawLine(xlo,yfirst,xlo+deltalo,ysecond);
    xlo:=xlo + deltalo;   { X-Wert erhöhen }
    kl:=kl+1;             { Laufindex für Summe erhöhen }
  until ( (xlo > x_rechts) or (kl>=aufloesung) );
  drucken;
  gotoxy(62,24); write('        <<RETURN>>');
  readln(ch);
  LeaveGraphic;
  if cad then close(acad);
end { summation };

{--------------------------------------}
{-------  Y-Achse einzeichnen  --------}
{--------------------------------------}

procedure y_axis;
var  iu : integer;
     x_achse,y_einh,dd : real;
begin { y_axis }
  dd:=delta_X/150;
  y_einh:=0.10*grafik_skal+205;
  x_achse:=x_min-offset/2;            { 0  <= Y-Achse <= 100 % }
  drawline(x_achse,205,x_achse,790);  { Achse einzeichnen }

  { Markierungen }
  for iu:=1 to 10 do
  begin
    DrawLine(x_achse-dd,y_einh,x_achse+dd,y_einh);
    y_einh:=y_einh+0.10*grafik_skal;
  end { for };

  gotoxy(6,6);  write(#30);      { Pfeil einzeichnen }
  gotoxy(2,5);  write('Intens.');
  gotoxy(2,6);  write('[%]');
  gotoxy(2,8);  write('100');
  gotoxy(2,13); write(' 60');
  gotoxy(2,18); write(' 20');
end { y_axis };

{-------------------------------------}
{-------  Grafik vorbereiten  --------}
{-------------------------------------}

procedure begin_grafik;
var gintens : real;
begin { begin_grafik }
  null:=0;
  profanz:=0;
  delta_X:=abs(energmax)+abs(energmin);
  offset:=delta_X*0.2;
  x_min:=energmin;
  x_max:=energmax;
  InitGraphic;                            {init the system and screen}
  SelectScreen(1);
  ClearScreen;                       { Wertebereiche für Grafik:     }
  x_links:=x_min-offset;             { 0      <= Y-Achse <= 1000     }
  x_rechts:=x_max+offset;            { x_links < X-Wert  <  x_rechts }
  DefineWorld(1,x_links,0,x_rechts,1000); {define a world for drawing}
  SelectWorld(1);                         {select it}
  SelectWindow(1);
  SetBackground(0);
  DrawBorder;
  DrawLine(x_links,200,x_rechts,200);      {  doppelte Energieachse  }
  DrawLine(x_links,205,x_rechts,205);      {  [MHz] zeichnen         }

  DrawLine(x_links,870,x_rechts,870);      { Fenster für Fu/Fo-Werte }
  DrawLine(x_links,850,x_rechts,850);
  y_axis;                                  { Y-Achse einzeichnen     }

  { Hfs-Isotop kennzeichnen }
  SetLineStyle(3);                         { gestrichelte Linie      }
  DrawLine(swp,200,swp,870);       {  Hfs-Linienschwerpunkt zeichnen }

  gotoxy(3,2); write(element);                {  Elementbezeichnung  }
  writeln(',  Übergang : ',vonzustand,' -> ',nachzustand);
  gotoxy(55,2); write(' SPEKTRUM ');
  gotoxy(55,3); write('Simulation');
  gotoxy(65,21); write('Energie [MHz]');

  { Gerade Isotope einzeichnen }
  SetLineStyle(1);                           { gepunktete Linie      }
  for i:=1 to isoanzahl do
  begin
    DrawLine(frequ[i],205,frequ[i],870);        { Linienschwerpunkte }
    { gint => siehe: procedure skal_intensity }
    gintens:=hauf[i]*grafik_skal*gint;
    Lorentz_profil(frequ[i],gintens,FALSE);     { Lorentzprofil      }
  end;
  SetLineStyle(0);                        { durchgezogene Linie      }
  repeat
    gotoxy(3,22); write('Profilart <L>orentz / <G>auss : ');
    readln(profil);
    profil:=upcase(profil);
    gotoxy(35,22); write(profil);
  until ((profil='L') or (profil='G'));
  writeln;
end { begin_grafik };

{---------------------------------------}
{-------   Grafik abschließen   --------}
{---------------------------------------}
procedure end_grafik;
var art : char;
    zeige : boolean;
begin { end_grafik }
  { Löschen der Abfrage }
  gotoxy(3,22);  write('                                     ');
  gotoxy(3,23);  write('                                     ');
  gotoxy(3,22);  write('Au = ',au:11:6);
  gotoxy(23,22); write('Ao = ',ao:11:6);
  gotoxy(3,23);  write('Bu = ',bu:11:6);
  gotoxy(23,23); write('Bo = ',bo:11:6);
  gotoxy(3,24);  write('Ju = ',ju:2:1);
  gotoxy(18,24); write('Jo = ',jo:2:1);
  gotoxy(32,24); write('I = ',ikern:2:1);
  gotoxy(42,22); write('E(min) = ',energmin:7:3);
  gotoxy(42,23); write('E(max) = ',energmax:7:3);
  gotoxy(42,24); write('Anzahl = ',linien_anzahl:3);
  gotoxy(62,22); write('Untergrund = ',unt:3:0);
  gotoxy(62,23); write('FWHM [MHz] = ',FWHM:3:0);
  if ((profil='L') or (profil='G'))
   then
     begin
       zeige:=TRUE;
       summation(zeige);
       exit;
     end { if }
   else
     begin
       drucken;
       leavegraphic;
     end { else };
  leavegraphic;
 end { end_grafik };

{----------------------------------------------------------------------}
{ Zeichnet die gefundenen HFS-Übergangsfrequenzen auf den Bildschirm.  }
{----------------------------------------------------------------------}

procedure zeige_Spektrum_CRT;
label ende;
var  switcher : boolean;
     yint     : real;
begin { zeige_spektrum_crt }
  begin_grafik;
  { Zeichnen der E[n,m] auf dem Bildschirm }
  { ACAD-DXF-Datei erzeugen }
   if cad then
    begin
      assign(acad,acadatname);
      rewrite(acad);
      { Hfs-Linien aufzeichnen }
      writeln(acad,'11111');
    end;
  for n:=0 to maxxu do
  begin
    for m:=maxxo downto 0 do
    begin
      if ( ( fu[n]-fo[m] = 0) or (abs( fu[n] - fo[m]) = 1) ) then
         begin
           if ( ( fu[n]=0) and (fo[m]=0) ) then goto ende;
           profanz:=profanz+1;
      {  HFS-šbergang einzeichnen:    }
           x:=energie[m,n]+swp;
      {  Linien-Intensitäten  }
           intensity:=intens(ju,jo,fu[n],fo[m],ikern)*skal_intensi;
           yint:=intensity*100;
           intensity:=intensity*grafik_skal;
      { Markierungen am oberen Rand setzen }
           DrawLine(x,850,x,870);
      { Linienschwerpunkt einzeichnen }
           DrawLine(x,205,x,205+intensity);
      { ACAD-DXF-Datei erzeugen }
        if cad then writeln(acad,x:15:4,yint:10:2);

           { Einzel-Linien suchen & einzeichnen }
           gotoxy(11,23);
           write(#16,' Profil No. : ',profanz:2);
             case profil of
               'L' : begin
                       gotoxy(3,23);  write('Lorentz');
                       lorentz_profil(x,intensity,FALSE);
                     end;
               'G' : begin
                       gotoxy(3,23);  write('Gauss  ');
                       gauss_profil(x,intensity,FALSE);
                     end;
             end { of case };
           ende:
         end { if };
    end { for };
  end { for };
  end_grafik;
end { zeige_spektrum_crt };

{===================    H a u p t p r o g r a m m    ==================}

begin { main }
  t:=40;
  test:=TRUE;
  save:=TRUE;
  cad:=FALSE;
  ladefacarr;  { Fakultäten-Array belegen }
  parameter_load;
  profil_parameter_load;
  untergrund:=untergrund+205;
  intro;
  repeat
    { Summen initialiesieren }
    for i:=1 to aufloesung do ysum[i]:=0;
    linien_anzahl:=0;
    parameter_eingeben;
    werte_speichern;
    clrscr;
    berechne_f;
    berechne_k;
    berechne_w;
    skal_intensity;
    energien_zuordnung;
    zeige_spektrum_CRT;
    write('Noch eine Zuordnung (J/N) ? ');
    readln(ch);
    ch:=upcase(ch);
  until ch='N';
  parameter_save;
  profil_parameter_save;
end { main }.

{====================   P r o g r a m m - E n d e    ==================}
