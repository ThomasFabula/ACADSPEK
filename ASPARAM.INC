{  ASPARAM.INC

   Parameter einlesen für das SPEKTRUM-Programm
   A-, B-Faktoren    >  für jeweils den
   J-Drehimpulse     >  unteren/oberen Zustand
   I-Kernspin
   und für die Parameter der geradzahligen Isotope
}

var  unt       : real;
     xxantwort : char;

{-----------------------------------------}
{--- Anfangsroutine Intro: allg. Daten  --}
{-----------------------------------------}

procedure intro;
var  ok : char;
     strx,strx1,strx2 : str12;
begin
  clrscr;
  highvideo;
  write(#201); for ij:=1 to 78 do write(#205); write(#187);
  gotoxy(1,2);
  write(#186,'  ASPEKTRUM   -   Berechnung des Spektrums eines Elementes ');
  gotoxy(80,2); write(#186);
  gotoxy(1,3);
  write(#200); for ij:=1 to 78 do write(#205); write(#188);
  lowvideo;

  gotoxy(1,19);highvideo;
  write('*** Plotten des Spektrums mit Hilfe von AutoCAD V2.5 ***');
  gotoxy(1,15);lowvideo;

  for ij:=1 to 80 do write(#205);
  gotoxy(1,17);
  for ij:=1 to 80 do write(#205);
  gotoxy(1,16);
  write(kommentar);

  repeat
    gotoxy(1,5);
    write('Bitte die Daten des Hfs-Isotops eingeben :');
    gotoxy(1,7);
    write(' Welches Element (z.B.: Zirkon) : ',defaultelement);
    gotoxy(35,7);
    readln(strx);
    if ((strx<>defaultelement) and (length(strx)<>0))
     then element:=strx
     else element:=defaultelement;
    gotoxy(1,9);
    writeln('Welcher Übergang soll betrachtet werden ?');
    gotoxy(1,10);
    write(' Übergang von Zustand           : ',defaultvon);
    gotoxy(35,10);
    readln(strx1);
    gotoxy(1,11);
    write(' nach Zustand                   : ',defaultnach);
    gotoxy(35,11);
    readln(strx2);
    if ((strx1<>defaultvon) and (length(strx1)<>0))
     then vonzustand:=strx1
     else vonzustand:=defaultvon;
    if ((strx2<>defaultvon) and (length(strx2)<>0))
     then nachzustand:=strx2
     else nachzustand:=defaultnach;
    gotoxy(1,14);
    write(#7);
    write('Alle Parameter richtig (J/N) ? ');readln(ok);
    ok:=upcase(ok);
  until (ok='J');
end;

{-----------------------------------------}
{----  Eingaberoutine der Parameter  -----}
{-----------------------------------------}

procedure parameter_eingeben;
var  l,zei :integer;
     xao,xau,xbo,xbu,xjo,xju,xikern,
     xunt,xfwhm,xaufl : real;
     strx : str8;

begin
  nulltestok:=FALSE;            { Sicherheitshalber: Parameter = Null }
  repeat
    clrscr;
    writeln('Bitte Parameter eingeben (u=unterer/o=oberer Zustand):');
    writeln('(A-, B-Faktoren in [MHz], Drehimpulse in h-Vielfachen)');
    repeat
    { Parameter aus SPEKTRUM.PAR abfragen }
      zei:=5;

    { Daten des Isotops mit Hfs }
      gotoxy(1,zei-1); write('Hfs-Isotop : ',hfsisotop);
      gotoxy(11,zei-1); readln(strx);
      if (length(strx)<>0) then hfsisotop:=strx;

      gotoxy(7,zei); writeln(ao:9:4);
      xao:=realin(1,zei,'Ao = ',9);
      if xao<>0 then ao:=xao;

      gotoxy(7,zei+1); writeln(au:9:4);
      xau:=realin(1,zei+1,'Au = ',9);
      if xau<>0 then au:=xau;

      gotoxy(7,zei+2); writeln(bo:9:4);
      xbo:=realin(1,zei+2,'Bo = ',9);
      if xbo<>0 then bo:=xbo;

      gotoxy(7,zei+3); writeln(bu:9:4);
      xbu:=realin(1,zei+3,'Bu = ',9);
      if xbu<>0 then bu:=xbu;

      gotoxy(7,zei+4); writeln(ikern:3:1);
      xikern:=realin(1,zei+4,'I  = ',4);
      if xikern<>0 then ikern:=xikern;

    { Konstante Daten des ungeraden Isotops }
      gotoxy(1,zei+5); write('H„ufigk. = ',hf:9:2 ,' [%]');
      gotoxy(1,zei+6); write('Schwpkt. = ',swp:9:4,' [MHz]');

    { Daten der geradzahligen Isotope }
      gotoxy(30,zei-1); write('Geradzahlige Isotope : ');
      gotoxy(30,zei);   write('Isotop     Frequ.[MHz]');
      for i:=1 to isoanzahl do
      begin
        gotoxy(30,zei+i);
        write(iso[i]:5,': ',frequ[i]:15:4,'  (',hauf[i]:5:2,'%)');
      end;


     { Drehimpulse }
      gotoxy(6,zei+8); writeln(jo:3:1);
      xjo:=realin(1,zei+8,'Jo = ',4);
      if xjo<>0 then jo:=xjo;

      gotoxy(6,zei+9); writeln(ju:3:1);
      xju:=realin(1,zei+9,'Ju = ',4);
      if xju<>0 then ju:=xju;


    { Parameter aus SPROFIL.PAR abfragen }
      unt:=untergrund-205;

      gotoxy(43,zei+8); writeln(unt:4:0);
      xunt:=realin(30,zei+8,'Untergrund = ',4);
      if xunt<>0 then untergrund:=xunt+205;

      gotoxy(43,zei+9); writeln(FWHM:4:0);
      xfwhm:=realin(30,zei+9,'FWHM [MHz] = ',3);
      if xfwhm<>0 then FWHM:=xfwhm;

      gotoxy(43,zei+10); writeln(aufloesung:4);
      xaufl:=realin(30,zei+10,'Aufl”sung  = ',4);
      if xaufl<>0 then aufloesung:=trunc(xaufl);

      gotoxy(1,zei+12);
      write('Koordinatendatei SPEKTRUM.CAD für AutoCAD generieren (J/N) ? ');
      readln(xxantwort); xxantwort:=upcase(xxantwort);
      if (xxantwort='J') then cad:=TRUE;

      writeln(#7);
      gotoxy(1,zei+14);
      write('Alle Parameter richtig (J/N) ? ');readln(antwort);
      antwort:=upcase(antwort);
    until antwort='J';

    { Abfrage Drehimpulse ungleich Null }
    if (((ju=0) and (jo=0)) or (ikern=0) ) then
      begin
        highvideo;
        gotoxy(1,19);
        for l:=1 to 80 do write(#205);
        gotoxy(1,21);
        for l:=1 to 80 do write(#205);
        gotoxy(1,20);
        writeln('ACHTUNG : Mind. ein Drehimpuls von Ju,Jo  u n d  I muß ungleich Null sein !');
        write(#7,#7,#7);
        lowvideo;
        for t:=1 to 10000 do;
        readln;
      end
    else
      nulltestok:=TRUE;
  until nulltestok;
end;

