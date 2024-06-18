clear all
more off
%% measumrement parameters (in mm) : 
dy=0.060
dx=0.0005
xmin=4
xmax=6
ymin=-2.25
ymax=-2.15

% measurement parameters (in mm) : Melvin
%dy=0.001
%dx=0.00025
%xmin=1.39
%xmax=1.42
%ymin=0.94
%ymax=1.01

%%% measurement parameters (in mm) : CMUT Sylvain
%dy=0.1
%dx=0.005
%xmin=-1.5
%xmax=9
%ymin=-7.5
%ymax=-4.5

%% measurement parameters (in mm) : SEAS10
%dy=0.010
%dx=0.00025
%xmin=-1.8
%xmax=0.2
%ymin=-4.0
%ymax=-3.6
%%ymax=-4.5  % antires
%% measurement parameters (in mm) : Vectron 868 MHz
%dy=0.010
%dx=0.00025
%xmin=-8.7
%xmax=-6.6
%ymin=-6.75
%ymax=-6.5
% nothing to edit below this line

rtl=0
b210=1
ONT=0    % demande a la table si elle est arrivee a son but (On Target ?)
total_length=50;
table_delay=0.015;  % in second(s)

pkg load zeromq
pkg load instrument-control
if (exist("serial") != 3)
    disp("No Serial Support");
endif   

s1 = serial("/dev/ttyUSB0");  % Open the port
pause(.1);                    % Optional wait for device to wake up 
set(s1, 'baudrate', 115200);  % communication speed
set(s1, 'bytesize', 8);       % 5, 6, 7 or 8
set(s1, 'parity', 'n');       % 'n' or 'y'
set(s1, 'stopbits', 1);       % 1 or 2
set(s1, 'timeout', 123);      % 12.3 Seconds as an example here

% system('./read9600 *IDN?')
% sock = zmq_socket(ZMQ_PULL);
vector=zeros(total_length,1);  % case of SUB socket: register all services
p=1;
m=1;
srl_write(s1,"SVO 1 1\n"); pause(0.1);
srl_write(s1,"SVO 2 1\n"); pause(0.1);
%srl_write(s1,"FRF 1\n");pause(0.5); % MUST BE "..." to interpret \n
%srl_write(s1,"FRF 2\n");pause(1.5); % penser a mettre un delai suffisant 
printf("done\n");

number=(ymax-ymin)/dy*(xmax-xmin)/dx;

if (rtl==1)
disp(['Expected duration: ',num2str(100e-3*number)]);
else
  if (ONT==0)
    disp(['Expected duration: ',num2str(25e-3*number)]);
  else
    disp(['Expected duration: ',num2str(48e-3*number)]);
  end
end
% recherche grossiere de la position du dispo
% y=-3.9;  chaine=['MOV 1 ',num2str(y),"\n"];srl_write(s1,chaine); % system(chaine)
% x=2.5; chaine=['MOV 2 ',num2str(x),"\n"];srl_write(s1,chaine); % system(chaine)
% pause(0.5)
 
