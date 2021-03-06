function [ref,numref] = make_reference(daily,varargin)         
% Create a reference trace by stacking over the time period specified by varargin
%
% Input:
%       daily: daily cross correlations
%       varargin:
%             whole = stack over the whole time period (default)
%             month = stack over each month, the first and last day of the
%                       recoding must be specified
%             days = stack over a specified number of days around the the 
%                       day to be measured 
%             firstdays = stack over the first days of the period, number 
%                       of days must be specified
%                   
% Output:
%       ref = the reference trace
%       numref = the number of reference traces 
%
% Written by Karina Løviknes
%

number_of_days = length(daily(:,1)); % Number of days
lenday = length(daily(1,:)); % Length of the day

if isempty(varargin)
    % Default: The reference is the stack of the whole period
    ref = sum(daily);
    numref = 1;
else
    stackperiod = varargin{1};
    num_days = varargin{2};
    
    if strcmp(stackperiod,'whole')
        % Default: The reference is the stack of the whole period
        ref = sum(daily);
        numref = 1;

    elseif strcmp(stackperiod,'month')
        % The refrences are the monthly stacks
        if length(num_days) == 3
            % Find the first and last year and and month:
            fd = str2num(num_days{1}); % First day of recording
            ld = str2num(num_days{2}); % Last day of recording
            [y1,m1,d1,h,mn,s] = datevec(fd);
            [y2,m2,d2,h,mn,s] = datevec(fd);

            % Yearly vector
            yearvec = datevec(years(y1:1:y2));
            yrs = (yearvec(:,1))';
            ny = length(yrs);

            % Monthly vector
            Mf = [m1+1 ones(1,ny-1)];
            Ml = [ones(1,ny-1)*12 m2-1];

            % The first monthly reference is the stack over the first 30 days
            ref(1,:) = sum(daily(1:30,:))

            mi = 1; % Count the number of monthly references
            i = 0; % Count the days
            for yy = 1:length(yrs)
                year = yrs(yy);
                for m = Mf(yy):Ml(yy)
                    mi = mi+1;       
                    daymon = zeros(eomday(year,m),lenday);
                    for dd = 1:eomday(year,m)
                        i = i+1;
                        daymon(dd,:) = daily(i,:);
                    end   
                    ref(mi,:) = sum(daymon);
                end 
            end       
            % The last monthly reference is the stack over the last 30 days:
            ref(mi+1,:) = sum(daily(end-30:end,:));
            numref = mi+1;
        else
            error('There should be two inputs specifying the first and last recording day for the station pair')
        end
    
    elseif strcmp(stackperiod,'firstdays')
        if length(num_days) == 1      
            numdays1 = 1;
            numdays2 = str2num(num_days{1});
        elseif length(num_days) == 2
            numdays1 = str2num(num_days{1});
            numdays2 = str2num(num_days{2});
        else
            error('Specify the days the reference should be stacked over')
        end        
        numref = 1;
        % The reference is the stack of the numdays first days of the
        % period
        ref = sum(daily(numdays1:numdays2,:));
        
    elseif strcmp(stackperiod,'oneday')     
        numdays1 = str2num(num_days{1});
        % The reference is one spesified day
        ref = daily(numdays1,:)*10;      
        numref = 1;
                
    elseif strcmp(stackperiod,'surrounding_days')
        if length(varargin) == 2
            numdays = str2num(num_days{2});
            numref = number_of_days;
            % The reference is the stack of the numdays days prior to the
            % day it is compared to
            ref = zeros(number_of_days,lenday);
                for d = 1:number_of_days
                    if d <= number_of_days
                        ref(d,:) = sum(daily(1:numdays,:));
                    else
                        ref(d,:) = sum(daily(d-numdays:d,:));
                    end
                end
        else
            error('Specify the number of days the refernce should be stacked over')
        end
    end     
end
end