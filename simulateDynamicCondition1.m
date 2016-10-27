function [] = simulateDynamicCondition1(initialrouteset, newcustomerset)
    % newcustomerset: eachnode: index, proposal_time, cx, cy, quantity, type
    %                   itself: indexset -- ��������ĳ��index��Ӧ��customer������                   
    
    eventlist = [];  % ʱ������Դ���״̬��
    
    % ���Ȱѳ�ʼ·���ĵ�һ���˿ͽڵ���ܷ�����¼�¼�뵽eventlist��
    for i = 1:length(initialrouteset)
       curroute = initialrouteset(i).route;
       initialrouteset(i).finishedmark = zeros(1,length(curroute)-2); 
       depot = curroute(1);      % �ֿ�ڵ�
       firstnode = curroute(2);  % ��һ������Ľڵ�
       servicestarttime = sqrt((depot.cx - firstnode.cx)^2 + (depot.cy - firstnode.cy)^2);
       if servicestarttime < firstnode.start_time
           servicestarttime = firstnode.start_time;
       end
       listelement = [servicestarttime, 'service', firstnode.index, firstnode.carindex];    % ����˿�
       eventlist(length(eventlist)+1,:) = listelement;
       serviceendtime = servicestarttime + firstnode.service_time;
       listelement = [serviceendtime, 'departure', firstnode.index, firstnode.carindex];    % ��������
       eventlist(length(eventlist)+1,:) = listelement;
    end
    
    % ��������
    routeinfolist = initialrouteset;
    
    % Ȼ����µ���Ĺ˿������ʱ������eventlist��
    for i = 1:length(newcustomerset)
        curcustomer = newcustomerset(i);
        listelement = [curcustomer.proposal_time, 'newdemandarrive', curcustomer.index, -1];  % �µ���Ĺ˿ͻ�û�з���·��
        eventlist(length(eventlist)+1,:) = listelement;
    end
    
    % ��ʱ���eventlist��������
    eventlist = sortEventlist(eventlist);
    
    % ִ��״̬��
    while isempty(eventlist) == 0  
        curevent = eventlist(1,:);
        eventlist(1,:) = [];  % ɾ�������¼�
        switch curevent(2)
            case 'service'
                routeindex = curevent(4);
                finishedmark = routeinfolist(routeindex).finishedmark;
                curfinishedpos = find(finishedmark == 0);  % ��ǰ����Ľڵ���nodeindex�е�λ��
                curfinishedpos = curfinishedpos(1);
                finishedmark(curfinishedpos) = 1;  % ��Ǹ�λ�õĽڵ����߹�
                routeinfolist(routeindex).finishedmark = finishedmark;
            case 'newdemandarrive'
                index = curevent(3);
                customerpos = find(index == newcustomerset.indexset);
                customernode = newcustomerset(customerpos);
                [bestrouteindex, bestinsertpos, newrouteinfolist] = searchBestInsertPos(customernode, routeinfolist);
                routeinfolist = newrouteinfolist;
            case 'departure'  % ��ʱ��Ҫȷ���û�������һ��������
                routeindex = curevent(4);
                curroutenode = routeinfolist(routeindex);
                nextnodepos = find()
        end
    end    
end

function [neweventlist] = sortEventlist(initialeventlist)
    timetable = initialeventlist(:,1);  % ȡ��ʱ�����¼�
    [sortresult, sortindex] = sort(timetable, 'ascend');
    neweventlist = initialeventlist(sortindex,:);
end

