function [final_path, final_cost] = ALNS(initial_path, capacity, dmax, quantitymax, n)
    % adaptive large neighbor search algorithm
    removeheuristicnum = 3;  % remove algorithm������
    insertheuristicnum = 2;  % insert algorithm������
    removeprob = 1/removeheuristicnum * ones(1, removeheuristicnum); % ����remove algorithm�ĸ���
    insertprob = 1/insertheuristicnum * ones(1, insertheuristicnum); % ����insert algorihtm�ĸ���
    removeweight = ones(1,removeheuristicnum); % ����remove algorithm��Ȩ��
    insertweight = ones(1,insertheuristicnum); % ����insert algorithm��Ȩ��
    noiseweight = ones(1,2); % ��һ��Ԫ���Ǽ�������Ȩ�أ��ڶ���Ԫ���ǲ���������Ȩ��
    removeusefrequency = zeros(1,removeheuristicnum); % ����remove����ʹ�õĴ���
    insertusefrequency = zeros(1,insertheuristicnum); % ����insert����ʹ�õĴ���
    removescore = zeros(1,removeheuristicnum);  % ����remove�����ڵ�ǰsegment�е�����
    insertscore = zeros(1,insertheuristicnum);  % ����insert�����ڵ�ǰsegment�е�����
    noiseaddscore = zeros(1,2);  % ��1��Ԫ���Ǽ������ĵ÷֣���2��Ԫ���ǲ��������ĵ÷� 
    noiseaddfrequency = 0;  % ����ʹ�õĴ���
    maxiter = 10000;  % �ܵĵ�������
    segment = 100;  % ÿ��һ��segment����removeprob��insertprob
    curpath = initial_path;
    curcost = routecost(initial_path);
    curglobalmincost = curcost; % ��ǰȫ�����Ž�
    globalbestsolution = curpath; % ȫ������·��
    initialroutecode = routecode(initial_path);  % �ѳ�ʼ����룬��������harsh key
    hashtable = {};
    hashtable{1} = hash(initialroutecode,'MD2');
    noiseprobability = 0.5;  % �ڼ���������ʱ��������ĸ��� 
    w = 0.05;
    T = w*curcost / log(2);  % ��ʼ�¶�
    r = 0.1;
    p = 6;
    ksi = 0.4;
    eta = 0.025;
    noiseamount = eta * dmax;
    c = 0.9998;
    sigma1 = 33;
    sigma2 = 9;
    sigma3 = 13;
    q = floor(ksi * n);
