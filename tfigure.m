classdef tfigure < hgsetget
    %TFIGURE A figure for holding tabbed groups of plots
    %   Creates a tabbed plot figure.  This allows the user to setup tabs
    %    to group plots.  Each tab contains a list of plots that can be
    %    selected using buttons on the left of the figure.
    %    
    %   Example
    %    h = tfigure;
    %
    % tfigure Properties:
    %  fig - Handle to the figure that displays tfigure.
    %  tabs - Handles to each of the tfigure's tabs
    %  figureSize - Current size of the figure containing tfigure
    %
    % tfigure Methods:
    %  tfigure - Constructs a new tabbed figure
    %  addTab - Adds a new tab
    %  addPlot - Adds a new plot to the given tab
    %  addSummary - Adds a summary
    %
    % Examples:
    %  <matlab:tfigure_example> tfigure example
    %
    % TO DO:
    %  * Finish Summary Slide functionality
    %  * Add "save all plots" functionality to the summary slide
    %     * ppt, pictures, figures
    %  * Add support for using a ppt template
    %  * Fix the handling of resizing figures that contain plots with 
    %   legends outside of their axis 
    %  * Add tables as an option for displaying data
    %  * Simplify plotting interface to act more like a traditional matlab
    %   plotting interface.
    %  * Add a uicontextmenu for editing plots when the user right clicks
    %  on them.  This would allow the user to change the name, etc.
    % Author: Curtis Mayberry
    % Curtisma3@gmail.com
    % Curtisma.org
    %
    % see also: tFigExample
    
    properties
        fig % Handle to the figure that displays tfigure.
        tabs % Handles to each of the tfigure's tabs
        menu % Tfigure menu
    end
    properties (Dependent)
        figureSize % Current size of the figure containing tfigure
    end
    properties (Access = private)
        tabGroup
    end
    methods
        function obj = tfigure(varargin)
        % TFIGURE([title_tab1]) Creates a new tabbed figure.
        %  Additional tabs can be added to the figure using the addTab
        %  function.  Plots can be added to each tab by using the addPlot
        %  function.
        %
        %
        	obj.fig = figure('Visible','off',...
                             'SizeChangedFcn',@obj.figResize); 
            obj.tabGroup = uitabgroup('Parent', obj.fig);
            obj.addTab;
%             obj.menu = uimenu(obj.fig,'Label','Tfigure');
            obj.menu = uimenu(obj.fig,'Label','Export');
            uimenu(obj.menu,'Label','Export PPT','Callback',@obj.exportMenu)
            obj.fig.Visible = 'on';
        end
        function out = get.figureSize(obj)
            out = get(obj.fig,'position');
        end
        function h = addSummary(obj)
            h = uitab('Parent', obj.tabGroup, 'Title', 'Summary');
            obj.tabs(2:end+1) = obj.tabs(1:end);
            obj.tabs(1) = h;
            obj.tabGroup.Children = obj.tabGroup.Children([end 1:end-1]);
        end
        function h = addTab(obj,varargin)
        % addTab([title]) Adds a new tab with the given title.
        %
        % USAGE:
        %  tfig.addTab(title);
        %
            p = inputParser;
            addOptional(p,'titleIn',...
                        ['dataset ' num2str(length(obj.tabs) +1)],@isstr);
            parse(p,varargin{:});
            h = uitab('Parent', obj.tabGroup,...
                      'Title', p.Results.titleIn);
            obj.tabs(end+1) = h;
            figSize = obj.figureSize;
            plotList = uibuttongroup('parent',h,'Title','Plots',...
                            'Units','pixels',...
                            'Position',[10 10  150 figSize(4)-45],...
                            'tag','plotList',...
                            'SelectionChangedFcn',@obj.selectPlot);
            h.UserData = plotList;
            if(length(plotList.Children) <= 1)
                plotList.Visible = 'off';
            end
%             axes('Parent',h,'Units','pixels',...
%                 'position',[210 50  figSize(3)-240 figSize(4)-110],'ActivePositionProperty','OuterPosition');
            
        end
        function h = addPlot(obj,tab,varargin)
        % addPlot(tab,[fun_handle],[title]) Adds a plot to the given tab.  
        %  When the button is selected the plotting routine given by
        %  fun_handle is ran.
        %  
            p=inputParser;
            p.addRequired('tab',@(x) (isa(x,'double') || isa(x,'matlab.ui.container.Tab') || ischar(x)))
            p.addOptional('fun_handle',[],@(x) isa(x,'function_handle'));
            p.addParameter('title','plot',@ischar)
            p.parse(tab,varargin{:})

            if(ischar(tab))
                tab_obj = findobj(tab,'Type','tab');
                if(isempty(tab_obj))
                    obj.addTab(tab)
                else
                    tab = tab_obj;
                end
            end
            figSize = obj.figureSize;
