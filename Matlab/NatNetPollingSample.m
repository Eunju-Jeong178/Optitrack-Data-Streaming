%Copyright © 2018 Naturalpoint
%
%Licensed under the Apache License, Version 2.0 (the "License");
%you may not use this file except in compliance with the License.
%You may obtain a copy of the License at
%
%http://www.apache.org/licenses/LICENSE-2.0
%
%Unless required by applicable law or agreed to in writing, software
%distributed under the License is distributed on an "AS IS" BASIS,
%WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%See the License for the specific language governing permissions and
%limitations under the License.

% Optitrack Matlab / NatNet Polling Sample
%  Requirements:
%   - OptiTrack Motive 2.0 or later
%   - OptiTrack NatNet 3.0 or later
%   - Matlab R2013
% This sample connects to the server and displays rigid body data.
% natnet.p, needs to be located on the Matlab Path.

%--------------------------------------------------------------------------
% Revised by Eunju Jeong
% Email : eunju0316@sookmyung.ac.kr
% Date : 2022.05.11
%
% This code allows user to get very accurate 6 DoF pose of ridig body 
% by using Optitrack
%
% Output data : 
% 1) input\position_optitrack.txt
%   : x[mm] y[mm] z[mm]
% 2) input\euler_angle_optitrack.txt
%   : roll[deg] pitch[deg] yaw[deg]
% 3) input\timestamp_optitrack.txt
%   : timestamp[unix timestamp version, https://www.epochconverter.com/]
% 4) input\rotation_1x9_optitrack.txt
%   : r11 r12 r13 r21 r22 r23 r31 r32 r33[rad]
%--------------------------------------------------------------------------


