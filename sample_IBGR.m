clc;
clear;
close all;

%% It is a sample code for IBGR based on a fixed group with five member and seven rated items

load('Rating.mat');

NumUser = 5;
NumItem = 7;

Trust = zeros(NumUser,NumUser);

for i = 1:NumUser
    
    U_i = Rating(i,:)>0;
    Sum_i = sum(U_i);
    
    for j = 1:NumUser
        
        U_j = Rating(j,:)>0;
        Sum_j = sum(U_j);
        
        Intersection = U_i.*U_j;
        IntersectionCount_ij = sum(Intersection);
        
        Dist_ij = pdist([Rating(i,:);Rating(j,:)],'euclidean');
          
        Partnership = IntersectionCount_ij/Sum_i;
        Distance = 1/(1+Dist_ij);
        
        Trust(i,j) = (2*Partnership*Distance)/(Partnership+Distance);
    end
        
end

Similarity = corr(Rating');


MembersSumSimi = (sum(Similarity))-1;
T = Trust';
MembersSumTrust = (sum(T))-1;

[L,LeaderId] = max (MembersSumSimi+MembersSumTrust);

LeaderImpact = L/(2*(NumUser-1));


MembersRating = zeros(NumUser,NumItem);

for i = 1:NumUser
    
    for k = 1:NumItem
        
        if Rating(i,k)==0
           
            Rating_ik = 1;
            
        else
            
            Rating_ik = Rating(i,k);
            
        end
        
        Influe = 0;
        
        for j = 1:NumUser
            
            if i ~= j
                
               Rating_jk = Rating(j,k);
            
               if j== LeaderId
                   
                   Weight_ji = (1/2) * (LeaderImpact + (2 * Similarity(i,j) * Trust(i,j)) / (Similarity(i,j) + Trust(i,j)));
                   
               else
                   
                   Weight_ji = (2 * Similarity(i,j) * Trust(i,j)) / (Similarity(i,j) + Trust(i,j));
                   
               end
            
               if Rating_jk > 0
                
                     Influe = Influe + (Weight_ji * ((Rating_jk - Rating_ik)));
            
               end
               
            end
            
        end
        
        MembersRating(i,k) = Rating_ik + Influe;
        
    end
    
end


GroupRating = (sum(MembersRating))./NumUser;

[R, Index] = sort(GroupRating,'descend');

RecommendationSize = 3;

Satisfying_Treshould = 3;

S = 0;

for i = 1:NumUser
    
    for k = 1:RecommendationSize
        
        ItemId = Index(k);
        
        if Rating(i,ItemId) ~= 0
            
           Rating_ik = Rating(i,ItemId);
           
           if Rating_ik >= Satisfying_Treshould
               
               S = S + 1;
           end
            
        end
    end 
end

Satisfication = (S / (NumUser * RecommendationSize)) * 100;


disp(['  Satisfication  :' num2str(Satisfication)]);



