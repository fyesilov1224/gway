import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/legal.dart';
import '../l10n.dart';
import 'providers.dart';

/// Full text of a legal document in a scrollable bottom sheet. [onReadToEnd] runs once the reader reaches the
/// end of the text (at once when it fits without scrolling): consent needs it (docs/ARCHITECTURE.md §3a, KVKK).
/// With [acceptLabel] a button after the last line closes the sheet with `true`: reaching it means the text was
/// scrolled through, so it also counts as read.
Future<bool?> showLegalDocument(
  BuildContext context,
  LegalDocument document, {
  VoidCallback? onReadToEnd,
  String? acceptLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(GwRadius.xl)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, controller) => _DocumentBody(
        document: document,
        controller: controller,
        onReadToEnd: onReadToEnd,
        acceptLabel: acceptLabel,
      ),
    ),
  );
}

class _DocumentBody extends StatefulWidget {
  const _DocumentBody({required this.document, required this.controller, this.onReadToEnd, this.acceptLabel});

  final LegalDocument document;
  final ScrollController controller;
  final VoidCallback? onReadToEnd;
  final String? acceptLabel;

  @override
  State<_DocumentBody> createState() => _DocumentBodyState();
}

class _DocumentBodyState extends State<_DocumentBody> {
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    if (widget.onReadToEnd == null) return;
    widget.controller.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_reported || !mounted || !widget.controller.hasClients) return;
    final position = widget.controller.position;
    if (position.extentAfter <= GwSpacing.md) _report();
  }

  void _report() {
    if (_reported) return;
    _reported = true;
    widget.onReadToEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.xl),
      children: [
        LegalText(document: widget.document),
        if (widget.acceptLabel case final label?) ...[
          const SizedBox(height: GwSpacing.lg),
          GwButton(
            label: label,
            expand: true,
            onPressed: () {
              _report();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ],
    );
  }
}

/// The latest version of every legal document, readable at any time (KVKK).
class LegalDocumentsScreen extends ConsumerWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(latestLegalDocumentsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(identityL10n.legalDocuments)),
      body: switch (docs) {
        AsyncData(:final value) => ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xs),
            itemCount: value.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) => ListTile(
              minTileHeight: GwSpacing.xxl + GwSpacing.xs,
              title: Text(value[i].displayTitle),
              subtitle: Text(identityL10n.versionLabel(value[i].version)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLegalDocument(context, value[i]),
            ),
          ),
        AsyncError(:final error) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(latestLegalDocumentsProvider),
          ),
        _ => ListView(
            padding: const EdgeInsets.all(GwSpacing.md),
            children: const [
              GwSkeleton(height: GwSpacing.xl),
              SizedBox(height: GwSpacing.md),
              GwSkeleton(height: GwSpacing.xl),
              SizedBox(height: GwSpacing.md),
              GwSkeleton(height: GwSpacing.xl),
            ],
          ),
      },
    );
  }
}

/// A document's title, version and text. A translation in the app language is shown first, with a note that the
/// Turkish text is binding and a switch to the Turkish original (docs/ARCHITECTURE.md §11).
class LegalText extends StatefulWidget {
  const LegalText({super.key, required this.document, this.titleStyle});

  final LegalDocument document;
  final TextStyle? titleStyle;

  @override
  State<LegalText> createState() => _LegalTextState();
}

class _LegalTextState extends State<LegalText> {
  bool _original = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final document = widget.document;
    final translation = _original ? null : document.translation;
    // The Turkish original reads left to right even in an Arabic app.
    final direction = translation == null && currentAppLanguage.isRtl ? TextDirection.ltr : null;
    final title = translation?.title ?? document.title;
    final titleText = Text(title, textDirection: direction, style: widget.titleStyle ?? textTheme.titleLarge);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A one-word title (German compounds) shrinks to the line instead of breaking mid-word at large text sizes.
        if (title.contains(' '))
          titleText
        else
          FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: titleText),
        const SizedBox(height: GwSpacing.xxs),
        Text(identityL10n.versionLabel(document.version), style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
        if (document.translation != null) ...[
          const SizedBox(height: GwSpacing.sm),
          GwFormMessage(identityL10n.legalTranslationNote, kind: GwFormMessageKind.info),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GwButton(
              label: _original ? identityL10n.legalShowTranslation : identityL10n.legalShowOriginal,
              variant: GwButtonVariant.text,
              onPressed: () => setState(() => _original = !_original),
            ),
          ),
        ],
        const SizedBox(height: GwSpacing.md),
        SelectableText(translation?.body ?? document.body, textDirection: direction, style: textTheme.bodyLarge),
      ],
    );
  }
}