function [bestrouteindex, bestinsertpos, newrouteinfolist] = searchBestInsertPos(customernode, routeinfolist)
    % ΪcustomernodeѰ����Ѳ���λ�ú���Ӧ��·��
    bestcost = inf;
    bestrouteindex = -1;
    bestinsertpos = -1;
    for i = 1:length(routeinfolist)
        curroutenode = routeinfolist(i);
        accessinsertpos = find(curroutenode.finishedmark == 0); % ���в���㣬�����route
        if isempty(accessinsertpos) == 1 % û�п��в���㣨����Ҫʻ�زֿ⣩ 
            continue
        else
            accessinsertpos = accessinsertpos(1);  % ת��Ϊ��route�е�����
        end
        for j = accessinsertpos : length(curroutenode.route)-1
            predecessor = curroutenode.route(j);   % �����
            successor = curroutenode.route(j+1);   % ��̽ڵ�
            switch customernode.type
                case 'L'
                    if predecessor.type == 'D' || predecessor.type == 'L' % �ǿɲ����
                        if curroutenode.quantityL + customernode.quantity < capacity  % ��������Լ��
                            if timeWindowJudge(j, curroutenode.route, newcustomer) == 1  % ����ʱ�䴰Լ��
                                temp = sqrt((predecessor.cx - customernode.cx)^2 + (predecessor.cy - customernode.cy)^2);
                                if temp < bestcost
                                    bestcost = temp;
                                    bestrouteindex = i;
                                    bestinsertpos = j;
                                end
                            end
                        end
                    end
                case 'B'
                    if predecessor.type == 'L' && successor.type == 'B' || predecessor.type == 'L' && successor.type == 'D' || predecessor.type == 'B'
                        if curroutenode.quantityB + customernode.quantity < capacity  % ��������Լ��
                            if timeWindowJudge(j, curroutenode.route, newcustomer) == 1  % ����ʱ�䴰Լ��
                                temp = sqrt((predecessor.cx - customernode.cx)^2 + (predecessor.cy - customernode.cy)^2);
                                if temp < bestcost
                                    bestcost = temp;
                                    bestrouteindex = i;
                                    bestinsertpos = j;
                                end
                            end
                        end
                    end
            end
        end
    end
    customernode = rmfield(customernode, 'proposal_time');  % ɾ�������󵽴���¼���һ����
    if bestrouteindex == -1  % û�п��в����
        newrouteindex = length(routeinfolist) + 1;
        newroutenode.index = newrouteindex;
        depot = routeinfolist(1).route(1);
        depot.carindex = newrouteindex;
        customernode.carindex = newrouteindex;
        newroutenode.route = [depot, customernode, depot];
        switch customernode.type
            case 'L'
                newroutenode.quantityL = customernode.quantity;
                newroutenode.quantityB = 0;
            case 'B'
                newroutenode.quantityB = customernode.quantity;
                newroutenode.quantityL = 0;
        end
        newroutenode.finishedmark = [];
        routeinfolist = [routeinfolist, newroutenode];
    else
        selectedroutenode = routeinfolist(bestrouteindex);  % customernode���뵽�ýڵ���
        % ����nodeindex, finishedmark����Ϣ
        temp = [];
        temp = [temp, selectedroutenode.nodeindex(1:bestinsertpos-1)];
        temp = [temp, customernode.index];
        temp = [temp, selectedroutenode.nodeindex(bestinsertpos:end)];
        routeinfolist(bestrouteindex).nodeindex = temp;
        temp = [];
        temp = [temp, selectedroutenode.route(1:bestinsertpos)];
        customernode.carindex = bestrouteindex;
        temp = [temp, customernode];
        temp = [temp, selectedroutenode.route(bestinsertpos+1:end)];
        selectedroutenode.finishedmark = [selectedroutenode.finishedmark, 0];
        switch customernode.type
            case 'L'
                selectedroutenode.quantityL = selectedroutenode.quantityL + customernode.quantity;
            case 'B'
                selectedroutenode.quantityB = selectedroutenode.quantityB + customernode.quantity;
        end
        routeinfolist(bestrouteindex) = selectedroutenode;
    end
    newrouteinfolist = routeinfolist;
end

function [mark] = timeWindowJudge(insertpointpos, route, newcustomer)
    % �ж��²���Ŀͻ����Ƿ��ʹ�ú����ڵ��ʱ�䴰Լ����Υ��
    time = 0;  % ��ǰʱ��Ϊ0
    temp = [];
    temp = [temp, route(1:insertpointpos)];
    temp = [temp newcustomer];
    temp = [temp route(insertpointpos + 1:end)];
    route = temp;
    mark = 1;  % Ϊ0��ʾΥ��Լ��
    for i = 1:length(route)-2
        predecessor = route(i); % ǰ�̽ڵ�
        successor = route(i+1); % ��̽ڵ�
        if (i < insertpointpos) % �ڲ����֮ǰ�Ĺ˿͵�ʱ�䴰��û���ܵ�Ӱ�죬����Ҫ�����ж�
            time = time + sqrt((predecessor.cx - successor.cx)^2 + (predecessor.cy - successor.cy)^2); % ��������ʱ��
            if (time < successor.start_time)  % ������ʱ�䴰��ʼǰ����
                time = successor.start_time;
            end
            time = time + successor.service_time;   % ����ʱ��
        else
            % �����֮��Ĺ˿͵�ʱ�䴰���ܵ�Ӱ�죬��Ҫ�����ж�
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