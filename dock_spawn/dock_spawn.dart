library dock_spawn;

import 'dart:html';
import 'dart:math';
import 'dart:json';
import '../../core_utils/lib/core_utils.dart';  // TODO: Place in pub

part 'dialog/dialog.dart';
part 'decorators/draggable_container.dart';
part 'decorators/resizable_container.dart';

part 'dock/dock_manager.dart';
part 'dock/dock_manager_context.dart';
part 'dock/dock_layout_engine.dart';
part 'dock/dock_model.dart';
part 'dock/dock_wheel.dart';
part 'dock/dock_exception.dart';

part 'containers/dock_container.dart';
part 'containers/splitter_dock_container.dart';
part 'containers/horizontal_dock_container.dart';
part 'containers/vertical_dock_container.dart';
part 'containers/fill_dock_container.dart';
part 'containers/panel_dock_container.dart';
part 'containers/document_dock_container.dart';

part 'splitter/splitter_bar.dart';
part 'splitter/splitter_panel.dart';
part 'splitter/splitter_exception.dart';
part 'tab/tab_handle.dart';
part 'tab/tab_page.dart';
part 'tab/tab_host.dart';

part 'serialization/dock_graph_serializer.dart';
part 'serialization/dock_graph_deserializer.dart';

part 'utils/dock_utils.dart';
part 'utils/image_repository.dart';
part 'utils/debug_utils.dart';
part 'utils/undock_initiator.dart';
