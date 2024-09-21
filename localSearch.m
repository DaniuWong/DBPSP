%VNS
function child=localSearch(Parent,Para,LS)
%dbstop if all error
%inputs
child=Parent;
flag=true;
for lambda=1:LS
    if flag==true
        %%选取执行任务时间最长的船
        [T,pos]=max(Parent.objective.Cm);
    else
        %%随机选取船
        pos=randi(size(Para.SMset,2));
    end
    tem=child;    
    R=sum(sum(Para.thetaSM(1:pos-1,:)));
    len=sum(Para.thetaSM(pos,:));
    Berth=find(Para.betaSK(pos,:)==1);
    if len>=2
        if rand<0.5
        %%swap
            R1=R+randperm(len);
            tem.chrome(:,R1(1))=child.chrome(:,R1(2));
            tem.chrome(:,R1(2))=child.chrome(:,R1(1));
        %%insertion
        else
            R1=R+randperm(len);
            if R1(1)>R1(2)
                tem.chrome(:,R1(1))=[];
                tem.chrome=[tem.chrome(:,1:R1(2)-1),child.chrome(:,R1(1)),tem.chrome(:,R1(2):end)];
            else 
                tem.chrome(:,R1(2))=[];     
                tem.chrome=[tem.chrome(:,1:R1(1)-1),child.chrome(:,R1(2)),tem.chrome(:,R1(1):end)];
            end
        end
    end
    %%对每个任务都选取具有两台取料机可达的堆垛
    for i=R+1:R+len
        task=tem.chrome(1,i);
        Uline=find(Para.alphaUP(:,Para.Pm{task}(tem.chrome(2,i)))==1);
        temflag=false;
        if length(Para.lambdaURset{Uline})==1
            for j=1:length(Para.Pm{task})
                for k=1:length(Para.Pm{task})
                    if j~=k
                        if find(Para.alphaUP(:,Para.Pm{task}(j))==1)==find(Para.alphaUP(:,Para.Pm{task}(k))==1)
                            tem.chrome(2,i)=j;
                            temflag=true;
                            break;
                        end
                    end
                end
                if temflag==true
                    break;
                end
            end
        end
    end
    %%对每个任务选取与相邻任务可以并行作业的装船机 
    for i=R+1:R+len
        task=tem.chrome(1,i);
        Uline=find(Para.alphaUP(:,Para.Pm{task}(tem.chrome(2,i)))==1);
        Wline=find(Para.alphaWK(:,Berth)==1);
        if Uline==1
            Wline(Wline==2)=[];  %保证取料线和装船线可达
        end  
        if i==R+1
            tem.chrome(4,i)=Wline(randi(length(Wline))); 
        else
            temflag=false;
            if length(Wline)>1
                for j=1:length(Wline)
                    if Wline(j)-tem.chrome(4,i-1)==1 || Wline(j)-tem.chrome(4,i-1)==-1
                        tem.chrome(4,i)=Wline(j);
                        temflag=true;
                        break;
                    end
                end
            end
        end
        if temflag==false
            tem.chrome(4,i)=Wline(randi(length(Wline))); 
        end
    end
    parallel=1;
    tem=decode(tem, Para,parallel);
    if tem.objective.T<=child.objective.T
        child=tem;
    else
        flag=~flag;
    end
end
