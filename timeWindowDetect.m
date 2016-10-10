function [mark, timeslot, starttimearray, endtimearray] = timeWindowDetect(route)
    % �ж�ĳ��·���Ƿ�Υ��ʱ�䴰Լ��
    time = 0;
    mark = 1;
    timeslot = [0];
    starttimearray = [];
    endtimearray = [];
    for i = 1:length(route) - 2
        predecessor = route(i); % ǰ�̽ڵ�
        successor = route(i+1); % ��̽ڵ�
        time = time + sqrt((predecessor.cx - successor.cx)^2 + (predecessor.cy - successor.cy)^2); % ��������ʱ��
        timeslot = [timeslot, time];
        if time > successor.end_time
            mark = 0;
            break;
        else
            if time < successor.start_time
                time = successor.start_time;
            end
            time = time + successor.service_time;
        end
        starttimearray = [starttimearray, successor.start_time];
        endtimearray = [endtimearray, successor.end_time];
    end            
end