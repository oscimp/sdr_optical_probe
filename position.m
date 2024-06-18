clear all
more off
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
set(s1, 'timeout', 1.23);      % 1.0 Seconds as an example here
srl_flush(s1);
srl_write(s1,"SVO 1 1\n"); % servo on
srl_write(s1,"SVO 2 1\n"); % servo on
srl_write(s1,"SVO?\n");char(srl_read(s1,256))
srl_write(s1,"FRF 1\n");pause(0.5); % MUST BE "..." to interpret \n
srl_write(s1,"FRF 2\n");pause(1.5); % MUST BE "..." to interpret \n

table_delay=0.015;  % in second(s)

while (1==1)
  x=input('X ? ');
chaine=["MOV 2 ",num2str(x),"\n"];srl_write(s1,chaine); 
  y=input('Y ? ');
  chaine=["MOV 1 ",num2str(y),"\n"];srl_write(s1,chaine); 
  
  pause(table_delay)
end
 