%     r,q,p,dmax,tmax,quantitymax,eta,c;  % ��Ҫ����Ĳ���
    for iter = 1:maxiter
        % ���������ѡȡremove���Ӻ�insert����
        if mod(iter, segment) == 1  % ��ʼ�µ�segment��Ӧ��Ҫ���ӷ���صı���ȫ������
            if iter ~= 1  % ������Ǹտ�ʼ����Ӧ�ø��¸����ӵĸ���
                for i = 1:removeheuristicnum
                    if removeusefrequency(i) ~= 0
                        removeweight(i) = removeweight(i) * (1-r) + r * removescore(i)/removeusefrequency(i);
                    end
                end
                for j = 1:insertheuristicnum
                    if insertusefrequency(j) ~= 0
                        insertweight(j) = insertweight(j) * (1-r) + r * insertscore(j)/insertusefrequency(j);
                    end
                end
                removeprob = removeweight / sum(removeweight); % ��һ��
                insertprob = insertweight / sum(insertweight);
                noiseweight(1) = noiseweight(1) * (1-r) + r * noiseaddscore(1) / noiseaddfrequency;
                noiseweight(2) = noiseweight(2) * (1-r) + r * noiseaddscore(2) / (segment - noiseaddfrequency);
                noiseprobability = noiseweight(1) / sum(noiseweight);
            end
            fprintf('-----segment: %d, current cost: %f, current best cost: %f, hashtable length: %d\n', floor(iter/segment)+1, curcost, curglobalmincost, length(hashtable));
            fprintf('     shaw removal score: %d, random removal score: %d, worst removal score: %d\n', removescore(1), removescore(2), removescore(3));
            fprintf('     shaw removal weight: %f, random removal weight: %f, worst removal weight: %f\n', removeweight(1), removeweight(2), removeweight(3));
            fprintf('     shaw removal freq: %d, random removal freq: %d, worst removal freq: %d\n', removeusefrequency(1), removeusefrequency(2), removeusefrequency(3));
            fprintf('     greedy insert score: %d, regret insert score: %d\n', insertscore(1), insertscore(2));
            fprintf('     greedy insert weight: %f, regret insert weight: %f\n', insertweight(1), insertweight(2));
            fprintf('     greedy insert freq: %d, regret insert freq: %d\n', insertusefrequency(1), insertusefrequency(2));
            fprintf('     noise score: %d, without noise score: %d\n', noiseaddscore(1), noiseaddscore(2));
            fprintf('     noise weight: %f, without noise weight: %f\n', noiseweight(1), noiseweight(2));
            fprintf('     noise use freq: %d\n', noiseaddfrequency);
            removescore = zeros(1,removeheuristicnum);  % ����remove�����ڵ�ǰsegment�е�����
            insertscore = zeros(1,insertheuristicnum);  % ����insert�����ڵ�ǰsegment�е�����
            removeusefrequency = zeros(1,removeheuristicnum); % ����remove����ʹ�õĴ���
            insertusefrequency = zeros(1,insertheuristicnum); % ����insert����ʹ�õĴ���
            noiseaddfrequency = 0;  % ����ʹ�õĴ���
            noiseaddscore = zeros(1,2);  % ��1��Ԫ���Ǽ������ĵ÷֣���2��Ԫ���ǲ��������ĵ÷� 
        end 
        % �Ը���ѡ��remove����
        removeselect = rand;
        removeindex = 1;
        while sum(removeprob(1:removeindex)) < removeselect 
            removeindex = removeindex + 1;
        end
        % �Ը���ѡ��insert����
        insertselect = rand;
        insertindex = 1;
        while sum(insertprob(1:insertindex)) < insertselect
            insertindex = insertindex + 1;
        end
        removeusefrequency(removeindex) = removeusefrequency(removeindex) + 1;
        insertusefrequency(insertindex) = insertusefrequency(insertindex) + 1;
        switch removeindex
            case 1
                tmax = countMaxValue(curpath);
                [removedpath, removedrequestnode, removedrequestindex] = shawRemoval(curpath, q, p, n, dmax, tmax, quantitymax);
            case 2
                [removedpath, removedrequestnode, removedrequestindex] = randomRemoval(curpath, q, n);
            case 3
                [removedpath, removedrequestnode, removedrequestindex] = worstRemoval(curpath, q, p, n);
        end
        switch insertindex
            case 1
                if noiseprobability > rand 
                    noiseadd = 1;
                    noiseaddfrequency = noiseaddfrequency + 1;
                else
                    noiseadd = 0;
                end
                [completeroute] = greedyInsert(removedrequestnode, removedpath, capacity, noiseadd, noiseamount);
            case 2
                if noiseprobability > rand 
                    noiseadd = 1;
                    noiseaddfrequency = noiseaddfrequency + 1;
                else
                    noiseadd = 0;
                end
                [completeroute] = regretInsert(removedrequestnode, removedpath, capacity, noiseadd, noiseamount);
        end
        [completeroute] = removeNullRoute(completeroute);
        newcost = routecost(completeroute);  % ��·���Ĵ���
        acceptprobability = exp(-(newcost - curcost)/T);  % ���ܴ�·���ĸ���
        accept = 0;
        if acceptprobability > rand
            accept = 1;
        end
        T = T * c;  % ����
        newroutecode = routecode(completeroute);
        newroutehashkey = hash(newroutecode, 'MD2');
        % �������ж��Ƿ���Ҫ�ӷ�
        % �ӷ�������£�
        % 1. ���õ�һ��ȫ�����Ž�ʱ
        % 2. ���õ�һ����δ�����ܹ��ĸ��õĽ�
        % 3. ���õ�һ����δ�����ܹ��Ľ⣬��Ȼ�����ȵ�ǰ����������ⱻ������
        if newcost < curglobalmincost   
            removescore(removeindex) = removescore(removeindex) + sigma1;
            insertscore(insertindex) = insertscore(insertindex) + sigma1;
            curglobalmincost = newcost;
            globalbestsolution = completeroute;
            if noiseadd == 1
                noiseaddscore(1) = noiseaddscore(1) + sigma1;
            else
                noiseaddscore(2) = noiseaddscore(2) + sigma1;
            end
        else
            if ismember(newroutehashkey, hashtable) == 0  % ��·����û�б����ܹ�
                if newcost < curcost  % �õ���һ�����õĽ⣬�ӷ�
                    removescore(removeindex) = removescore(removeindex) + sigma2;
                    insertscore(insertindex) = insertscore(insertindex) + sigma2;
                    if noiseadd == 1
                        noiseaddscore(1) = noiseaddscore(1) + sigma2;
                    else
                        noiseaddscore(2) = noiseaddscore(2) + sigma2;
                    end
                else
                    if accept == 1  % ��Ȼ�õ���һ����̫�õĽ⣬���Ǳ������ˣ��ӷ�
                        removescore(removeindex) = removescore(removeindex) + sigma3;
                        insertscore(insertindex) = insertscore(insertindex) + sigma3;
                        if noiseadd == 1
                            noiseaddscore(1) = noiseaddscore(1) + sigma3;
                        else
                            noiseaddscore(2) = noiseaddscore(2) + sigma3;
                        end
                    end
                end
            end
        end
        if accept == 1  % ����������ˣ����жϵ�ǰ���Ƿ���hashtable�У����ޣ�����ӵ�hashtable��
            if ismember(newroutehashkey, hashtable) == 0  % ��·����û�б����ܹ�
                hashtable{length(hashtable)+1} = newroutehashkey;
            end
            curcost = newcost;  % ���µ�ǰ��cost
            curpath = completeroute;  % ���µ�ǰ��path
        end    
    end
    final_path = globalbestsolution;
    final_cost = curglobalmincost;
end

