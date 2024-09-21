clc;
clear all;
load dataDt.mat;
load dataMCD.mat;
load dataPara.mat;
load dataT.mat;

%算法参数
popsize = 50;
MAXGEN=100;
LS=100;
trend=[];
tic 
pop=Initialize(Para,M,popsize); 
for gen=1:MAXGEN
     %%sort 
    T=[];
    for i=1:popsize
        T(i)=pop(i).objective.T;
    end
    [TT, index]=max(T);
%     [TT,index]=sort(T,2,'ascend');
    best=pop(index(1));   
    newnum=1;
    for i=1:popsize
        p1=randi(popsize);
        p2=randi(popsize);
        if pop(p1).objective.T>pop(p2).objective.T
            tem1 = p2;
            p2=p1;
            p1=tem1;
        end
        %%learning 
        newpop(newnum)=learning(pop(p1),pop(p2),Para); 
        if rand<0.5
            %mutation
            temindi=mutation(newpop(newnum),Para);
            if(temindi.objective.T<newpop(newnum).objective.T)
                newpop(newnum)=temindi;
            end
        end
        newnum=newnum+1;
    end
     %%sort and best replace the worst
    for i=1:length(newpop)
        T(end+1)=newpop(i).objective.T;
    end
    [nTT,newindex]=sort(T,2,'ascend');
    for i=1:popsize
        if newindex(i)>popsize
            tem(i)=newpop(newindex(i)-popsize);
        else
            tem(i)=pop(newindex(i));
        end
    end
    for i=1:popsize
        pop(i)=tem(i);
    end
    %%lcoal search
    r=randi(0.1*popsize);
    pop(r) = localSearch(pop(r),Para,LS);
    if pop(1).objective.T<best.objective.T
        best=pop(1);
    end
    if pop(r).objective.T<best.objective.T
        best=pop(r);
    end
    trend(end+1)=best.objective.T;
end
toc
disp(['running time:', num2str(toc)]);
disp(['best solution:',num2str(best.objective.T)]);
save KMAtrend trend