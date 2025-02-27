function W = nextperm(V, K)
% nextperm - next (lexicographic) permutation of values
%
%   W = NEXTPERM(V) or W = NEXTPERM(V,1) returns the next permutation of
%   the vector V using lexographic ordening  of the values in V.  If there
%   is no next permutation, W returns V sorted in lexographic ordening
%   The output W is a row vector.
%
%   W = NEXTPERM(V, K), where K is vector of positive integers (>= 0),
%   returns the Kth next permutation(s). The output is matrix with numel(K)
%   rows. The rows of W are sorted according to K, that is, W(x,:) holds
%   the K(x)-th permutation of V. 
%
%   This function may be useful to generate permutations one-by-one, when
%   the total number of permutations is too large to store them all in
%   memory.
%
%   Examples:
%      % call nextperm repeatedly
%        V = [1 2 3 4]
%        V = nextperm(V)       % (#1) 1 2 4 3
%        V = nextperm(V)       % (#2) 1 3 2 4
%        V = nextperm(V)       % (#3) 1 3 4 2
%
%      % get specific next permutations
%        W = nextperm([1 2 3 4], [0 3 1])  % returns a matrix 
%           % [ 1 2 3 4 
%           %   1 3 4 2
%           %   1 2 4 3 ]
%
%      % last permutation -> original array 
%        V = [10:-1:2 1]        % the last permutation of 1:10
%        W = nextperm(V)        % 1:10 (0th permutation of 1:10)
%
%      % lexicographic permutations of a random array
%        R = randperm(10)      % a random permutation
%        Rnext = nextperm(R, 1:5)    % the next 5 permutation
%
%      % non-unique values of V
%        V = [10 20 20 30]
%        x = nextperm(1:numel(V), 3)   % 1 3 4 2
%        W1 = V(x)                     % 10 20 30 20
%        W2 = nextperm(V,3)            % 20 10 20 30 (lexicographic)
%
%      % use indices to get the next permutation of cells and struct arrays
%        C1 = {'A', 'BB', 1:4}
%        x = nextperm(1:numel(C1))
%        C2 = C1(x)       % {'A', 1:4 ,'BB'}
%
%  Notes:
%  1) The functionality of the second input of perms has changed since
%     version 3.0. 
%  2)  The matlab function PERMS generates all permutations at once and can
%      therefore only be used for small array sizes. Note the PERMS does not
%      returns the permutations in sorted order. 
%         V = 1:3 ;  % 3 distinct values -> 6 permutations
%         W1 = perms(V)          
%         W2 = nextperm(V, 0:5)     
%
%  See also PERMS, NCHOOSEK, RANDPERM
%           PERMPOS, NEXTPERMPOS, PERMN, NCHOOSE2, NCHOOSE (FileExchange)

% tested in Matlab 2017b
% version 3.0 (mar 2018)
% (c) Jos van der Geest
% Matlab File Exchange Author ID: 10584
% email: samelinoa@gmail.com

% History
% 1.0 (may 2016) created, based on an algorithm found at
%                https://en.wikipedia.org/wiki/Permutation 
% 2.0 (may 2016) - incorporated the return of several next permutations
% 3.0 (mar 2018) - functional change for the second input argument. In
%       previous versions nextperm(V, N) returned all next permutations
%       from 1 to N in a matrix. To mimick this, now use nextperm(V, 1:N)

narginchk(1,2) ;
V = reshape(V, 1, []) ; % row vector

% which subsequent permutations do we need to return
if nargin==1 || isequal(K, 1)
    % 1) only the next one
    W = nextperm_local(V) ;
else
    if ~isnumeric(K) || ~all(K>=0) || ~all(fix(K) == K)    
        error('N should be a vector of positive scalars.')
    end
    N = numel(K) ;
    [K, ix] = sort(reshape(K,1,N)) ; % sort the requested permutions
    
    W = repmat(V, N, 1) ; % pre-allocation by creating the first one
    K = [0  K] ; % start with the original array,
    for k = 1:N
        % skip the unwanted permutations
        for j = K(k):K(k+1)-1
            V = nextperm_local(V) ;
        end
        % the last permutation is a permutation we need to store
        % at the row 
        W(ix(k),:) = V ;
    end
end


function P = nextperm_local(P)
% nextperm_local - returns the next permutation
% find the last element in the vector that is larger than the previous one
k1 = find(P(2:end) > P(1:end-1), 1, 'last') ;
if isempty(k1)
    % if there is none, V is already the last permutation
    k1 = 0 ;
else
    % find the last element in V that is smaller than V(k1)
    k2 = find(P(k1)<P, 1, 'last');
    P([k1 k2]) = P([k2 k1]) ;       % switch the two elements
end
% reverse the sequence from position k1+1 till the end
P((k1+1):end) = P(end:-1:(k1+1));

