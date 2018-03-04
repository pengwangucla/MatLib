function salmapsind  = genplotind(rows,cols,figmat)
figmat = figmat([2,1]);
[posx,posy] = meshgrid(cols,rows);
posx = posx'; posy = posy';
salmapsind = sub2ind(figmat,posx(:),posy(:));
end