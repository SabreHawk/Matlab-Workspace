%{  
  File Illustration:
  Creation Time : 2017/5/25
  Creator : SabreHawk - Zhiquan Wang
 
  TimeStep  |    Author     |  Comment
  2017/5/26 | Zhiquan Wang  | Complete The Entrie Function
  
  Script Illustration:
  Function:
   Calculate The Root Of The Equation
  Method:
    HalfInterval
%}

function root = HalfInterval(f,a,b,eps)

if nargin == 3
    eps = 1.0e-4;
end

f1 = subs(sym(f),findsym(sym(f)),a);
f2 = subs(sym(f),findsym(sym(f)),b);

if f1 == 0
    root = a;
elseif f2 == 0
    root = b;
elseif f1 * f2 > 0
    disp('No Root');
    return;
else
    root = FindRoots(f,a,b,eps);
end

function r = FindRoots(f,a,b,eps)
f_1 = subs(sym(f),findsym(sym(f)),a);
f_2 = subs(sym(f),findsym(sym(f)),b);
f_m = subs(sym(f),findsym(sym(f)),(a+b)/2);

r1 = f_1 * f_m;
r2 = f_2 * f_m;

if r1 == 0 %|| r2== 0
    r = (a+b)/2;
elseif abs(b-a) < eps
    r = (b + 3 * a) / 4;
elseif r1 < 0
    r = FindRoots(f,a,(a+b)/2,eps);
elseif r2 < 0
    r = FindRoots(f,(a+b)/2,b,eps);
else 
    disp('Unconsiderable Conditions');
end

    
    