%% ------------------------ removal algorithms ---------------------- %%
%% shaw removal
function [removedpath, removedrequestnode, removedrequestindex] = shawRemoval(solutions, q, p, n, dmax, tmax, quantitymax)
    % solutions: ��ǰ��·��
    % q: Ҫ�Ƴ���request������
    % p: ����removal�������
    % n: �ܵĽڵ���Ŀ
    % dmax: �˿ͽڵ���������
    % tmax: ������������˿͵��ʱ��
    % quantitymax: �˿͵����������
    % ÿ��ѭ���Ƴ���request����Ϊy^p * |L|��LΪ�Ƴ�ĳЩ�ڵ��ĵ�ǰ·��
    phi = 9;
    kai = 3;
    psi = 2;
    K = length(solutions); % ������
    % ���������ѡȡ·���е�һ���ڵ�
    selectedcarset = 1:K;   % ��ѡ�ĳ�������
    selectfinished = 0;  % ѡ��ɹ����
    while selectfinished == 0 && length(selectedcarset) ~= 0
        randvalue = randi([1,length(selectedcarset)]);
        selectedrouteindex = selectedcarset(randvalue);  % ���ѡȡһ��·��
        if length(solutions(selectedrouteindex).nodeindex) == 0   % ��·��
            selectedcarset = setdiff(selectedcarset, selectedrouteindex, 'stable');  % ȥ������·��������ѡ
        else
            selectfinished = 1;
            selectedroute = solutions(selectedrouteindex).route; % ���ѡ�е�·��
            selectedroutelen = length(selectedroute) - 2;  % ȥͷȥβ�ĳ���
            selectednodeindex = randi([1,selectedroutelen]);  % ���ѡȡ��·���е�һ���ڵ�
            selectednode = selectedroute(selectednodeindex + 1); % ע���һ���ڵ��ǲֿ�
        end
    end
    R = inf(n,n);  % �����ڵ�֮�������̶�
    temp = [];
    for i = 1:K  % �Ȱ����нڵ�ķŵ�һ����ʱ����temp��
        curroute = solutions(i).route;
        for j = 2 : length(curroute) - 1
            temp = [temp, curroute(j)];
        end
    end
    for i = 1:n
        for j = i+1:n
            node1 = temp(i);
            node2 = temp(j);
            node1index = node1.index;
            node2index = node2.index;
            R(node1index, node2index) = phi * sqrt((node1.cx - node2.cx)^2 + (node1.cy - node2.cy)^2)/dmax + ...
                                        kai * abs(node1.arrival_time - node2.arrival_time)/tmax + ...
                                        psi * abs(node1.quantity - node2.quantity)/quantitymax;
            R(node2index, node1index) = R(node1index, node2index);
        end
    end
    D = [selectednode.index];  % D�洢���Ǳ��Ƴ��ڵ�ı��
    nodeindexinroute = setdiff(1:n, selectednode.index);  % ����·���еĽڵ���
    selectednodenum = selectednode.index;
    while length(D) < q
        % һֱѭ��ִ�е�D�е�request����ΪqΪֹ
        [sortR, sortRindex] = sort(R(selectednodenum, nodeindexinroute), 'ascend');  
        % ������̶ȴӵ͵��߽�������
        % ֻ��������·���еĽڵ�
        y = rand;
        removenum = max(floor(y^p * length(nodeindexinroute)), 1);  % �Ƴ���request������
        removenodeindex = nodeindexinroute(sortRindex(1:removenum)); % ���Ƴ���·���ڵ�ı��
        nodeindexinroute = setdiff(nodeindexinroute, removenodeindex, 'stable');
        D = [D, removenodeindex];
        randompos = randi([1 length(D)]);
        selectednodenum = D(randompos);  % �ٴ����ѡȡһ��request���Ѿ��Ƴ���·��������
    end
    % ���ڶ�D�еı�Ž���ӳ�䣬�Ƴ�������·���е�D�е�Ԫ��
    [solutions, DD] = removeNodeInRoute(D, solutions);
    removedpath = solutions;
    removedrequestnode = DD;
    removedrequestindex = D; 
end

%% random removal
function [removedpath, removedrequestnode, removedrequestindex] = randomRemoval(solutions, q, n)
    % ����Ƴ�q���ڵ�
    allnodeindex = 1:n;  % ���нڵ�ı��
    selectednodeindex = [];
    while length(selectednodeindex) < q   % �������q��request�ı��
        randomvalue = randi([1 length(allnodeindex)]);
        curselected = allnodeindex(randomvalue);
        selectednodeindex = [selectednodeindex, curselected];
        allnodeindex = setdiff(allnodeindex, curselected);
    end
    [result, removednode] = removeNodeInRoute(selectednodeindex, solutions);
    removedpath = result;
    removedrequestnode = removednode;
    removedrequestindex = selectednodeindex;
end

