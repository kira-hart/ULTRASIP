function esp301 = espConnect(comPort)
% This function will automatically connect the esp301 motion controller
% using the virtual serial port (usually COM3), and configuring it
% appropriately.  To my knowledge, the only two parameters of the ESP301
% which are different from matlab defaults are the baudrate and terminator.
%  These are set below.
%
% James Heath 09/28/2020
%%
esp301 = serial(comPort);
set(esp301, 'baudrate', 921600);
set(esp301, 'terminator', 13);

%%
fopen(esp301)
fprintf(esp301,'VE'); %Sends current wavelength cmd, which is echoed
esp301_Status=fscanf(esp301)

if ~fprintf(esp301,'1AU5000') % Set max accel/decel
    success = false;
    return;
end
fprintf(esp301,'2AU5000');
fprintf(esp301,'3AU5000');

fprintf(esp301,'1MO; 2MO; 3MO'); % Turn on motors

global CURRENT_POS;
response = query(esp301,'1TP?;2TP?;3TP?');

if ~isempty(response) && length(response) == 3
    CURRENT_POS = response;
else
    success = false;
    return;
end

global CURRENT_SPEED;
if isempty(CURRENT_SPEED)
    CURRENT_SPEED = 50;
end

global CURRENT_ACCEL;
if isempty(CURRENT_ACCEL)
    CURRENT_ACCEL = 50;
end

global CURRENT_DECEL;
if isempty(CURRENT_DECEL)
    CURRENT_DECEL = 50;
end

for n = 1:3
    fprintf(esp301,sprintf('%dVA%0.5f', n, CURRENT_SPEED)); % Set axis 3 velocity
    fprintf(esp301,sprintf('%dAC%0.5f', n, CURRENT_ACCEL)); % Set axis 3 accel
    fprintf(esp301,sprintf('%dAG%0.5f', n, CURRENT_DECEL)); % Set axis 3 decel
end

fclose(esp301)

%% NEED TO ADD HOMING COMMANDS