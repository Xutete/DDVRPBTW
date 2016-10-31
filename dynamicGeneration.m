function [dynamicnodeset, determinednodeset, codemat] = dynamicGeneration(LHs, BHs, dynamicism, adheadtime)
	% ������̬����Ĺ˿ͼ�
	% dynamicism: ��̬����Ĺ˿���ռBHs�ı���
	% aheadtime: ��̬����Ĺ˿�������start_time��ǰaheadtime����
	BHnum = length(BHs);  % BHs����Ŀ
	dynamicnodenum = floor(BHnum * dynamicism);
	dynamicnodepos = randperm(BHnum);  % ����dynamicnodenum�����λ�ã�ѡ��̬����Ĺ˿�
    dynamicnodepos = dynamicnodepos(1:dynamicnodenum);
	dynamicnodeset = BHs(dynamicnodepos);   % ��̬����Ĺ˿ͽڵ�?
    determinedpos = setdiff(1:BHnum, dynamicnodepos, 'stable');
	determinednodeset = BHs(determinedpos);  % ȷ������Ĺ˿ͽڵ�?
	determinednodeset = [LHs, determinednodeset];  % ��LHs���뵽ȷ������Ĺ˿���
    totalnodenum = length([LHs, BHs]);  % �ܹ˿���
    
	% ������˿ͽ������±�ţ�����¼�����ǵ�index�Ķ�Ӧ��ϵ
	% ����determined��˿ʹ�1-m���б�ţ�dynamic��˿ʹ�m+1-n���б��
	codemat = zeros(1, totalnodenum);  % codemat(i)��Ź˿ͽڵ����ʵid
	for i = 1:length(determinednodeset)
		codemat(i) = determinednodeset(i).index;
		determinednodeset(i).index = i;
	end
	
	for i = 1:length(dynamicnodeset)
		codemat(i+length(determinednodeset)) = dynamicnodeset(i).index;
		dynamicnodeset(i).index = i + length(determinednodeset);
		dynamicnodeset(i).proposal_time = max(dynamicnodeset(i).start_time - adheadtime, 0);
	end
end