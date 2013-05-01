import "TabHandle";

dockspawn.TabPage = function(host, container)
{
    if (arguments.length == 0)
        return;

    this.selected = false;
    this.host = host;
    this.container = container;

    this.handle = new dockspawn.TabHandle(this);
    this.containerElement = container.containerElement;

    if (container instanceof dockspawn.PanelContainer)
    {
        var panel = container;
        panel.onTitleChanged = this.onTitleChanged.bind(this);
    }
};

dockspawn.TabPage.prototype.onTitleChanged = function(sender, title)
{
    this.handle.updateTitle();
};

dockspawn.TabPage.prototype.destroy = function()
{
    this.handle.destroy();

    if (this.container instanceof dockspawn.PanelContainer)
    {
        var panel = this.container;
        delete panel.onTitleChanged;
    }
};

dockspawn.TabPage.prototype.onSelected = function()
{
    this.host.onTabPageSelected(this);
};

dockspawn.TabPage.prototype.setSelected = function(flag)
{
    this.selected = flag;
    this.handle.setSelected(flag);

    if (this.selected)
    {
        this.host.contentElement.appendChild(this.containerElement);
        // force a resize again
        var width = this.host.contentElement.clientWidth;
        var height = this.host.contentElement.clientHeight;
        this.container.resize(width, height);
    }
    else
        removeNode(this.containerElement);
};

dockspawn.TabPage.prototype.resize = function(width, height)
{
    this.container.resize(width, height);
};
