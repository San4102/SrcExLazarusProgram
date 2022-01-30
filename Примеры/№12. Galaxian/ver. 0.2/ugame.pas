unit ugame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  uPlayer, uEnemy, uBullet;

type

  { TGame }

  TGame = class(TForm)
    Timer1: TTimer;
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure Load();
    procedure Frame();
    procedure UpdateGame();
  public

  end;

var
  Game: TGame;
  player : TPlayer;
  ListBot: TList;
  ListBullet: TList;
  isFinish : Boolean;


const StepPlayer = 3;

const NAME_PLAYER  = 'assets\Player.bmp';
const NAME_ENEMY   = 'assets\bot.bmp';
const NAME_BULLET  = 'assets\bullet.bmp';


implementation

{$R *.lfm}


// -----------------------------------------------
procedure TGame.Load();
begin
  isFinish := false;

  // Создание играка
  player := TPlayer.Create( NAME_PLAYER );
  player.SetPosition((Game.Width div 2) - (player.GetWidth div 2),
                             Game.Height - player.GetHeight);


  // Создание пуль
  ListBullet := TList.Create;




  // Создание ботов
  ListBot := TList.Create;
  ListBot.Add(TEnemy.Create(NAME_ENEMY,   0, 10));
  ListBot.Add(TEnemy.Create(NAME_ENEMY,  70, 10));
  ListBot.Add(TEnemy.Create(NAME_ENEMY, 140, 10));
  ListBot.Add(TEnemy.Create(NAME_ENEMY, 210, 10));
end;

procedure TGame.Frame();
var
  i : integer;
begin
  // Игрок
  Canvas.Draw(player.GetPosX, player.GetPosY, player.GetImage);

  // Боты
  for i := 0 to ListBot.Count-1 do
    if  (TEnemy(ListBot[i]).GetVisable) then
      Canvas.Draw(TEnemy(ListBot[i]).GetPosX,
                  TEnemy(ListBot[i]).GetPosY,
                  TEnemy(ListBot[i]).GetImage);

  // Пули
  for i := 0 to ListBullet.Count-1 do
    if  (TBullet(ListBullet[i]).GetVisable) then
      Canvas.Draw(TBullet(ListBullet[i]).GetPosX,
                  TBullet(ListBullet[i]).GetPosY,
                  TBullet(ListBullet[i]).GetImage);

end;

procedure TGame.UpdateGame();
var
  i, j : integer;
begin

  for i := 0 to ListBullet.Count-1 do begin
    // перемещение пули
    if  (TBullet(ListBullet[i]).GetVisable) then
      TBullet(ListBullet[i]).Move( -StepPlayer );

    // проверка - выход за приделы окна
    if ( TBullet(ListBullet[i]).GetPosY < 0 ) then begin
      TBullet(ListBullet[i]).SetVisable( false );
      ListBullet.Remove(TBullet(ListBullet[i]));
      Break;
    end;

    // проверка - столкновение с ботом
    for j := 0 to ListBot.Count-1 do
      if TBullet(ListBullet[i]).Collision(TEnemy(ListBot[j])) then
         begin
           TEnemy(ListBot[j]).Damage( 1 );
           TBullet(ListBullet[i]).SetVisable( false );

           if TEnemy(ListBot[j]).Health <= 0 then
           begin
             ListBot.Remove(TEnemy(ListBot[j]));
             //  xPos := play.GetPosX + (play.GetWidth div 2);
  //yPos := play.GetPosY;  Break;
           end;
         end;


  end;

  if ListBot.Count = 0 then begin
    isFinish := true;
    ShowMessage('Победа !!!');
  end;

  /// Caption := ListBullet.Count.ToString;

end;

// ----------------------------------------------------

procedure TGame.FormKeyPress(Sender: TObject; var Key: char);
var
  xPos, yPos : Integer;
begin
  if key in ['a'] then player.Move( -StepPlayer );
  if key in ['d'] then player.Move(  StepPlayer );
  if key in [' '] then
  begin
   xPos := player.GetPosX + (player.GetWidth div 2);
   yPos := player.GetPosY;
   ListBullet.Add(TBullet.Create(NAME_BULLET, xPos, yPos));
  end;

end;

procedure TGame.FormPaint(Sender: TObject);
begin
  if not (isFinish) then begin
    Frame();
    UpdateGame();
  end;
end;

procedure TGame.FormShow(Sender: TObject);
begin
 Load();
end;

procedure TGame.Timer1Timer(Sender: TObject);
begin
  Repaint;
end;

end.

