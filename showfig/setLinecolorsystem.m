%%  charactor of all lines
ctype = {'b','c','g','r','k','m'}; 
ptype = {'d','v','o','s','^','x','*','p','h'};
%additional colors:  purple, brown, pink
colornum = [255 20 147;139 76 57;160 32 240;255,200,0];
colornum = colornum/255;
ltype = {'-','-.',':','--'};
lw = 3; 
ms= 5;

type = {'-bd'; '-.kv'; '-rs'; '-go'; '-m^';...,
    [ltype{1},ptype{6}]; ...,
    [ltype{2},ptype{4}]; ...,
    [ltype{1},ptype{8}];...,
[ltype{1},ptype{7}]};

type_line = cell(1, length(ctype)); 
for i = 1:length(ctype)
    type_line{i} = ['-', ctype{i}]; 
end