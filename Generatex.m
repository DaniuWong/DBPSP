%随机产生解
function solution=Generatex(Para,M)
%inputs
%outputs
%chrom_os:chromosome of operation sequence(OS) (vector)
%Population_st:结构数组，分别包括：染色体、解码信息、目标值

%%
chrome=zeros(4,M);   %存储种群染色体
solution=struct('chrome',[],'decode',[],'objective',[]);

%% random vector for chromosome of OS
num = 0;
for i=1:size(Para.SMset,2)
    len=sum(Para.thetaSM(i,:));
    R1=num+randperm(len);
    chrome(1,num+1:num+len)=R1;  %每艘船的任务顺序
    Berth=find(Para.betaSK(i,:)==1);
    for j=(num+1):(num+len)
        task=chrome(1,j);
        chrome(2,j)=randi(length(Para.Pm{task})); %每个任务选取的垛位index，通过Para.Pm(chrome(1,j),chrome(2,j))得到垛位号
        Uline=find(Para.alphaUP(:,Para.Pm{task}(chrome(2,j)))==1);
        chrome(3,j)=Para.lambdaURset{Uline}{randi(length(Para.lambdaURset{Uline}))}; %每个任务选取的取料机号
        Wline=find(Para.alphaWK(:,Berth)==1);
        if Uline==1
            Wline(Wline==2)=[];  %保证取料线和装船线可达
        end         
        chrome(4,j)=Wline(randi(length(Wline)));   %每个任务选取的装船机号
    end
    num=num+len;
end
solution.chrome=chrome;
parallel=1;
solution=decode(solution, Para,parallel);
end
