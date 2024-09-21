%VNS
function child=VNS(Parent,Para,MAXGEN)
%inputs
child=Parent;

for lambda=1:MAXGEN
    w=0;
    while w<3
        tem=child;
        %%swap
        pos=randi(size(Para.SMset,2));
        R=sum(sum(Para.thetaSM(1:pos-1,:)));
        len=sum(Para.thetaSM(pos,:));
        if w==0
            if len>=2
                R1=R+randperm(len);
                tem.chrome(:,R1(1))=child.chrome(:,R1(2));
                tem.chrome(:,R1(2))=child.chrome(:,R1(1));
            end
        %%reversion
        elseif w==1
            if len>=2
                R1=R+randperm(len);              
                tem.chrome(:,R1(1):R1(2))=flip(tem.chrome(:,R1(1):R1(2)),2);
            end
        %%insertion
        elseif w==2
            if len>2
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

        parallel=1;
        tem=decode(tem, Para,parallel);
        if tem.objective.T<=child.objective.T
            child=tem;
        end
        w=w+1;
    end
end
