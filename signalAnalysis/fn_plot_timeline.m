% fn_plot_timeline
% Information to complete:
function fn_plot_timeline(st_cfg)
    
nm_nLines	= size(st_cfg.tLine,1);

axes(st_cfg.parent)
hold on
% plot condition plots
for kk =  1:nm_nLines
        
    vt_curLine	= st_cfg.tLine(kk,:);
    
    if ~isempty(st_cfg.tError)
        vt_curError	= st_cfg.tError(kk,:);
        vt_curPatch = horzcat(vt_curLine + vt_curError,...
                    fliplr(vt_curLine)-fliplr(vt_curError));
        vt_timPatch =  horzcat(st_cfg.xAxes(:)' ,fliplr(st_cfg.xAxes(:)'));
        
        patch(vt_timPatch,vt_curPatch,st_cfg.color{kk},...
            'parent',gca,...
            'FaceColor',st_cfg.color{kk},...
            'FaceAlpha',st_cfg.faceAlpha,...
            'EdgeColor',st_cfg.color{kk},...
            'EdgeAlpha',st_cfg.edgeAlpha)
    end

    plot(st_cfg.xAxes,vt_curLine,...
        'Color',st_cfg.color{kk},'LineWidth',st_cfg.lineWidth),

end

if isfield(st_cfg,'signif')
    mx_signif               = nan(size(st_cfg.xAxes));
    mx_signif(st_cfg.signif)= 1;
    
    if any(~isnan(mx_signif))
        vt_ylim	= get(st_cfg.parent,'ylim');
        vt_area	= diff(vt_ylim) * 0.1;
        vt_area	= [vt_ylim(1), vt_ylim(1) + vt_area];
        vt_lPos	= linspace(vt_area(1),vt_area(2),size(mx_signif,1));
        
        for kk = 1:numel(vt_lPos)
            vt_linePlot	= mx_signif(kk,:).*vt_lPos(kk);
            vt_color    = 1 - st_cfg.color{kk+1};
            plot(st_cfg.xAxes,vt_linePlot,...
                'Color',vt_color,'LineWidth',4),
        end
    end
end
hold off

set(st_cfg.parent,'xlim',st_cfg.xAxes([1,end]))
xlabel(st_cfg.xlabel)
ylabel(st_cfg.ylabel)
