import 'package:trirecall/core/models/date_card_model.dart';
import 'package:trirecall/core/models/topic_model.dart';

// This is an abstract "base" class. You can't create a `DueItem` directly.
abstract class DueItem {}

// This class represents a DateCard that is due. It "wraps" a DateCard object.
class DueDateCardItem extends DueItem {
  final DateCard dateCard;
  DueDateCardItem(this.dateCard);
}

// This class represents a single Topic that is due. It "wraps" a Topic object.
class DueTopicItem extends DueItem {
  final Topic topic;
  DueTopicItem(this.topic);
}