%% worst removal
function [removedpath, removedrequestnode, removedrequestindex] = worstRemoval(solutions, q, p, n)
    % �Ƴ���q��������request
    D = [];  % Ҫ�Ƴ��Ľڵ�
    DD = [];  % Ҫ�Ƴ��Ľڵ���
    nodeindexset = 1:n;
    while length(D) < q
        [reducedcost] = computeReducedCost(solutions, nodeindexset, n); 
        % reducedcost��ŵ������нڵ���Ƴ�����
        % ����nodeindexset�еĽڵ����Ƴ����۸�Ϊ��
        [sortreducedcost, sortindex] = sort(reducedcost, 'ascend'); 
        y = rand;
        removednum = max(floor(y^p*length(nodeindexset)), 1);
        removenodeindex = sortindex(1: removednum);
        DD = [DD, removenodeindex];
        [result, removednode] = removeNodeInRoute(removenodeindex, solutions);
        solutions = result;  % �Ƴ��ڵ�����·��
        nodeindexset = setdiff(nodeindexset, removenodeindex, 'stable');
        D = [D, removednode];
    end
    removedpath = solutions;
    removedrequestnode = D;
    removedrequestindex = DD;
end

%% һЩ���ӵĺ���
function [result, removednode] = removeNodeInRoute(removenodeindex, routeset)
    % removenodeindex: Ҫ�Ƴ��Ľڵ���
    % routeset: ���е�·������
    D = removenodeindex;
    DD = [];
    for i = 1:length(routeset)
        curpath = routeset(i);
        curroute = curpath.route;
        [curremovednodeindex, curremovenodepos] = intersect(curpath.nodeindex, D);  % �ҳ����Ƴ��Ľڵ���
        for j = 1:length(curremovenodepos)  % ����ڵ�����Ƴ���ע��ͬ������quantityL��quantityB
            curnode = curroute(curremovenodepos(j)+1);  % ע���һ���ڵ���depot��nodeindex��ֻ�й˿ͽڵ�ı��
            DD = [DD, curnode];
            if (curnode.type == 'L')
                curpath.quantityL = curpath.quantityL - curnode.quantity;
            else
                curpath.quantityB = curpath.quantityB - curnode.quantity;
            end
        end
        curpath.nodeindex = setdiff(curpath.nodeindex, curremovednodeindex, 'stable');  % ����·���е�node�±�
        curroute(curremovenodepos+1) = [];  % һ�����Ƴ���������Ҫ�Ƴ��Ľڵ�
        curpath.route = curroute;
        routeset(i) = curpath;
    end
    result = routeset;
    removednode = DD;
end

function [reducedcost] = computeReducedCost(routeset, nodeindexset, n)
    % ����routeset�����нڵ���Ƴ����ۣ����Ƴ�����֮�������·�����۱仯����
    % ����nodeindexset�еĽڵ����Ƴ����۸�Ϊ��
    reducedcost = inf(1,n);  % û�б������node���Ƴ����ۼ�Ϊinf
    for i = 1:length(routeset)
        curroute = routeset(i).route;
        computednodeindex = intersect(routeset(i).nodeindex, nodeindexset); % ��·������Ҫ����reducedcost�Ľڵ��±�
        for j = 1:length(computednodeindex)
            nodeindex = computednodeindex(j);
            pos = find(routeset(i).nodeindex == nodeindex);  % �ҵ���ǰҪ����Ľڵ���·����nodeindex�����µ�����
            predecessor = curroute(pos);
            curnode = curroute(pos+1);
            successor = curroute(pos+2);
            temp = -sqrt((predecessor.cx-curnode.cx)^2 + (predecessor.cy-curnode.cy)^2) -...
                   sqrt((successor.cx-curnode.cx)^2 + (successor.cy-curnode.cy)^2) +...
                   sqrt((predecessor.cx-successor.cx)^2 + (predecessor.cy-successor.cy)^2);
            reducedcost(nodeindex) = temp;
        end
    end
end

