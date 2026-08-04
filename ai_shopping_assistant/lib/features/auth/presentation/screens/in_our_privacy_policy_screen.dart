import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_sizes.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightMedium,
      appBar: AppBar(
        backgroundColor: AppColors.lightMedium,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.secondBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.poppins(
            fontSize: AppSizes.sp16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.w24, vertical: AppSizes.h16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            SizedBox(height: AppSizes.h24),
            _buildSection(
              title: "1. Information We Collect",
              content:
              "We collect information you provide directly to us, such as when you create an account, update your profile, or contact us for support. This includes:\n\n"
                  "• Name, email address, and password\n"
                  "• Profile information such as location and phone number\n"
                  "• Property preferences and search history\n"
                  "• Communications you send to us",
            ),
            _buildSection(
              title: "2. How We Use Your Information",
              content:
              "We use the information we collect to:\n\n"
                  "• Provide, maintain, and improve our services\n"
                  "• Process transactions and send related information\n"
                  "• Send promotional communications (with your consent)\n"
                  "• Respond to comments and questions\n"
                  "• Monitor and analyze usage patterns",
            ),
            _buildSection(
              title: "3. Information Sharing",
              content:
              "We do not sell, trade, or rent your personal information to third parties. We may share your information in the following circumstances:\n\n"
                  "• With service providers who assist in our operations\n"
                  "• When required by law or to protect our rights\n"
                  "• In connection with a merger or acquisition\n"
                  "• With your consent",
            ),
            _buildSection(
              title: "4. Data Security",
              content:
              "We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.",
            ),
            _buildSection(
              title: "5. Your Rights",
              content:
              "You have the right to:\n\n"
                  "• Access the personal data we hold about you\n"
                  "• Request correction of inaccurate data\n"
                  "• Request deletion of your personal data\n"
                  "• Opt-out of marketing communications\n"
                  "• Lodge a complaint with a supervisory authority",
            ),
            _buildSection(
              title: "6. Cookies",
              content:
              "We use cookies and similar tracking technologies to track activity on our app and hold certain information. You can instruct your device to refuse all cookies or to indicate when a cookie is being sent.",
            ),
            _buildSection(
              title: "7. Children's Privacy",
              content:
              "Our service is not directed to individuals under the age of 18. We do not knowingly collect personal information from children. If you become aware that a child has provided us with personal information, please contact us.",
            ),
            _buildSection(
              title: "8. Changes to This Policy",
              content:
              "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the 'Last Updated' date.",
            ),
            _buildSection(
              title: "9. Contact Us",
              content:
              "If you have any questions about this Privacy Policy, please contact us at:\n\n"
                  "📧 privacy@habispace.com\n"
                  "📍 Cairo, Egypt",
            ),
            SizedBox(height: AppSizes.h32),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: EdgeInsets.all(AppSizes.h12),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.r8),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.blue, size: AppSizes.r16),
          SizedBox(width: AppSizes.w8),
          Text(
            "Last updated: May 1, 2025",
            style: GoogleFonts.poppins(
              fontSize: AppSizes.sp12,
              color: AppColors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.h20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.sp14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondBlack,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.sp12,
              fontWeight: FontWeight.w400,
              color: AppColors.secondBlack.withValues(alpha: 0.75),
              height: 1.7,
            ),
          ),
          SizedBox(height: AppSizes.h12),
          Divider(color: AppColors.borderColor, thickness: 1),
        ],
      ),
    );
  }
}