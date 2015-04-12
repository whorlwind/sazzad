%directory='c:\Users\zephyr\Desktop\sazzad\'; %Directory that database file is located in
%directory='e:\googleygoogle\summer13files\'; %Directory that database file is located in
directory='./'
datafile=[directory,'ParticipantData3.mat'];
% bad=[1,12,16,4,15,26,19,3,9,21]; %without quicklearners
% good=[20,24,28,25,11,22,8,30,2,29];
good=[2,3,8,10,20,24,25,28,29,32,7,12,14,19,23,27];
%bad=[1,4,9,11,13,15,16,21,26,30,17];
bad=[1,4,5,9,11,13,15,16,17,18,21,26,30,31,22];
goodsize=size(good,2);
badsize=size(bad,2);
load(datafile);
subjects=fieldnames(Database);


for z=[1:5,7:32]
    %% do thresholding of all sounds
    
    for i = 1:size(Database.(subjects{z}).sounds,2)
        
        micformants=Database.(subjects{z}).sounds(i).formants;
        fdbkformants=Database.(subjects{z}).sounds(i).fdbkformants;
        minthresh=.80;
        maxthresh=1.30;
        meansound=mean(micformants(:,3));
        outliers=or(micformants(:,3)<meansound*minthresh,micformants(:,3)>meansound*maxthresh);
        firstoutlier=999;
        for j = 0:(size(outliers,1)-1)
            if and(outliers(end-j)==1,sum(outliers(end-j:end))>j*.90) %from end to beginning find start threshold point where outliers are 70% continuous to end
                firstoutlier=(size(outliers,1)-j);
            end
        end
        if firstoutlier~=999
            micformants=micformants(1:firstoutlier,:);
            if(~isempty(fdbkformants))
                firstoutlier=min(firstoutlier,size(fdbkformants,1));
                fdbkformants=fdbkformants(1:firstoutlier,:);
            end
            
        end
        DB2.(subjects{z}).threshsnds(i).micformants=micformants;
        DB2.(subjects{z}).threshsnds(i).fdbkformants=fdbkformants;
    end
    
    
    %% interpolate all sounds to create standardized 200 point data per sound
    
    for i = 1:size(Database.(subjects{z}).sounds,2)
        micinterp=[];
        fdbkinterp=[];
        micformants=DB2.(subjects{z}).threshsnds(i).micformants;
        fdbkformants=DB2.(subjects{z}).threshsnds(i).fdbkformants;
        micformants(:,1)=(micformants(:,1)-micformants(1,1));
        if size(micformants,1)>30
            timeinterp=(0:(micformants(end,1)/199):(micformants(end,1)))';%creates time stamps for even divisions to make 200 data points
            micinterp=interp1(micformants(:,1),micformants(:,2:4),timeinterp(:,1));%does the interpolation to find f1 at those times
        end
        if size(fdbkformants,1)>30
            fdbkformants(:,1)=fdbkformants(:,1)-fdbkformants(1,1);
            timeinterp=(0:(fdbkformants(end,1)/199):(fdbkformants(end,1)))';
            fdbkinterp=interp1(fdbkformants(:,1),fdbkformants(:,2:4),timeinterp(:,1));
        end
        
        DB2.(subjects{z}).interpsnds(i).micformants=micinterp;
        DB2.(subjects{z}).interpsnds(i).fdbkformants=fdbkinterp;
    end
    %% smooth all sounds with hanning matrix
    for i = 1:size(Database.(subjects{z}).sounds,2)
        micsmooth=[];
        fdbksmooth=[];
        micformants=DB2.(subjects{z}).interpsnds(i).micformants;
        fdbkformants=DB2.(subjects{z}).interpsnds(i).fdbkformants;
        h=hanning(5);h=h/sum(h); %creates hanning matrix
        if(~isempty(micformants))
            micsmooth=convn(micformants,h,'valid'); %convolves hanning matrix with formant frequencies
        end
        if(~isempty(fdbkformants))
            fdbksmooth=convn(fdbkformants,h,'valid');
        end
        
        DB2.(subjects{z}).smoothsnds(i).micformants=micsmooth;
        DB2.(subjects{z}).smoothsnds(i).fdbkformants=fdbksmooth;
    end
    
    %% pull index sound data
    DB2.(subjects{z}).index.baseline=Database.(subjects{z}).index.base(:,1);
    DB2.(subjects{z}).index.basehead=Database.(subjects{z}).index.base(Database.(subjects{z}).index.base(:,8)==4,1);
    DB2.(subjects{z}).index.training=Database.(subjects{z}).index.exp(:,1);
    DB2.(subjects{z}).index.recovery=Database.(subjects{z}).index.recov(:,1);
    
    for i=1:size(DB2.(subjects{z}).index.baseline(:,1))
        DB2.(subjects{z}).index.baseline(i,2:4)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.baseline(i,1)).micformants);
        if ~isempty(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.baseline(i,1)).fdbkformants)
            DB2.(subjects{z}).index.baseline(i,5:7)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.baseline(i,1)).fdbkformants);
        end
    end
    
    for i=1:size(DB2.(subjects{z}).index.basehead(:,1))
        DB2.(subjects{z}).index.basehead(i,2:4)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.basehead(i,1)).micformants);
        if ~isempty(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.basehead(i,1)).fdbkformants)
            DB2.(subjects{z}).index.basehead(i,5:7)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.basehead(i,1)).fdbkformants);
        end
    end
    
    for i=1:size(DB2.(subjects{z}).index.training(:,1))
        DB2.(subjects{z}).index.training(i,2:4)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.training(i,1)).micformants);
        if ~isempty(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.training(i,1)).fdbkformants)
            DB2.(subjects{z}).index.training(i,5:7)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.training(i,1)).fdbkformants);
        end
    end
    
    for i=1:size(DB2.(subjects{z}).index.recovery(:,1))
        DB2.(subjects{z}).index.recovery(i,2:4)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.recovery(i,1)).micformants);
        if ~isempty(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.recovery(i,1)).fdbkformants)
            DB2.(subjects{z}).index.recovery(i,5:7)=mean(DB2.(subjects{z}).smoothsnds(DB2.(subjects{z}).index.recovery(i,1)).fdbkformants);
        end
    end
    
    
    %% Normalize all smoothed sounds by mean baseline frequency and baseline trajectory
    basetrajf0=[];
    basetrajf1=[];
    basetrajf2=[];
    mabasetraj=[];
    mbase=[];
    
    baseline=Database.(subjects{z}).index.base(Database.(subjects{z}).index.base(:,8)==4,1);
    for i=1:size(baseline)
        basetrajf0(:,i)=DB2.(subjects{z}).smoothsnds(baseline(i,1)).micformants(:,1);
        basetrajf1(:,i)=DB2.(subjects{z}).smoothsnds(baseline(i,1)).micformants(:,2);
        basetrajf2(:,i)=DB2.(subjects{z}).smoothsnds(baseline(i,1)).micformants(:,3);
    end
    mbasetraj(:,1)=mean(basetrajf0,2);
    mbasetraj(:,2)=mean(basetrajf1,2);
    mbasetraj(:,3)=mean(basetrajf2,2);
    mbase(1,1)=mean(mbasetraj(:,1));
    mbase(1,2)=mean(mbasetraj(:,2));
    mbase(1,3)=mean(mbasetraj(:,3));
    DB2.(subjects{z}).index.mbasetraj=mbasetraj;
    DB2.(subjects{z}).index.mbase=mbase;
    for i = 1:size(DB2.(subjects{z}).smoothsnds,2)
        if ~isempty(DB2.(subjects{z}).smoothsnds(i).micformants)
            DB2.(subjects{z}).mnormsnds(i).micformants=bsxfun(@minus,DB2.(subjects{z}).smoothsnds(i).micformants,mbase);
            DB2.(subjects{z}).trajnormsnds(i).micformants=DB2.(subjects{z}).smoothsnds(i).micformants-mbasetraj;
            DB2.(subjects{z}).nosmoothmnormsnds(i).micformants=bsxfun(@minus,DB2.(subjects{z}).interpsnds(i).micformants,mbase);
            
        end
        if ~isempty(DB2.(subjects{z}).smoothsnds(i).fdbkformants)
            DB2.(subjects{z}).mnormsnds(i).fdbkformants=bsxfun(@minus,DB2.(subjects{z}).smoothsnds(i).fdbkformants,mbase);
            DB2.(subjects{z}).trajnormsnds(i).fdbkformants=DB2.(subjects{z}).smoothsnds(i).fdbkformants-mbasetraj;
            DB2.(subjects{z}).nosmoothmnormsnds(i).fdbkformants=bsxfun(@minus,DB2.(subjects{z}).interpsnds(i).fdbkformants,mbase);
            
        end
    end
    
    
    
    
    
    
    %% Correlate Mic to Feedback
    
    
    base=[DB2.(subjects{z}).index.basehead(:,1)'];
    train=[DB2.(subjects{z}).index.training(:,1)'];
    recovery=[DB2.(subjects{z}).index.recovery(:,1)'];
    for i=train
        micn=DB2.(subjects{z}).mnormsnds(i).micformants;
        fdbkn=DB2.(subjects{z}).mnormsnds(i).fdbkformants;
        if isempty(micn) || isempty(fdbkn)
            train(train==i)=[];
        end
    end
    
    for i = 1:size(base,2)
        micformants=DB2.(subjects{z}).mnormsnds(base(i)).micformants;
        fdbkformants=DB2.(subjects{z}).mnormsnds(base(i)).fdbkformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(f0cortemp);
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(f2cortemp);
            f2Lag=f2Lagtemp(f2L);
            
            
        end
        
        
        DB2.(subjects{z}).mnormcorr(base(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).mnormcorr(base(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    for i = 1:size(train,2)
        micformants=DB2.(subjects{z}).mnormsnds(train(i)).micformants;
        fdbkformants=DB2.(subjects{z}).mnormsnds(train(i)).fdbkformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(f0cortemp);
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(f2cortemp);
            f2Lag=f2Lagtemp(f2L);
            
        end
        
        
        DB2.(subjects{z}).mnormcorr(train(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).mnormcorr(train(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    for i = 1:size(recovery,2)
        micformants=DB2.(subjects{z}).mnormsnds(recovery(i)).micformants;
        fdbkformants=DB2.(subjects{z}).mnormsnds(recovery(i)).fdbkformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(f0cortemp);
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(f2cortemp);
            f2Lag=f2Lagtemp(f2L);
            
        end
        
        
        DB2.(subjects{z}).mnormcorr(recovery(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).mnormcorr(recovery(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    
    %% Correlate Mic to Previous Feedback
    base=[DB2.(subjects{z}).index.basehead(:,1)'];
    train=[DB2.(subjects{z}).index.training(:,1)'];
    recovery=[DB2.(subjects{z}).index.recovery(:,1)'];
    for i=train
        micn=DB2.(subjects{z}).mnormsnds(i).micformants;
        fdbkn=DB2.(subjects{z}).mnormsnds(i).fdbkformants;
        if isempty(micn) || isempty(fdbkn)
            train(train==i)=[];
        end
    end
    
    for i = 2:size(base,2)
        micformants=DB2.(subjects{z}).mnormsnds(base(i)).micformants;
        fdbkformants=DB2.(subjects{z}).mnormsnds(base(i-1)).fdbkformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(abs(f0cortemp));
            f0Lag=f0Lagtemp(f0L);
            f0c=f0cortemp(f0L);
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(abs(f2cortemp));
            f2Lag=f2Lagtemp(f2L);
            f2c=f2cortemp(f2L);
            
        end
        
        
        DB2.(subjects{z}).NMIN1mnormcorr(base(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).NMIN1mnormcorr(base(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    for i = 2:size(train,2)
        micformants=DB2.(subjects{z}).mnormsnds(train(i)).micformants;
        fdbkformants=DB2.(subjects{z}).mnormsnds(train(i-1)).fdbkformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(abs(f0cortemp));
            f0Lag=f0Lagtemp(f0L);
            f0c=f0cortemp(f0L);
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(abs(f2cortemp));
            f2Lag=f2Lagtemp(f2L);
            f2c=f2cortemp(f2L);
            
            
        end
        
        
        DB2.(subjects{z}).NMIN1mnormcorr(train(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).NMIN1mnormcorr(train(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    for i = 2:size(recovery,2)
        micformants=DB2.(subjects{z}).mnormsnds(recovery(i)).micformants;
        fdbkformants=DB2.(subjects{z}).mnormsnds(recovery(i-1)).fdbkformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(abs(f0cortemp));
            f0Lag=f0Lagtemp(f0L);
            f0c=f0cortemp(f0L);
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(abs(f2cortemp));
            f2Lag=f2Lagtemp(f2L);
            f2c=f2cortemp(f2L);
            
            
        end
        
        
        DB2.(subjects{z}).NMIN1mnormcorr(recovery(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).NMIN1mnormcorr(recovery(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    
    %% normalize each sound by its mean
    for i = 1: size(DB2.(subjects{z}).smoothsnds,2)
        micformants=[];
        fdbkformants=[];
        if ~isempty(DB2.(subjects{z}).smoothsnds(i).micformants)
            micformants=bsxfun(@minus,DB2.(subjects{z}).smoothsnds(i).micformants,nanmean(DB2.(subjects{z}).smoothsnds(i).micformants));
        end
        if ~isempty(DB2.(subjects{z}).smoothsnds(i).fdbkformants)
            fdbkformants=bsxfun(@minus,DB2.(subjects{z}).smoothsnds(i).fdbkformants,nanmean(DB2.(subjects{z}).smoothsnds(i).fdbkformants));
        end
        
        DB2.(subjects{z}).zeroedsnds(i).micformants=micformants;
        DB2.(subjects{z}).zeroedsnds(i).fdbkformants=fdbkformants;
    end
    %% correlate previous normalized mic to current normalized mic
    
    base=[DB2.(subjects{z}).index.basehead(:,1)'];
    train=[DB2.(subjects{z}).index.training(:,1)'];
    recovery=[DB2.(subjects{z}).index.recovery(:,1)'];
    for i=train
        micn=DB2.(subjects{z}).mnormsnds(i).micformants;
        if isempty(micn)
            train(train==i)=[];
        end
    end
    
    for i = 2:size(base,2)
        micformants=DB2.(subjects{z}).zeroedsnds(base(i)).micformants;
        fdbkformants=DB2.(subjects{z}).zeroedsnds(base(i-1)).micformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(f0cortemp);
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(f1cortemp);
            f1Lag=f1Lagtemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(f2cortemp);
            f2Lag=f2Lagtemp(f2L);
            
        end
        
        
        DB2.(subjects{z}).NMIN1zeroedcorr(base(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).NMIN1zeroedcorr(base(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    for i = 2:size(train,2)
        micformants=DB2.(subjects{z}).zeroedsnds(train(i)).micformants;
        fdbkformants=DB2.(subjects{z}).zeroedsnds(train(i-1)).micformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(f0cortemp);
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(f1cortemp);
            f1Lag=f1Lagtemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(f2cortemp);
            f2Lag=f2Lagtemp(f2L);
            
        end
        
        
        DB2.(subjects{z}).NMIN1zeroedcorr(train(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).NMIN1zeroedcorr(train(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    for i = 2:size(recovery,2)
        micformants=DB2.(subjects{z}).zeroedsnds(recovery(i)).micformants;
        fdbkformants=DB2.(subjects{z}).zeroedsnds(recovery(i-1)).micformants;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micformants),~isempty(fdbkformants))
            [f0cortemp,f0Lagtemp]=xcorr(micformants(:,1),fdbkformants(:,1),15,'coeff');
            [f0c,f0L]=max(f0cortemp);
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micformants(:,2),fdbkformants(:,2),15,'coeff');
            [f1c,f1L]=max(f1cortemp);
            f1Lag=f1Lagtemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micformants(:,3),fdbkformants(:,3),15,'coeff');
            [f2c,f2L]=max(f2cortemp);
            f2Lag=f2Lagtemp(f2L);
            
        end
        
        DB2.(subjects{z}).NMIN1zeroedcorr(recovery(i)).correlation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).NMIN1zeroedcorr(recovery(i)).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
        
    end
    
    
    
    %% Find instantaneous velocity, average v, & vrms of non-normalized sounds
    for i = 1: size(DB2.(subjects{z}).smoothsnds,2)
        micformants=DB2.(subjects{z}).smoothsnds(i).micformants;
        fdbkformants=DB2.(subjects{z}).smoothsnds(i).fdbkformants;
        micvelocity = [];
        fdbkvelocity =[];
        if ~isempty(micformants)
            v=diff(micformants);
            DB2.(subjects{z}).smoothsnds(i).micvelocity=v;
            DB2.(subjects{z}).smoothsnds(i).micvrms=sqrt(sum((v.^2)/size(v,1)));
            DB2.(subjects{z}).smoothsnds(i).micmeanv=mean(v);
            [a,b]=max(abs(v));
            DB2.(subjects{z}).smoothsnds(i).micmaxv=[v(b(1),1),v(b(2),2),v(b(3),3)];
        end
        if ~isempty(fdbkformants)
            v=diff(fdbkformants);
            DB2.(subjects{z}).smoothsnds(i).fdbkvelocity=v;
            DB2.(subjects{z}).smoothsnds(i).fdbkvrms=sqrt(sum((v.^2)/size(v,1)));
            DB2.(subjects{z}).smoothsnds(i).fdbkmeanv=mean(v);
            [a,b]=max(abs(v));
            DB2.(subjects{z}).smoothsnds(i).fdbkmaxv=[v(b(1),1),v(b(2),2),v(b(3),3)];
        end
    end
    
    %% Find instantaneous velocity, average v, & vrms of normalized sounds
    for i = 1: size(DB2.(subjects{z}).mnormsnds,2)
        micformants=DB2.(subjects{z}).mnormsnds(i).micformants;
        fdbkformants=DB2.(subjects{z}).mnormsnds(i).fdbkformants;
        micvelocity = [];
        fdbkvelocity =[];
        if ~isempty(micformants)
            v=diff(micformants);
            DB2.(subjects{z}).mnormsnds(i).micvelocity=v;
            DB2.(subjects{z}).mnormsnds(i).micvrms=sqrt(sum((v.^2)/size(v,1)));
            DB2.(subjects{z}).mnormsnds(i).micmeanv=mean(v);
            DB2.(subjects{z}).mnormsnds(i).micmaxv=max(v);
        end
        if ~isempty(fdbkformants)
            v=diff(fdbkformants);
            DB2.(subjects{z}).mnormsnds(i).fdbkvelocity=v;
            DB2.(subjects{z}).mnormsnds(i).fdbkvrms=sqrt(sum((v.^2)/size(v,1)));
            DB2.(subjects{z}).mnormsnds(i).fdbkmeanv=mean(v);
            DB2.(subjects{z}).mnormsnds(i).fdbkmaxv=max(v);
        end
    end
    %% Correlate Mic V to Feedback V
    
    for i = 1: size(DB2.(subjects{z}).mnormsnds,2)
        
        micvelocity=DB2.(subjects{z}).mnormsnds(i).micvelocity;
        fdbkvelocity=DB2.(subjects{z}).mnormsnds(i).fdbkvelocity;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micvelocity),~isempty(fdbkvelocity))
            [f0cortemp,f0Lagtemp]=xcorr(micvelocity(:,1),fdbkvelocity(:,1),15,'coeff');
            [f0c,f0L]=max(f0cortemp);
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micvelocity(:,2),fdbkvelocity(:,2),15,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micvelocity(:,3),fdbkvelocity(:,3),15,'coeff');
            [f2c,f2L]=max(f2cortemp);
            f2Lag=f2Lagtemp(f2L);
            
        end
        DB2.(subjects{z}).mnormcorr(i).vcorrelation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).mnormcorr(i).vmaxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
        
    end
    
    
    %% Correlate Mic V to Previous Feedback V
    
    
    
    for i = 2: size(DB2.(subjects{z}).mnormsnds,2)
        micvelocity=DB2.(subjects{z}).mnormsnds(i).micvelocity;
        fdbkvelocity=DB2.(subjects{z}).mnormsnds(i-1).fdbkvelocity;
        fdbkvelocity=fdbkvelocity*-1;
        f0cortemp=[]; f0Lag=[]; f0c=[];
        f1cortemp=[]; f1Lag=[]; f1c=[];
        f2cortemp=[]; f2Lag=[]; f2c=[];
        if and(~isempty(micvelocity),~isempty(fdbkvelocity))
            micvelocity=micvelocity(20:60,:);
            fdbkvelocity=fdbkvelocity(20:60,:);
            [f0cortemp,f0Lagtemp]=xcorr(micvelocity(:,1),fdbkvelocity(:,1),20,'coeff');
            [f0c,f0L]=max(abs(f0cortemp));
            f0Lag=f0Lagtemp(f0L);
            
            [f1cortemp,f1Lagtemp]=xcorr(micvelocity(:,2),fdbkvelocity(:,2),20,'coeff');
            [f1c,f1L]=max(abs(f1cortemp));
            f1Lag=f1Lagtemp(f1L);
            f1c=f1cortemp(f1L);
            
            [f2cortemp,f2Lagtemp]=xcorr(micvelocity(:,3),fdbkvelocity(:,3),20,'coeff');
            [f2c,f2L]=max(abs(f2cortemp));
            f2Lag=f2Lagtemp(f2L);
            
        end
        
        DB2.(subjects{z}).NMIN1mnormcorr(i-1).vcorrelation=[f0cortemp,f1cortemp,f2cortemp];
        DB2.(subjects{z}).NMIN1mnormcorr(i-1).vmaxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
    end
    
    
    
    
    
    
    %% Correlate Mic to Previous Mic - Previous Feedback
    %
    %
    %
    %         for i = 2: size(DB2.(subjects{z}).mnormsnds,2)
    %             micn=DB2.(subjects{z}).mnormsnds(i).micformants;
    %             micnmin1=DB2.(subjects{z}).mnormsnds(i-1).micformants;
    %             fdbknmin1=DB2.(subjects{z}).mnormsnds(i-1).fdbkformants;
    %
    %             f0cortemp=[]; f0Lag=[]; f0c=[];
    %             f1cortemp=[]; f1Lag=[]; f1c=[];
    %             f2cortemp=[]; f2Lag=[]; f2c=[];
    %             if ~isempty(micn) && ~isempty(micnmin1) && ~isempty(fdbknmin1)
    %                 error=micnmin1-fdbknmin1;
    %                 [f0cortemp,f0Lagtemp]=xcorr(micn(:,1),error(:,1),15,'coeff');
    %                 [f0c,f0L]=max(f0cortemp);
    %                 f0Lag=f0Lagtemp(f0L);
    %
    %                 [f1cortemp,f1Lagtemp]=xcorr(micn(:,2),error(:,2),15,'coeff');
    %                 [f1c,f1L]=max(f1cortemp);
    %                 f1Lag=f1Lagtemp(f1L);
    %
    %                 [f2cortemp,f2Lagtemp]=xcorr(micn(:,3),error(:,3),15,'coeff');
    %                 [f2c,f2L]=max(f2cortemp);
    %                 f2Lag=f2Lagtemp(f2L);
    %
    %             end
    %
    %             DB2.(subjects{z}).errorcor(i-1).correlation=[f0cortemp,f1cortemp,f2cortemp];
    %             DB2.(subjects{z}).errorcor(i-1).maxcorrelation=[f0c,f1c,f2c;f0Lag,f1Lag,f2Lag];
end

