function EPSCurve(filename, Data, Color, BoundingBox)
% EPSCurve     Append a curve to an EPS figure.
%
% EPSCurve(filename, Data, Color, BoundingBox)
%
% Appends a curve to the eps file at filename (or creates it, if
% necessary).   
% 
%   Data  -  Complex (x + i*y) data vector.  
%   Color -  [r g b] color (optional, gray by default). 
%   BoundingBox - Bounding box of the data in data coordinates 
%                   (optional, determined automatically if unspecified)
%
% The width of the figure is pegged at 640 pixels.  This is typically good
% enough.  If absolutely necessary, you can modify the "W" variable in this
% script to change it.
%
% See also StartEPS, EPSFig

% DTS 4/4/12 - Initial commit.

% vars shared with coordinate conversion functions
global xmin xmax ymin ymax H W;

if nargin < 4,
    % Find the natural bounding box
    xmin = min(min(real(Data)));
    ymin = min(min(imag(Data)));
    xmax = max(max(real(Data)));
    ymax = max(max(imag(Data)));
    
    % inflate the bounding box 10%
    xmin_new = 0.5*(xmin + xmax) - 0.6*(xmax - xmin);
    xmax_new = 0.5*(xmin + xmax) + 0.6*(xmax - xmin);
    ymin_new = 0.5*(ymin + ymax) - 0.6*(ymax - ymin);
    ymax_new = 0.5*(ymin + ymax) + 0.6*(ymax - ymin);
    xmin = xmin_new;  ymin = ymin_new;  xmax = xmax_new;  ymax = ymax_new;
else
    xmin = BoundingBox(1);
    xmax = BoundingBox(2);
    ymin = BoundingBox(3);
    ymax = BoundingBox(4);
end

% Find the bounding box in drawing coordinates
W = 640;
H = round(W*(ymax-ymin)/(xmax-xmin));

% Figure out if the file exists, create it if not
ftest = fopen(filename);
if(ftest < 0),
    StartEPS(filename,[0 0 W H]);
else,
    fclose(ftest);
end

% Open the file for appending
file = fopen(filename,'a');

% Default color (gray)
if(nargin < 3),
    Color = [0.75 0.75 0.75];
end

% Figure out how many curves and how long each is
[ncurves curvelength] = size(Data);

[ncolors junk] = size(Color);
if(ncolors < ncurves),
    Color = repmat(Color(1,:), [ncurves 1]);
end

% this will cause problems
if(~curvelength), return, end

for ii = 1 : ncurves,
    fprintf(file, '\n\ngsave\nnewpath\n');
    fprintf(file, '%f %f %f setrgbcolor\n', Color(ii,1), Color(ii,2), Color(ii,3));
    fprintf(file, '%f %f moveto\n', xconvert(Data(ii,1)), yconvert(Data(ii,1)));
    for jj = 2 : curvelength,
        fprintf(file, '%f %f lineto\n', xconvert(Data(ii,jj)), yconvert(Data(ii,jj)));
    end
    fprintf(file,'stroke\ngrestore\n\n');
    
end

fclose(file);

clear xmin xmax ymin ymax H W;

function x = xconvert(data)
global xmin xmax ymin ymax H W;
x = (real(data) - xmin)*(W)/(xmax-xmin);

function y = yconvert(data)
global xmin xmax ymin ymax H W;
y = (imag(data) - ymin)*(H)/(ymax-ymin);