%% ------------------------ insertion algorithms ---------------------- %%
%% greedy insert
function [completeroute] = greedyInsert(removednode, removedroute, capacity, noiseadd, noiseamount)
    % ̰���㷨��ÿ�ζ�Ѱ����õĵ����
    % ��removednode���뵽removedroute��
    % ���û���ҵ����в���㣬Ӧ������һ���µ�·��
    alreadyinsert = [];
    [bestinsertcostperroute, bestinsertinfo, secondinsertcostperroute, secondinsertinfo] = computeInsertCostMap(removednode, removedroute, capacity, noiseadd, noiseamount);
    while length(alreadyinsert) < length(removednode)
        m = length(removednode);
        K = length(removedroute);
        mincost = min(min(bestinsertcostperroute));
        if mincost == inf   % ����ʣ��Ĵ�����㶼û�п��еط�����
            restnodepos = setdiff(1:m, alreadyinsert);  % ʣ���ѡ�ڵ�
            row = restnodepos(1);
            col = 1;  % ����ν����Ϊ���½�һ��·��
        else
            index = find(bestinsertcostperroute == mincost);
            index = index(1);
            col = floor(index/m)+1;  % ��С������������У�������ţ�
            row = index - m*(col-1); % ��С������������У��ڵ��ţ���removednode�е�λ�ã�
            if row == 0
                row = m;
                col = col - 1;
            end
        end
        alreadyinsert = [alreadyinsert, row];
        selectednode = removednode(row); % �˴α�ѡ�еĽڵ�
        selectednode.carindex = col;   % ��������
        bestinsertcostperroute(row,:) = inf;  % �ýڵ��Ѳ��ڴ����������У��ʽ������в��������Ϊinf
        insertpointindex = bestinsertinfo(row, col); % ��Ѳ����
        if insertpointindex == -1  % û���ҵ����в���㣬���½�һ��·��
            newrouteindex = length(removedroute) + 1;
            depot = removedroute(1).route(1);
            depot.carindex = newrouteindex;
            selectednode.carindex = newrouteindex;
            newroute.route = [depot, selectednode, depot];
            newroute.nodeindex = [selectednode.index];
            if selectednode.type == 'L'
                newroute.quantityL = selectednode.quantity;
                newroute.quantityB = 0;
            else
                 newroute.quantityB = selectednode.quantity;
                newroute.quantityL = 0;
            end
            newroute.index = newrouteindex;
            removedroute = [removedroute newroute];
            operationroute = newroute;
            col = newrouteindex;
        else
            nodeindexinroute = removedroute(col).nodeindex;  % Ҫ�����·��������ӵ�еĽڵ��ţ�ȫ�֣�
            temp = [];
            temp = [temp, nodeindexinroute(1:insertpointindex-1)];
            temp = [temp, selectednode.index];
            temp = [temp, nodeindexinroute(insertpointindex:end)];
            removedroute(col).nodeindex = temp;
            selectedroute = removedroute(col).route;
            temp = [];
            temp = [temp, selectedroute(1:insertpointindex)];
            temp = [temp, selectednode];
            temp = [temp, selectedroute(insertpointindex+1:end)];
            removedroute(col).route = temp;
            switch selectednode.type
                case 'L'
                    removedroute(col).quantityL = removedroute(col).quantityL + selectednode.quantity;
                case 'B'
                    removedroute(col).quantityB = removedroute(col).quantityB + selectednode.quantity;
            end
            operationroute = removedroute(col);
        end
        % �������µĽڵ�󣬶Բ����·�����۽������¹���
        % ֻ��Ҫ����·����Ϣ�б仯����һ�����ݾͿ���
        mark = ones(1,m);  % 1��ʾ�ڵ㻹û�в��룬0��ʾ�ڵ��Ѿ�����
        mark(alreadyinsert) = 0;  % �Ѿ�������Ľڵ���Ϊ0
        [bestinsertcostarr, bestinsertinfoarr, secondinsertcostarr, secondinsertinfoarr] = ...
            computeInsertCostInARoute(removednode, operationroute.route, operationroute.quantityL, operationroute.quantityB, capacity, mark, noiseadd, noiseamount);
        bestinsertcostperroute(:,col) = bestinsertcostarr;
        bestinsertinfo(:,col) = bestinsertinfoarr;
    end
    completeroute = removedroute;  
end

