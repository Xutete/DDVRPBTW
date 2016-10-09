function [LHIndex, BHIndex] = seperateCustomer(start_time, cx, percentage)
    % ��percentageΪ�����ָ�ԭ��׼���Լ�
    % benchmarkmat: ��׼���Լ�mat
    % percentage: backhaulcustomer�ı���
    % LHIndex, BHIndexΪlinehaul��backhaul�ڵ���ԭ��׼���е��±�
    [sort_starttime, starttimeindex] = sort(start_time);
    totalcustomernum = length(cx);  % �ܵĹ˿�����
    backhaulnum = floor(totalcustomernum * percentage); % backhaul������
    LHIndex = starttimeindex(1:totalcustomernum - backhaulnum);
    BHIndex = starttimeindex(totalcustomernum - backhaulnum + 1: end);
end