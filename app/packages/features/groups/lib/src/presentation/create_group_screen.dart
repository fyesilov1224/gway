import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Name, address, category, join policy and a short introduction. Images,
/// rules and links are added on the edit screen afterwards.
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

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
        ));
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        ref
          ..invalidate(userGroupsProvider)
          ..invalidate(discoverGroupsProvider);
        context.pushReplacement(GroupRoutes.group(value));
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
      backgroundColor: GxColors.surface,
      appBar: AppBar(title: const Text('Grup oluştur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: GxSpacing.lg, horizontal: GxSpacing.page),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GxLayout.contentMaxWidth),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GxPanel(
                    title: 'Grup bilgileri',
                    subtitle: 'Logo, kapak, kurallar ve bağlantıları grubu oluşturduktan sonra ekleyebilirsin.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _name,
                          maxLength: GroupRules.nameMaxLength,
                          textCapitalization: TextCapitalization.words,
                          onChanged: _onNameChanged,
                          validator: GroupRules.validateName,
                          decoration: const InputDecoration(labelText: 'Grup adı', counterText: ''),
                        ),
                        const SizedBox(height: GxSpacing.md),
                        HandleField(
                          key: _handleField,
                          controller: _handle,
                          onEdited: () => _handleEdited = true,
                          onAvailabilityChanged: (v) => setState(() => _handleAvailable = v),
                        ),
                        const SizedBox(height: GxSpacing.md),
                        CategoryField(value: _category, onChanged: (v) => setState(() => _category = v)),
                        const SizedBox(height: GxSpacing.md),
                        TextFormField(
                          controller: _about,
                          maxLength: GroupRules.aboutMaxLength,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Tanıtım',
                            hintText: 'Grubunuz ne yapar, kimler katılabilir?',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GxSpacing.lg),
                  GxPanel(
                    title: 'Katılım',
                    subtitle: 'Bunu daha sonra değiştirebilirsin.',
                    child: JoinPolicyPicker(value: _policy, onChanged: (p) => setState(() => _policy = p)),
                  ),
                  const SizedBox(height: GxSpacing.lg),
                  if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.md)],
                  Align(
                    alignment: Alignment.centerRight,
                    child: GxButton(label: 'Grubu oluştur', onPressed: _create, isLoading: _saving),
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
