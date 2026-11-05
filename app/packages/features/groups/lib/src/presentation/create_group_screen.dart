import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Name, address, category, join policy and a short introduction. Images,
/// rules and links are added on the edit screen afterwards.
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key, this.nextRoute});

  /// Where the owner goes once the group exists (the plan step in the app); the group page if null.
  final String Function(String handle)? nextRoute;

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _form = GlobalKey<FormState>();
  final _handleField = GlobalKey<HandleFieldState>();
  final _name = TextEditingController();
  final _handle = TextEditingController();
  final _about = TextEditingController();
  String? _category;
  int? _province;
  JoinPolicy _policy = JoinPolicy.open;
  bool? _handleAvailable;
  bool _handleEdited = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    _about.dispose();
    super.dispose();
  }

  void _onNameChanged(String name) {
    if (_handleEdited) return;
    _handle.text = GroupRules.suggestHandle(name);
    _handleField.currentState?.recheck();
  }

  Future<void> _create() async {
    if (!_form.currentState!.validate() || _handleAvailable != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(groupsRepositoryProvider).create(GroupDraft(
          handle: GroupRules.normalizeHandle(_handle.text),
          name: _name.text.trim(),
          categorySlug: _category!,
          joinPolicy: _policy,
          about: _about.text.trim(),
          province: _province,
        ));
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        ref
          ..invalidate(userGroupsProvider)
          ..invalidate(discoverGroupsProvider);
        context.pushReplacement(widget.nextRoute?.call(value) ?? GroupRoutes.group(value));
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(groupsL10n.createGroup)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: GwSpacing.lg, horizontal: GwSpacing.page),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GwPanel(
                    title: groupsL10n.groupInfo,
                    subtitle: groupsL10n.groupInfoHint,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _name,
                          maxLength: GroupRules.nameMaxLength,
                          textCapitalization: TextCapitalization.words,
                          onChanged: _onNameChanged,
                          validator: GroupRules.validateName,
                          decoration: InputDecoration(labelText: groupsL10n.groupName, counterText: ''),
                        ),
                        const SizedBox(height: GwSpacing.md),
                        HandleField(
                          key: _handleField,
                          controller: _handle,
                          onEdited: () => _handleEdited = true,
                          onAvailabilityChanged: (v) => setState(() => _handleAvailable = v),
                        ),
                        const SizedBox(height: GwSpacing.md),
                        CategoryField(value: _category, onChanged: (v) => setState(() => _category = v)),
                        const SizedBox(height: GwSpacing.md),
                        ProvinceField(value: _province, onChanged: (v) => setState(() => _province = v)),
                        const SizedBox(height: GwSpacing.md),
                        TextFormField(
                          controller: _about,
                          maxLength: GroupRules.aboutMaxLength,
                          minLines: 3,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: groupsL10n.about,
                            hintText: groupsL10n.aboutHint,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  GwPanel(
                    title: groupsL10n.joining,
                    subtitle: groupsL10n.changeLater,
                    child: JoinPolicyPicker(value: _policy, onChanged: (p) => setState(() => _policy = p)),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GwButton(label: groupsL10n.createTheGroup, onPressed: _create, isLoading: _saving),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
