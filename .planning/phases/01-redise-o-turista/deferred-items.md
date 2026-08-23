# Deferred Items — Phase 01 (Rediseño Turista)

Out-of-scope discoveries found during plan execution, logged per the executor's scope
boundary rule (do not auto-fix issues unrelated to the current task's changes).

## From Plan 01-02

- **Pre-existing failing tests in `guia/` (unrelated to this plan's files):**
  - `test/features/guia/home/presentation/blocs/sos_cubit_test.dart` — 3 failing tests
    (`SosCubit` initial state / `cancelSos` / `triggerWarning`)
  - `test/features/guia/shared/widgets/critical_medical_card_test.dart` — 1 failing test
    (`Muestra alerta médica si el turista es vulnerable y tiene notas`)
  - Confirmed unrelated: this plan only touched
    `frontend/lib/core/widgets/{saving_overlay,info_modal,phone_number_field}.dart` and
    `frontend/test/core/widgets/shared_widgets_theme_test.dart`. None of the failing
    tests import or exercise those files. `flutter test test/core/widgets/` (the plan's
    actual scope) passes 11/11.
  - Not fixed here — out of scope for a Turista-only visual redesign plan, and Guía's
    own redesign is Phase 2 per PROJECT.md.
