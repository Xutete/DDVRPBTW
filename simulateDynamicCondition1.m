function [finalrouteset, finalcost] = simulateDynamicCondition1(initialrouteset, newcustomerset, capacity)
    % newcustomerset: eachnode: index, proposal_time, cx, cy, quantity, type     
    % indexset
    
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
       eventlist = addEventlist(eventlist, servicestarttime, 'service', firstnode.index, firstnode.carindex);
    end
    
    % ��������
    routeinfolist = initialrouteset;
    
    % Ȼ����µ���Ĺ˿������ʱ������eventlist��
    for i = 1:length(newcustomerset.nodeset)
        curcustomer = newcustomerset.nodeset(i);
        eventlist = addEventlist(eventlist, curcustomer.proposal_time, 'newdemandarrive', curcustomer.index, -1);
    end
    
    % ��ʱ���eventlist��������
    eventlist = sortEventlist(eventlist);
    
    % ִ��״̬��
	backtimetable = [];  % ���������زֿ��ʱ���
    while isempty(eventlist) == 0  
        curevent = eventlist(1);
		curtime = curevent.time;
        eventlist(1) = [];  % ɾ�������¼�
        switch curevent.type
            case 'service'   % �ڴ˴�����������ʱ��
                routeindex = curevent.carindex;
                finishedmark = routeinfolist(routeindex).finishedmark;
                curfinishedpos = find(finishedmark == 0);  % ��ǰ����Ľڵ���nodeindex�е�λ��
                curfinishedpos = curfinishedpos(1);
				onservicenode = routeinfolist(routeindex).route(curfinishedpos+1);  % ��ǰ���ܷ���Ľڵ�
                finishedmark(curfinishedpos) = 1;  % ��Ǹ�λ�õĽڵ����߹�
				departuretime = curtime + onservicenode.service_time;
                eventlist = addEventlist(eventlist, departuretime, 'departure', onservicenode.index, onservicenode.carindex);
				eventlist = sortEventlist(eventlist);
                routeinfolist(routeindex).finishedmark = finishedmark;
            case 'newdemandarrive'
                index = curevent.nodeindex;
                customerpos = find(index == newcustomerset.indexset);
                customernode = newcustomerset.nodeset(customerpos);
                [bestrouteindex, bestinsertpos, newrouteinfolist] = searchBestInsertPos(customernode, routeinfolist, capacity);
				if bestrouteindex == -1   % ���û�п���·������Ҫ�ֶ���ӷ���ʼ�¼�����Ϊ������·���ĵ�һ���ڵ�
					newroutenode = newrouteinfolist(end);   % �����ӵ�·��
					startnode = newroutenode.route(1);
					nextnode = newroutenode.route(2);
					servicestarttime = curtime + sqrt((startnode.cx - nextnode.cx)^2+(startnode.cy - nextnode.cy)^2);
					if servicestarttime < nextnode.start_time
						servicestarttime = nextnode.start_time;
                    end
                    eventlist = addEventlist(eventlist, servicestarttime, 'service', nextnode.index, nextnode.carindex);
					eventlist = sortEventlist(eventlist);
				end	
                routeinfolist = newrouteinfolist;
            case 'departure'  % ��ʱ��Ҫȷ���û�������һ��������
                routeindex = curevent.carindex;
                curroutenode = routeinfolist(routeindex);
                nextnodepos = find(curroutenode.finishedmark == 0);
				if isempty(nextnodepos) == 1  % �����·�������нڵ��Ѿ����꣬��Ӧ�ûص��ֿ�
					depot = curroutenode.route(end);
					lastnode = curroutenode.route(end-1);
					backtime = curtime + sqrt((lastnode.cx - depot.cx)^2 + (lastnode.cy - depot.cy)^2);
                    eventlist = addEventlist(eventlist, backtime, 'backtime', lastnode.index, lastnode.carindex);
					eventlist = sortEventlist(eventlist);
				else
					nextnodepos = nextnodepos(1);
                    curroutenode
					curnode = curroutenode.route(nextnodepos);      % ��ǰ�ڵ�
					nextnode = curroutenode.route(nextnodepos+1);   % ��һ���ڵ�
					servicestarttime = curtime + sqrt((curnode.cx - nextnode.cx)^2 + (curnode.cy - nextnode.cy)^2);
					if servicestarttime < nextnode.start_time
						servicestarttime = nextnode.start_time;
                    end
                    eventlist = addEventlist(eventlist, servicestarttime, 'service', nextnode.index, nextnode.carindex);
					eventlist = sortEventlist(eventlist);
				end
			case 'back'
				backtimetable(length(backtimetable)+1,:) = [curevent.time, curevent.carindex];
        end
    end  
	finalrouteset = routeinfolist;
	finalcost = routecost(finalrouteset)
end

function [neweventlist] = sortEventlist(initialeventlist)
    % ��ʱ��˳���initialeventlist��������
    eventlistlen = length(initialeventlist);
    timetable = [];
    for i = 1:eventlistlen
        timetable = [timetable, initialeventlist(i).time];
    end
    [sortresult, sortindex] = sort(timetable);
    neweventlist = initialeventlist(sortindex);
end

function [neweventlist] = addEventlist(initialeventlist, time, type, nodeindex, carindex)
    eventlistlen = length(initialeventlist);
    initialeventlist(eventlistlen+1).time = time;
    initialeventlist(eventlistlen+1).type = type;
    initialeventlist(eventlistlen+1).nodeindex = nodeindex;
    initialeventlist(eventlistlen+1).carindex = carindex;
    neweventlist = initialeventlist;
end

function [bestrouteindex, bestinsertpos, newrouteinfolist] = searchBestInsertPos(customernode, routeinfolist, capacity)
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
                            if timeWindowJudge(j, curroutenode.route, customernode) == 1  % ����ʱ�䴰Լ��
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
                            if timeWindowJudge(j, curroutenode.route, customernode) == 1  % ����ʱ�䴰Լ��
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
        newroutenode.finishedmark = [0];
        newroutenode.nodeindex = [customernode.index];
        routeinfolist = [routeinfolist, newroutenode];
    else
        selectedroutenode = routeinfolist(bestrouteindex);  % customernode���뵽�ýڵ���
        % ����nodeindex, finishedmark����Ϣ
        temp = [];
        temp = [temp, selectedroutenode.nodeindex(1:bestinsertpos-1)];
        temp = [temp, customernode.index];
        temp = [temp, selectedroutenode.nodeindex(bestinsertpos:end)];
        selectedroutenode.nodeindex = temp;
        temp = [];
        temp = [temp, selectedroutenode.route(1:bestinsertpos)];
        customernode.carindex = bestrouteindex;
        temp = [temp, customernode];
        temp = [temp, selectedroutenode.route(bestinsertpos+1:end)];
        selectedroutenode.route = temp;
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
    newcustomer = rmfield(newcustomer, 'proposal_time');
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

function [cost] = routecost(routeset)
    % ����path����·��
    cost = 0;
    for i = 1:length(routeset)
        curroute = routeset(i).route;
        for j = 1:length(curroute)-1
            front = curroute(j);
            back = curroute(j+1);
            cost = cost + sqrt((front.cx-back.cx)^2+(front.cy-back.cy)^2);
        end
    end
end