import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});
  // Helper method to launch URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildAcceptanceCard(),
              const SizedBox(height: 16),
              _buildEducationalCard(),
              const SizedBox(height: 16),
              _buildMedicalDisclaimerCard(),
              const SizedBox(height: 16),
              _buildLicenceCard(),
              const SizedBox(height: 16),
              _buildUserResponsibilitiesCard(),
              const SizedBox(height: 16),
              _buildLiabilityCard(),
              const SizedBox(height: 16),
              _buildLegalCard(),
              const SizedBox(height: 16),
              _buildContactCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.indigo.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: Colors.indigo.shade700,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please read these terms carefully before using our app.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.handshake_outlined,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Acceptance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'By downloading or using the COPD proof-of-concept app ("the App") you agree to these Terms and Conditions ("Terms"). If you do not agree, do not use the App.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.green.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Educational Use Only',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This app is for educational and self-awareness purposes only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The App is provided for educational and self-awareness purposes. It is not a medical device and does not supply personalised medical advice, diagnosis, treatment plans or prescriptions.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalDisclaimerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.orange.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Medical Disclaimer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(
              'Educational content is taken from the 2025 GOLD Report and NICE guideline NG115 on COPD',
            ),

            Text(
              "References:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            _buildClickableLink(
              'Global Initiative for Chronic Obstructive Lung Disease (2024). Global Strategy for Prevention, Diagnosis and Management of COPD: 2025 Report. Available at: ',
              'https://goldcopd.org/2025-gold-report/',
              urlText: ' (Accessed: 20 June 2025).',
            ),
            _buildClickableLink(
              'NICE (2018). Chronic obstructive pulmonary disease in over 16s: diagnosis and management (NICE guideline NG115). National Institute for Health and Care Excellence. Available at: ',
              'https://www.nice.org.uk/guidance/ng115',
              urlText: '(Accessed: 20 June 2025).',
            ),

            _buildBulletPoint(
              'Daily assessments and symptom check-ins are wellness tools intended to encourage reflection and discussion with a healthcare professional',
            ),
            _buildBulletPoint(
              'The App issues no medication advice, rescue-pack instructions, clinical triage or emergency guidance',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.emergency, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'If you feel unwell, notice worsening symptoms or believe you may be experiencing an emergency, contact your GP, or dial 999 immediately.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_membership_outlined,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Licence',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Laennec AI Ltd grants you a non-exclusive, revocable licence to use the App for personal, non-commercial purposes. All intellectual property rights remain with Laennec AI Ltd.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserResponsibilitiesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'User Responsibilities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'You agree not to:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Reverse-engineer, modify or distribute the App'),
            _buildBulletPoint('Upload unlawful content'),
            _buildBulletPoint(
              'Use the App in any manner that could damage, disable or overburden our infrastructure',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiabilityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security_outlined,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Limitation of Liability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'To the fullest extent permitted by law, Laennec AI Ltd shall not be liable for any loss or damage arising from use of, or inability to use, the App or from reliance on any content contained in it.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You agree to indemnify and hold Laennec AI Ltd harmless from any claim or demand arising out of your misuse of the App or breach of these Terms.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gavel_outlined,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Legal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Modifications',
              'We may update the App and these Terms at any time. Continued use after an update constitutes acceptance of the revised Terms.',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Termination',
              'We may terminate or suspend access to the App without notice if you breach these Terms. Sections 2, 3, 7 and 8 survive termination.',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Governing Law',
              'These Terms are governed by and construed in accordance with the laws of England and Wales. Any disputes shall be subject to the exclusive jurisdiction of the English courts.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_support_outlined,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Contact & Support',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'For questions or support please contact us:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Colors.indigo.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'jase@laennec.ai',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildClickableLink(
    String description,
    String url, {
    String? urlText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _launchURL(url),
                  child: Text(
                    url,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.blue.shade600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue.shade600,
                    ),
                  ),
                ),
                Text(urlText ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
