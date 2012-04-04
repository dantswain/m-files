function EPSFig(filename, CurveData, CurveColor, ParticleData, ...
    ParticleColor, ArrowSizes, Edge, Beta, Rho, BoundingBox)
% EPSFig     Create an EPS figure from trajectory data.
%
% EPSFig(filename, CData, CColor, PData, PColor, ASizes, Edges, B, R, BB)
%
% Creates an eps figure with filename or appends this figure to an existing
% figure with filename.  All data is expected in complex (x + i*y) format.
%
% CData - Curves as vertically stacked row vectors, i.e.,
%            [ncurves, ndatapoints] = size(CData)
%            Curves are skipped if ncurves = 0
% CColor - Vertically stacked [r g b] colors for each curve, or just one
%            [r g b] color to be used for all curves. 
% PData - Particle locations (first column) and velocities (second column)
%            Velocities determine arrow directions.
%            Particles are skipped if nparticles = 0
% PColor - Particle colors (same format as CColor)
% ASizes - Arrowhead sizes (proportional).  Optional - sizes determined
%            from velocity magnitudes if necessary.
% Edge - Draws a dashed arrow (e.g., graph edge) from the first column to 
%            the second column.  Optional (nil or empty).
% Beta - Optional (nil or = -1), common blind angle (full arc) for
%           particles.
% Rho - Optional (nil or = -1), common sensing radius for particles. 
%
% See also EPSCurve, StartEPS

% DTS 4/4/12 - Initial commit.

if nargin == 7,
    Beta = -1;
    rho = -1;
end

% vars shared with coordinate conversion functions
global xmin xmax ymin ymax H W;

if nargin < 10,
    % Find the natural bounding box
    xmin = min(min(real(CurveData)));
    ymin = min(min(imag(CurveData)));
    xmax = max(max(real(CurveData)));
    ymax = max(max(imag(CurveData)));
    [xmin min(real(ParticleData(:,1)))];
    [xmax max(real(ParticleData(:,1)))];
    [ymin min(imag(ParticleData(:,1)))];
    [ymax max(imag(ParticleData(:,1)))];
    xmin = min([xmin min(real(ParticleData(:,1)))]);
    xmax = max([xmax max(real(ParticleData(:,1)))]);
    ymin = min([ymin min(imag(ParticleData(:,1)))]);
    ymax = max([ymax max(imag(ParticleData(:,1)))]);
    
    % inflate the bounding box 10%
    op = 1.5;
    xmin_new = 0.5*(xmin + xmax) - (0.5 + op)*(xmax - xmin);
    xmax_new = 0.5*(xmin + xmax) + (0.5 + op)*(xmax - xmin);
    ymin_new = 0.5*(ymin + ymax) - (0.5 + op)*(ymax - ymin);
    ymax_new = 0.5*(ymin + ymax) + (0.5 + op)*(ymax - ymin);
    xmin = xmin_new;  ymin = ymin_new;  xmax = xmax_new;  ymax = ymax_new;
else
    xmin = BoundingBox(1);
    xmax = BoundingBox(2);
    ymin = BoundingBox(3);
    ymax = BoundingBox(4);
    op = 1.5;
end

% Find the bounding box in drawing coordinates
W = 640;
H = round(640*(ymax-ymin)/(xmax-xmin));

ObjSize = 0.02*W/(1 + op);

% Figure out if the file exists, create it if not
ftest = fopen(filename);
if(ftest < 0),
    StartEPS(filename,[0 0 W H]);
else,
    fclose(ftest);
end

% Open the file for appending
file = fopen(filename,'a');

% Figure out how many curves and how long each is
[ncurves curvelength] = size(CurveData);
[nparts junk] = size(ParticleData);

