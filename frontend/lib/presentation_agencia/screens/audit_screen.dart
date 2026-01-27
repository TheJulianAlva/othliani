import 'package:flutter/material.dart';
import '../widgets/audit/audit_toolbar.dart';
import '../widgets/audit/audit_log_table.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [AuditToolbar(), Expanded(child: AuditLogTable())],
    );
  }
}
