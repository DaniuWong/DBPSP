%根据heuristic解码
function [solution]=decode(solution, Para, parallel)
%染色体解码
%parallel=1表示采用heuristic考虑取料机并联，否则不考虑

%outputs
%decode：调度方案(cell)
%每行有M个元胞，每个元胞每列如下
%%第一列：装船作业时长Tm
%%第二列：取料机作业时长Rtm
%%第三列：从堆垛到泊位的运输时长Dtm
%%第四列：任务开始装船时间t_m
%%第五列：任务结束时间t_me
%%第六列：船舶进港时间t_arr
%%第七列：船舶离港时间t_dep
%%第八列：各取料机的占用时间，每个元素包括任务数编号、服务的垛位、开始时间、结束时间Reclaimer
%%第九列：各装船机的占用时间，每个元素包括任务数编号、服务的泊位、开始时间、结束时间Shiploder
%%第十列：各泊位的进港和离港时间Berth

%decode.objective:调度方案目标值
%第一列：每个船舶的完成时间Cm
%第二列：总任务完成时间T
num=0;
solution.decode=struct('Tm',[],'Rtm',[],'Dtm',[],'t_m',[],'t_me',[],'t_arr',[],'t_dep',[],'Reclaimer',[],'Shiploader',[],'Berth',[]);
solution.objective=struct('Cm',[],'T',0);
solution.decode.Reclaimer={};%cell(length(Para.Rset),1);
for i=1:length(Para.Rset)
    solution.decode.Reclaimer{i,1}=zeros(1,4);
end
solution.decode.Shiploader={};%cell(length(Para.Wset),1);
for i=1:length(Para.Wset)
    solution.decode.Shiploader{i,1}=zeros(1,4);
end
solution.decode.Berth={};%cell(length(Para.Kset),1);
for i=1:length(Para.Kset)
    solution.decode.Berth{i,1}=zeros(1,2);