%% regret insert
function [completeroute] = regretInsert(removednode, removedroute, capacity, noiseadd, noiseamount)
    % ÿ��ѡ����õ���κõ�ֻ�����������Ӧ�Ľڵ���뵽·����
    % ��˼���ǣ���������ڲ�������ڵ���룬����Ҫ��������Ĵ���
    alreadyinsert = [];
    m = length(removednode);
    [bestinsertcostperroute, bestinsertinfo, secondinsertcostperroute, secondinsertinfo] = computeInsertCostMap(removednode, removedroute, capacity, noiseadd, noiseamount);
    while length(alreadyinsert) < length(removednode)
        costdiffarr = [];  % ���ÿ���ڵ���ú��������֮��
        for i = 1:length(removednode)
            tempbest = bestinsertcostperroute;
            if ismember(i,alreadyinsert) == 0  % �Ѳ��벻������
                [best1, index1] = min(tempbest(i,:));
                tempbest(i,index1) = inf;
                [best2, index2] = min(tempbest(i,:));
                tempsecond = secondinsertcostperroute;
                [best3, index3] = min(tempsecond(i,:));
                if best1(1) == inf  % �����Ѳ�����۶�Ϊ�ޣ�˵���Ѿ�û�п��в����
                    costdiffarr = [costdiffarr, inf];
                else
                    if best2(1) < best3(1)
                        costdiffarr = [costdiffarr, abs(best1(1) - best2(1))];
                    else
                        costdiffarr = [costdiffarr, abs(best1(1) - best3(1))];
                    end
                end
            else
                costdiffarr = [costdiffarr, -inf];  % �Ѿ����뵽·���еĽڵ㣬����۲Ϊ-��
            end
        end
        [maxdiff, maxdiffindex] = max(costdiffarr);
        nodeindex = maxdiffindex(1);  % ��ǰregret cost���ĵ���±꣨��removednode��λ�ã�
        [mincost, mincostindex] = min(bestinsertcostperroute(nodeindex,:));   % �ҳ���ǰ�ڵ����Ѳ���λ��
        mincostindex = mincostindex(1);   % ��Ѳ���㣬Ҳ���ǻ������
        alreadyinsert = [alreadyinsert, nodeindex];  % ��ŵ��������removednode���±�
        selectednode = removednode(nodeindex); % �˴α�ѡ�еĽڵ�
        selectednode.carindex = mincostindex;   % ��������
        bestinsertcostperroute(nodeindex,:) = inf;  % �ýڵ��Ѳ��ڴ����������У��ʽ������в��������Ϊinf
        secondinsertcostperroute(nodeindex,:) = inf;
        insertpointindex = bestinsertinfo(nodeindex, mincostindex); % ��Ѳ����
        if insertpointindex == -1  % û���ҵ����в���㣬���½�һ��·��
            newrouteindex = length(removedroute) + 1;
            depot = removedroute(1).route(1);
            depot.carindex = newrouteindex;
            selectednode.carindex = newrouteindex;
            newroute.route = [depot, selectednode, depot];
            newroute.nodeindex = [selectednode.index];
            if selectednode.type == 'L'
                newroute.quantityL = selectednode.quantity;
                newroute.quantityB = 0;
            else
                 newroute.quantityB = selectednode.quantity;
                newroute.quantityL = 0;
            end
            newroute.index = newrouteindex;
            removedroute = [removedroute, newroute];
            operationroute = newroute;
            col = newrouteindex;
        else
            col = mincostindex;
            nodeindexinroute = removedroute(col).nodeindex;           
            temp = [];
            temp = [temp, nodeindexinroute(1:insertpointindex-1)];
            temp = [temp, selectednode.index];
            temp = [temp, nodeindexinroute(insertpointindex:end)];
            removedroute(col).nodeindex = temp;
            selectedroute = removedroute(col).route;
            temp = [];
            temp = [temp, selectedroute(1:insertpointindex)];
            temp = [temp, selectednode];
            temp = [temp, selectedroute(insertpointindex+1:end)];
            removedroute(col).route = temp;
            switch selectednode.type
                case 'L'
                    removedroute(col).quantityL = removedroute(col).quantityL + selectednode.quantity;
                case 'B'
                    removedroute(col).quantityB = removedroute(col).quantityB + selectednode.quantity;
            end
            operationroute = removedroute(col);
        end
        % �������µĽڵ�󣬶Բ����·�����۽������¹���
        % ֻ��Ҫ����·����Ϣ�б仯����һ�����ݾͿ���
        mark = ones(1,m);  % 1��ʾ�ڵ㻹û�в��룬0��ʾ�ڵ��Ѿ�����
        mark(alreadyinsert) = 0;  % �Ѿ�������Ľڵ���Ϊ0
        [bestinsertcostarr, bestinsertinfoarr, secondinsertcostarr, secondinsertinfoarr] = ...
            computeInsertCostInARoute(removednode, operationroute.route, operationroute.quantityL, operationroute.quantityB, capacity, mark, noiseadd, noiseamount);
        bestinsertcostperroute(:,col) = bestinsertcostarr;
        bestinsertinfo(:,col) = bestinsertinfoarr;
        secondinsertcostperroute(:,col) = secondinsertcostarr;
        secondinsertinfo(:,col) = secondinsertinfoarr;
    end
    completeroute = removedroute;
end

%% ���Ӻ���
function [bestinsertcostperroute, bestinsertinfo, secondinsertcostperroute, secondinsertinfo] = computeInsertCostMap(nodeset, routeset, capacity, noiseadd, noiseamount)
    % ����nodeset�нڵ���뵽routeset�е���С���ۺʹ�С����
    % bestinsertcostperroute: �����ڵ��ڸ���·���е���С������ۣ�secondxxxΪ��С
    % bestinsertinfo: �����ڵ��ڸ���·������С�������Ϣ��secondxxxΪ��С
    K = length(routeset);  % ������Ŀ
    m = length(nodeset);
    bestinsertcostperroute = [];
    bestinsertinfo = [];
    secondinsertcostperroute = [];
    secondinsertinfo = [];
    for i = 1:m
        curnode = nodeset(i);  % ��ǰ��Ҫ����Ľڵ�
        for j = 1:K
            curpath = routeset(j);
            curroute = curpath.route;
            mininsertcost = inf;
            mininsert.insertpointindex = -1;
            secondinsertcost = inf;
            secondinsert.insertpointindex = -1;
            for k = 1:length(curroute) - 1
                insertnode = curroute(k);  % ����㣬���뵽�˵��
                successor = curroute(k+1);
                switch curnode.type
                    case 'L'
                        if insertnode.type == 'D' || insertnode.type == 'L' % �ǿɲ����
                            if curpath.quantityL + curnode.quantity < capacity  % ��������Լ��
                                if timeWindowJudge(k, curroute, curnode) == 1   % ����ʱ�䴰Լ��
                                    temp = sqrt((insertnode.cx-curnode.cx)^2 + (insertnode.cy-curnode.cy)^2) +...
                                           sqrt((successor.cx-curnode.cx)^2 + (successor.cy-curnode.cy)^2) -...
                                           sqrt((insertnode.cx-successor.cx)^2 + (insertnode.cy-successor.cy)^2);
                                    if noiseadd == 1
                                        noise = -noiseamount + 2*noiseamount*rand;
                                        temp = max(temp + noise,0);
                                    end
                                    if temp < mininsertcost
                                        secondinsertcost = mininsertcost;  % ԭ������õġ�����ˡ��κõġ�
                                        secondinsert.insertpointindex = mininsert.insertpointindex; 
                                        mininsertcost = temp;           
                                        mininsert.insertpointindex = k;  % �����
                                    end
                                end
                            end
                        end
                    case 'B'
                        if insertnode.type == 'L' && successor.type == 'B' || insertnode.type == 'L' && successor.type == 'D' ||insertnode.type == 'B'
                            if curpath.quantityB + curnode.quantity < capacity  % ��������Լ��
                                if timeWindowJudge(k, curroute, curnode) == 1   % ����ʱ�䴰Լ��
                                    temp = sqrt((insertnode.cx-curnode.cx)^2 + (insertnode.cy-curnode.cy)^2) +...
                                           sqrt((successor.cx-curnode.cx)^2 + (successor.cy-curnode.cy)^2) -...
                                           sqrt((insertnode.cx-successor.cx)^2 + (insertnode.cy-successor.cy)^2);
                                    if noiseadd == 1
                                        noise = -noiseamount + 2*noiseamount*rand;
                                        temp = max(temp + noise,0);
                                    end   
                                    if temp < mininsertcost
                                        secondinsertcost = mininsertcost;  % ԭ������õġ�����ˡ��κõġ�
                                        secondinsert.insertpointindex = mininsert.insertpointindex;     
                                        mininsertcost = temp;       
                                        mininsert.insertpointindex = k;  % �����
                                    end
                                end
                            end
                        end
                end                
            end
            bestinsertcostperroute(i,j) = mininsertcost;
            bestinsertinfo(i,j) = mininsert.insertpointindex;
            secondinsertcostperroute(i,j) = secondinsertcost;
            secondinsertinfo(i,j) = secondinsert.insertpointindex;
        end
    end
