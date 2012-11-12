
class Dialog {
  DivElement elementDialog;
  PanelContainer panel;
  DraggableContainer draggable;
  ResizableContainer resizable;
  DialogEventListener eventListener;
  DockManager dockManager;
  static int zIndexCounter = 1000;
  var mouseDownHandler;
  
  Dialog.fromElement(String id, this.dockManager) {
    this.panel = new PanelContainer(query(id), dockManager);
    this.eventListener = dockManager;
    _initialize();  
  }
  
  Dialog(this.panel, this.dockManager) {
    _initialize();
    this.eventListener = dockManager;
  }
  
  void _initialize() {
    panel.floatingDialog = this;
    elementDialog = new DivElement();
    elementDialog.nodes.add(panel.elementPanel);
    draggable = new DraggableContainer(this, panel, elementDialog, panel.elementTitle);
    resizable = new ResizableContainer(this, draggable, draggable.topLevelElement);

    window.document.body.nodes.add(elementDialog);
    elementDialog.classes.add("dialog-floating");
    elementDialog.classes.add("rounded-corner-top");
    panel.elementTitle.classes.add("rounded-corner-top");
    
    mouseDownHandler = onMouseDown;
    elementDialog.on.mouseDown.add(mouseDownHandler);
    
    
    resize(panel.elementPanel.clientWidth, panel.elementPanel.clientHeight);
    bringToFront();
  }
  
  void setPosition(num x, num y) {
    elementDialog.style.left = "${x}px";
    elementDialog.style.top = "${y}px";
  }

  void onMouseDown(MouseEvent e) {
    bringToFront();
  }
  
  void destroy() {
    elementDialog.classes.remove("rounded-corner-top");
    panel.elementTitle.classes.remove("rounded-corner-top");
    elementDialog.remove();
    draggable.removeDecorator();
    panel.elementPanel.remove();
    panel.floatingDialog = null;
  }
  
  void resize(int width, int height) {
    resizable.resize(width, height);
  }
  
  void setTitle(String title) {
    panel.setTitle(title);
  }
  
  void setTitleIcon(String iconName) {
    panel.setTitleIcon(iconName);
  }
  
  void bringToFront() {
    zIndexCounter++;
    elementDialog.style.zIndex = "$zIndexCounter";
  }
}


interface DialogEventListener {
  void onDialogDragStarted(Dialog sender, MouseEvent e);
  void onDialogDragEnded(Dialog sender, MouseEvent e);
}