%             plotList = findobj(tab,'tag','plotList','-and',...
%                                 'Type','uibuttongroup');
            plotList = get(tab,'UserData');
            numPlots = length(findobj(plotList,'tag','plot','-and',...
                                      'Style','togglebutton'));
            h = uicontrol('parent',plotList,...
                          'Style', 'togglebutton',...
                          'String', p.Results.title,'Units','pixels',...
                          'Position', [10 figSize(4)-85-30*numPlots 120 20],...
                          'tag','plot');
%             if(length(plotList.Children) > 1)
%                 axesSize = [210 50 figSize(3)-240 figSize(4)-110];
%                 plotList = get(tab,'UserData');
%                 for i = 1:length(plotList.Children)
%                     plotList.Children(i).UserData.fa.Visible = 'off';
%                 end
%             else
%                 axesSize = [50 50 figSize(3)-90 figSize(4)-110];
%             end
            h.UserData.fa = axes('Parent',tab,'Units','pixels',...
...%                              'position',axesSize,...
                             'ActivePositionProperty','OuterPosition');
            h.UserData.fa.Visible = 'on';             
            if(~isempty(p.Results.fun_handle))
                h.UserData.fh = p.Results.fun_handle;
                p.Results.fun_handle();
            end
            plotList.SelectedObject = h;
            obj.selectPlot(plotList,[]);
        end
        function h = addPlotList(obj)
        end
        function h = addTable(obj,tab,fun_handle,fig,varargin)
        % addTable Adds a table to the given tab.
        %
        % TODO: Finish functionality
        %
            p=inputParser;
            p.addRequired('tab',@(x) (isa(x,'double') || isa(x,'matlab.ui.container.Tab') || ischar(x)))
            p.addRequired('fun_handle',@(x) isa(x,'function_handle'));
            p.addParameter('title','plot',@ischar)
            p.parse(tab,fun_handle,varargin{:})
            if(ischar(tab))
                tab_obj = findobj(tab,'Type','tab');
                if(isempty(tab_obj))
                    obj.addTab(tab)
                else
                    tab = tab_obj;
                end
            end
            figSize = obj.figureSize;
            plotList = findobj(tab,'tag','plotList','-and',...
                                'Type','uibuttongroup');
            numPlots = length(findobj(plotList,'tag','plot','-and',...
                                      'Style','togglebutton'));
