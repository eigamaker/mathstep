import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/localization_extensions.dart';
import '../localization/app_language.dart';
import '../providers/language_provider.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageStateProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: _buildAppBar(context, l10n),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context, languageState.language),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, dynamic l10n) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.privacy_tip, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              l10n.privacyPolicyTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLanguage language) {
    switch (language.code) {
      case 'ja':
        return _buildJapaneseContent(context);
      case 'en':
        return _buildEnglishContent(context);
      case 'ko':
        return _buildKoreanContent(context);
      case 'zh':
      case 'zh_CN':
      case 'zh_TW':
        return _buildChineseContent(context);
      default:
        return _buildEnglishContent(context);
    }
  }

  Widget _buildJapaneseContent(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'プライバシーポリシー', Icons.privacy_tip),
              const SizedBox(height: 16),
              _buildLastUpdated(context, '最終更新日: 2024年12月19日'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. はじめに', [
                'MathStep（以下「本アプリ」）は、数学学習を支援する教育アプリです。',
                '本アプリは、ユーザーのプライバシーを尊重し、個人情報の保護に努めます。',
                '本プライバシーポリシーは、本アプリの利用に関して収集される情報について説明します。'
              ]),
              
              _buildSection(context, '2. 収集する情報', [
                '本アプリは以下の情報を収集します：',
                '• 入力された数式（学習目的のため）',
                '• アプリの使用状況（クラッシュレポート、パフォーマンスデータ）',
                '• デバイス情報（OS、アプリバージョン、デバイスモデル）',
                '• 広告表示に関する情報（AdMobによる）'
              ]),
              
              _buildSection(context, '3. 収集しない情報', [
                '本アプリは以下の情報を収集しません：',
                '• 個人を特定できる情報（氏名、メールアドレス、電話番号など）',
                '• 位置情報',
                '• 連絡先情報',
                '• カメラやマイクからの音声・画像データ（権限は要求しますが、データは保存しません）'
              ]),
              
              _buildSection(context, '4. 情報の利用目的', [
                '収集した情報は以下の目的で利用します：',
                '• 数学問題の解決支援',
                '• アプリの機能向上',
                '• エラーの修正',
                '• 広告の表示（AdMob）'
              ]),
              
              _buildSection(context, '5. 第三者との共有', [
                '収集した情報は以下の場合を除き、第三者と共有しません：',
                '• OpenAI API（数式の解析のため）',
                '• Google AdMob（広告表示のため）',
                '• 法的な要請がある場合'
              ]),
              
              _buildSection(context, '6. データの保存', [
                '• 入力された数式は、デバイス内のローカルストレージに保存されます',
                '• インターネット経由で送信されるのは、OpenAI APIへの数式のみです',
                '• ユーザーはいつでもアプリ内の履歴を削除できます'
              ]),
              
              _buildSection(context, '7. お子様のプライバシー', [
                '本アプリは13歳未満のお子様にも安全にご利用いただけます',
                'COPPA（児童オンラインプライバシー保護法）に準拠しています',
                'お子様の個人情報は収集しません'
              ]),
              
              _buildSection(context, '8. プライバシーポリシーの変更', [
                '本プライバシーポリシーは必要に応じて更新される場合があります',
                '重要な変更がある場合は、アプリ内でお知らせします'
              ]),
              
              _buildSection(context, '9. お問い合わせ', [
                'プライバシーに関するご質問は、アプリ内の設定画面からお問い合わせください'
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnglishContent(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Privacy Policy', Icons.privacy_tip),
              const SizedBox(height: 16),
              _buildLastUpdated(context, 'Last Updated: December 19, 2024'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. Introduction', [
                'MathStep (the "App") is an educational app designed to support math learning.',
                'We respect your privacy and are committed to protecting your personal information.',
                'This Privacy Policy explains what information we collect when you use our App.'
              ]),
              
              _buildSection(context, '2. Information We Collect', [
                'We collect the following information:',
                '• Math expressions you input (for educational purposes)',
                '• App usage data (crash reports, performance data)',
                '• Device information (OS, app version, device model)',
                '• Advertising-related information (via AdMob)'
              ]),
              
              _buildSection(context, '3. Information We Do NOT Collect', [
                'We do NOT collect the following information:',
                '• Personally identifiable information (name, email, phone number, etc.)',
                '• Location data',
                '• Contact information',
                '• Audio or image data from camera/microphone (we request permissions but do not store data)'
              ]),
              
              _buildSection(context, '4. How We Use Information', [
                'We use collected information for the following purposes:',
                '• Providing math problem-solving assistance',
                '• Improving app functionality',
                '• Fixing errors and bugs',
                '• Displaying advertisements (AdMob)'
              ]),
              
              _buildSection(context, '5. Third-Party Sharing', [
                'We do not share your information with third parties except:',
                '• OpenAI API (for math expression analysis)',
                '• Google AdMob (for advertisement display)',
                '• When required by law'
              ]),
              
              _buildSection(context, '6. Data Storage', [
                '• Math expressions are stored locally on your device',
                '• Only math expressions are sent to OpenAI API over the internet',
                '• You can delete your history at any time within the app'
              ]),
              
              _buildSection(context, '7. Children\'s Privacy', [
                'Our App is safe for children under 13',
                'We comply with COPPA (Children\'s Online Privacy Protection Act)',
                'We do not collect personal information from children'
              ]),
              
              _buildSection(context, '8. Privacy Policy Changes', [
                'This Privacy Policy may be updated as needed',
                'We will notify you of significant changes within the app'
              ]),
              
              _buildSection(context, '9. Contact Us', [
                'For privacy-related questions, please contact us through the app settings'
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKoreanContent(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, '개인정보처리방침', Icons.privacy_tip),
              const SizedBox(height: 16),
              _buildLastUpdated(context, '최종 업데이트: 2024년 12월 19일'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. 개요', [
                'MathStep(이하 "앱")는 수학 학습을 지원하는 교육용 앱입니다.',
                '저희는 사용자의 개인정보를 존중하며 보호에 최선을 다합니다.',
                '본 개인정보처리방침은 앱 사용 시 수집되는 정보에 대해 설명합니다.'
              ]),
              
              _buildSection(context, '2. 수집하는 정보', [
                '저희는 다음 정보를 수집합니다:',
                '• 입력된 수식 (학습 목적)',
                '• 앱 사용 데이터 (크래시 리포트, 성능 데이터)',
                '• 기기 정보 (OS, 앱 버전, 기기 모델)',
                '• 광고 관련 정보 (AdMob을 통해)'
              ]),
              
              _buildSection(context, '3. 수집하지 않는 정보', [
                '저희는 다음 정보를 수집하지 않습니다:',
                '• 개인 식별 정보 (이름, 이메일, 전화번호 등)',
                '• 위치 정보',
                '• 연락처 정보',
                '• 카메라/마이크의 음성/이미지 데이터 (권한은 요청하지만 데이터는 저장하지 않음)'
              ]),
              
              _buildSection(context, '4. 정보 이용 목적', [
                '수집한 정보는 다음 목적으로 이용합니다:',
                '• 수학 문제 해결 지원',
                '• 앱 기능 개선',
                '• 오류 수정',
                '• 광고 표시 (AdMob)'
              ]),
              
              _buildSection(context, '5. 제3자 공유', [
                '수집한 정보는 다음 경우를 제외하고 제3자와 공유하지 않습니다:',
                '• OpenAI API (수식 분석용)',
                '• Google AdMob (광고 표시용)',
                '• 법적 요청이 있는 경우'
              ]),
              
              _buildSection(context, '6. 데이터 저장', [
                '• 입력된 수식은 기기 내 로컬 스토리지에 저장됩니다',
                '• 인터넷을 통해 전송되는 것은 OpenAI API로의 수식뿐입니다',
                '• 사용자는 언제든지 앱 내 기록을 삭제할 수 있습니다'
              ]),
              
              _buildSection(context, '7. 아동 개인정보', [
                '본 앱은 13세 미만 아동도 안전하게 이용할 수 있습니다',
                'COPPA(아동 온라인 개인정보보호법)를 준수합니다',
                '아동의 개인정보는 수집하지 않습니다'
              ]),
              
              _buildSection(context, '8. 개인정보처리방침 변경', [
                '본 개인정보처리방침은 필요에 따라 업데이트될 수 있습니다',
                '중요한 변경사항이 있을 경우 앱 내에서 알려드립니다'
              ]),
              
              _buildSection(context, '9. 문의사항', [
                '개인정보 관련 문의사항은 앱 내 설정 화면을 통해 문의해 주세요'
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChineseContent(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, '隐私政策', Icons.privacy_tip),
              const SizedBox(height: 16),
              _buildLastUpdated(context, '最后更新：2024年12月19日'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. 简介', [
                'MathStep（以下简称"本应用"）是一款旨在支持数学学习的教育应用。',
                '我们尊重您的隐私，致力于保护您的个人信息。',
                '本隐私政策说明了您使用我们的应用时收集的信息。'
              ]),
              
              _buildSection(context, '2. 我们收集的信息', [
                '我们收集以下信息：',
                '• 您输入的数学表达式（用于教育目的）',
                '• 应用使用数据（崩溃报告、性能数据）',
                '• 设备信息（操作系统、应用版本、设备型号）',
                '• 广告相关信息（通过AdMob）'
              ]),
              
              _buildSection(context, '3. 我们不收集的信息', [
                '我们不收集以下信息：',
                '• 个人身份信息（姓名、电子邮件、电话号码等）',
                '• 位置数据',
                '• 联系人信息',
                '• 来自摄像头/麦克风的音频或图像数据（我们请求权限但不存储数据）'
              ]),
              
              _buildSection(context, '4. 信息使用方式', [
                '我们将收集的信息用于以下目的：',
                '• 提供数学问题解决帮助',
                '• 改进应用功能',
                '• 修复错误和漏洞',
                '• 显示广告（AdMob）'
              ]),
              
              _buildSection(context, '5. 第三方共享', [
                '除以下情况外，我们不与第三方共享您的信息：',
                '• OpenAI API（用于数学表达式分析）',
                '• Google AdMob（用于广告显示）',
                '• 法律要求时'
              ]),
              
              _buildSection(context, '6. 数据存储', [
                '• 数学表达式存储在您设备的本地存储中',
                '• 只有数学表达式通过互联网发送到OpenAI API',
                '• 您可以随时在应用内删除您的历史记录'
              ]),
              
              _buildSection(context, '7. 儿童隐私', [
                '我们的应用对13岁以下儿童是安全的',
                '我们遵守COPPA（儿童在线隐私保护法）',
                '我们不收集儿童的个人信息'
              ]),
              
              _buildSection(context, '8. 隐私政策变更', [
                '本隐私政策可能会根据需要更新',
                '如有重大变更，我们将在应用内通知您'
              ]),
              
              _buildSection(context, '9. 联系我们', [
                '如有隐私相关问题，请通过应用设置联系我们'
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdated(BuildContext context, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        date,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...content.map((text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}
