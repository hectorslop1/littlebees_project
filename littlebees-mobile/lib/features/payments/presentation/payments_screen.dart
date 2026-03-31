import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/widgets/compact_layout.dart';
import '../../../../design_system/widgets/lb_card.dart';
import '../../../../shared/enums/enums.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../auth/application/auth_provider.dart';
import '../application/payments_providers.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  PaymentFilter _selectedFilter = PaymentFilter.all;
  String? _processingPaymentId;

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final authState = ref.watch(authProvider);
    final canPayFromThisRole = authState.isParent;

    return Scaffold(
      backgroundColor: context.appColor(AppColors.background),
      appBar: AppBar(
        title: const Text('Pagos'),
        backgroundColor: context.appColor(AppColors.surface),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: context.appColor(AppColors.textPrimary),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(paymentsProvider.future),
          child: paymentsAsync.when(
            data: (payments) =>
                _buildContent(context, payments, canPayFromThisRole),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorState(context, ref, error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Payment> payments,
    bool canPayFromThisRole,
  ) {
    final summary = _PaymentsSummary.fromPayments(payments);
    final filteredPayments = _applyFilter(payments);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      children: [
        _buildBalanceCard(context, summary)
            .animate()
            .fadeIn(duration: 320.ms)
            .slideY(begin: 0.06, duration: 320.ms),
        const SizedBox(height: 12),
        _buildStatusGrid(summary)
            .animate()
            .fadeIn(delay: 80.ms, duration: 320.ms)
            .slideY(begin: 0.06, duration: 320.ms),
        const SizedBox(height: 12),
        _buildNoticeCard(canPayFromThisRole)
            .animate()
            .fadeIn(delay: 140.ms, duration: 320.ms)
            .slideY(begin: 0.06, duration: 320.ms),
        const SizedBox(height: 14),
        Text(
          'Movimientos',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(delay: 180.ms),
        const SizedBox(height: 10),
        _buildFilterChips()
            .animate()
            .fadeIn(delay: 220.ms, duration: 320.ms)
            .slideX(begin: 0.04, duration: 320.ms),
        const SizedBox(height: 10),
        if (filteredPayments.isEmpty)
          _buildEmptyState()
        else
          ...filteredPayments.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPaymentCard(context, entry.value, canPayFromThisRole)
                  .animate()
                  .fadeIn(delay: (260 + (entry.key * 40)).ms, duration: 260.ms)
                  .slideY(begin: 0.05, duration: 260.ms),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, _PaymentsSummary summary) {
    final dueLabel = summary.nextDueLabel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB8892D), Color(0xFFD9B161), Color(0xFF8FAE8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x221F2C1F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.wallet, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Estado de cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (dueLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(24),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    dueLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(summary.pendingBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.pendingBalance > 0
                ? 'Saldo pendiente total'
                : 'No tienes saldo pendiente',
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Cargos pendientes',
                  '${summary.pendingCount}',
                ),
                _buildSummaryRow('Pagos registrados', '${summary.paidCount}'),
                if (summary.overdueCount > 0)
                  _buildSummaryRow(
                    'Pendientes vencidos',
                    '${summary.overdueCount}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Consulta tu historial y revisa los cargos activos de cada hijo en tiempo real desde la nube.',
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 50.ms, begin: const Offset(0.95, 0.95)).fadeIn();
  }

  Widget _buildSummaryRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusGrid(_PaymentsSummary summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CompactMetricTile(
                label: 'Pendientes',
                value: _formatCurrency(summary.pendingBalance),
                accent: AppColors.warning,
                icon: LucideIcons.clock3,
                tint: AppColors.warning.withAlpha(18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CompactMetricTile(
                label: 'Pagado',
                value: _formatCurrency(summary.paidTotal),
                accent: AppColors.success,
                icon: LucideIcons.badgeCheck,
                tint: AppColors.success.withAlpha(18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CompactMetricTile(
                label: 'Vencidos',
                value: '${summary.overdueCount}',
                accent: AppColors.error,
                icon: LucideIcons.alertTriangle,
                tint: AppColors.error.withAlpha(18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CompactMetricTile(
                label: 'Hijos con cargos',
                value: '${summary.childrenWithPayments}',
                accent: AppColors.info,
                icon: LucideIcons.baby,
                tint: AppColors.info.withAlpha(18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoticeCard(bool canPayFromThisRole) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surface),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColor(AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.shieldCheck,
            color: context.appColor(AppColors.secondary),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              canPayFromThisRole
                  ? 'Los cargos y pagos mostrados aquí provienen del backend real. Puedes liquidar tus cargos pendientes y revisar el historial de tus hijos.'
                  : 'Los cargos y pagos mostrados aquí provienen del backend real. Desde este rol solo puedes consultar el estado financiero; el pago corresponde a las familias.',
              style: TextStyle(
                height: 1.35,
                fontSize: 12,
                color: context.appColor(AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PaymentFilter.values.map((filter) {
          final selected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              labelStyle: TextStyle(
                color: selected
                    ? context.appColor(AppColors.textOnPrimary)
                    : context.appColor(AppColors.textPrimary),
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: context.appColor(AppColors.surface),
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: selected
                    ? context.appColor(AppColors.primary)
                    : context.appColor(AppColors.divider),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    Payment payment,
    bool canPayFromThisRole,
  ) {
    final visualStatus = _visualStatus(payment);
    final dueDateLabel = _dateFormat.format(payment.dueDate.toLocal());
    final paidDateLabel = payment.paidAt == null
        ? null
        : _dateFormat.format(payment.paidAt!.toLocal());

    return LBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: visualStatus.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  visualStatus.icon,
                  color: visualStatus.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.concept,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.childName ?? 'Alumno',
                      style: TextStyle(
                        color: context.appColor(AppColors.textSecondary),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(payment.amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(visualStatus),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildMetaPill(
                icon: LucideIcons.calendarDays,
                label: 'Vence $dueDateLabel',
              ),
              if (paidDateLabel != null)
                _buildMetaPill(
                  icon: LucideIcons.badgeCheck,
                  label: 'Pagado $paidDateLabel',
                ),
              if (payment.paymentMethod != null &&
                  payment.paymentMethod!.isNotEmpty)
                _buildMetaPill(
                  icon: LucideIcons.landmark,
                  label: _paymentMethodLabel(payment.paymentMethod!),
                ),
            ],
          ),
          if (canPayFromThisRole &&
              (payment.status == PaymentStatus.pending ||
                  _isOverdue(payment))) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _processingPaymentId == payment.id
                    ? null
                    : () => _openDummyCardSheet(payment),
                icon: _processingPaymentId == payment.id
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.creditCard, size: 18),
                label: Text(
                  _processingPaymentId == payment.id
                      ? 'Procesando...'
                      : 'Pagar con tarjeta demo',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: context.appColor(AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.appColor(AppColors.textSecondary),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(_VisualPaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: status.tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LBCard(
      child: Column(
        children: [
          Icon(
            LucideIcons.receipt,
            size: 36,
            color: context.appColor(AppColors.textTertiary),
          ),
          SizedBox(height: 12),
          Text(
            'No hay movimientos para este filtro',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Prueba con otro estado para revisar tu historial.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appColor(AppColors.textSecondary),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        LBCard(
          child: Column(
            children: [
              const Icon(LucideIcons.receipt, size: 44, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'No fue posible cargar los pagos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => ref.refresh(paymentsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Payment> _applyFilter(List<Payment> payments) {
    final sorted = [...payments]
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    switch (_selectedFilter) {
      case PaymentFilter.all:
        return sorted;
      case PaymentFilter.pending:
        return sorted
            .where((payment) => payment.status == PaymentStatus.pending)
            .toList();
      case PaymentFilter.overdue:
        return sorted.where((payment) => _isOverdue(payment)).toList();
      case PaymentFilter.paid:
        return sorted
            .where((payment) => payment.status == PaymentStatus.paid)
            .toList();
      case PaymentFilter.cancelled:
        return sorted
            .where((payment) => payment.status == PaymentStatus.cancelled)
            .toList();
    }
  }

  bool _isOverdue(Payment payment) {
    return payment.status == PaymentStatus.overdue ||
        (payment.status == PaymentStatus.pending &&
            payment.dueDate.isBefore(
              DateTime.now().copyWith(
                hour: 0,
                minute: 0,
                second: 0,
                millisecond: 0,
                microsecond: 0,
              ),
            ));
  }

  _VisualPaymentStatus _visualStatus(Payment payment) {
    if (_isOverdue(payment)) {
      return const _VisualPaymentStatus(
        label: 'Vencido',
        color: AppColors.error,
        tint: Color(0x1FD4655E),
        icon: LucideIcons.alertTriangle,
      );
    }

    switch (payment.status) {
      case PaymentStatus.pending:
        return const _VisualPaymentStatus(
          label: 'Pendiente',
          color: AppColors.warning,
          tint: Color(0x1FE8B84B),
          icon: LucideIcons.clock3,
        );
      case PaymentStatus.paid:
        return const _VisualPaymentStatus(
          label: 'Pagado',
          color: AppColors.success,
          tint: Color(0x1F6BA368),
          icon: LucideIcons.badgeCheck,
        );
      case PaymentStatus.overdue:
        return const _VisualPaymentStatus(
          label: 'Vencido',
          color: AppColors.error,
          tint: Color(0x1FD4655E),
          icon: LucideIcons.alertTriangle,
        );
      case PaymentStatus.cancelled:
        return const _VisualPaymentStatus(
          label: 'Cancelado',
          color: AppColors.textSecondary,
          tint: Color(0x14888888),
          icon: LucideIcons.circleSlash2,
        );
    }
  }

  String _formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  String _paymentMethodLabel(String value) {
    switch (value.toLowerCase()) {
      case 'spei':
        return 'Pago por SPEI';
      case 'card':
        return 'Tarjeta';
      case 'cash':
        return 'Efectivo';
      default:
        return value.toUpperCase();
    }
  }

  Future<void> _openDummyCardSheet(Payment payment) async {
    final cardholderController = TextEditingController(text: 'Carlos Ramirez');
    final cardNumberController = TextEditingController(
      text: '4242 4242 4242 4242',
    );
    final expiryMonthController = TextEditingController(text: '12');
    final expiryYearController = TextEditingController(text: '29');
    final cvvController = TextEditingController(text: '123');
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: 14,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final isProcessing = _processingPaymentId == payment.id;

              Future<void> submit() async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final navigator = Navigator.of(sheetContext);
                final messenger = ScaffoldMessenger.of(context);

                setState(() {
                  _processingPaymentId = payment.id;
                });
                setModalState(() {});

                try {
                  await ref
                      .read(paymentsRepositoryProvider)
                      .simulatePayment(
                        paymentId: payment.id,
                        cardholderName: cardholderController.text.trim(),
                        cardNumber: cardNumberController.text.trim(),
                        expiryMonth: expiryMonthController.text.trim(),
                        expiryYear: expiryYearController.text.trim(),
                        cvv: cvvController.text.trim(),
                      );

                  if (mounted) {
                    navigator.pop();
                    ref.invalidate(paymentsProvider);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pago registrado para ${payment.childName ?? 'el alumno'}',
                        ),
                      ),
                    );
                  }
                } catch (error) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'No fue posible procesar el pago: $error',
                        ),
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _processingPaymentId = null;
                    });
                    setModalState(() {});
                  }
                }
              }

              return Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.appColor(AppColors.surface),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(context.isDark ? 32 : 34),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 56,
                            height: 5,
                            decoration: BoxDecoration(
                              color: context.appColor(AppColors.divider),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tarjeta demo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Este pago se registrara en la base de datos real de IONOS y marcara el cargo como pagado.',
                          style: TextStyle(
                            color: context.appColor(AppColors.textSecondary),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildDemoCardPreview(payment),
                        const SizedBox(height: 18),
                        _buildTextField(
                          controller: cardholderController,
                          label: 'Titular',
                          hint: 'Carlos Ramirez',
                          validator: (value) =>
                              (value == null || value.trim().length < 3)
                              ? 'Ingresa el nombre del titular'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: cardNumberController,
                          label: 'Numero de tarjeta',
                          hint: '4242 4242 4242 4242',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final digits = (value ?? '').replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            if (digits.length < 12) {
                              return 'Ingresa una tarjeta dummy valida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: expiryMonthController,
                                label: 'Mes',
                                hint: '12',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final month = int.tryParse(value ?? '');
                                  if (month == null ||
                                      month < 1 ||
                                      month > 12) {
                                    return 'Mes invalido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: expiryYearController,
                                label: 'Ano',
                                hint: '29',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final year = int.tryParse(value ?? '');
                                  if (year == null || year < 24) {
                                    return 'Ano invalido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: cvvController,
                                label: 'CVV',
                                hint: '123',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final digits = (value ?? '').replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );
                                  if (digits.length < 3) {
                                    return 'CVV invalido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isProcessing ? null : submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isProcessing
                                  ? 'Procesando...'
                                  : 'Pagar ${_formatCurrency(payment.amount)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    cardholderController.dispose();
    cardNumberController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    cvvController.dispose();
  }

  Widget _buildDemoCardPreview(Payment payment) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D2A38), Color(0xFF31465C), Color(0xFF496F87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.creditCard, color: Colors.white),
              const Spacer(),
              Text(
                _formatCurrency(payment.amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            '4242 4242 4242 4242',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            payment.concept,
            style: const TextStyle(
              color: Color(0xFFDDE7F0),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: context.appColor(AppColors.surfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.appColor(AppColors.divider)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

enum PaymentFilter {
  all('Todos'),
  pending('Pendientes'),
  overdue('Vencidos'),
  paid('Pagados'),
  cancelled('Cancelados');

  const PaymentFilter(this.label);
  final String label;
}

class _PaymentsSummary {
  const _PaymentsSummary({
    required this.pendingBalance,
    required this.pendingCount,
    required this.overdueCount,
    required this.overdueAmount,
    required this.paidCount,
    required this.paidTotal,
    required this.childrenWithPayments,
    required this.nextPendingDueDate,
  });

  final double pendingBalance;
  final int pendingCount;
  final int overdueCount;
  final double overdueAmount;
  final int paidCount;
  final double paidTotal;
  final int childrenWithPayments;
  final DateTime? nextPendingDueDate;

  String? get nextDueLabel {
    if (nextPendingDueDate == null) return null;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final diff = nextPendingDueDate!.difference(startOfToday).inDays;

    if (diff < 0) return 'Hay cargos vencidos';
    if (diff == 0) return 'Vence hoy';
    if (diff == 1) return 'Vence mañana';
    return 'Vence en $diff días';
  }

  factory _PaymentsSummary.fromPayments(List<Payment> payments) {
    final pendingPayments = payments.where(
      (payment) => payment.status == PaymentStatus.pending,
    );
    final paidPayments = payments.where(
      (payment) => payment.status == PaymentStatus.paid,
    );
    final overduePayments = payments.where((payment) {
      return payment.status == PaymentStatus.overdue ||
          (payment.status == PaymentStatus.pending &&
              payment.dueDate.isBefore(
                DateTime.now().copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                ),
              ));
    });

    DateTime? nextPendingDueDate;
    for (final payment in pendingPayments) {
      if (nextPendingDueDate == null ||
          payment.dueDate.isBefore(nextPendingDueDate)) {
        nextPendingDueDate = payment.dueDate;
      }
    }

    return _PaymentsSummary(
      pendingBalance: pendingPayments.fold(
        0.0,
        (sum, payment) => sum + payment.amount,
      ),
      pendingCount: pendingPayments.length,
      overdueCount: overduePayments.length,
      overdueAmount: overduePayments.fold(
        0.0,
        (sum, payment) => sum + payment.amount,
      ),
      paidCount: paidPayments.length,
      paidTotal: paidPayments.fold(0.0, (sum, payment) => sum + payment.amount),
      childrenWithPayments: payments
          .map((payment) => payment.childId)
          .toSet()
          .length,
      nextPendingDueDate: nextPendingDueDate,
    );
  }
}

class _VisualPaymentStatus {
  const _VisualPaymentStatus({
    required this.label,
    required this.color,
    required this.tint,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color tint;
  final IconData icon;
}

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: 'es_MX',
  symbol: '\$',
  decimalDigits: 0,
);

final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'es_MX');
