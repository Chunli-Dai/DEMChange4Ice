
%Test  adjustOffsets.m for coreg3.m
n=5;
icase=2; %1 1.1 2;
switch icase
    case 1 %Not the good example, because the mean of ksi is not zero
        ksi=[1 2 3 4 5;1 2 3 4 5; 1 2 3 4 5]'; 
    case 1.1
        ksi=[1 2 3 4 5;1 2 3 4 5; 1 2 3 4 5]'; 
    case 1.2
        ksi=[1 2 3 4 5;1 2 3 4 5; 1 2 3 4 5]'; 
    case 2 % good example
        ksi=rand(n,3);
        ksi=ksi-mean(ksi); %let the mean of ksi is not zero
end

clear offsets;
count=0;
for idem1=1:n
  for idem2=idem1+1:n
%      p=ksi(idem2,:)-ksi(idem1,:);not consistent with the design matrix in
%      adjustOffsets.m
     p= (ksi(idem2,:)-ksi(idem1,:)); 
     perr=[0.01 0.01 0.01];
     dz=[-0.01 0 0.01];

    count=count+1;
    offsets.i(count)=idem1; %dem 1 index
    offsets.j(count)=idem2; %dem 2 index
    offsets.dz(count)=-p(1); %[n×1 double] z offset (dem 2 - dem 1)
    offsets.dx(count)=-p(2); % [n×1 double] x offset (dem 2 - dem 1)
    offsets.dy(count)=-p(3); % [n×1 double] y offset (dem 2 - dem 1)
    offsets.dze(count)=perr(1); % [n×1 double] z offset 1-sigma error
    offsets.dxe(count)=perr(2); % [n×1 double] x offset 1-sigma error
    offsets.dye(count)=perr(3); % [n×1 double] y offset 1-sigma error
    offsets.mean_dz_coreg(count)=nanmean(dz(:)); % [n×1 double] mean diff in z after corgestration
    offsets.median_dz_coreg(count)=nanmedian(dz(:)); % [n×1 double] median diff in z after corgestration
    offsets.sigma_dz_coreg(count)=nanstd(dz(:)); 
  end
end

switch icase
    case 1 % input 1:5; output dZ=[-2 -1 0 1 2];%Double difference can only gives the residual.
        [dZ,dX,dY] = adjustOffsets(offsets);
    case 1.1 % one line of dem6-dem1=-1;
        if 1
            %input dZ=1:5; and dem1-dem6=1 (assuming dem6 is the reference); 
            %hoping for output: [1:5, 0];
            %actual output: dZ=[-1.5   -0.5    0.5    1.5  2.5   -2.5]
            %dZ-(dZ(1)-1)= [1 2 3 4 5 0]
            %The direct constraint of ksi = 0 +sigma (4m);
            p=[1 1 1];
            count=count+1; 
            offsets.i(count)=6; %dem 1 index
            offsets.j(count)=1; %dem 2 index
        else %same output as above;
            %dem6-dem1=-1;
            p=-[1 1 1];
            count=count+1; 
            offsets.i(count)=1; %dem 1 index
            offsets.j(count)=6; %dem 2 index
        end
        offsets.dz(count)=-p(1); %[n×1 double] z offset (dem 2 - dem 1)
        offsets.dx(count)=-p(2); % [n×1 double] x offset (dem 2 - dem 1)
        offsets.dy(count)=-p(3); % [n×1 double] y offset (dem 2 - dem 1)
        offsets.dze(count)=perr(1); % [n×1 double] z offset 1-sigma error
        offsets.dxe(count)=perr(2); % [n×1 double] x offset 1-sigma error
        offsets.dye(count)=perr(3); % [n×1 double] y offset 1-sigma error
        offsets.mean_dz_coreg(count)=nanmean(dz(:)); % [n×1 double] mean diff in z after corgestration
        offsets.median_dz_coreg(count)=nanmedian(dz(:)); % [n×1 double] median diff in z after corgestration
        offsets.sigma_dz_coreg(count)=nanstd(dz(:)); 
        [dZ,dX,dY] = adjustOffsets(offsets);
        ksi(6,1:3)=[0 0 0];
    case 1.2 %dem6 =[0 0 0]; add five lines of dem6- dem(1:5) -> same results as case 1.1;
        %input [1:5, 0]; output dZ=[[-1.5   -0.5    0.5    1.5  2.5   -2.5]]; %dZ-(dZ(1)-1)= [1 2 3 4 5 0]
        for i=1:5
            %dem6-dem1=-1;
            p=([0 0 0] - ksi(i,:));
            count=count+1; 
            offsets.i(count)=i; %dem 1 index
            offsets.j(count)=6; %dem 2 index
            offsets.dz(count)=-p(1); %[n×1 double] z offset (dem 2 - dem 1)
            offsets.dx(count)=-p(2); % [n×1 double] x offset (dem 2 - dem 1)
            offsets.dy(count)=-p(3); % [n×1 double] y offset (dem 2 - dem 1)
            offsets.dze(count)=perr(1); % [n×1 double] z offset 1-sigma error
            offsets.dxe(count)=perr(2); % [n×1 double] x offset 1-sigma error
            offsets.dye(count)=perr(3); % [n×1 double] y offset 1-sigma error
            offsets.mean_dz_coreg(count)=nanmean(dz(:)); % [n×1 double] mean diff in z after corgestration
            offsets.median_dz_coreg(count)=nanmedian(dz(:)); % [n×1 double] median diff in z after corgestration
            offsets.sigma_dz_coreg(count)=nanstd(dz(:)); 
            [dZ,dX,dY] = adjustOffsets(offsets);
        end %i
        ksi(6,1:3)=[0 0 0];
    case 2 % input rand; 
        %output [dZ,dX,dY]-ksi=[five lines of '-0.47476    -0.30343    -0.39237'];%Double difference can only gives the residual.
        [dZ,dX,dY] = adjustOffsets(offsets);
end

% fprintf(['\n Case ',num2str(icase),' ([dZ,dX,dY])-ksi=:'])
num2str([([dZ,dX,dY])-ksi])
num2str([([dZ,dX,dY]-[dZ(1),dX(1),dY(1)]+ksi(1,:))-ksi])

%compare with inv(ATPA)*ATPY;
%debug in adjustOffsets.m -> wz = 1./dze is closer to dZd compared to using wz = 1./dze.^2;
%                           but its less close to ksi (true value) compared to using wz = 1./dze.^2;
%The least square solution should be wz = 1./dze.

Pz=diag(1./dze.^2);
Px=diag(1./dxe.^2);
Py=diag(1./dye.^2);

dZd = inv(A'*Pz*A)*A'*Pz*dz;
dXd = inv(A'*Px*A)*A'*Px*dx;
dYd = inv(A'*Py*A)*A'*Py*dy;

num2str([([dZ,dX,dY])-[dZd,dXd,dYd]])


