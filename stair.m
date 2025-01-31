close all, clc, clear all

stair_depth = 'C:\Users\ini55\OneDrive\바탕 화면\stair\전체\depth'; % depth 이미지 가져오기
% depth 이미지에 저장되어 있는 depth값의 경우 나(or 카메라)로부터 멀수록 큰 값을 가짐.
stair_rgb = 'C:\Users\ini55\OneDrive\바탕 화면\stair\전체\rgb'; % rgb 이미지 가져오기
a = 0;
error = 0;
I = dir(stair_depth); % dir은 현재 폴더에 있는 파일과 폴더를 나열하는 함수
                      % dir함수를 사용해 depth이미지들을 나열함.
img_name = []; 
img_up = [];
img_flat = [];
img_down = [];
m = length(I); % 이미지는 x(미지수)개 인데 I의 길이인 m은 x+2개가 나옴.
               % I를 확인해보면 이미지 앞에 두개의 이상한 값이 있음.
for i = 3:m % 따라서 3부터 m(x+2)까지
    img_name = [img_name; I(i).name]; % I의 여러 값들 중 name만 불러와 img_name변수에 저장해 줌.
end
% c = length(img_name)
size_n = size(img_name);
for i = 1:size_n(1) % img_name변수에 저장된 사진의 개수만큼 반복함을 의미.
    img = imread([stair_depth, '\', img_name(i, :)]); % stair_depth 이미지 중에서 img_name이 i인 것을 읽음.
    line_profile = img(330:end-20, 441); % up, down, flat 셋 다 적당하게 잘 잡히는 기준을 잡은 것.
    % depth 이미지의 크기가 480x848임.
    % 이때 이미지의 (330:end-20, 441)이라는 범위를 기준으로 잡아서 보겠다는 의미.
    % depth이미지의 경우 카메라로부터 멀수록 큰 값을 가진다고 했으므로
    % 330:end-20은 up, down, flat에 관계없이 왼쪽이 높고 오른쪽이 낮은 형태를 보임. 
    % 441의 경우 noise가 가장 적게 나오는 것 같은 부분을 임의로 찾은 것으로
    % 만약 사진에 noise가 없거나 제거할 수 있다면 그냥 848의 중간값을 사용해도 될 것으로 예상됨.
    n = 15; % 필터의 크기
    w = 1/n*ones(1,n); % 15X15짜리 LPF
    ma_line = conv(line_profile, w, "valid"); % 이미지의 특정 범위(330:end-20, 441)의 값들에 LPF를 적용해 white noise 제거
    uuu = diff(ma_line); % white noise를 제거한 특정 범위의 값들을 차분한 값을 구함.
                         % 이는 기울기가 0보다 크거나 같은 부분을 찾기 위해 하는 것.
    for j = 1:length(uuu) % uuu에서 기울기가 0보다 크거나 같은 부분을 찾기위해 처음부터 끝까지 살펴봄.
        if uuu(j) >= 0 % 만약 diff를 했을 때 기울기가 0이거나 0보다 커지는 부분이 있다면? (stair_up)
            a = a+1; % a에 1을 더함. a의 초기값은 0(위에 나옴)
        end
    end
    if a>=1 % 만약 a가 1보다 크거나 같으면? 
        img_up = [img_up; img_name(i,:)]; % 만들어둔 img_up에 해당하는 이미지들을 넣음
    else % 그렇지 않으면? stair_down이거나 stair_flat
        x = 0:1:116; % 1차식을 그려주기위한 x값
        p1 = polyfit(x,ma_line,1); % 1차로 fitting할 때의 계수
        y1 = polyval(p1,x); % fitting한 1차식의 y값
        y = y1'; % sum을 계산하기 위해 전치행렬로 만들어 ma_line(171x1)과 똑같은 형태로 바꿈.
        for k = 1:length(ma_line)
            error = error + (ma_line(k)-y(k))^2; % 실제 y값과 regression한 y값의 차의 제곱의 합 자체를 전체 error로 둠.
                                                 % 확인 결과 평지의 error는 보통 e+4 이하이고,
                                                 % stair_down의 error는 e+5 이상.(계단사진을 잘 찾았다는 가정 하에)
        end
        if error < 10^5 % 따라서 만약 error가 10^5 미만이면? (stair_flat)
            img_flat = [img_flat; img_name(i,:)]; % 마찬가지로 만들어둔 img_flat에 해당하는 이미지들을 넣음.
        else img_down = [img_down; img_name(i,:)]; % (img_up도 아니고)img_flat이 아니면? (img_down)
        end
        error = 0; % 다음 이미지의 error를 계산하기 위해 error 값 초기화.
    end
    a = 0; % 다음 이미지가 stair_up인지 아닌지를 판단하기위해 a 값 초기화.
end

% %% stair_up인 rgb이미지를 모은 것
% 
% for i = 1:length(img_up)
%     img = imread([stair_rgb, '\', img_up(i, :)]);
%     figure(1), subplot(5,7,i)
%     imshow(img);
%     title(img_up(i,:))
% end
%% stair_up인 rgb 이미지를 모은 것

size_u = size(img_up);
for i = 1:size_u(1)
    img = imread([stair_rgb, '\', img_up(i, :)]);
    figure(1), subplot(6,7,i)
    imshow(img);
    title(img_up(i,:))
end

%% stair_down인 rgb 이미지를 모은 것

size_d = size(img_down);
for i = 1:size_d(1)
    img = imread([stair_rgb, '\', img_down(i, :)]);
    figure(2), subplot(6,7,i)
    imshow(img);
    title(img_down(i,:))
end

%% stair_flat(평지+횡단보도)인 rgb 이미지를 모은 것

size_f = size(img_flat);
for i = 1:size_f(1)
    img = imread([stair_rgb, '\', img_flat(i, :)]);
    figure(3), subplot(6,7,i), title('flat')
    imshow(img);
    title(img_flat(i,:))
end

%%
% figure(1)
% plot(ma_line);
% % plot(uuu);
% title('ROI Depth value');
% xlabel('Distance'), ylabel('Depth')
