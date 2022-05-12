# Optitrack-Data-Streaming

The user can receive the exact x y z position and rotation information of the rigid body with the marker attached by using optitrack.

## MATLAB
### step 1
motive가 설치된 데스크탑과, 데이터를 취득할 노트북이 Optitrack과 같은 WIFI에 연결되어 있어야 함 (ex) TP-Link_12DC)

### step 2
NatNetPollingSample.m 실행 후, 차례로 NatNetLib.dll, NatNetML.dll 종속성 추가

### step3
make_Crazyflie_6DoF_Optitrack.m 실행 후, output 폴더에 6-DoF pose 저장됨 
<br/>timestamp r11 r12 r13 tx r21 r22 r23 ty r31 r32 r33 tz

### another method
1. NatNetEventHandlerSample.m 실행시, position과 rotation이 plot 됨
  <br/>line75의 pause(#) 는 #초 동안 데이터를 받아오는 것을 의미
