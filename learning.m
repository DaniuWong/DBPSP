%差的个体P2向好的个体P1学习
function C=learning(P1,P2,Para)
%inputs
C=P2;

deltaT=P2.objective.Cm-P1.objective.Cm;
[T, index]=max(deltaT);
for i=1:length(index)
    len=sum(sum(Para.thetaSM(1:index(i)-1,:)));
    for j=len+1:len+sum(Para.thetaSM(index(i),:))
        C.chrome(:,j)=P1.chrome(:,j);
    end
end
parallel=1;
C=decode(C, Para,parallel);