% if there are no curves, don't do any of this stuff
if(curvelength),
    
    [ncolors junk] = size(CurveColor);
    if(ncolors < ncurves),
        CurveColor = repmat(CurveColor(1,:), [ncurves 1]);
    end
    
    for ii = 1 : ncurves,
        fprintf(file, '\n\ngsave\nnewpath\n');
        fprintf(file, '0.15 setlinewidth\n');
        fprintf(file, '%f %f %f setrgbcolor\n', CurveColor(ii,1), CurveColor(ii,2), CurveColor(ii,3));
        fprintf(file, '%f %f moveto\n', xconvert(CurveData(ii,1)), yconvert(CurveData(ii,1)));
        for jj = 2 : curvelength,
            if(~isnan(CurveData(ii,jj))),
                fprintf(file, '%f %f lineto\n', xconvert(CurveData(ii,jj)), yconvert(CurveData(ii,jj)));
            end
        end
        fprintf(file,'stroke\ngrestore\n\n');
        
    end
end

[nedges c] = size(Edge);

if(nedges),
    fprintf(file, '\n\n');
    
    %    OLD WAY using edge labels - breaks when we repeat particles
    %   for ii = 1 : nedges,
    %     fprintf(file, '%f 1 %f 1 ', ObjSize, distconvert((ParticleData(Edge(ii,2),1) - ParticleData(Edge(ii,1),1))));
    %     fprintf(file, '%f %f %f edge\n', 180*angle(ParticleData(Edge(ii,2),1) - ParticleData(Edge(ii,1),1))/pi,...
    %         xconvert(ParticleData(Edge(ii,1))), yconvert(ParticleData(Edge(ii,1))));
    %   end
    for ii = 1 : nedges,
        fprintf(file, '%f 1 %f 1 ', ObjSize, distconvert(Edge(ii,2) - Edge(ii,1)));
        fprintf(file, '%f %f %f edge\n', 180*angle(Edge(ii,2) - Edge(ii,1))/pi,...
            xconvert(Edge(ii,1)), yconvert(Edge(ii,1)));
    end
end

% if there are no particles, don't do any of this stuff
if(nparts),
    
    fprintf(file, '\n\n');
    
    [ncolors junk] = size(ParticleColor);
    if(ncolors < nparts),
        ParticleColor = repmat(ParticleColor(1,:), [nparts 1]);
    end
    
    if( ~length(ArrowSizes) )
        minspeed = min(abs(ParticleData(:,2)));
        maxspeed = max(abs(ParticleData(:,2)));
        avgspeed = (minspeed+maxspeed)/2;
        speedspread = maxspeed-minspeed;
        if(speedspread == 0),
            speedspread = 1;
        end
    end
    
    for ii = 1 : nparts,
        
        if( ~length(ArrowSizes) ),
            speed = abs(ParticleData(ii,2));
            arrowsize = 0.5*(avgspeed - speed)/speedspread;
        else,
            arrowsize = ArrowSizes(ii);
        end
        % the arrow syntax is
        %    size R G B orientation(degrees) X Y arrow
        fprintf(file, '%f ', ObjSize*arrowsize);
        fprintf(file, '%f %f %f ', ParticleColor(ii,1), ParticleColor(ii,2), ParticleColor(ii,3));
        fprintf(file, '%f %f ', ObjSize, 180.0*angle(ParticleData(ii,2))/pi);
        fprintf(file, '%f %f ', xconvert(ParticleData(ii,1)), yconvert(ParticleData(ii,1)));
        fprintf(file, 'arrow\n');
        
        if((Beta ~= -1) && (Rho ~= -1)),
            fprintf(file, '%f %f %f %f ', 180*Beta/pi, ParticleColor(ii,1), ParticleColor(ii,2), ParticleColor(ii,3));
            fprintf(file, '%f %f %f %f sensarc\n', distconvert(Rho), 180.0*angle(ParticleData(ii,2))/pi,...
                xconvert(ParticleData(ii,1)), yconvert(ParticleData(ii,1)));
        end
    end
    
end

fclose(file);

clear xmin xmax ymin ymax H W;

function x = xconvert(data)
global xmin xmax ymin ymax H W;
x = (real(data) - xmin)*(W)/(xmax-xmin);

function y = yconvert(data)
global xmin xmax ymin ymax H W;
y = (imag(data) - ymin)*(H)/(ymax-ymin);

function r = distconvert(data)
global xmin xmax ymin ymax H W;
r = W*abs(data)/(xmax-xmin);
