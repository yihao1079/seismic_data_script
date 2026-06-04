function plot_model(filename, NX, NY, DH)
% PLOT_SOFI2D_MODEL  读取并显示 SOFI2D 输出的单个二进制模型文件
%
% 用法：
%   plot_sofi2d_model('model/test.SOFI2D.vs', 100, 100, 54.0)
%
% 输入：
%   filename : 字符串，模型文件完整路径（如 'model/test.SOFI2D.vs'）
%   NX       : x 方向网格点数
%   NY       : y 方向网格点数
%   DH       : 网格间距 (米)
%
% 文件格式：
%   32 位 float，无文件头，存储顺序为 y 方向变化最快（列主序），
%   即 (x0,y0), (x0,y1), ..., (x1,y0), (x1,y1), ...

% 打开文件
fid = fopen(filename, 'rb');
if fid == -1
    error('无法打开文件: %s', filename);
end

% 读取全部 float32 数据
raw = fread(fid, NX * NY, 'float32');
fclose(fid);

% 检查大小
if numel(raw) ~= NX * NY
    error('文件大小与 NX*NY 不符。期望 %d 个 float32，实际 %d。', NX*NY, numel(raw));
end

% 重塑矩阵：文件顺序 (x外循环, y内循环) → 转置后变为 [NX, NY]
data = reshape(raw, NY, NX)';   % data(i,j) 对应 x=i, y=j

% ---- 绘图 ----
figure;
imagesc((1:NX)*DH, (1:NY)*DH, data');   % 转置使 x 横轴，y 纵轴
axis xy equal tight
colorbar;

% 自动设置标题（从文件名提取基础名，去掉路径和后缀）
[~, name, ext] = fileparts(filename);
title(sprintf('%s%s', name, ext), 'Interpreter', 'none');
xlabel('X (m)');
ylabel('Depth (m)');

% 打印数值范围
fprintf('文件: %s\n', filename);
fprintf('数值范围: min = %.3f, max = %.3f\n', min(data(:)), max(data(:)));
end