debut=time;
tic
for y=ymin:2*dy:ymax
  chaine=['MOV 1 ',num2str(y),"\n"];srl_write(s1,chaine);
  %pause(table_delay)
  if (ONT==0) pause(table_delay);end
  % for x=xmax:-dx:xmin
  for x=xmin:dx:xmax
    chaine=['MOV 2 ',num2str(x),"\n"];srl_write(s1,chaine);
    %pause(table_delay)
    if (ONT==1) 
       do
	 chaine=["ONT?\n"];srl_write(s1,chaine);
	 [chaine,count]=srl_read(s1,9);
       until ((chaine(3)=='1') && (chaine(8)=='1'));
    else
      pause(table_delay);
    end
    if (b210==1)
     sock1 = zmq_socket(ZMQ_SUB);  % socket-connect-opt-close = 130 us
     zmq_connect   (sock1,"tcp://127.0.0.1:5555");
     zmq_setsockopt(sock1, ZMQ_SUBSCRIBE, "");
     recv=zmq_recv(sock1, total_length*8*2, 0); % *2: interleaved channels
     value=typecast(recv,"single complex"); % char -> float
     mesure1(m,p)=mean(value(1:length(value)/2));
     mesure2(m,p)=mean(value(length(value)/2+1:end));
     zmq_close (sock1);
    end
    if (rtl==1)
      sock1 = zmq_socket(ZMQ_SUB);  % socket-connect-opt-close = 130 us
      zmq_connect   (sock1,"tcp://127.0.0.1:6555");
      zmq_setsockopt(sock1, ZMQ_SUBSCRIBE, "");
      recv=zmq_recv(sock1, total_length*8*2, 0);
      value=typecast(recv,"single complex"); % char -> float
      mesure_rtl1(m,p)=mean(value(1:length(value)/2));
      mesure_rtl2(m,p)=mean(value(length(value)/2+1:end));
      zmq_close (sock1);
    end
    p=p+1;
  end
  toc
  % repeat the same sequence but backward
  m=m+1
  p=p-1
  chaine=['MOV 1 ',num2str(y+dy),"\n"];srl_write(s1,chaine);
 % pause(table_delay)
  if (ONT==0) pause(table_delay);end
  for x=xmax:-dx:xmin
    chaine=['MOV 2 ',num2str(x),"\n"];srl_write(s1,chaine);
     % pause(table_delay)
    if (ONT==1) 
       do
	 chaine=["ONT?\n"];srl_write(s1,chaine);
	 [chaine,count]=srl_read(s1,9);
       until ((chaine(3)=='1') && (chaine(8)=='1'));
    else
      pause(table_delay);
    end
    if (b210==1)
      sock1 = zmq_socket(ZMQ_SUB);  % socket-connect-opt-close = 130 us
      zmq_connect   (sock1,"tcp://127.0.0.1:5555");
      zmq_setsockopt(sock1, ZMQ_SUBSCRIBE, "");
      recv=zmq_recv(sock1, total_length*8*2, 0); % *2: interleaved channels
      value=typecast(recv,"single complex"); % char -> float
      mesure1(m,p)=mean(value(1:length(value)/2));
      mesure2(m,p)=mean(value(length(value)/2+1:end));
      zmq_close (sock1);
    end
    if (rtl==1)
      sock1 = zmq_socket(ZMQ_SUB);  % socket-connect-opt-close = 130 us
      zmq_connect   (sock1,"tcp://127.0.0.1:6555");
      zmq_setsockopt(sock1, ZMQ_SUBSCRIBE, "");
      recv=zmq_recv(sock1, total_length*8*2, 0);
      value=typecast(recv,"single complex"); % char -> float
      mesure_rtl1(m,p)=mean(value(1:length(value)/2));
      mesure_rtl2(m,p)=mean(value(length(value)/2+1:end));
      zmq_close (sock1);
    end
    p=p-1;
  end
  p=p+1
  m=m+1
  if (b210==1)
subplot(221)
imagesc(20*log10(abs(mesure2)));colorbar
title('amplitude')
subplot(223)
imagesc(angle(mesure2));colorbar
title('phase')
subplot(222)
imagesc(20*log10(real(mesure1)));colorbar
title('sideband')
subplot(224)
imagesc(20*log10(imag(mesure1)));colorbar
title('carrier')
  end
  pause(table_delay)
%  if (rtl==1)
%    imagesc(real(mesure_rtl2))
%  end
end
toc
fin=time;
clear s1 sock1 
save tout.mat
(fin-debut)/number

subplot(221)
imagesc(20*log10(abs(mesure2)));colorbar
title('amplitude')
subplot(223)
imagesc(angle(mesure2));colorbar
title('phase')
subplot(222)
imagesc(20*log10(real(mesure1)));colorbar
title('sideband')
subplot(224)
imagesc(20*log10(imag(mesure1)));colorbar
title('carrier')
print -depsc tout.eps