end
solution.objective.Cm=zeros(size(Para.SMset,2),1);
Rnum=ones(length(Para.Rset),1);
Snum=ones(length(Para.Wset),1);
Bnum=ones(length(Para.Kset),1);
for i=1:size(Para.SMset,2)
    Berth=find(Para.betaSK(i,:)==1);
    len=sum(Para.thetaSM(i,:));
    if Bnum(Berth)==1
        begint = hours(Para.t_ar{i})+Para.t_tr(i);
    else
        begint=max(solution.decode.Berth{Berth,Bnum(Berth)}(2),hours(Para.t_ar{i})+Para.t_tr(i));
    end
    solution.decode.t_arr(end+1)=begint;
    for j=(num+1):(num+len)
        task=solution.chrome(1,j);
        if j==num+1
            start=begint+Para.t_aux(i);
        end
        tem=find(Para.Krr(solution.chrome(3,j),:)==1);
        if i==1&&j==1
            opeRs=start;
            opeSs=start;            
        else
            if solution.decode.Shiploader{solution.chrome(4,j),Snum(solution.chrome(4,j))}(2)==0
                oBerth=Berth;
            else
                oBerth=solution.decode.Shiploader{solution.chrome(4,j),Snum(solution.chrome(4,j))}(2);
            end
            %%取料线优先级            
            if(length(tem)==2)
                maxR=max(solution.decode.Reclaimer{tem(1),Rnum(tem(1))}(end),solution.decode.Reclaimer{tem(2),Rnum(tem(2))}(end));
            elseif length(tem)==1
                maxR=solution.decode.Reclaimer{tem(1),Rnum(tem(1))}(end);
            end
            %%考虑装船机联机，若装船机编号为1或3，则需同时考虑安排在3或1号装船机完成之后；若装船机为2号，则需考虑与相邻装船机是否交叉
            if solution.chrome(4,j)==1
                maxS=max(solution.decode.Shiploader{3,Snum(3)}(end),Para.paiKK(oBerth,Berth)+solution.decode.Shiploader{solution.chrome(4,j),Snum(solution.chrome(4,j))}(end));
            elseif solution.chrome(4,j)==3
                maxS=max(solution.decode.Shiploader{1,Snum(1)}(end),Para.paiKK(oBerth,Berth)+solution.decode.Shiploader{solution.chrome(4,j),Snum(solution.chrome(4,j))}(end));
            elseif solution.chrome(4,j)==2             
                maxS=Para.paiKK(oBerth,Berth)+solution.decode.Shiploader{solution.chrome(4,j),Snum(solution.chrome(4,j))}(end);
                if Berth>solution.decode.Shiploader{3,Snum(3)}(2)
                    maxS=max(maxS, solution.decode.Shiploader{3,Snum(3)}(end));
                elseif Berth<solution.decode.Shiploader{1,Snum(1)}(2)
                    maxS=max(maxS, solution.decode.Shiploader{1,Snum(1)}(end));
                end
            end
            opeRs=max([start,maxR,maxS]);
            opeSs=max([start,maxR,maxS]);
        end
        solution.decode.Rtm(task)=Para.Dm(task)/(Para.Vr{solution.chrome(3,j)});
        if parallel==1
            flag=false;
            if(length(tem)==2)
                %判断是否满足并行作业条件
                aR = tem(1);
                if aR==solution.chrome(3,j)
                    aR=tem(2);
                end
                %判断该取料作业线上是否有其他堆垛可以取料
                Uline=find(Para.lambdaUR(:,aR)==1);
                for k=1:length(Para.Pm{task})
                    if Para.Pm{task}(k)~=Para.Pm{task}(solution.chrome(2,j))
                        if Para.alphaUP(Uline,Para.Pm{task}(k))==1
                            aStack=Para.Pm{task}(k);
                            flag=true;
                            break;
                        end
                    end
                end
                %根据时间来判断是否需要并行取料提高效率
                if flag==true
                    if solution.decode.Reclaimer{aR,Rnum(aR)}(end)<=opeRs 
                        solution.decode.Rtm(task)=Para.Dm(task)/(Para.Vr{solution.chrome(3,j)}+Para.Vr{aR});
                    elseif solution.decode.Reclaimer{aR,Rnum(aR)}(end)+Para.Dm(task)/(Para.Vr{solution.chrome(3,j)}+Para.Vr{aR})<=opeRs+Para.Dm(task)/(Para.Vr{solution.chrome(3,j)})
                        solution.decode.Rtm(task)=Para.Dm(task)/(Para.Vr{solution.chrome(3,j)}+Para.Vr{aR});
                        maxR=max(maxR,solution.decode.Reclaimer{aR,Rnum(aR)}(end));
                        opeRs=max(opeRs, maxR);
                        opeSs=max(opeSs, maxR);
                    end
                end            
            end
        end
        solution.decode.Dtm(task)=Para.DtPK(i, solution.chrome(4,j));
        solution.decode.Tm(task)=solution.decode.Rtm(task)+solution.decode.Dtm(task);          
        solution.decode.t_m(task)=opeRs;
        solution.decode.t_me(task)=opeSs+solution.decode.Tm(task);
        opeR=[Rnum(solution.chrome(3,j))+1,Para.Pm{solution.chrome(1,j)}(solution.chrome(2,j)),opeRs,opeRs+solution.decode.Rtm(task)];
        opeS=[Snum(solution.chrome(4,j))+1,Berth,opeSs,solution.decode.t_me(task)];
        if j==num+len
            endt=max(solution.decode.t_me((num+1):(num+len)))+Para.t_un(i); 
            solution.decode.t_dep(end+1)=endt;
        end
        solution.decode.Reclaimer{solution.chrome(3,j),opeR(1)}=opeR;
        if parallel==1 && flag==true
            solution.decode.Reclaimer{aR,Rnum(aR)+1}=[Rnum(aR)+1, aStack,opeRs,opeRs+solution.decode.Rtm(task)];
            Rnum(aR)=Rnum(aR)+1;
        end
        solution.decode.Shiploader{solution.chrome(4,j),opeS(1)}=opeS;
        Rnum(solution.chrome(3,j))=Rnum(solution.chrome(3,j))+1;
        Snum(solution.chrome(4,j))=Snum(solution.chrome(4,j))+1;
    end
    solution.objective.Cm(i)=endt-begint;
    solution.decode.Berth{Berth,Bnum(Berth)+1}=[begint,endt];
    Bnum(Berth)=Bnum(Berth)+1;
    num=num+len;
end
solution.objective.T=sum(solution.objective.Cm(:,1));
end

