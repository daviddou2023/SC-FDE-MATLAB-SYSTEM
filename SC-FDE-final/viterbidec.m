%Hard Decision Viterbi Decoder


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function gets an encoded message 'rcvd(encoded by a convolutional encoder) 
%as argument and returns the decoded message 'dec_op' 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dec_op]=viterbidec(rcvd)


%Concatenate two consecutive bits of recieved encoded sequence to 
%make up a symbol
input=[];
for j=1:2:length(rcvd)
   input=[ input (rcvd(j))* 2 + (rcvd(j+1))];
end

%initializing all arrays
op_table=[00 00 11; 01 11 00; 10 10 01; 11 01 10]; %OUTPUT array
ns_table=[0 0 2; 1 0 2; 2 1 3; 3 1 3]; %NEXT STATE array
transition_table=[0 1 1 55; 0 0 1 1; 55 0 55 1; 55 0 55 1];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    A R R A Y S - U P D A T I N G  Part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

st_hist(1:4, 1:17)=55; %STATE HISTORY array
aem=zeros(4, 17); %ACCUMULATED ERROR METRIC (AEM) array
ssq=zeros(1, 17); %STATE SEQUENCE array

% input=rcvd;
%input(1, :)=bin2dec(rcvd)
%input=[0 3 3 0 1 2 1 3 3 2 0 0 3 0 3 2 3]    %INPUT vector  
%rcvd=['00';'11';'11';'00';'01';'10';'01';'11';'11';'10';'00';'00';'11';'00';'11';'10'; '11']

lim=length(input); %number of clock cycles
for (t=0:1:lim) %clock loop
%     disp('------------------------------------------------------')
    t; %display current clock instance
    if(t==0)
        st_hist(1,1)=0;        %start at state 00
    else
        temp_state=[];%vector to store possible states at an instant
        temp_metric=[];%vector to store metrics of possible states  
        temp_parent=[];%vector to store parent states of possible states 
        
        for (i=1:1:4) 
            i; 
            in=input(t);
            if(st_hist(i, t)==55)  %if invalid state
                %do nothing
            else    
                ns_a=ns_table(i, 2)+1;    %next possible state-1
                ns_b=ns_table(i, 3)+1;    %next possible state-2 
        
                op_a=op_table(i, 2);      %next possible output-1
                op_b=op_table(i, 3);      %next possible output-2
                
                cs=i-1;                   %current state
                
                M_a=hamm_dist(in, op_a);  %branch metric for ns_a
                M_b=hamm_dist(in, op_b);  %branch metric for ns_b
          
                indicator=0; %flag to indicate redundant states
                
                for k=1:1:length(temp_state) %check redundant next states
                    %if next possible state-1 redundant
                    if(temp_state(1,k)==ns_a) 
                        indicator=1;
                        %ADD-COMPARE-SELECT Operation
                        %em_c: error metric of current state
                        %em_r: error metric of redundant state
                        em_c=M_a + aem(i,t);
                        em_r=temp_metric(1,k) + aem(temp_parent(1, k)+1,t);                        
                        if( em_c< em_r)%compare the two error metrics
                            st_hist(ns_a,t+1)=cs;%select state with low AEM
                            temp_metric(1,k)=M_a;
                            temp_parent(1,k)=cs;
                        end
                    end
                    %if next possible state-2 redundant
                    if(temp_state(1,k)==ns_b)
                        indicator=1;
                        em_c=M_b + aem(i,t);
                        em_r=temp_metric(1,k) + aem(temp_parent(1, k)+1,t);
                        
                        if( em_c < em_r)%compare the two error metrics
                            st_hist(ns_b,t+1)=cs;%select state with low AEM
                            temp_metric(1,k)=M_b;
                            temp_parent(1,k)=cs;
                        end 
                    end 
                end     
                %if none of the 2 possible states are redundant
                if(indicator~=1)
                    %update state history table
                    st_hist(ns_a,t+1)=cs; 
                    st_hist(ns_b,t+1)=cs;
                    %update the temp vectors accordingly                   
                    temp_parent=[temp_parent cs cs];
                    temp_state=[temp_state ns_a ns_b];
                    temp_metric=[temp_metric M_a, M_b];
                end
                %print the temp vectors
                temp_parent;
                temp_state;
                temp_metric;  
            end   
        end
        %update the AEMs (accumulative error metrics) for all states for
        %current instant 't'
        for h=1:1:length(temp_state)
            xx1=temp_state(1, h);
            xx2=temp_parent(1, h)+1;
            aem(xx1, t+1)=temp_metric(1, h) + aem(xx2, t);
        end 
    end
end %end of clock loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       T R A C E - B A C K   Part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for(t=0:1:lim)
    slm=min(aem(:, t+1));
    slm_loc=find( aem(:, t+1)==slm );
    sseq(t+1)=slm_loc(1)-1;
end

dec_op=[];
for p=1:1:length(sseq)-1
    p;
    dec_op=[dec_op, transition_table((sseq(p)+1), (sseq(p+1)+1))];
end



