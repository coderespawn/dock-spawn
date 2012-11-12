#library('dock_spawn');

#import('dart:html');
#import('dart:math');
#import('dart:json');


#source('dialog/dialog.dart');
#source('decorators/draggable_container.dart');
#source('decorators/resizable_container.dart');

#source('dock/dock_manager.dart');
#source('dock/dock_manager_context.dart');
#source('dock/dock_layout_engine.dart');
#source('dock/dock_model.dart');
#source('dock/dock_wheel.dart');
#source('dock/dock_exception.dart');

#source('containers/dock_container.dart');
#source('containers/splitter_dock_container.dart');
#source('containers/horizontal_dock_container.dart');
#source('containers/vertical_dock_container.dart');
#source('containers/fill_dock_container.dart');
#source('containers/panel_dock_container.dart');
#source('containers/document_dock_container.dart');

#source('splitter/splitter_bar.dart');
#source('splitter/splitter_panel.dart');
#source('splitter/splitter_exception.dart');
#source('tab/tab_handle.dart');
#source('tab/tab_page.dart');
#source('tab/tab_host.dart');

#source('serialization/dock_graph_serializer.dart');
#source('serialization/dock_graph_deserializer.dart');

#source('utils/dock_utils.dart');
#source('utils/image_repository.dart');
#source('utils/debug_utils.dart');
#source('utils/undock_initiator.dart');
#source('utils/math_utils.dart');
