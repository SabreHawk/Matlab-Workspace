function [x, error, iter, flag] = gmres( A,b,restrt, max_it, tol ) 
  iter = 0;                              
  flag = 0; 
  omiga=1.2; 
  [D,L,U]=dlu(A);
  M=(D-omiga*L)*inv(D)*(D-omiga*U)/(omiga*(2-omiga));
  [cols,rows]=size(b); 
  if cols > rows 
      x=ones(cols,1);
  else 
      x=ones(rows,1);
      b=b'; 
  end; 
  bnrm2 = norm( b ); 
  if  ( bnrm2 == 0.0 ), bnrm2 = 1.0; end 

  r = M \ ( b-A*x ); 
  error = norm( r ) / bnrm2; 
  if ( error < tol ) return;
  end 

  [n,n] = size(A);                               
  m = restrt; 
  V(1:n,1:m+1) = zeros(n,m+1); 
  H(1:m+1,1:m) = zeros(m+1,m); 
  cs(1:m) = zeros(m,1); 
  sn(1:m) = zeros(m,1); 
  e1    = zeros(n,1); 
  e1(1) = 1.0; 

  for iter = 1:max_it 
      r = M \ ( b-A*x ); 
      V(:,1) = r / norm( r ); 
      s = norm( r )*e1; 
      for i = 1:m                         
      w = M \ (A*V(:,i));                        
      for k = 1:i 
          H(k,i)= w'*V(:,k); 
          w = w - H(k,i)*V(:,k); 
      end 
      H(i+1,i) = norm( w ); 
      V(:,i+1) = w / H(i+1,i); 
      for k = 1:i-1 
              temp    =  cs(k)*H(k,i) + sn(k)*H(k+1,i); 
              H(k+1,i) = -sn(k)*H(k,i) + cs(k)*H(k+1,i); 
              H(k,i)  = temp; 
      end 
      [cs(i),sn(i)] = rotmat( H(i,i), H(i+1,i) ); 
          temp  = cs(i)*s(i);                       
          s(i+1) = -sn(i)*s(i); 
      s(i)  = temp; 
          H(i,i) = cs(i)*H(i,i) + sn(i)*H(i+1,i); 
          H(i+1,i) = 0.0; 
      error  = abs(s(i+1)) / bnrm2; 
      if ( error <= tol )                       
          y = H(1:i,1:i) \ s(1:i);             
              x = x + V(:,1:i)*y; 
          break; 
      end 
      end

      if ( error <= tol ), break, end 
      y = H(1:m,1:m) \ s(1:m); 
      x = x + V(:,1:m)*y;                        
      r = M \ ( b-A*x );                           
      s(i+1) = norm(r); 
      error = s(i+1) / bnrm2;                         
      if ( error <= tol ), break, end; 
  end  

  if ( error > tol ) flag = 1; end;                % converged 

% END of gmres.m 



