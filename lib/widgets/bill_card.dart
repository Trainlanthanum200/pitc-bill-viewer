import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/disco_bill_scraper_service.dart';

class BillCard extends StatelessWidget {
  final Map<String, dynamic> bill;
  final Disco disco;
  final VoidCallback? onOpenBill;

  const BillCard({
    super.key,
    required this.bill,
    required this.disco,
    this.onOpenBill,
  });

  String _val(String key) => (bill[key] ?? "-").toString();

  @override
  Widget build(BuildContext context) {
    final history = (bill["bill_history"] as List?) ?? [];
    final gradientColors = discoGradient(disco.themeColor);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Header (company theme color) ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.electric_bolt_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _val("name_address").split(",").first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              disco.shortName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Ref: ${_val('reference_no')}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _val("bill_month"),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ---- 3-tier payment section ----
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildPaymentTiers(),
          ),

          // ---- Reading highlight ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildReadingHighlight(),
          ),

          const SizedBox(height: 16),

          // ---- Details grid ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _DetailTile(
                            label: "Status",
                            value: _val("status").split(" ").first,
                            icon: Icons.check_circle_outline_rounded,
                            color: disco.themeColor)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _DetailTile(
                            label: "Meter No",
                            value: _val("meter_no"),
                            icon: Icons.confirmation_number_outlined,
                            color: Colors.orange.shade600)),
                  ],
                ),
                const Divider(height: 32),
                _InfoRow(label: "Consumer ID", value: _val("consumer_id")),
                _InfoRow(label: "Address", value: _val("name_address")),
                _InfoRow(label: "Tariff", value: _val("tariff")),
                _InfoRow(label: "Category", value: _val("category")),
                _InfoRow(
                    label: "Issue / Reading Date",
                    value: "${_val('issue_date')} / ${_val('reading_date')}"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---- Bill History ----
          if (history.isNotEmpty) _buildHistorySection(history),

          // ---- Action button: open official bill page ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOpenBill,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text(
                  "Open Your Bill",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: disco.themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTiers() {
    return Column(
      children: [
        _PaymentTierCard(
          title: "PAYABLE WITHIN DUE DATE",
          subtitle: "Due by ${_val('due_date')}",
          amount: _val("payable_within_due_date"),
          color: const Color(0xFF00B894),
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(height: 10),
        _PaymentTierCard(
          title: "PAYABLE ${_val('payable_till_date_label').toUpperCase()}",
          subtitle:
              "Includes Rs. ${_val('lp_surcharge_within_due')} surcharge",
          amount: _val("payable_till_date"),
          color: Colors.orange.shade600,
          icon: Icons.schedule_rounded,
        ),
        const SizedBox(height: 10),
        _PaymentTierCard(
          title: "PAYABLE ${_val('payable_after_date_label').toUpperCase()}",
          subtitle:
              "Includes Rs. ${_val('lp_surcharge_after_due')} surcharge",
          amount: _val("payable_after_due_date"),
          color: Colors.red.shade400,
          icon: Icons.warning_rounded,
        ),
      ],
    );
  }

  Widget _buildReadingHighlight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            disco.themeColor.withOpacity(0.08),
            disco.themeColor.withOpacity(0.03)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: disco.themeColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text("PREVIOUS",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_val("previous_reading"),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.arrow_forward_rounded, color: disco.themeColor),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: disco.themeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_val('units_consumed')} units",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                const Text("PRESENT",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_val("present_reading"),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List history) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: disco.themeColor),
              const SizedBox(width: 8),
              const Text(
                "BILL HISTORY",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                  flex: 3,
                  child: Text("MONTH",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45))),
              Expanded(
                  flex: 3,
                  child: Text("UNITS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45))),
              Expanded(
                  flex: 4,
                  child: Text("BILL (RS.)",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45))),
            ],
          ),
          const Divider(height: 16),
          ...history.map((h) {
            final month = h["month"]?.toString() ?? "-";
            final units = h["units"]?.toString() ?? "-";
            final billAmt = h["bill_amount"]?.toString() ?? "-";
            final status = h["status"]?.toString() ?? "";
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text(month,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        if (status.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: disco.themeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: disco.themeColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(units,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text("Rs. $billAmt",
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentTierCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final Color color;
  final IconData icon;

  const _PaymentTierCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          Text(
            "Rs. $amount",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

