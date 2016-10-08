% ��ȡxml�ļ�

infilename = '';   % Ҫ��ȡ�ļ���

try
    xDoc = xmlread(infilename);
catch
    error('Failed to read XML file %s', infilename);
end
cx = []; % ���x����
cy = []; % ���y����
start_time = []; % ���ʱ�䴰��ʼʱ��
end_time = [];   % ���ʱ�䴰����ʱ��
quantity = [];   % ��Ż���������
service_time = [];  % ��ŷ���ʱ��

allXcoordItems = xDoc.getElementsByTagName('cx');  % x����
allYcoordItems = xDoc.getElementsByTagName('cy');  % y����
capacity = xDoc.getElementsByTagName('capacity');  % ������
max_travel_time = xDoc.getElementsByTagName('max_travel_time');  % �����������ʱ��
allStarttimeItems = xDoc.getElementsByTagName('start');  % ʱ�䴰����ʼʱ��
allEndtimeItems = xDoc.getElementsByTagName('end');  % ʱ�䴰����ֹʱ��
allQuantityItems = xDoc.getElementsByTagName('quantity');  % ����������
allServiceTimeItems = xDoc.getElementsByTagName('service_time');  % ����ʱ��

% ��ȡx����
for i = 0 : allXcoordItems.getLength - 1
    if i == 0  % �ֿ�����
        depotx = char(allXcoordItems.item(i).getData);
    else
        cx = [cx, char(allXcoordItems.item(i).getData)];
    end
end

% ��ȡy����
for i = 0 : allYcoordItems.getLength - 1
    if i == 0  % �ֿ�����
        depoty = char(allYcoordItems.item(i).getData);
    else
        cy = [cy, char(allYcoordItems.item(i).getData)];
    end
end

% ��ȡʱ�䴰��ʼʱ��
for i = 0 : allStarttimeItems.getLength - 1
    start_time = [start_time, char(allStarttimeItems.item(i).getData)];
end

% ��ȡʱ�䴰����ʱ��
for i = 0 : allEndtimeItems.getLength - 1
    end_time = [end_time, char(allEndtimeItems.item(i).getData)];
end

% ��ȡ�˿͵����������
for i = 0 : allQuantityItems.getLength - 1
    quantity = [quantity, char(allQuantityItems.item(i).getData)];
end

% ��ȡ�˿͵����ʱ��
for i = 0 : allServiceTimeItems.getLength - 1
    service_time = [service_time, char(allServiceTimeItems.item(i).getData)];
end

% ����Ϊ.mat��ʽ
save(infilename, 'cx', 'cy', 'depotx', 'depoty', 'start_time', 'end_time', 'quantity', 'service_time', 'capacity', 'max_travel_time');



% allCoordinatesItems = xDoc.getElementsByTagName_r('node'); % ����������ݸ���ȡ����
% for i = 0 : allCoordinatesItems.getLength - 1 % ÿ��node������ȡ
%     thisItem = allCoordinatesItems(i);    % ��ǰnode
%     childNode = thisItem.getFirstChild;   % node�ĵ�һ���ӽڵ㣨x���꣩
%     k = 0;  % 0��ʾx���꣬1��ʾy����
%     while ~empty(childNode)
%         if k == 0
%             cx = [cx childNode.getFirstChild.getData];
%         else
%             cy = [cy childNode.getFirstChild.getData];
%         end
%         k = k + 1;
%         childNode = childNode.getNextSibling;  % node����һ���ӽڵ㣨y���꣩
%     end    
% end
% allRequestItems = xDoc.getElementsByTagName_r('request');  % ��ȡʱ�䴰��������Ϣ