function NatNetPollingSample
    clc; clear all;

	fprintf( 'NatNet Polling Sample Start\n' )

	% create an instance of the natnet client class
	fprintf( 'Creating natnet class object\n' )
	natnetclient = natnet;

	% connect the client to the server (multicast over local loopback) -
	% modify for your network
	fprintf( 'Connecting to the server\n' )
	natnetclient.HostIP = '192.168.0.80'; % desktop(with Motive) ip address
	natnetclient.ClientIP = '192.168.0.80'; % my laptop ip address, for acquire 6DoF, timestamp data
	natnetclient.ConnectionType = 'Multicast'; % have to be same as Motive setting
	natnetclient.connect;
	if ( natnetclient.IsConnected == 0 )
		fprintf( 'Client failed to connect\n' )
		fprintf( '\tMake sure the host is connected to the network\n' )
		fprintf( '\tand that the host and client IP addresses are correct\n\n' ) 
		return
	end

	% get the asset descriptions for the asset names
	model = natnetclient.getModelDescription;
 
	if ( model.RigidBodyCount < 1 )
		return
	end

	% Poll for the rigid body data a regular intervals (~1 sec) for 10 sec.
	fprintf( '\nPrinting rigid body frame data approximately every second for 10 seconds...\n\n' )
	all_pos=[];
    all_euler=[];
    all_unixtime=[];
    all_rotm = [];
    all_datetime=[];

    time = 10; % the number of data
    for idx = 1 : time

        % to change Hz, change this number (for example, [1Hz --> 1000 ms] and [10Hz --> 100ms])
		java.lang.Thread.sleep(10); % time interval
        % java.lang.Thread.sleep(10) --> 60 ~ 100 Hz
        
		data = natnetclient.getFrame; % method to get current frame
		
		if (isempty(data.RigidBody(1)))
			fprintf( '\tPacket is empty/stale\n' )
			fprintf( '\tMake sure the server is in Live mode or playing in playback\n\n')
			return
		end
		fprintf( 'Frame:%6d  ' , data.Frame )
		fprintf( 'Time:%0.2f\n' , data.Timestamp )
        pos_append = [];
        euler_deg_append = [];
        unixtime_append = [];
        rotm_append = [];
        datetime_append = [];
        
		for i = 1:model.RigidBodyCount
			fprintf( 'Name:"%s"  ', model.RigidBody( i ).Name )
            % Get the x y z position 
            x = data.RigidBody( i ).x * 1000;
            y = data.RigidBody( i ).y * 1000;
            z = data.RigidBody( i ).z * 1000;

            % Get the euler angle
	        qx = data.RigidBody( i ).qx;
	        qy = data.RigidBody( i ).qy;
	        qz = data.RigidBody( i ).qz;
	        qw = data.RigidBody( i ).qw;

	        q = quaternion( qx, qy, qz, qw );
	        qRot = quaternion( 0, 0, 0, 1);
	        q = mtimes( q, qRot);
	        a = EulerAngles( q , 'zyx' );
	        eulerx = a( 1 ) * -180.0 / pi;  % roll (red, x axis)
	        eulery = a( 2 ) * 180.0 / pi;   % pitch (green, y axis)
	        eulerz = a( 3 ) * -180.0 / pi;  % yaw (blue, z axis)

            % print rotation [deg] (euler angle)
            fprintf( 'eulerX:%0.6f deg  ', eulerx )  % roll [deg]
			fprintf( 'eulerY:%0.6f deg  ', eulery )  % pitch [deg]
			fprintf( 'eulerZ:%0.6f deg\n', eulerz )  % yaw [deg]

            euler_deg = [eulerx eulerz -eulery]; % [deg], yaw angle is opposite --> add minus
            euler_deg_append = horzcat(euler_deg_append, euler_deg); % append data
            
            euler_rad = [deg2rad(eulerx); deg2rad(eulerz); -deg2rad(eulery)]; % [deg] --> [rad], yaw angle is opposite --> add minus

            rotm = angle2rotmtx(euler_rad) % euler angles to ratation matrix (3x3)
            
            %rotm_xaxis_minus90rot = rotm*[1 0 0;0 0 1;0 -1 0] 
            
            %original
            rotm_1DArray = reshape(rotm.',1,[]); % (3x3) --> (1x9)
           
            %rotm_1DArray = reshape(rotm_xaxis_minus90rot.',1,[]); % (3x3) --> (1x9) 
            
            rotm_append = [rotm_1DArray]
            
            % print x y z position [mm]
			fprintf( 'X:%0.6f mm  ', x )
			fprintf( 'Y:%0.6f mm  ', y )
			fprintf( 'Z:%0.6f mm\n', z )
            pos = [x y z]; 
            pos_xaxis_minus90rot = pos*[1 0 0;0 0 1;0 -1 0] % Pc = Po*Roc

            %original
            pos_append = horzcat(pos_append, pos);
%             pos_append = horzcat(pos_append, pos_xaxis_minus90rot);


            % print timestamp [ms]
            fprintf( 'Timestamp:%0.6f ms\n\n  ', data.Timestamp)
            
            %timestamp = [data.Timestamp];
            
            timestamp_datetime = (datetime("now", "TimeZone","Asia/Seoul", "Format","HH:mm:ss.SSS")); % KST 
            datetime_append = horzcat(datetime_append, timestamp_datetime)


            % if you want to get KST version timestamp (yyyy-mm-dd HH:MM:SS), comment this line
            timestamp_unixtime = posixtime(timestamp_datetime); % unix timestamp, (https://www.epochconverter.com/)
            
            unixtime_append = horzcat(unixtime_append, timestamp_unixtime);
            
        end
        all_pos = vertcat(all_pos, pos_append);
        all_euler = vertcat(all_euler, euler_deg_append);
        all_unixtime = vertcat(all_unixtime, unixtime_append);
        all_rotm = vertcat(all_rotm, rotm_append);
        all_datetime = vertcat(all_datetime, datetime_append);

    end
    % write text files (position, rotation, timestamp)
    writematrix(all_pos, 'input\position_optitrack.txt', 'delimiter', ' ')
    writematrix(all_euler, 'input\euler_angle_optitrack.txt', 'delimiter', ' ')
    writematrix(all_unixtime, 'input\timestamp_optitrack.txt', 'delimiter', ' ')
    writematrix(all_rotm, 'input\rotation_1x9_optitrack.txt', 'delimiter', ' ')
    writematrix(all_datetime, 'input\date_timestamp_optitrack.txt', 'delimiter', ' ')

    disp('Done making position, orientation, and timestamp text file!')

    % When the timestamp format is KST(yyyy-mm-dd HH:MM:SS),
    % then comment this line
    % and run 'make_6Dof_pose_crazyflie_optitrack.m' seperately.
    make_6DoF_pose_crazyflie_optirack % make 6 DoF pose of Crazyflie (Optitrack)
    
end
