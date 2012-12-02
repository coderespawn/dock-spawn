part of dock_spawn;

class DockManagerContext {
  DockModel model;
  DockManager dockManager;
  DocumentManagerContainer documentManagerView;

  DockManagerContext(this.dockManager) {
    model = new DockModel();
    documentManagerView = new DocumentManagerContainer(dockManager);
  }
}