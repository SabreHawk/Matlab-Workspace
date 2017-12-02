function [D,L,U]=dlu(A)
D=zeros(size(A)); 
L=D; 
U=D; 

for i=1:size(A,1) 
    D(i,i)=A(i,i); 
end 
for i=1:size(A,1) 
    for j=1:size(A,2) 
        L(i,j)=-(i <j)*A(i,j); 
        U(i,j)=-(i>j)*A(i,j); 
    end 
end; 
