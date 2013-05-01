dockspawn.DockManagerContext = function(dockManager)
{
    this.dockManager = dockManager;
    this.model = new dockspawn.DockModel();
    this.documentManagerView = new dockspawn.DocumentManagerContainer(this.dockManager);
};
