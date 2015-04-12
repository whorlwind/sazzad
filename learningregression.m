learngood=[];
for z=good
    base=[];
    te=[];
    ts=[];
    re=[];
    
    
    basehead=DB2.(subjects{z}).index.basehead;
    training=DB2.(subjects{z}).index.training;
    trainpercent=.30;
    trainnumber=round(size(training,1)*trainpercent);
    ts=nanmean(training(1:trainnumber,3));
    te=nanmean(training(end-(trainnumber-1):end,3));
    base=nanmean(basehead(:,3));
    learn=(te-base)/base;
    learngood=[learngood;z,learn];
end
learnbad=[];
for z=bad
    base=[];
    te=[];
    ts=[];
    re=[];
    
    
    
    
    basehead=DB2.(subjects{z}).index.basehead;
    training=DB2.(subjects{z}).index.training;
    trainpercent=.30;
    trainnumber=round(size(training,1)*trainpercent);
    ts=nanmean(training(1:trainnumber,3));
    te=nanmean(training(end-(trainnumber-1):end,3));
    base=nanmean(basehead(:,3));
    learn=(te-base)/base;
    learnbad=[learnbad;z,learn];
end
% learnyz=[];
% for z=yz
%     base=[];
%     te=[];
%     ts=[];
%     re=[];
%     
%     
%     
%     
%     basehead=DB2.(subjects{z}).index.basehead;
%     training=DB2.(subjects{z}).index.training;
%     trainpercent=.30;
%     trainnumber=round(size(training,1)*trainpercent);
%     ts=nanmean(training(1:trainnumber,3));
%     te=nanmean(training(end-(trainnumber-1):end,3));
%     base=nanmean(basehead(:,3));
%     learn=(te-base)/base;
%     learnyz=[learnyz;learn];
% end

%for j=1:30
 %   beg=j;
 %   en=j+60;
    
    
%     ctebad=(nanmean(tebad(beg:en,:))'-nanmean(tsbad(beg:en,:))');
%     ctegood=(nanmean(tegood(beg:en,:))'-nanmean(tsgood(beg:en,:))');
%     
%     
%     xxgood=[learngood,nanmean(tsgood(beg:en,:))',nanmean(tegood(beg:en,:))',nanmean(regood(beg:en,:))',ctegood];
%     xxbad=[learnbad,nanmean(tsbad(beg:en,:))',nanmean(tebad(beg:en,:))',nanmean(rebad(beg:en,:))',ctebad];
%     xx=[xxgood;xxbad];
%     
%     
    
%     xxgood=[learngood,goodcorpf];
%     xxbad=[learnbad,badcorpf];
%     xx=[xxgood;xxbad];
%     
%     



%      xxgood=[learngood,nanmean(tagood)',(nanstd(tagood)'./sqrt(178))];
%      xxbad=[learnbad,nanmean(tabad)',(nanstd(tabad)'./sqrt(178))];
%      xx=[xxgood;xxbad];
%      figure;
%      hold on;
%      errorbar(xx(:,1),xx(:,2),xx(:,3),'w.');
%      errorbar(xxgood(:,1),xxgood(:,2),xxgood(:,3),'c.');
%      errorbar(xxbad(:,1),xxbad(:,2),xxbad(:,3),'k.');
     
%     

%     for i =2:5
%         [a,b]=corrcoef(xx(:,1),xx(:,i));
%         if b(1,2)<.05
%             [1,i,a(1,2),b(1,2)]
%         end
%         [a,b]=corrcoef(xxgood(:,1),xxgood(:,i));
%         if b(1,2)<.05
%             [2,i,a(1,2),b(1,2)]
%         end
%         [a,b]=corrcoef(xxbad(:,1),xxbad(:,i));
%         if b(1,2)<.05
%             [2,i,a(1,2),b(1,2)]
%         end
%     end
% %end
% 
