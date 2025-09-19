import 'package:flutter/material.dart';
import '../models/solution.dart';

class VerificationSection extends StatelessWidget {
  final Verification verification;

  const VerificationSection({super.key, required this.verification});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 螳夂ｾｩ蝓溘メ繧ｧ繝・け
            if (verification.domainCheck != null &&
                verification.domainCheck!.isNotEmpty) ...[
              _buildVerificationItem(
                icon: Icons.domain_verification,
                title: 'Domain check',
                content: verification.domainCheck!,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
            ],

            // Verification
            if (verification.verification != null &&
                verification.verification!.isNotEmpty) ...[
              _buildVerificationItem(
                icon: Icons.verified,
                title: 'Verification',
                content: verification.verification!,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
            ],

            // Common mistakes
            if (verification.commonMistakes != null &&
                verification.commonMistakes!.isNotEmpty) ...[
              _buildVerificationItem(
                icon: Icons.warning,
                title: 'Common pitfalls',
                content: verification.commonMistakes!,
                color: Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
