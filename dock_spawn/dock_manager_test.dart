
class DockManagerTest {
  DockManager dockManager;
  DockManagerTest() {
    _setup();
  }
  
  _setup() {
    dockManager = new DockManager(query("#my_dock_manager"));
    dockManager.initialize();
    window.on.resize.add(onResized);
    onResized(null);
  }
  
  _teardown() {
    
  }
  
  void onResized(Event event) {
    dockManager.resize(window.innerWidth, window.innerHeight);
//    dockManager.resize(400, 300);
  }

  void testDialog() {
    var dialog = new Dialog.fromElement("#output_window", dockManager);
    var dialog2 = new Dialog.fromElement("#output_window2", dockManager);
    var dialog3 = new Dialog.fromElement("#output_window3", dockManager);
    var dialog4 = new Dialog.fromElement("#output_window4", dockManager);

    dialog.setPosition(100, 100);
    dialog2.setPosition(150, 150);
    dialog3.setPosition(200, 200);
    dialog4.setPosition(250, 250);
  }
  
  void testManualLayout() {
    var panel1 = new PanelContainer(query("#output_window"), dockManager);
    var panel2 = new PanelContainer(query("#output_window2"), dockManager);
    var panel3 = new PanelContainer(query("#output_window3"), dockManager);
    var panel4 = new PanelContainer(query("#output_window4"), dockManager);
    
    DockNode documentNode = dockManager.context.model.documentManagerNode;
    DockNode panel1Node = dockManager.dockLeft(documentNode, panel1, 0.20);
    DockNode panel2Node = dockManager.dockDown(panel1Node, panel2, 0.5);
    DockNode panel3Node = dockManager.dockDown(documentNode, panel3, 0.20);
    DockNode panel4Node = dockManager.dockFill(documentNode, panel4);
    
    dockManager.rebuildLayout(dockManager.context.model.rootNode);
  }

  void testLoading() {
//    String data = '{"containerType":"vertical","state":{"width":973,"height":682},"children":[{"containerType":"panel","state":{"width":973,"element":"output_window4","height":250},"children":[]},{"containerType":"fill","state":{"width":973,"documentManager":true,"height":427},"children":[]}]}';
    String data = '{"containerType":"horizontal","state":{"width":1680,"height":959},"children":[{"containerType":"vertical","state":{"width":1290,"height":959},"children":[{"containerType":"panel","state":{"width":1290,"element":"output_window3","height":280},"children":[]},{"containerType":"horizontal","state":{"width":1290,"height":674},"children":[{"containerType":"panel","state":{"width":293,"element":"output_window4","height":674},"children":[]},{"containerType":"vertical","state":{"width":992,"height":674},"children":[{"containerType":"fill","state":{"width":992,"documentManager":true,"height":418},"children":[]},{"containerType":"panel","state":{"width":992,"element":"output_window2","height":251},"children":[]}]}]}]},{"containerType":"panel","state":{"width":385,"element":"output_window","height":959},"children":[]}]}';
    dockManager.loadState(data);
    
    
    debug_DumpTree(dockManager.context.model.rootNode);
  }

}
