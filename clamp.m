function out = clamp(in, lowerlimit, upperlimit)
% CLAMP    Limit a value to a range.
%
% out = clamp(in, lowerlimit, upperlimit)
%
% The ix'th element of output is determined as per
%
% if in(ix) < lowerlimit,
%     out(ix) = lowerlimit;
% elseif in(ix) > upperlimit,
%     out(ix) = upperlimit;
% else
%     out(ix) = in(ix);
% end
%
% The actual implementation is array-optimized.

% DTS 4/4/12 - Initial commit.

out = max( min( in, upperlimit ), lowerlimit);

