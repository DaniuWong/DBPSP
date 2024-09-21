%%绘制甘特图
function ganttchart(solution, Para)

%% 画甘特图
col=jet(size(Para.SMset,2));                                                    %颜色的设定
rec=zeros(1,4);
num=0;
for i=1:size(Para.SMset,2)
    Berth=find(Para.betaSK(i,:)==1);
    len=sum(Para.thetaSM(i,:));
    for j=(num+1):(num+len)
        task_rank=solution.chrome(1,j);  %任务编号
        Claimer=solution.chrome(3,j);  %取料机编号
        Shiploader=solution.chrome(4,j);       %装船机编号
        ma_rank=(Berth-1)*length(Para.Wset)+Shiploader;  %机器编号
        Ship=i;         %船的编号
        ST_ope=solution.decode.t_m(task_rank);                                    %取出该任务开始加工时间
        CT_ope=solution.decode.t_m(task_rank)+solution.decode.Tm(task_rank);                  %取出该任务结束加工时间
        rec(1)=ST_ope;                                                         %矩形的横坐标
        rec(2)=ma_rank-0.5;                                                    %矩形的纵坐标
        rec(3)=CT_ope-ST_ope;                                                  %矩形的x轴方向的长度
        rec(4)=0.7;
        rectangle('Position',rec,'LineWidth',1.5,'LineStyle','-','FaceColor',col(i,:)); %draw every rectangle
        text(rec(1)+rec(3)*0.5-2,ma_rank+rec(4)/4,strcat('T',num2str(task_rank)),'fontsize',10);
        %text(rec(1)+rec(3)*0.5-2,ma_rank-rec(4)/4,strcat('S',num2str(Shiploader)),'fontsize',10);
    end
    num=num+len;
    ST_ope=solution.decode.t_arr(i);                                   
    CT_ope=solution.decode.t_dep(i);                
    rec(1)=ST_ope;                                                         %矩形的横坐标
    rec(2)=(Berth-1)*length(Para.Wset)+0.5;                                                    %矩形的纵坐标
    rec(3)=CT_ope-ST_ope; 
    rec(4)=0.9*length(Para.Wset);
    rectangle('Position',rec,'LineWidth',1.5,'LineStyle','-'); %draw every rectangle
    text(rec(1)+0.5,(Berth-1)*length(Para.Wset)+rec(4)/4,strcat('S',num2str(Ship)),'fontsize',10);
end
makespan=max(solution.decode.t_dep);
Machine_number=length(Para.Kset)*length(Para.Wset);
mach_info=cell(1,Machine_number);                                          %存储字符串变量，机器
k=1;
for i=1:length(Para.Kset)
    for j=1:length(Para.Wset)
        str1='Berth';
        str=sprintf('%s%d%s%d',str1,i,'S',j);
        mach_info{1,k}=str;
        k=k+1;
    end
end
y=1:Machine_number;
x=0:0.1*makespan:makespan*1.001;
set(gca,'YTick',y);                                                       %设置y坐标轴的范围
set(gca,'XTick',x);
set(gca,'YTickLabel',mach_info);
set(gca,'FontName','Times New Roman','FontSize',10);
hold on
end