end

function [bestinsertcostarr, bestinsertinfoarr, secondinsertcostarr, secondinsertinfoarr] = computeInsertCostInARoute(nodeset, route, quantityL, quantityB, capacity, mark, noiseadd, noiseamount)
    % ����nodeset�нڵ㵽route�е���С�ʹ�С�������
    % mark = 0 ��ʾ��Ӧ�Ľڵ��Ѿ������������δ�����
    % quantityL, quantityB: ��·���ϵ�LHs��BHs�Ļ�����
    m = length(nodeset);
    bestinsertcostarr = inf(1,m);
    bestinsertinfoarr = -1 * ones(1,m);
    secondinsertcostarr = inf(1,m);
    secondinsertinfoarr = -1 * ones(1,m);
    curroute = route;
    for i = 1:m
        curnode = nodeset(i);
        mininsertcost = inf;
        mininsert.insertpointindex = -1;
        secondinsertcost = inf;
        secondinsert.insertpointindex = -1;
        if mark(i) == 1  % ֻ����û�в�����Ľڵ�
            for j = 1:length(route)-1
                insertnode = route(j);  % �����ڸýڵ����
                successor = route(j+1); % ������
                switch curnode.type
                    case 'L'
                        if insertnode.type == 'D' || successor.type == 'L' % �ǿɲ����
                            if quantityL + curnode.quantity < capacity  % ��������Լ��
                                if timeWindowJudge(j, route, curnode) == 1   % ����ʱ�䴰Լ��
                                    temp = sqrt((insertnode.cx-curnode.cx)^2 + (insertnode.cy-curnode.cy)^2) +...
                                           sqrt((successor.cx-curnode.cx)^2 + (successor.cy-curnode.cy)^2) -...
                                           sqrt((insertnode.cx-successor.cx)^2 + (insertnode.cy-successor.cy)^2);
                                    if noiseadd == 1
                                        noise = -noiseamount + 2*noiseamount*rand;
                                        temp = max(temp + noise,0);
                                    end
                                    if temp < mininsertcost
                                        secondinsertcost = mininsertcost;  % ԭ������õġ�����ˡ��κõġ�
                                        secondinsert.insertpointindex = mininsert.insertpointindex;  
                                        mininsertcost = temp;          
                                        mininsert.insertpointindex = j;  % �����
                                    end
                                end
                            end
                        end
                    case 'B'
                        if insertnode.type == 'L' && successor.type == 'B' || insertnode.type == 'L' && successor.type == 'D' || insertnode.type == 'B'
                            if quantityB + curnode.quantity < capacity  % ��������Լ��
                                if timeWindowJudge(j, curroute, curnode) == 1   % ����ʱ�䴰Լ��
                                    temp = sqrt((insertnode.cx-curnode.cx)^2 + (insertnode.cy-curnode.cy)^2) +...
                                           sqrt((successor.cx-curnode.cx)^2 + (successor.cy-curnode.cy)^2) -...
                                           sqrt((insertnode.cx-successor.cx)^2 + (insertnode.cy-successor.cy)^2);
                                    if noiseadd == 1
                                        noise = -noiseamount + 2*noiseamount*rand;
                                        temp = max(temp + noise,0);
                                    end   
                                    if temp < mininsertcost
                                        secondinsertcost = mininsertcost;  % ԭ������õġ�����ˡ��κõġ�
                                        secondinsert.insertpointindex = mininsert.insertpointindex;  
                                        mininsertcost = temp;          
                                        mininsert.insertpointindex = j;  % �����
                                    end
                                end
                            end
                        end
                end
            end
            bestinsertcostarr(i) = mininsertcost;
            bestinsertinfoarr(i) = mininsert.insertpointindex;
            secondinsertcostarr(i) = secondinsertcost;
            secondinsertinfoarr(i) = secondinsert.insertpointindex;
        end
    end
