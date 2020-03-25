classdef CatalyticLabelOracle
    properties
        current
        voltage
        time
        refcv
        label
        score
        Det %details of the BMS oracle
    end
    methods
        function self = CatalyticLabelOracle(current,voltage,time,refcv)

            self.current = current;
            self.voltage = voltage;
            self.time = time;
            self.refcv = refcv;
            if ~((min(current)==0 && max(current)==1))
                self.current = myNormalizeData(current);
            end
            if ~((min(time)==0 && max(time)==1))
                self.time = myNormalizeData(time);
            end
            if ~((min(refcv)==0 && max(refcv)==1))
                self.refcv = myNormalizeData(refcv);
            end
  
        end
        function [label, score] = SimilaritySearch(self,distance)
            if nargin<2
                distance = 'correlation';
            end
            over_potential_range = 0:0.1:0.5;
            dist_mat = [];
            for i=1:length(over_potential_range)
                dist_mat= [dist_mat;pdist2(self.current',...
                    (self.refcv-over_potential_range(i))',distance)];
            end
            for i=2:length(over_potential_range)
                dist_mat= [dist_mat;pdist2(self.current',...
                    (self.refcv+over_potential_range(i))',distance)];
            end
            score = min(dist_mat);
            if score<0.015
                label = 1;
            else
                label = -1;
            end
        end
        function [label, score] = FOWAFit(self)
            const = 38.9211;
            over_potential_range = min(self.voltage):0.1:max(self.voltage);
            lsv_inds = {1:round(length(self.voltage)/2),...
                round(length(self.voltage)/2):length(self.voltage)};
            for lind = 1:length(lsv_inds)
                rsq = [];
                for i = 1:length(over_potential_range)
                    fowa_volt = 1./(1+exp(const*(self.voltage(lsv_inds{lind}) - over_potential_range(i))));
                    y = self.current(lsv_inds{lind});
                    p = polyfit(fowa_volt,y,1);
                    yfit = polyval(p,fowa_volt);
                    yresid = y - yfit;
                    SSresid = sum(yresid.^2);
                    SStotal = (length(y)-1) * var(y);
                    rsq = [rsq;1 - SSresid/SStotal];
                end
                rsq_cell{lind}=rsq;
            end
            score = max(0.5*(rsq_cell{1}+rsq_cell{2}));
            if score>0.95
                label = 1;
            else
                label = -1;
            end
        end
        
        function [label, score, Det]= BayesianModelSelection(self)

            [label,Det] = oracle_cvcatalytic([self.time self.voltage], self.current);
            score = Det.posts(2);
        end
    end
end
