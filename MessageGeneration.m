%generating message for the given latitude and longitude for short and long
%message type.For long msg type optinal data is give present date.

clc;
close all;
clear;

BitSyncronization = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
FrameSynchronization = [0 0 0 1 0 1 1 1 1];
dummybits=[0 0 0 0 0];
dummybits=[dummybits zeros(1,40)];

latitude = input("Enter latitude: ");
longitude = input("Enter longitude: ");

%direction
if(latitude>0)
    bit70 = 0;%North
else
    bit70 = 1;%South

end

if(longitude>0)
    bit85 = 0;%East
else
    bit85 = 1;%West

end

%Converting Floating point representation to Fixed point representation

txLatitude =cast(((abs(latitude)) * (16384)),"uint32");
txLongitude =cast(((abs(longitude)) * (8192)),"uint32");

%lat and lon in binary

lat_bin = int2bit(txLatitude,21);
long_bin = int2bit(txLongitude,22);
lat_int = bit2int(lat_bin,21);
long_int = bit2int(long_bin,22);

location = [lat_bin'  bit70 long_bin' bit85];

message_type = input("Enter the message_type(short/long):  ",'s');

ProtocolFlag = 0;
CountryCode=[0 1 1 1 1 0 1 1 1 1];%example
ProtocolCode=[1 1 1 0];

if (message_type=="short")
     FormatFlag = 0;
    message_Tx = [BitSyncronization FrameSynchronization FormatFlag ProtocolFlag CountryCode ProtocolCode location];
   
   
else
    FormatFlag = 1;
   message_Tx =[BitSyncronization FrameSynchronization FormatFlag ProtocolFlag CountryCode ProtocolCode location];
   
end

data = [FormatFlag ProtocolFlag CountryCode ProtocolCode location];

%obtaing error correcting codes using BCH codes
msg_error = [dummybits data];
msg_error_Tx = gf(msg_error);
enc = bchenc(msg_error_Tx,127,106);
errorCorrectingCode = enc(1,107:127);
msgTx = [message_Tx errorCorrectingCode];

if (message_type=="short")

    emergencydata = [0 0 0 0 0 0];
    messageTx = [msgTx emergencydata];
else
    %optional message bits in long
    formatOut = 'mm/dd/yyyy';
    date_now = datestr(now,formatOut);
    disp(date_now);
    Month = str2double(date_now(1:2));
    Date = str2double(date_now(4:5));
    Year = str2double(date_now(7:10));
    Month_bin = int2bit(Month,7);
    Date_bin = int2bit(Date,6);
    Year_bin = int2bit(Year,13);
    Optionalmsg_long = [Month_bin' Date_bin' Year_bin'];
   
    %errror correcting codes for optional data in long message type
    dummybits1=[0 0 0 0 0];
    dummybits1=[dummybits1 zeros(1,20)];
    msg_error_optional = [dummybits1 Optionalmsg_long];
    msg_error_Tx_optional = gf(msg_error_optional);
    enc_optional = bchenc(msg_error_Tx_optional,63,51);
    enc_op = enc_optional.x;
    disp(enc_op);
    errorCorrectingCode_optional = enc_optional(1,52:63);
    messageTx = [msgTx Optionalmsg_long errorCorrectingCode_optional];
end
    

disp(messageTx.x);%generated message
MsgBits =  messageTx.x;
save('MsgBits.mat');

