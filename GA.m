clc;
clear all;
load dataDt.mat;
load dataMCD.mat;
load dataPara.mat;
load dataT.mat;

%算法参数
popsize = 50;
MAXGEN=100;
GGAP=0.8;
PC=0.8;
PM=0.05;
tic 
trend=[];
pop=Initialize(Para,M,popsize); 
for gen=1:MAXGEN
     %%sort 
    T=[];
    for i=1:popsize
        T(i)=pop(i).objective.T;
    end
    [TT,index]=sort(T,2,'ascend');
    
    %VNS for best
    pop(index(1))=VNS(pop(index(1)),Para,MAXGEN);
    best=pop(index(1));
    %selection
    fit=[];
    for i=1:popsize
        if max(TT)>pop(index(1)).objective.T
            fit(i)=(max(TT)-pop(i).objective.T)/(max(TT)-pop(index(1)).objective.T);
        else 
            fit(i)=1;
        end
    end
    normfit=fit./sum(fit);
    select=[];
    for k=1:GGAP*popsize
        b=cumsum(normfit);
        x=min(find(b>=rand));
        select(end+1)=x;
    end
    newnum=1;
    for i=1:2:length(select)
        if rand<PC
            %crossover
            [newpop(newnum),newpop(newnum+1)]=crossover(pop(select(i)),pop(select(i+1)),Para);
            if rand<PM
                %mutation
                newpop(newnum)=mutation(newpop(end-1),Para);
                newpop(newnum+1)=mutation(newpop(end),Para);
            end
            newnum=newnum+2;
        end
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
%         if newpop(newindex(1)).objective.T<pop(index(i)).objective.T
%             kk=i;
%             break;
%         end
    end
    for i=1:popsize
        pop(i)=tem(i);
    end
%     k=1;
%     for i=kk:length(pop)
%         if newpop(newindex(k)).objective.T<pop(index(i)).objective.T
%             pop(index(i))=newpop(newindex(k));
%             k=k+1;
%         end
%         if k>= length(newpop)
%             break;
%         end
%     end
    if pop(1).objective.T<best.objective.T
        best=pop(1);
    end
    trend(end+1)=best.objective.T;
end
toc
disp(['running time:', num2str(toc)]);
disp(['best solution:',num2str(best.objective.T)]);
save GAtrend trend