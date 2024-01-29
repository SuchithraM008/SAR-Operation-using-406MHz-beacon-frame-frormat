%Recever part where it will recv the message and decode lat and long for
%bothe short and long message type.For long message type date will also 
% be decoded 


clc;
close all;
clear;

Msg_Rx = load('MsgBits.mat');
Msg_Rx = Msg_Rx.MsgBits;
%$disp(Msg_Rx);

dummybits = [0 0 0 0 0];
dummybits = [dummybits zeros(1,40)];

msg1 = [dummybits Msg_Rx(1,25:85)];
msg1_gf = gf(msg1);
encoded_msg = [msg1,Msg_Rx(86:106)];
message = gf(encoded_msg);

%decoding the message bits for both long and short type message
noisycode = message + randerr(1,127,1:3);
[msg_Rx] =  bchdec(noisycode,127,106);
%disp("Decoded Codeword: ");
%disp(msg_Rx);
new_msg = msg_Rx.x;
if msg1_gf==msg_Rx
    disp('The message was recoverd');
else
    disp("Error in recoverd message");

end

if new_msg(1,46) == 0
    disp("Message_type = short");
else
    disp("Message_type = long")
    
end
   

lat_bin = new_msg(1,62:82);
direction1 = new_msg(1,83);
long_bin = new_msg(1,84:105);
direction2 = new_msg(1,106);

%converting from binary to integer
lat_int = bit2int(lat_bin',21);
long_int = bit2int(long_bin',22);
%decoding the inputs latitude and longitude
latitude1  = (double(lat_int) / (16384) );
longitude1 = (double(long_int)/ (8192) );

if direction1==0
    latitude = latitude1*1;
else 
     latitude = latitude1*(-1);
end

if direction2==0
    longitude = longitude1*1;
else 
     longitude = longitude1*(-1);
end

disp(latitude);
disp(longitude);





if new_msg(1,46) == 1
    msg_op = Msg_Rx(1,107:132);
    parity_op = Msg_Rx(1,133:144);
    dummybits1 = [0 0 0 0 0];
    dummybits1=[dummybits1 zeros(1,20)];
    dec_msg = [dummybits1 msg_op];
    dec_msggf = gf(dec_msg);
    msg_parity = [dec_msg parity_op];
    msg_paritygf = gf(msg_parity);
    data_noise = msg_paritygf + randerr(1,63,1:2);
    [data_recv, error ,code]= bchdec(data_noise,63,51);
    
   
    data=data_recv.x;
    if data_recv == dec_msggf
        disp("message recovered(long message)");
    else
        disp("error in decoded messsage");
    end
    
    %converting binary to int
    month_int = bit2int(data(1,26:32)',7);
    date_int = bit2int(data(1,33:38)',6);
    year_int = bit2int(data(1,39:51)',13);
    date = [month_int' date_int' year_int'];
    disp("date recv");
    disp(date);

end