function plot_su(filename, save_dir)
    % plot_su_v2.m - 读取SU文件并绘制地震剖面
    % 用法: 
    %   plot_su('test.su')                    % 保存到当前目录
    %   plot_su('test.su', '/home/user/results')  % 保存到指定目录
    
    % 检查文件是否存在
    if ~exist(filename, 'file')
        fprintf('错误: 文件 %s 不存在！\n', filename);
        return;
    end
    
    % 如果没指定保存目录，使用当前目录
    if nargin < 2
        save_dir = pwd;
    end
    
    % 确保保存目录存在，如果不存在则创建
    if ~exist(save_dir, 'dir')
        fprintf('创建保存目录: %s\n', save_dir);
        mkdir(save_dir);
    end
    
    fprintf('正在读取文件: %s\n', filename);
    fprintf('文件将保存到: %s\n', save_dir);
    
    % 读取SU文件
    try
        [Data, SuTraceHeaders, SuHeader] = ReadSu(filename);
    catch ME
        fprintf('读取失败，尝试指定字节序为大端(big-endian)...\n');
        try
            [Data, SuTraceHeaders, SuHeader] = ReadSu(filename, 'endian', 'b');
        catch
            fprintf('读取失败，尝试指定字节序为小端(little-endian)...\n');
            [Data, SuTraceHeaders, SuHeader] = ReadSu(filename, 'endian', 'l');
        end
    end
    
    % 显示数据信息
    [ns, nt] = size(Data);
    fprintf('数据维度: %d 采样点 × %d 道\n', ns, nt);
    fprintf('采样间隔: %d 微秒\n', SuHeader.dt);
    
    % 创建时间轴（秒）
    dt_sec = SuHeader.dt / 1e6;
    t = (0:ns-1) * dt_sec;
    
    % 创建道号轴
    traces = 1:nt;
    
    % 使用灰度图显示
    figure('Visible', 'off', 'Position', [100, 100, 800, 600]);
    
    % 子图1: 变密度显示
    subplot(1,2,1);
    imagesc(traces, t, Data);
    colormap(gray);
    xlabel('Trace');
    ylabel('Time (s)');
    title('Seismic Record');
    colorbar;
    set(gca, 'YDir', 'reverse');  % 时间轴向下
    set(gca, 'XAxisLocation', 'top');
    
    
    % 子图2: 波形显示 (取部分道)
    subplot(1,2,2);
    plot_traces = min(20, nt);  % 最多显示20道
    step = max(1, floor(nt/plot_traces));
    for i = 1:step:min(nt, step*plot_traces)
        if i <= nt
            plot(Data(:,i)/max(abs(Data(:,i))) + i, t, 'k-', 'LineWidth', 0.5);
            hold on;
        end
    end
    xlabel('Trace');
    ylabel('Time (s)')
    title('Seismic Record(waveform)');
    set(gca, 'YDir', 'reverse');
    set(gca, 'XAxisLocation', 'top');
    xlim([0.5, nt+0.5]);
    hold off;
    
    % 生成输出文件名
    [~, name, ~] = fileparts(filename);
    
    % 拼接完整的保存路径
    png_file = fullfile(save_dir, [name, '_wf.png']);
    mat_file = fullfile(save_dir, [name, '_data.mat']);
    
    % 保存图像
    saveas(gcf, png_file);
    fprintf('图像已保存为: %s\n', png_file);
    
    % 关闭图形窗口
    close(gcf);
    
    % 保存数据到mat文件
    save(mat_file, 'Data', 'SuTraceHeaders', 'SuHeader');
    fprintf('数据已保存为: %s\n', mat_file);
    
    fprintf('所有文件保存完成！\n');
end
