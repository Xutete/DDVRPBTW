function [] = ALNS()
    % adaptive large neighbor search algorithm
end

%%%%%%%%%%%%%%%%%%%%%%%%%% removal algorithms %%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    end
    % ���ڶ�D�еı�Ž���ӳ�䣬�Ƴ�������·���е�D�е�Ԫ��
    DD = [];  % DD��ŵ���D�еı�Ŷ�Ӧ�Ľڵ�
    for i = 1:K
        curpath = solutions(i);
        [curremovednodeindex, curremovenodepos] = intersect(curpath.nodeindex, D);  % �ҳ����Ƴ��Ľڵ���
        for j = 1:length(curremovenodepos)  % ����ڵ�����Ƴ���ע��ͬ������quantityL��quantityB
            curnode = curpath(curremovenodepos+1);  % ע���һ���ڵ���depot��nodeindex��ֻ�й˿ͽڵ�ı��
            DD = [DD, curnode]
            if (curnode.type == 'L')
                curpath.quantityL = curpath.quantityL - curnode.quantity;
            else
                curpath.quantityB = curpath.quantityB - curnode.quantity;
            end
        end
        curpath.nodeindex = curremovednodeindex;
        solutions(i) = curpath
    end
    removedpath = solutions;
    removedrequestnode = DD;
    removedrequestindex = D; 
end