%             obj.tabs.UserData.plotlist = cell([]);
            h = uicontrol('parent',plotList,...
                            'Style', 'togglebutton',...
                            'String', p.Results.title,'Units','pixels',...
                            'Position', [10 figSize(4)-85-30*numPlots 120 20],...
                            'tag','plot');
            h.UserData = fun_handle;
            plotList.SelectedObject = h;
            obj.selectPlot(plotList,[]);
        end
        function savePPT(obj,varargin)
        % savePPT Saves all the plots in tfigure to a powerpoint 
        %  presentation.  
        % 
            if(~(exist('exportToPPTX','file')))
               error('tfigure:NeedExportToPPTX',...
                     ['exportToPPTX must be added to the path. ',...
                     'It can be downloaded from the MATLAB file exchange']);
            end
            if(~isempty(obj.fig.Name))
                figTitle = obj.fig.Name;
            else
                figTitle = ['Figure ' num2str(obj.fig.Number) ' Data'];
            end
            p = inputParser;
            p.addOptional('fileName','',@ischar);
            p.addParameter('title',figTitle);
            p.addParameter('author','');
            p.addParameter('subject','');
            p.addParameter('comments','');
            p.parse(varargin{:});
            if(isempty(p.Results.fileName))
                [fileName,pathname] = uiputfile('.pptx','Export PPTX: select a file name');
                fileName = fullfile(pathname,fileName);
            else
                fileName = p.Results.fileName;
            end
            isOpen  = exportToPPTX();
            if ~isempty(isOpen),
                % If PowerPoint already started, then close first and then open a new one
                exportToPPTX('close');
            end
            exportToPPTX('new',... %'Dimensions',[12 6], ...
                         'Title',p.Results.title, ...
                         'Author',p.Results.author, ...
                         'Subject',p.Results.subject, ...
                         'Comments',p.Results.comments);
            exportToPPTX('addslide');
            exportToPPTX('addtext',p.Results.title,...
                         'HorizontalAlignment','center',...
                         'VerticalAlignment','middle','FontSize',48);
            numTabs = length(obj.tabs);
            summary = findobj(obj.tabs,'Title','Summary');
            if(~isempty(summary))
                startTab = 2;
            else
                startTab = 1;
            end
            for tabNum = startTab:numTabs
                ht = get(obj.tabs(tabNum));
                hp = findobj(ht.Children,'tag','plot');
                exportToPPTX('addslide');
                exportToPPTX('addtext',ht.Title,...
                             'HorizontalAlignment','center',...
                             'VerticalAlignment','middle','FontSize',48);
                for plotNum = 1:length(hp)
                    h = figure('Position',obj.fig.Position,...
                               'Color',[1 1 1],'Visible','off');
                    hp(plotNum).UserData();
                    exportToPPTX('addslide');
                    exportToPPTX('addpicture',h,'Scaled','maxfixed');
                    close(h);
                end
            end
            exportToPPTX('save',fileName);
            exportToPPTX('close');
        end
    end
    methods (Access = private)
        function figResize(obj,src,~) % callbackdata is unused 3rd arg.
        % figResize Resizes the gui elements in each tab whenever the 
        %  figure is resized. 
        
            figSize = obj.figureSize;
            % Resize each list of plots
            plotLists = findobj(src,'tag','plotList','-and',...
                                'Type','uibuttongroup');
            set(plotLists,'Units','pixels','Position',[10 10  150 figSize(4)-45])
            % Resize each axis
            axesList = findobj(src,'Type','axes');
            if(~isempty(axesList))
                l = legend;
                if(~isempty(l))
                    l.Units = 'pixels';
                    leg_pos = l.Position;
                    set(axesList,'Units','pixels','Position',[210 50  figSize(3)-240 figSize(4)-110] - [0 0 ceil(leg_pos(3)) 0],'ActivePositionProperty','OuterPosition');
                end
            end
            % Reposition plot buttons
            for i_tab = 1:length(obj.tabs)
                plots = findobj(obj.tabs(i_tab),'tag','plot','-and',...
                                'Style','togglebutton');
                for n = 1:length(plots)
                    set(plots(n),'Position',[10 figSize(4)-85-30*(n-1) 120 20]);
                end
            end
            
        end
        function selectPlot(obj,src,c) % ~ is obj and callbackdata          
            if(length(src.Children) > 1)
                visible_plot = findobj(src.Parent.Children(2:end),'Visible','on');
                for i = 1:length(visible_plot)
                    visible_plot(i).Visible = 'off';
                end
                % Hide 
                axesSize = [210 50 obj.figureSize(3)-240 obj.figureSize(4)-110];
                src.SelectedObject.UserData.fa.Position = axesSize;
                src.SelectedObject.UserData.fa.Visible = 'on';
                % Turn on plotted material 
                material = src.SelectedObject.UserData.fa.Children;
                if(~isempty(material))
                    for i = 1:length(material)
                        material(i).Visible = 'on';
                    end
                end
                    
                src.Visible = 'on';
%                 for i = 1:length(src.Children)
%                     src.Children(i).UserData.fa.Visible = 'off';
%                 end

            else
                axesSize = [50 50 obj.figureSize(3)-90 obj.figureSize(4)-110];
                src.SelectedObject.UserData.fa.Position = axesSize;
            end
%             if isa(src.SelectedObject.UserData, 'function_handle')
%                 axes(findobj(src.Parent,'Type','Axes'));
%                 src.SelectedObject.UserData(); % contains the plot function handle
%             elseif(isa(src.SelectedObject.UserData,'matlab.graphics.axis.Axes'))
%                 % Turn off current axes
%                 h_current = axes(findobj(src.Parent,'Type','Axes','-and',...
%                                          'Visible','on'));
%                 h_current.Visible = 'off';
%                 h_current.children.Visible = 'off';
%                 % Turn on new axes
% %                 h_new = 
%             end
        end
        function exportMenu(obj,menu,ActionData)
            if(strcmp(menu.Label,'Export PPT'))
                obj.savePPT();
            end
        end    
    end
end

