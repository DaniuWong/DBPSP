%个体间的交叉操作
function [C1,C2]=crossover(P1,P2,Para)
%inputs
num=randi(size(Para.SMset,2));
v=randperm(size(Para.SMset,2));
C1=P1;
C2=P2;
for i=1:num
    len=sum(sum(Para.thetaSM(1:v(i)-1,:)));
    for j=len+1:len+sum(Para.thetaSM(v(i),:))
        C1.chrome(:,j)=P2.chrome(:,j);
        C2.chrome(:,j)=P1.chrome(:,j);
    end
end

parallel=1;
C1=decode(C1, Para,parallel);
C2=decode(C2, Para,parallel);
