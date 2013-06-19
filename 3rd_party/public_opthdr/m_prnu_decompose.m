function [ahat avig] = m_prnu_decompose(a)

%n = size(a,2);
%x = (1:n)';
%y = a(1,:)';

% 2d try #1
%c = polyfit(x,y,2);
%figure(1), clf
%plot(x,y,'r;original;'), hold on,
%plot(x,c(1)*x.^2+c(2)*x.^1+c(3)*x.^0,'g;polyfit;')

% 2d try #2
%c = [ones(n,1) x x.^2] \ y
%plot(x,c(1)*x.^0+c(2)*x.^1+c(3)*x.^2,'b;slash;')

% 3d try #1
%nm = size(a);
%[x y] = meshgrid(1:nm(2), 1:nm(1));
%x = x(:); y = y(:);
%%xy = [ones(nm)(:) x(:) x(:).^2 y(:) y(:).^2 x(:).*y(:)]; % 2nd degree
%xy = [ones(nm)(:) x x.^2 x.^3 y y.^2 y.^3 x.^2.*y x.*y.^2]; % 3rd degree
%c = xy \ a(:);
%ahat = xy*c;
%ahat = reshape(ahat, nm);
%disp(sprintf('MSE=%f',mean((a(:)-ahat(:)).^2)));

% 3d try #2

avig = imfilter(a, fspecial('gaussian', 13, 2), 'symmetric');
ahat = a./avig;
% a = ahat + avig
