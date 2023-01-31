function out=stringwrap(A)
%replace empties with ''
%replace function handles with names

if iscell(A)
    %replace empties with ''
    emptyA=cellfun(@isempty,A);
    A(emptyA)=repmat({''},sum(emptyA),1);
    %replace function handles with names
    fhA=cellfun(@(x) isa(x,'function_handle'),A);
    A(fhA)=cellfun(@(x) func2str(x),A,'UniformOutput', false);
end
out=string(A);
end

