function [] = dataanalysis()
    % ���������ݷ���
    load('C:\Users\cfinsbear\Documents\DDVRPBTW\RC101_050.mat');
    drawRoute(final_path);
    routecost(initial_path)
    routecost(final_path)
    [nodeindex1, nodeindex2] = showNodeindexInRouteSet(final_path)
    sort(nodeindex2, 'ascend')
% [mark, timeslot, starttimearray, endtimearray] = timeWindowDetect(final_path(4).route)
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