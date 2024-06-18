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
set(s1, 'timeout', 1.23);     % 12.3 Seconds as an example here

srl_write(s1,"SVO 1 0\n");    % MUST be "..." to interpret \n
pause(0.1);
srl_write(s1,"SVO 2 0\n"); 
pause(0.1);
