function [initial_path] = initial(LHs, BHs, depot, capacity)
    % ��ʼ��·������
    initial_path = []; % ��ʼ·����
    candidate = [];  
    % ��˳�򽫹˿ͽڵ����
    % �Ƚ�LHs, BHsһ����һ������
    % ʣ�²��ԳƵĲ���ֱ�ӷŵ�����
    
    min_len = min(length(LHs), length(BHs));
    for i = 1:min_len
        candidate = [candidate, LHs(i)];
        candidate = [candidate, BHs(i)];
    end
    if length(LHs) < length(BHs)
        candidate = [candidate, BHs(min_len+1 : end)];
    else
        candidate = [candidate, LHs(min_len+1 : end)];
    end
    depot.carindex = 1;
    pathnode.route = [depot candidate(1) depot];  % �Ƚ�candidate�ĵ�һ���ڵ���뵽·����
    pathnode.quantityL = candidate(1).quantity;  % LHs��������
    pathnode.quantityB = 0;  % BHs��������
    pathnode.index = 1;  % �������
    pathnode.nodexindex = [candidate(1).index];  % ����·����ӵ�еĹ˿ͽڵ�ı�ţ�ע�ⰴ˳������
    carindex = 1;
    initial_path = [initial_path, pathnode];
    for k = 2:length(candidate)
        cost = inf;
        curnode = candidate(k);  % ��ǰҪ���뵽·���еĹ˿͵�
        for pathindex = 1:length(initial_path)  % ����·��ȥ��
            curpath = initial_path(pathindex);  % ��ǰ������·��
            curroute = curpath.route;
            for insertpointindex = 1:length(curroute)-1 % ÿ��·�������������������
                predecessor = curroute(insertpointindex); % ǰ�̽ڵ�
                successor = curroute(insertpointindex+1); % ��̽ڵ�
                switch curnode.type
                    case 'L'
                        if predecessor.type == 'D' || predecessor.type == 'L' % �ǿɲ����
                            if curpath.quantityL + curnode.quantity <= capacity % ��������Լ��
                                % ���ж��Ƿ�����ʱ�䴰Լ��
                                if timeWindowJudge(insertpointindex, curroute, curnode) == 1 % ����ʱ�䴰Լ��
                                    tempcost = computeCost(predecessor, curnode, successor, insertpointindex, curroute);
                                    if tempcost < cost
                                        cost = tempcost;
                                        insert.pathindex = pathindex;  % ��ǰ�����·��
                                        insert.insertpointindex = insertpointindex; % ���������·���е��±�
                                    end
                                end
                            end
                        end
                    case 'B'
                       if predecessor.type == 'L' && successor.type == 'B' || predecessor.type == 'L' && successor.type == 'D' || predecessor.type == 'B'
                            if curpath.quantityB + curnode.quantity <= capacity % ��������Լ��
                                % ���ж��Ƿ�����ʱ�䴰Լ��
                                if timeWindowJudge(insertpointindex, curroute, curnode) == 1 % ����ʱ�䴰Լ��
                                    tempcost = computeCost(predecessor, curnode, successor, insertpointindex, curroute);
                                    if tempcost < cost
                                        cost = tempcost;
                                        insert.pathindex = pathindex;  % ��ǰ�����·��
                                        insert.insertpointindex = insertpointindex; % ���������·���е��±�
                                    end
                                end
                            end
                        end   
                end
            end
        end
        if cost == inf % û�п��в����
            carindex = carindex + 1;
            depot.carindex = carindex;
            curnode.carindex = carindex;
            pathnode.route = [depot, curnode, depot]; % ����һ����·��
            if curnode.type == 'L'
                pathnode.quantityL = curnode.quantity;
                pathnode.quantityB = 0;
            else
                pathnode.quantityB = curnode.quantity;
                pathnode.quantityL = 0;
            end
            pathnode.index = carindex; % Ϊÿ��·����ע����������
            pathnode.nodeindex = [curnode.index];
            initial_path = [initial_path, pathnode];
        else  % ���뵽������С����������·��
            selectpath = initial_path(insert.pathindex);
            selectpath_route = selectpath.route;
            temp = [];
            nodeindex = selectpath.nodeindex;
            tempnodeindex = [];
            tempnodeindex = [tempnodeindex, selectpath.nodeindex(1:insert.insertpointindex)];
            tempnodeindex = [tempnodeindex, curnode.index];
            tempnodeindex = [tempnodeindex, selectpath.nodeindex(insert.insertpointindex+1 : end)];
            temp = [temp, selectpath_route(1:insert.insertpointindex)];
            curnode.carindex = selectpath.index;  % Ϊÿ���˿ͱ�ע����������
            temp = [temp, curnode];
            temp = [temp, selectpath_route(insert.insertpointindex+1 : end)];
            if curnode.type == 'L'
                selectpath.quantityL = selectpath.quantityL + curnode.quantity;
            else
                selectpath.quantityB = selectpath.quantityB + curnode.quantity;
            end
            selectpath.route = temp;
            selectpath.nodeindex = tempnodeindex;
            initial_path(insert.pathindex) = selectpath;
        end
    end
    initial_path = countArrivalTime(initial_path);
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

function [c1] = computeCost(predecessor, newcustomer, successor, insertpointindex, path)
    % ����������
    % ��ʱѡ�����·����
    c1 = sqrt((predecessor.cx - newcustomer.cx)^2 + (predecessor.cy - newcustomer.cy)^2) +... 
         sqrt((newcustomer.cx - successor.cx)^2 + (newcustomer.cy - successor.cy)^2) -... 
         sqrt((predecessor.cx - successor.cx)^2 + (predecessor.cy - successor.cy)^2);  % ·���仯
end

function [newrouteset] = countArrivalTime(routeset)
    % ����route��ÿ���˿ͽڵ�Ļ�������ʱ��
    routelen = length(routeset);   % ·����Ŀ����������
    newrouteset = [];
    for i = 1 : routelen
        route = routeset(i).route;  % ��ǰ·��
        currenttime = 0; 
        depot = route(1);
        depot.arrival_time = 0;   % �ֿ����ʱ���Ϊ0
        temp = [depot]; % temp������ӻ�������ʱ����·��
        for j = 2 : length(route) - 1
            predecessor = route(j-1);  % ǰ�̽ڵ�
            currentnode = route(j); % ��ǰ
            currenttime = currenttime + sqrt((predecessor.cx - currentnode.cx)^2 + (predecessor.cy - currentnode.cy)^2);
            currentnode.arrival_time = currenttime;  % ���ＴΪ��������ʱ��
            if currenttime < currentnode.start_time  % ��Ҫ�ȴ�
                currenttime = currentnode.start_time;
            end
            currenttime = currenttime + currentnode.service_time;  % ���Ϸ���ʱ��
            temp = [temp, currentnode];
        end
        temp = [temp, depot];
        node.route = temp;
        node.quantityL = routeset(i).quantityL;
        node.quantityB = routeset(i).quantityB;
        newrouteset = [newrouteset, node];
    end
end