%个体的变异操作
function child=mutation(Parent,Para)
%inputs
pos=randi(size(Para.SMset,2));
child=Parent;
R=sum(sum(Para.thetaSM(1:pos-1,:)));
len=sum(Para.thetaSM(pos,:));
R1=R+randperm(len);
child.chrome(1,R+1:R+len)=R1;  %每艘船的任务顺序
Berth=find(Para.betaSK(pos,:)==1);
for j=(R+1):(R+len)
    task=child.chrome(1,j);
    child.chrome(2,j)=randi(length(Para.Pm{task})); %每个任务选取的垛位index，通过Para.Pm(j,chrome(2,j))得到垛位号
    Uline=find(Para.alphaUP(:,Para.Pm{task}(child.chrome(2,j)))==1);
    child.chrome(3,j)=Para.lambdaURset{Uline}{randi(length(Para.lambdaURset{Uline}))}; %每个任务选取的取料机号
    Wline=find(Para.alphaWK(:,Berth)==1);
    if Uline==1
        Wline(Wline==2)=[];  %保证取料线和装船线可达
    end         
    child.chrome(4,j)=Wline(randi(length(Wline)));   %每个任务选取的装船机号
end
parallel=1;
child=decode(child, Para,parallel);       