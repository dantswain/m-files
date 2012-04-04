function StartEPS(filename,BoundingBox)
% StartEPS
%
% StartEPS(filename, BoundingBox)
%
% Creates a new eps figure with bounding box given by the elements of 
% BoundingBox ([xmin ymin width height]) in filename and inserts the 
% postscript macros from the ps subdirectory.  This file gets called by 
% EPSCurve and EPSFig (which can determine the bounding box automatically).
%
% See also EPSCurve, EPSFig

% DTS 4/4/12 - Initial commit.

file = fopen(filename,'w');

epspath = [fileparts(mfilename('fullpath')) '/ps/'];
locatepsfilename = [epspath 'locandor.ps'];
arrowpsfilename = [epspath 'arrow.ps'];
sensarcpsfilename = [epspath 'sensarc.ps'];
edgepsfilename = [epspath 'edge.ps'];
fishpsfilename = [epspath 'fish.ps'];

fprintf(file,'%!PS-Adobe-2.0 EPSF-2.0\n');
% Notice %% for a single % in the fprintf calls.
fprintf(file, '%%%%Creator: Matlab->EPSWriter, Dan Swain, 10/13/07 \n');
fprintf(file, '%%%%BoundingBox: %d %d %d %d\n',...
    BoundingBox(1),BoundingBox(2),BoundingBox(3),BoundingBox(4));
fprintf(file,'%%EndComments\n');
fprintf(file,'\n');

% gets clipping rectangle right when figures are inserted into Latex
fprintf(file, '%d %d %d %d rectclip  %% Clip to viewport, remove to not do this\n\n',...
    BoundingBox(1),BoundingBox(2),BoundingBox(3),BoundingBox(4));

% put in the commands necessary to generate the different objects
injectglyph(file, locatepsfilename);
injectglyph(file, arrowpsfilename);
injectglyph(file, sensarcpsfilename);
injectglyph(file, edgepsfilename);
injectglyph(file, fishpsfilename);

fclose(file);



function injectglyph(intofile, fromfile)

ffile = fopen(fromfile,'r');
while 1,
    tline = fgetl(ffile);
    if ~ischar(tline), break, end
    fprintf(intofile,'%s\n',tline);
end
fclose(ffile);
