function [LHs, BHs, depot] = seperateCustomer(path, percentage)
    % ��percentageΪ�����ָ�ԭ��׼���Լ�
    % path: ��׼���Լ�mat��·��
    % percentage: backhaulcustomer�ı���
    % LHs, BHsΪlinehaul��backhaul�ڵ㣬����������Ϣ�������������λ�õ���Ϣ
    load(path);
    [sort_starttime, starttimeindex] = sort(start_time, 'ascend'); % ������ʼʱ����������
    totalcustomernum = length(cx);  % �ܵĹ˿�����
    backhaulnum = floor(totalcustomernum * percentage); % backhaul������
    LHIndex = starttimeindex(1:totalcustomernum - backhaulnum);  % LHs��ԭ�˿ͼ��еĶ�λ
    BHIndex = starttimeindex(totalcustomernum - backhaulnum + 1: end);  % BHs��ԭ�˿ͼ��еĶ�λ
    depot.cx = depotx;
    depot.cy = depoty;
    depot.start_time = 0;
    depot.end_time = 0;
    depot.service_time = 0;
    depot.index = 0;
    depot.quantity = inf;
    depot.type = 'D';
    LHs = [];
    for i = 1:length(LHIndex)
        node.index = LHIndex(i);   % �ڵ���ԭ�˿ͼ��еĶ�λ
        node.start_time = start_time(node.index);
        node.end_time = end_time(node.index);
        node.service_time = service_time(node.index);
        node.cx = cx(node.index);
        node.cy = cy(node.index);
        node.quantity = quantity(node.index);
        node.carindex = 1;
        node.type = 'L';
        LHs = [LHs, node];
    end
    BHs = [];
    for i = 1:length(BHIndex)
        node.index = BHIndex(i);   % �ڵ���ԭ�˿ͼ��еĶ�λ
        node.start_time = start_time(node.index);
        node.end_time = end_time(node.index);
        node.service_time = service_time(node.index);
        node.cx = cx(node.index);
        node.cy = cy(node.index);
        node.quantity = quantity(node.index);
        node.carindex = 1;
        node.type = 'B';
        BHs = [BHs, node];
    end
end