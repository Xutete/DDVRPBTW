function [] = adjustCapacity(routeset, capacity, tradeoff)
    % capacity: ԭ��Ϊÿһ��������Ĺ̶�����
    % tradeoff: Ϊ��ʼȷ���Ĺ˿Ͱ���·��ʱ����ÿһ����������tradeoff�����Ա��÷�����涯̬����Ĺ˿�
    availablequantityLset = [];
    availablequantityBset = [];
    for i = 1:length(routeset)
        routenode = routeset(i);
        leftcapacity = capacity - max(routenode.quantityL, routenode.quantityB)
end