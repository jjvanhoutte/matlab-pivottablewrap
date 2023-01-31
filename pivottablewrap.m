function out=pivottablewrap(inMatrix, pivotRow, varargin)
%wrapper for pivottable that allows tables as input and output 
%and deals with column names
%and repeats the functions as needed 
%              
%SYNTAX
% pivottablewrap(inMatrix, pivotRow, varargin)
% pivottablewrap(inMatrix, pivotRow, valueColumn, valueFun)
% pivottablewrap(inMatrix, pivotRow, pivotColumn, valueColumn, valueFun)
% pivottablewrap(..., empty2NaN) if true converts empty cells in numeric
%                                   columns to NaN (default = false)

narg_in=nargin;

if islogical(varargin{end})
    empty2NaN=varargin{end};
    varargin=varargin(1:end-1);
    narg_in=nargin-1;
else
    empty2NaN=false;
end

if narg_in == 5
    pivotColumn = varargin{1};
    valueColumn = varargin{2};
    valueFun = varargin{3};
else
    pivotColumn = [];
    valueColumn = varargin{1};
    valueFun = varargin{2};
end

if size(valueFun,2)<size(valueColumn,2)
    if size(unique(stringwrap(valueFun)),2)>1 
        warning('ValueFun has fewer columns than ValueColumn: repeating');
    end
    temp=repmat(valueFun,[1,ceil(size(valueColumn,2)/size(valueFun,2))]);
    valueFun=temp(1:size(valueColumn,2));
elseif size(valueFun,2)>size(valueColumn,2)
    warning('ValueFun has more columns than ValueColumn: truncating');
    valueFun=valueFun(1:size(valueColumn,2));
end

if istable(inMatrix)
    
    variableNames=[inMatrix.Properties.VariableNames(pivotRow)];
    if sum(size(pivotColumn))==0
        variableNames=[variableNames inMatrix.Properties.VariableNames(valueColumn)];
    else
        pivotVal=string(unique(inMatrix{:,pivotColumn}));
        for i=1:size(pivotVal,1)
            variableNames=[variableNames,...
                strcat(inMatrix.Properties.VariableNames(valueColumn),...
                pivotVal(i))...
                ];
        end
    end
    
    %convert table to cell of array (no string, no logical)
    inCell=table2cell(inMatrix);
    selectstring=cellfun(@isstring, inCell(1,:));
    inCell(:,selectstring)=cellstr(inCell(:,selectstring));
    selectlogical=cellfun(@islogical, inCell(1,:));
    inCell(:,selectlogical)=cellfun(@(x) {x*1},inCell(:,selectlogical));

    cellout=pivottable(inCell,pivotRow, pivotColumn, valueColumn, valueFun)  ;
    if empty2NaN
        % only for numeric columns here
        numCol=cellfun(@isnumeric,cellout(2,:));
        cellnum=cellout(:,numCol);
        select=cellfun(@isempty,cellnum(:));
        cellnum(select)={NaN};
        cellout(:,numCol)=cellnum;
    end
    
    % TODO, if the variablenames are made of string from double, lack of
    % precision may result in duplicate names and errors.
   
    
    out=cell2table(cellout(2:end,:),...
    'VariableNames',variableNames ...
    );
      
    
else
    out=pivottable(inMatrix, pivotRow, pivotColumn, valueColumn, valueFun);
end
end