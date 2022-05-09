m = [0 1 2]

pos = [];
for i = 1:3
        x = 1;
        y = 2;
        z = 3;
% 			fprintf( 'X:%0.1fmm  ', x )
% 			fprintf( 'Y:%0.1fmm  ', y )
% 			fprintf( 'Z:%0.1fmm\n', z )
        m = [x y z];
        pos = horzcat(pos, [x y z]);
end
pos