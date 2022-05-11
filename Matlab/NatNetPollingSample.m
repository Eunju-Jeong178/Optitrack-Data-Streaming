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

function NatNetPollingSample
	fprintf( 'NatNet Polling Sample Start\n' )

	% create an instance of the natnet client class
	fprintf( 'Creating natnet class object\n' )
	natnetclient = natnet;

	% connect the client to the server (multicast over local loopback) -
	% modify for your network
	fprintf( 'Connecting to the server\n' )
	natnetclient.HostIP = '192.168.0.80';
	natnetclient.ClientIP = '192.168.0.82';
	natnetclient.ConnectionType = 'Multicast';
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
    all_rot=[];
    time = 600; % 개수
    for idx = 1 : time
		java.lang.Thread.sleep( 50 ); % original is 996 % ms, 간격
		data = natnetclient.getFrame; % method to get current frame
		
		if (isempty(data.RigidBody(1)))
			fprintf( '\tPacket is empty/stale\n' )
			fprintf( '\tMake sure the server is in Live mode or playing in playback\n\n')
			return
		end
		fprintf( 'Frame:%6d  ' , data.Frame )
		fprintf( 'Time:%0.2f\n' , data.Timestamp )
        pos = [];
        rot = [];
		for i = 1:model.RigidBodyCount
			fprintf( 'Name:"%s"  ', model.RigidBody( i ).Name )
            x = data.RigidBody( i ).x * 1000;
            y = data.RigidBody( i ).y * 1000;
            z = data.RigidBody( i ).z * 1000;

            % Get the rb rotation
	        %rb = evnt.data.RigidBodies( i );
	        qx = data.RigidBody( i ).qx;
	        qy = data.RigidBody( i ).qy;
	        qz = data.RigidBody( i ).qz;
	        qw = data.RigidBody( i ).qw;
	
	        q = quaternion( qx, qy, qz, qw );
	        qRot = quaternion( 0, 0, 0, 1);
	        q = mtimes( q, qRot);
	        a = EulerAngles( q , 'zyx' );
	        eulerx = a( 1 ) * -180.0 / pi;  % roll
	        eulery = a( 2 ) * 180.0 / pi;   % pitch
	        eulerz = a( 3 ) * -180.0 / pi;  % yaw

            fprintf( 'eulerX:%0.1fdeg  ', eulerx )  % roll
			fprintf( 'eulerY:%0.1fdeg  ', eulery )  % pitch
			fprintf( 'eulerZ:%0.1fdeg\n', eulerz )  % yaw
            n = [eulerx eulery eulerz];
            rot = horzcat(rot, n)
            
			fprintf( 'X:%0.1fmm  ', x )
			fprintf( 'Y:%0.1fmm  ', y )
			fprintf( 'Z:%0.1fmm\n', z )
            m = [x y z];
            pos = horzcat(pos, m)
        end
        all_pos = vertcat(all_pos, pos);
        all_rot = vertcat(all_rot, rot);
    end
    csvwrite('postion_xyz.txt',all_pos)
    csvwrite('rotation_euler.txt',all_rot)
	disp('NatNet Polling Sample End')
end







 