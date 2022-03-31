unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, Process;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnPTT: TButton;
    btnRx: TButton;
    btnTx: TButton;
    edtDestinationHostIP: TEdit;
    edtTCPIPTransmitPort: TEdit;
    edtTCPIPReceivePort: TEdit;
    grpStatus: TGroupBox;
    imgM17Logo: TImage;
    MainMenu1: TMainMenu;
    memStatus: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    OpenWaveInDialog: TOpenDialog;
    rgAudioSource: TRadioGroup;
    rgAudioDestination: TRadioGroup;
    SaveWAVEOutDialog: TSaveDialog;
    Timer1: TTimer;
    procedure btnPTTClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure rgAudioDestinationSelectionChanged(Sender: TObject);
    procedure rgAudioSourceSelectionChanged(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
  public
      procedure UpdateStatusMemo;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.UpdateStatusMemo;
VAR strStatus: STRING;
begin
     memStatus.Lines.Clear;
     case rgAudioSource.ItemIndex of
        0: strStatus := 'Click on PTT to read the audio from a WAV file, M17 encode it';
        1: strStatus := 'Click on PTT to record the audio from the microphone, M17 encode it';
        2: strStatus := 'Click on Listen to listen for M17 encoded audio from a TCPIP port, M17 decode it';
     end;
     memStatus.Lines.Add( strStatus );
     case rgAudioDestination.ItemIndex of
        0: strStatus := 'and save the decoded audio to a WAV file.';
        1: strStatus := 'and play the decoded audio out the speaker.';
        2: strStatus := 'and send the encoded audio via TCPIP.';
     end;
     memStatus.Lines.Add( strStatus );
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.rgAudioDestinationSelectionChanged(Sender: TObject);
begin
  UpdateStatusMemo;
end;

procedure TForm1.rgAudioSourceSelectionChanged(Sender: TObject);
begin
  if ( rgAudioSource.ItemIndex = 0 ) or (rgAudioSource.ItemIndex = 1 )
  then begin
     btnPTT.Caption := 'PTT';
  end
  else begin
    btnPTT.Caption := 'Listen';
  end;
  UpdateStatusMemo;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Application.ProcessMessages;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  UpdateStatusMemo;
end;

CONST
   strCRLF = #13#10;
   strPathToRec = '/usr/bin/rec';
   strPathToPlay = '/usr/bin/play';
   strPathToSox  = '/usr/bin/sox';
   strPathToNetcat = '/usr/bin/netcat';
   strPathToM17Mod = './m17-mod';
   strPathToM17Demod = './m17-demod';

procedure TForm1.btnPTTClick(Sender: TObject);
VAR FirstProcess : TProcess;
    strCommand : STRING;
begin

  // check for required executables
  if NOT FileExists( strPathToRec ) then begin
     Application.MessageBox('The rec executable was not found at '
        + strPathToRec + '  ' + strCRLF
        + 'Is the sox package installed?  ',
        'Error!',
        0);
     Exit;
  end;
  if NOT FileExists( strPathToPlay ) then begin
     Application.MessageBox('The play executable was not found at '
        + strPathToPlay + '  ' + strCRLF
        + 'Is the sox package installed?  ',
        'Error!',
        0);
     Exit;
  end;
  if NOT FileExists( strPathToNetcat ) then begin
     Application.MessageBox('The netcat executable was not found at '
        + strPathToNetcat + '  ' + strCRLF
        + 'Is the netcat package installed?  ',
        'Error!',
        0);
     Exit;
  end;
  if NOT FileExists( strPathToM17mod ) then begin
     Application.MessageBox('The m17-mod executable was not found'
        + strCRLF
        + 'Is the m17mod executable in the same directory as miriad?  ',
        'Error!',
        0);
     Exit;
  end;
  if NOT FileExists( strPathToM17Demod ) then begin
     Application.MessageBox('The m17-demod executable was not found'
        + strCRLF
        + 'Is the m17demod executable in the same directory as miriad?  ',
        'Error!',
        0);
     Exit;
  end;

  if rgAudioSource.ItemIndex = 0 // from WAVE
  then begin
     OpenWAVEInDialog.Filename := '';
     if NOT OpenWAVEInDialog.Execute
     then begin
        memStatus.Lines.Add( 'Open WAVE file cancelled.');
        Exit;
     end;
     memStatus.Lines.Clear;
     memStatus.Lines.Add( 'Encoding ' + OpenWAVEInDialog.Filename );
     strCommand := '/usr/bin/sh -c "/usr/bin/cat '
        + OpenWaveInDialog.Filename
        + ' | '
        + strPathToM17Mod + ' -S NOCALL | ';
  end;

  if rgAudioSource.ItemIndex = 1 // from microphone
  then begin
     memStatus.Lines.Clear;
     memStatus.Lines.Add( 'Recording microphone audio for ten seconds.');
     memStatus.Lines.Add( 'Start talking now' );
     strCommand := '/usr/bin/bash -c '
        + '"'
        + strPathToRec + ' -b 16 -e unsigned-integer -r 8000 -c 1 -d --clobber --buffer $((8000*1*10)) -t wav - trim 0 10 | '
        + strPathToM17Mod + ' -S NOCALL | ';
  end;

  if rgAudioSource.ItemIndex = 2 // from TCPIP port
  then begin
     memStatus.Lines.Clear;
     memStatus.Lines.Add( 'Listening for M17 encoded audio on TCPIP port ' + edtTCPIPReceivePort.Text + '.');
     strCommand := '/usr/bin/bash -c "'
        + '/usr/bin/netcat -l localhost ' + edtTCPIPReceivePort.Text + ' | ';
  end;
  //---------------------------------------------------------------------------------------------------
  if rgAudioDestination.ItemIndex = 0 // to WAVE file
  then begin
     SaveWAVEOutDialog.Filename := '';
     if NOT SaveWAVEOutDialog.Execute
     then begin
        memStatus.Lines.Add( 'Save to WAVE file cancelled.');
        Exit;
     end;
     memStatus.Lines.Add( 'Decododed M17 audio will be saved to ' + SaveWAVEOutDialog.Filename);
     strCommand := strCommand
        + strPathToM17Demod + ' | '
        + strPathToSox + ' --type raw --rate 8k --bits 16 -e signed - ' + SaveWAVEOutDialog.Filename + '"';
  end;
  if rgAudioDestination.ItemIndex = 1 // to speaker
  then begin
     memStatus.Lines.Add( 'and the demodulated M17 audio will be played out to the speaker.');
     strCommand := strCommand
        + strPathToM17Demod
        + ' | '
        + strPathToPlay + ' -b 16 -r 8000 -c1 -t s16 -"';
     btnTX.Font.Color := clGray;
     btnRX.Font.Color := clGreen;
     Application.ProcessMessages;
  end;
  if rgAudioDestination.ItemIndex = 2 // send TCPIP
  then begin
     strCommand := strCommand
        + strPathToNetcat
        + ' -N ' + edtDestinationHostIP.Text + ' ' + edtTCPIPTransmitPort.Text + '"';
     memStatus.Lines.Add( 'Sending via TCPIP...' );
     btnTX.Font.Color := clRed;
     btnRX.Font.Color := clGray;
     Application.ProcessMessages;
  end;

  // From WAV to TCPIP port
  //strCommand := '/usr/bin/sh -c "/usr/bin/cat /home/douglas/m17recordings/count-to-ten.wav | '
  //   + '/home/douglas/m17recordings/m17-mod -S KA2UPW | '
  //   + '/usr/bin/netcat -N ' + edtDestinationHostIP.Text + ' ' + edtTCPIPTransmitPort.Text + '"';

  //strCommand := '/usr/bin/sh -c "/usr/bin/netcat -l localhost ' + edtTCPIPReceivePort.Text + ' | '
  //   + '/home/douglas/m17recordings/m17-demod -d -l | '
  //   + '/usr/bin/play -b 16 -r 8000 -c1 -t s16 - "';

  //strCommand := '/usr/bin/bash -c "/usr/bin/netcat -l localhost ' + edtTCPIPReceivePort.Text + ' | '
  //   + '/home/douglas/m17recordings/m17-demod -d -l | '
  //   + '/usr/bin/play -b 16 -r 8000 -c1 -t s16 - "';

  //strCommand := '/usr/bin/bash -c "/usr/bin/netcat -l localhost ' + edtTCPIPReceivePort.Text + ' | '
  //   + '/home/douglas/m17recordings/m17-demod  > x.x"';

  // From TCPIP, demodulate, play out speaker
  //strCommand := '/usr/bin/bash -c "/usr/bin/netcat -l localhost ' + edtTCPIPReceivePort.Text + ' | '
  //   + '/home/douglas/m17recordings/m17-demod  | '
  //   + '/usr/bin/play -b 16 -r 8000 -c1 -t s16 - "';

   // From TCPIP, demodulate, play out speaker
   //strCommand := '/usr/bin/bash -c "/usr/bin/netcat -l localhost ' + edtTCPIPReceivePort.Text + ' | '
   //  + '/home/douglas/m17recordings/m17-demod  | '
   //  + '/usr/bin/sox --type raw --rate 8k --bits 16 -e signed -  output.wav"';

   // From Microphone for ten seconds, encode, send via TCPIP
   //strCommand := '/usr/bin/bash -c '
   //   + '"/usr/bin/rec -b 16 -e unsigned-integer -r 8000 -c 1 -d --clobber --buffer $((8000*1*10)) -t wav - trim 0 10 | '
   //  + '/home/douglas/m17recordings/m17-mod -S KA2UPW | '
   //   + '/usr/bin/netcat -N ' + edtDestinationHostIP.Text + ' ' + edtTCPIPTransmitPort.Text + '"';

  //DEBUG:
  //memStatus.Lines.Clear;
  //memStatus.Lines.Add( strCommand );
  Application.ProcessMessages;
  FirstProcess          := TProcess.Create(nil);
  FirstProcess.Options  := [poWaitOnExit, poUsePipes];
  FirstProcess.CommandLine := strCommand;
  FirstProcess.Execute;
  memStatus.Lines.Add( 'Done.' );
  btnRX.Font.Color := clGray;
  btnTX.Font.Color := clGray;
end;

end.

