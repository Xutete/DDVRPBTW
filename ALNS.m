function [] = ALNS()
    % adaptive large neighbor search algorithm
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
    phi = 2;
    K = length(solutions); % ������
    % ���������ѡȡ·���е�һ���ڵ�
    selectedrouteindex = randi([1,K]);  % ���ѡȡһ��·��
    selectedroute = solutions(selectedrouteindex).route; % ���ѡ�е�·��
    selectedroutelen = length(selectedroute) - 2;  % ȥͷȥβ�ĳ���
    selectednodeindex = randi([1 selectedroutelen]);  % ���ѡȡ��·���е�һ���ڵ�
    selectednode = selectedroute(selectednodeindex + 1); % ע���һ���ڵ��ǲֿ�
    R = inf(n,n);  % �����ڵ�֮�������̶�
    temp = []
    for i = 1:K  % �Ȱ����нڵ�ķŵ�һ����ʱ����temp��
        curroute = solutions(i).route;
        for j = 2 : length(curroute - 1)
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
                                        phi * abs(node1.quantity - node2.quantity);
            R(node2index, node1index) = R(node1index, node2index);
        end
    end
    D = [selectednode.index];  % D�洢���Ǳ��Ƴ��ڵ�ı��
    nodeindexinroute = setdiff(1:n, selectednode.index);  % ����·���еĽڵ���
    while length(D) < q
        % һֱѭ��ִ�е�D�е�request����ΪqΪֹ
        [sortR, sortRindex] = sort(R(selectednodeindex, nodeindexinroute), 'ascend');  
        % ������̶ȴӵ͵��߽�������
        % ֻ��������·���еĽڵ�
        y = rand;
        removenum = y^p * length(nodeindexinroute);  % �Ƴ���request������
        removenodeindex = nodeindexinroute(sortRindex(1:removenum)); % ���Ƴ���·���ڵ�ı��
        nodeindexinroute = setdiff(nodeindexinroute, removenodeindex);
        D = [D, removenodeindex];
        selectednodeindex = randi(nodeindexinroute);  % �ٴ����ѡȡһ��request
    end
    % ���ڶ�D�еı�Ž���ӳ�䣬�Ƴ�������·���е�D�е�Ԫ��
    [solutions, DD] = removeNodeInRoute(D, solutions)
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
        curselected = randi(allnodeindex);
        selectednodeindex = [selectednodeindex, curselected];
        allnodeindex = setdiff(allnodeindex, curselected);
    end
    [result, removednode] = removeNodeInRoute(selectednodeindex, solutions)
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
        [sortreducedcost, sortindex] = sort(reducedcost, 'ascend');
        y = rand;
        removenodeindex = sortindex(y^p*length(nodeindexset));
        DD = [DD, removenodeindex];
        [result, removednode] = removeNodeInRoute(removenodeindex, solutions);
        solutions = result;  % �Ƴ��ڵ�����·��
        nodeindexset = setdiff(nodeindexset, removenodeindex);
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
    DD = [];
    for i = 1:K
        curpath = routeset(i);
        curroute = curpath.route;
        [curremovednodeindex, curremovenodepos] = intersect(curpath.nodeindex, D);  % �ҳ����Ƴ��Ľڵ���
        for j = 1:length(curremovenodepos)  % ����ڵ�����Ƴ���ע��ͬ������quantityL��quantityB
            curnode = curroute(curremovenodepos(j)+1);  % ע���һ���ڵ���depot��nodeindex��ֻ�й˿ͽڵ�ı��
            DD = [DD, curnode]
            if (curnode.type == 'L')
                curpath.quantityL = curpath.quantityL - curnode.quantity;
            else
                curpath.quantityB = curpath.quantityB - curnode.quantity;
            end
        end
        curpath.nodeindex = curremovednodeindex;
        curroute(curremovenodepos+1) = [];  % һ�����Ƴ���������Ҫ�Ƴ��Ľڵ�
        curpath.route = curroute
        routeset(i) = curpath
    end
    result = routeset;
    removednode = DD;
end

function [reducedcost] = computeReducedCost(routeset, nodeindexset, n)
    % ����routeset�����нڵ���Ƴ����ۣ����Ƴ�����֮�������·�����۱仯����
    reducedcost = inf(1,n);
    for i = 1:length(routeset)
        curroute = routeset(i).route;
        for j = 2:length(curroute)-1
            predecessor = curroute(j-1);
            curnode = curroute(j);
            successor = curroute(j+1);
            nodeindex = curroute(j).index;
            temp = -sqrt((predecessor.cx-curnode.cx)^2 + (predecessor.cy-curnode.cy)^2) -...
                   sqrt((successor.cx-curnode.cx)^2 + (successor.cy-curnode.cy)^2) +...
                   sqrt((predecessor.cx-successor.cx)^2 + (predecessor.cy-successor.cy)^2);
            reducedcost(nodeindex) = temp;
        end
    end
end

%% ------------------------ insertion algorithms ---------------------- %%
%% greedy insert
function [] = greedyInsert(removednode, removedroute)
    % ̰���㷨��ÿ�ζ�Ѱ����õĵ����
    % ��removednode���뵽removedroute��
    countInsertCost
end

%% ���Ӻ���
function [] = countInsertCost(nodeset, routeset)
    % ����nodeset�нڵ���뵽routeset�е���С����
    for i = 1:length(nodeset)
        curnode = nodeset(i);  % ��ǰ��Ҫ����Ľڵ�
        mininsertcost = inf;
        for j = 1:length(routeset)
            curpath = routeset(j);
            curroute = curpath.route;
            for k = 1:length(curroute-1)
                insertnode = curroute(k);  % ����㣬���뵽�˵��
                successor = curroute(k+1);
                switch curnode.type
                    case 'L'
                        if curpath.quantityL + curnode.quantity < capacity  % ��������Լ��
                            if timeWindowJudge(k, curroute, curnode) == 1   % ����ʱ�䴰Լ��
                                temp = sqrt((insertnode.cx-curnode.cx)^2 + (insertnode.cy-curnode.cy)^2) +...
                                       sqrt((successor.cx-curnode.cx)^2 + (successor.cy-curnode.cy)^2) -...
                                       sqrt((insertnode.cx-successor.cx)^2 + (insertnode.cy-successor.cy)^2);
                                if temp < mininsertcost
                                    
                                end
            end
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
            