end
        
function [mark] = timeWindowJudge(insertpointindex, path, newcustomer)
    % �ж��²���Ŀͻ����Ƿ��ʹ�ú����ڵ��ʱ�䴰Լ����Υ��
    time = 0;  % ��ǰʱ��Ϊ0
    temp = [];
    temp = [temp, path(1:insertpointindex)];
    temp = [temp newcustomer];
    temp = [temp path(insertpointindex + 1:end)];
    path = temp;
    mark = 1;  % Ϊ0��ʾΥ��Լ��
    for i = 1:length(path)-1
        predecessor = path(i); % ǰ�̽ڵ�
        successor = path(i+1); % ��̽ڵ�
        if (i < insertpointindex) % �ڲ����֮ǰ�Ĺ˿͵�ʱ�䴰��û���ܵ�Ӱ�죬����Ҫ�����ж�
            time = time + sqrt((predecessor.cx - successor.cx)^2 + (predecessor.cy - successor.cy)^2); % ��������ʱ��
            if (time < successor.start_time)  % ������ʱ�䴰��ʼǰ����
                time = successor.start_time;
            end
            time = time + successor.service_time;   % ����ʱ��
        else
            % �����֮��Ĺ˿͵�ʱ�䴰���ܵ�Ӱ�죬��Ҫ�����ж�
            if i ~= length(path) - 1  % ��̽ڵ㲻�ǲֿ�
                time = time + sqrt((predecessor.cx - successor.cx)^2 + (predecessor.cy - successor.cy)^2); % ��������ʱ��
                if time > successor.end_time  % Υ����ʱ�䴰Լ��
                    mark = 0;
                    break;
                else
                    if time < successor.start_time   % ������ʱ�䴰��ʼǰ����
                        time = successor.start_time;
                    end
                    time = time + successor.service_time;
                end
            end
        end
    end
end

%% --------------------- ����ĸ��Ӻ��� ------------------------- %%
function [code] = routecode(codepath)
    % ��codepath���б���
    code = '';
    for i = 1:length(codepath)
        nodeindexarr = codepath(i).nodeindex;
        for j = 1:length(nodeindexarr)
            code = strcat(code, num2str(nodeindexarr(j)));
        end
    end
end

function [cost] = routecost(path)
    % ����path����·��
    cost = 0;
    for i = 1:length(path)
        curroute = path(i).route;
        for j = 1:length(curroute)-1
            front = curroute(j);
            back = curroute(j+1);
            cost = cost + sqrt((front.cx-back.cx)^2+(front.cy-back.cy)^2);
        end
    end
end

function [tmax] = countMaxValue(path)
    % ����path�е������������ʱ���Լ������
    tmax = -inf;
    for i = 1:length(path)
        curroute = path(i).route;
        time = 0;
        if length(curroute) > 2   % ��·��������
            for j = 2:length(curroute) - 1
                predecessor = curroute(j-1);
                successor = curroute(j);
                time = time + sqrt((predecessor.cx-successor.cx)^2 + (predecessor.cy-successor.cy)^2);
                if time < successor.start_time
                    time = successor.start_time;
                end
                time = time + successor.service_time;
            end
            time = time - successor.service_time;  % ���һ���ڵ�ķ���ʱ�䲻��
            if time > tmax
                tmax = time;
            end
        end
    end
end

function [nodeindex1, nodeindex2] = showNodeindexInRouteSet(routeset)
    % ��routeset�еĽڵ���ȡ����
    % nodeindex1ȡ����routeset(x).nodeindex
    % nodeindex2ȡ����routeset(x).route.node.index
    nodeindex1 = [];
    nodeindex2 = [];
    for i = 1:length(routeset)
        nodeindex1 = [nodeindex1, routeset(i).nodeindex];
        for j = 2:length(routeset(i).route) - 1
            nodeindex2 = [nodeindex2, routeset(i).route(j).index];
        end
    end
end

function [nodeindex] = showNodeindexInNodeSet(nodeset)
    nodeindex = [];
    for i = 1:length(nodeset)
        nodeindex = [nodeindex, nodeset(i).index];
    end
end

function [result] = removeNullRoute(routeset)
    % �Ƴ���routeset�еĿ�·��
    removedindex = [];  % Ҫ�Ƴ���route��routeset�е��±�
    for i = 1:length(routeset)
        if length(routeset(i).nodeindex) == 0
            removedindex = [removedindex, i];
        end
    end
    routeset(removedindex) = [];  % ȥ����·��
    for i = 1:length(routeset)    % ���±��routeset�и��ڵ�ĳ������
        routeset(i).index = i;
        curroute = routeset(i).route;
        for j = 1:length(curroute)
            curroute(j).carindex = i;
        end
        routeset(i).route = curroute;
    end
    result = routeset;
end
        

            
