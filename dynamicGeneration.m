function [dynamicnodeset, determinednodeset, codemat] = dynamicGeneration(nodeset, dynamicism, adheadtime)
	% ������̬����Ĺ˿ͼ�
	% dynamicism: ��̬����Ĺ˿���ռ�ܹ˿����ı���
	% aheadtime: ��̬����Ĺ˿�������start_time��ǰaheadtime����
	totalnodenum = length(nodeset);  % �ܹ˿���
	dynamicnodenum = floor(totalnodenum * dynamicism);
	dynamicnodepos = randi([1 totalnodenum], 1, dynamicnodenum);  % ����dynamicnodenum�����λ�ã�ѡ��̬����Ĺ˿�
	dynamicnodeset = nodeset(dynamicnodepos);   % ��̬����Ĺ˿ͽڵ�?
	determinednodeset = setdiff(nodeset, dynamicnodeset, 'stable');  % ȷ������Ĺ˿ͽڵ�?
	
	% ������˿ͽ������±�ţ�����¼�����ǵ�index�Ķ�Ӧ��ϵ
	% ����determined��˿ʹ�1-m���б�ţ�dynamic��˿ʹ�m+1-n���б��
	codemat = zeors(1, totalnodenum);  % codemat(i)��Ź˿ͽڵ����ʵid
	for i = 1:length(determinednodeset)
		codemat(i) = determinednodeset(i).index;
		determinednodeset(i).index = i;
	end
	
	for i = 1:length(dynamicnodeset)
		codemat(i+length(determinednodeset)) = dynamicnodeset(i).index;
		dynamicnodeset(i).index = i + length(determinednodeset);
		dynamicnodeset(i).proprosal_time = max(dynamicnodeset(i).start_time - adheadtime, 0);
	end
end