/// "Bu akşam boşum" and the small table (docs/ARCHITECTURE.md §3d, Bu akşam boşum ve küçük masa).
library;

/// Someone free tonight who shares a group with the viewer, or a person at a table.
class TonightPerson {
  const TonightPerson({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.note = '',
    this.groups = const [],
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String note;

  /// Names of the shared groups (at most three).
  final List<String> groups;
}

enum TableInviteState {
  pending,
  accepted,
  declined,
  left;

  static TableInviteState? parse(Object? value) => values.where((s) => s.name == value).firstOrNull;
}

/// A small table as the viewer sees it: the founder and who joined by name, the pending as a count.
class TonightTable {
  const TonightTable({
    required this.id,
    required this.closesAt,
    required this.founder,
    this.myState,
    this.joined = const [],
    this.pending = 0,
    this.conversationId,
  });

  final String id;
  final DateTime closesAt;
  final TonightPerson founder;
  final TableInviteState? myState;
  final List<TonightPerson> joined;
  final int pending;

  /// Set once three people joined.
  final String? conversationId;

  /// People needed before the chat opens.
  int get missing => conversationId == null ? (3 - joined.length).clamp(0, 3) : 0;
}

/// The viewer's evening.
class Tonight {
  const Tonight({this.note, this.until, this.candidates = 0, this.table, this.invites = const []});

  /// Null when the viewer has not said they are free.
  final String? note;
  final DateTime? until;

  /// Who a table could ask now; a table needs [minCandidates].
  final int candidates;
  final TonightTable? table;
  final List<TonightTable> invites;

  bool get isFree => until != null;

  /// A table asks at least two people besides its founder.
  static const minCandidates = 2;

  bool get canSetTable => isFree && table == null && candidates >= minCandidates;
}
