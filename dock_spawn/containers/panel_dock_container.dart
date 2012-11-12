/**
 * This dock container wraps the specified element on a panel frame with a title bar and close button
 */
class PanelContainer implements IDockContainer {
  // User provided container element to be placed in the panel's content area
  Element elementContent; 
  String name;
  DockManager dockManager;
  UndockInitiator undockInitiator;

  DivElement elementPanel;
  DivElement elementTitle;
  DivElement elementTitleText;
  DivElement elementButtonClose;
  DivElement elementContentHost;
  String containerType = "panel";
  String title = "Panel";
  String iconName = "icon-circle-arrow-right";
  var closeButtonClickedHandler;
  
  // When the panel switches to floating mode, it is wrapped around a dialog and a reference is set
  Dialog _floatingDialog = null;
  Dialog get floatingDialog() { 
    return _floatingDialog;
  }
  void set floatingDialog(Dialog value) {
    _floatingDialog = value;
    bool canUndock = (_floatingDialog == null);
    undockInitiator.enabled = canUndock;
  }
  
  PanelContainer(this.elementContent, this.dockManager, [this.title = "Panel"]) {
    _initialize();
  }
  
  PanelContainer.loadFromState(var state, this.dockManager) {
    String elementName = state["element"];
    this.elementContent = query("#$elementName");
    _initialize();
    loadState(state);
  }

  void saveState(Map<String, Object> state) {
    state['element'] = elementContent.id;
    state['width'] = width;
    state['height'] = height;
  }
  
  void loadState(Map<String, Object> state) {
    width = state['width'];
    height = state['height'];
    resize(width, height);
  }
  
  
  void setActiveChild(IDockContainer child) { 
  }

  int get minimumAllowedChildNodes() { return 0; }
  
  Element get containerElement() {
    return elementPanel;
  }
  
  void _initialize() {
    name = getNextId("panel_");
    elementPanel = new DivElement();
    elementTitle = new DivElement();
    elementTitleText = new DivElement();
    elementContentHost = new DivElement();
    elementButtonClose = new DivElement();

    elementPanel.nodes.add(elementTitle);
    elementTitle.nodes.add(elementTitleText);
    elementTitle.nodes.add(elementButtonClose);
    elementButtonClose.innerHTML = '<i class="icon-remove"></i>';
    elementButtonClose.classes.add("panel-titlebar-button-close");
    elementPanel.nodes.add(elementContentHost);

    elementPanel.classes.add("panel-base");
    elementTitle.classes.add("panel-titlebar");
    elementTitle.classes.add("disable-selection");
    elementTitleText.classes.add("panel-titlebar-text");
    elementContentHost.classes.add("panel-content");
    
    // set the size of the dialog elements based on the panel's size
    int panelWidth = elementContent.clientWidth; 
    int panelHeight = elementContent.clientHeight; 
    int titleHeight = elementTitle.clientHeight; 
    _setPanelDimensions(panelWidth, panelHeight + titleHeight);
    
    
    // Add the panel to the body
    window.document.body.nodes.add(elementPanel);
    
    closeButtonClickedHandler = onCloseButtonClicked;
    elementButtonClose.on.click.add(closeButtonClickedHandler);
    
    elementContent.remove();
    elementContentHost.nodes.add(elementContent);
    
    // Extract the title from the content element's attribute
    String contentTitle = elementContent.attributes['caption'];
    String contentIcon = elementContent.attributes['icon'];
    if (contentTitle != null) title = contentTitle;
    if (contentIcon != null) iconName = contentIcon;
    _updateTitle();
    
    undockInitiator = new UndockInitiator(elementTitle, performUndockToDialog);
    floatingDialog = null;
  }

  void destroy() {
    elementPanel.remove();
    elementButtonClose.on.click.remove(closeButtonClickedHandler);
  }
  
  /**
   * Undocks the panel and and converts it to a dialog box
   */
  Dialog performUndockToDialog(MouseEvent e, Point2 dragOffset) {
    undockInitiator.enabled = false;
    return dockManager.requestUndockToDialog(this, e, dragOffset);
  }
  
  /**
   * Undocks the container and from the layout hierarchy
   * The container would be removed from the DOM
   */
  void performUndock() {
    undockInitiator.enabled = false;
    dockManager.requestUndock(this);
  }
  
  void prepareForDocking() {
    undockInitiator.enabled = true;
  }
  
  int get width() {
    return elementPanel.clientWidth;
  }
  

  int get height() {
    int containerHeight = elementContent.clientHeight;
    int titleHeight = elementTitle.clientHeight;
    return titleHeight + containerHeight;
  }
  
  
  void resize(int _width, int _height) {
    _setPanelDimensions(_width, _height);
  }
  
  void _setPanelDimensions(int _width, int _height) {
    elementTitle.style.width = "${_width}px";
    elementContentHost.style.width = "${_width}px";
    elementContent.style.width = "${_width}px";
    elementPanel.style.width = "${_width}px";
    
    int titleBarHeight = elementTitle.clientHeight;
    int contentHeight = _height - titleBarHeight;
    elementContentHost.style.height = "${contentHeight}px";
    elementContent.style.height = "${contentHeight}px";
    elementPanel.style.height = "${_height}px";
    
  }
  
  void setTitle(String _title) {
    title = _title;
    _updateTitle();
  }
  
  void setTitleIcon(String _iconName) {
    iconName = _iconName;
    _updateTitle();
  }
  
  void _updateTitle() {
    elementTitleText.innerHTML = '<i class="$iconName"></i> $title';
  }
  
  String getRawTitle() {
    return elementTitleText.innerHTML;
  }
  
  void performLayout(List<IDockContainer> children) {
    
  }
  
  void onCloseButtonClicked(MouseEvent evt) {
    if (floatingDialog != null) {
      floatingDialog.destroy();
    } else {
      performUndock();
      destroy();
    }
  }
}
