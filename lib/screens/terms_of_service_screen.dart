import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../localization/localization_extensions.dart';
import '../localization/app_language.dart';
import '../providers/language_provider.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

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
            child: const Icon(Icons.description, color: Colors.white, size: 20),
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
              l10n.termsOfServiceTitle,
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
            colors: [Colors.green.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, '利用規約', Icons.description),
              const SizedBox(height: 16),
              _buildLastUpdated(context, '最終更新日: 2025年10月1日'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. はじめに', [
                '本利用規約（以下「本規約」）は、MathStep（以下「本アプリ」）の利用条件を定めるものです。',
                '本アプリを利用することにより、本規約に同意したものとみなされます。',
                '本規約に同意できない場合は、本アプリの利用を停止してください。'
              ]),
              
              _buildSection(context, '2. アプリの目的', [
                '本アプリは教育目的で数学学習を支援するツールです。',
                '受験生や数学を学習する方々の理解促進を目的としています。',
                '商用利用は禁止されています。'
              ]),
              
              _buildSection(context, '3. 利用条件', [
                '本アプリは以下の条件で利用できます：',
                '• 教育目的での個人利用',
                '• 13歳以上の方、または保護者の同意を得た13歳未満の方',
                '• 本規約を遵守すること',
                '• 適切な学習環境での利用'
              ]),
              
              _buildSection(context, '4. 禁止事項', [
                '以下の行為は禁止されています：',
                '• 本アプリを教育目的以外で利用すること',
                '• 本アプリの著作権を侵害する行為',
                '• 不正な方法でアプリを操作すること',
                '• 他のユーザーに迷惑をかける行為',
                '• 不適切な内容の数式を入力すること'
              ]),
              
              _buildSection(context, '5. 知的財産権', [
                '本アプリの著作権は開発者に帰属します。',
                'ユーザーが入力した数式の著作権は、ユーザーに帰属します。',
                '本アプリの機能やデザインの無断複製・転載を禁止します。'
              ]),
              
              _buildSection(context, '6. 免責事項', [
                '本アプリの利用により生じた損害について、開発者は一切の責任を負いません。',
                '本アプリの内容の正確性を保証するものではありません。',
                '本アプリの利用は自己責任で行ってください。',
                '学習結果や試験結果について責任を負いません。'
              ]),
              
              _buildSection(context, '7. サービスの中止・変更', [
                '開発者は事前の通知なく、本アプリのサービスを中止・変更する場合があります。',
                'サービスの中止・変更により生じた損害について責任を負いません。'
              ]),
              
              _buildSection(context, '8. 広告について', [
                '本アプリには広告が表示される場合があります。',
                '広告の内容について開発者は責任を負いません。',
                '広告をクリックした結果について責任を負いません。'
              ]),
              
              _buildSection(context, '9. プライバシー', [
                'プライバシーについては、別途プライバシーポリシーをご確認ください。',
                '個人情報は適切に保護されます。'
              ]),
              
              _buildSection(context, '10. 規約の変更', [
                '本規約は必要に応じて変更される場合があります。',
                '変更があった場合は、アプリ内でお知らせします。',
                '変更後の規約は、アプリ内での表示と同時に効力を生じます。'
              ]),
              
              _buildSection(context, '11. 準拠法・管轄', [
                '本規約は日本法に準拠します。',
                '本規約に関する紛争は、東京地方裁判所を専属的合意管轄とします。'
              ]),
              
              _buildSection(context, '12. お問い合わせ', [
                '本規約に関するご質問は、アプリ内の設定画面からお問い合わせください。'
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
            colors: [Colors.green.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Terms of Service', Icons.description),
              const SizedBox(height: 16),
              _buildLastUpdated(context, 'Last Updated: October 1, 2025'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. Introduction', [
                'These Terms of Service ("Terms") govern your use of MathStep (the "App").',
                'By using our App, you agree to be bound by these Terms.',
                'If you do not agree to these Terms, please discontinue use of the App.'
              ]),
              
              _buildSection(context, '2. App Purpose', [
                'This App is designed to support math learning for educational purposes.',
                'It aims to help students and math learners improve their understanding.',
                'Commercial use is prohibited.'
              ]),
              
              _buildSection(context, '3. Usage Conditions', [
                'You may use this App under the following conditions:',
                '• Personal use for educational purposes',
                '• Age 13 or older, or under 13 with parental consent',
                '• Compliance with these Terms',
                '• Use in an appropriate learning environment'
              ]),
              
              _buildSection(context, '4. Prohibited Activities', [
                'The following activities are prohibited:',
                '• Using the App for non-educational purposes',
                '• Infringing on the App\'s copyright',
                '• Manipulating the App through unauthorized means',
                '• Causing inconvenience to other users',
                '• Inputting inappropriate mathematical expressions'
              ]),
              
              _buildSection(context, '5. Intellectual Property', [
                'Copyright of this App belongs to the developer.',
                'Copyright of mathematical expressions input by users belongs to the users.',
                'Unauthorized reproduction or redistribution of App features or design is prohibited.'
              ]),
              
              _buildSection(context, '6. Disclaimer', [
                'The developer assumes no responsibility for damages arising from App use.',
                'We do not guarantee the accuracy of App content.',
                'Use the App at your own risk.',
                'We are not responsible for learning or exam results.'
              ]),
              
              _buildSection(context, '7. Service Suspension/Changes', [
                'The developer may suspend or change App services without prior notice.',
                'We assume no responsibility for damages caused by service suspension or changes.'
              ]),
              
              _buildSection(context, '8. Advertising', [
                'This App may display advertisements.',
                'We are not responsible for advertisement content.',
                'We are not responsible for results of clicking advertisements.'
              ]),
              
              _buildSection(context, '9. Privacy', [
                'Please refer to our Privacy Policy for privacy matters.',
                'Personal information will be protected appropriately.'
              ]),
              
              _buildSection(context, '10. Terms Changes', [
                'These Terms may be changed as necessary.',
                'We will notify you of changes within the App.',
                'Changed Terms take effect upon display within the App.'
              ]),
              
              _buildSection(context, '11. Governing Law/Jurisdiction', [
                'These Terms are governed by the laws of Japan.',
                'Any disputes regarding these Terms shall be subject to the exclusive jurisdiction of the Tokyo District Court.'
              ]),
              
              _buildSection(context, '12. Contact', [
                'For questions regarding these Terms, please contact us through the app settings.'
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
            colors: [Colors.green.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, '이용약관', Icons.description),
              const SizedBox(height: 16),
              _buildLastUpdated(context, '최종 업데이트: 2025년 10월 1일'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. 개요', [
                '본 이용약관(이하 "약관")은 MathStep(이하 "앱")의 이용 조건을 정하는 것입니다.',
                '앱을 이용함으로써 본 약관에 동의한 것으로 간주됩니다.',
                '본 약관에 동의할 수 없는 경우 앱 이용을 중단해 주세요.'
              ]),
              
              _buildSection(context, '2. 앱의 목적', [
                '본 앱은 교육 목적으로 수학 학습을 지원하는 도구입니다.',
                '수험생과 수학 학습자들의 이해 증진을 목적으로 합니다.',
                '상업적 이용은 금지됩니다.'
              ]),
              
              _buildSection(context, '3. 이용 조건', [
                '본 앱은 다음 조건에서 이용할 수 있습니다:',
                '• 교육 목적의 개인 이용',
                '• 13세 이상 또는 보호자 동의를 받은 13세 미만',
                '• 본 약관 준수',
                '• 적절한 학습 환경에서의 이용'
              ]),
              
              _buildSection(context, '4. 금지 사항', [
                '다음 행위는 금지됩니다:',
                '• 앱을 교육 목적 외로 이용하는 행위',
                '• 앱의 저작권을 침해하는 행위',
                '• 부정한 방법으로 앱을 조작하는 행위',
                '• 다른 사용자에게 불편을 끼치는 행위',
                '• 부적절한 내용의 수식을 입력하는 행위'
              ]),
              
              _buildSection(context, '5. 지적재산권', [
                '본 앱의 저작권은 개발자에게 귀속됩니다.',
                '사용자가 입력한 수식의 저작권은 사용자에게 귀속됩니다.',
                '앱의 기능이나 디자인을 무단 복제·전재하는 것을 금지합니다.'
              ]),
              
              _buildSection(context, '6. 면책사항', [
                '앱 이용으로 인해 발생한 손해에 대해 개발자는 일체의 책임을 지지 않습니다.',
                '앱 내용의 정확성을 보장하지 않습니다.',
                '앱 이용은 본인 책임으로 하시기 바랍니다.',
                '학습 결과나 시험 결과에 대해 책임을 지지 않습니다.'
              ]),
              
              _buildSection(context, '7. 서비스 중단·변경', [
                '개발자는 사전 통지 없이 앱 서비스를 중단·변경할 수 있습니다.',
                '서비스 중단·변경으로 인한 손해에 대해 책임을 지지 않습니다.'
              ]),
              
              _buildSection(context, '8. 광고에 대해', [
                '본 앱에는 광고가 표시될 수 있습니다.',
                '광고 내용에 대해 개발자는 책임을 지지 않습니다.',
                '광고 클릭 결과에 대해 책임을 지지 않습니다.'
              ]),
              
              _buildSection(context, '9. 개인정보', [
                '개인정보에 대해서는 별도의 개인정보처리방침을 확인해 주세요.',
                '개인정보는 적절히 보호됩니다.'
              ]),
              
              _buildSection(context, '10. 약관 변경', [
                '본 약관은 필요에 따라 변경될 수 있습니다.',
                '변경 시 앱 내에서 알려드립니다.',
                '변경된 약관은 앱 내 표시와 동시에 효력을 발생합니다.'
              ]),
              
              _buildSection(context, '11. 준거법·관할', [
                '본 약관은 일본 법률에 준거합니다.',
                '본 약관에 관한 분쟁은 도쿄 지방법원을 전속적 합의관할로 합니다.'
              ]),
              
              _buildSection(context, '12. 문의사항', [
                '본 약관에 관한 문의사항은 앱 내 설정 화면을 통해 문의해 주세요.'
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
            colors: [Colors.green.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, '服务条款', Icons.description),
              const SizedBox(height: 16),
              _buildLastUpdated(context, '最后更新：2025年10月1日'),
              const SizedBox(height: 20),
              
              _buildSection(context, '1. 简介', [
                '本服务条款（以下简称"条款"）规定了MathStep（以下简称"应用"）的使用条件。',
                '使用我们的应用即表示您同意受这些条款约束。',
                '如果您不同意这些条款，请停止使用应用。'
              ]),
              
              _buildSection(context, '2. 应用目的', [
                '本应用旨在支持教育目的的数学学习。',
                '它旨在帮助学生和数学学习者提高理解能力。',
                '禁止商业使用。'
              ]),
              
              _buildSection(context, '3. 使用条件', [
                '您可以在以下条件下使用本应用：',
                '• 教育目的的个人使用',
                '• 13岁或以上，或经父母同意的13岁以下',
                '• 遵守这些条款',
                '• 在适当的学习环境中使用'
              ]),
              
              _buildSection(context, '4. 禁止活动', [
                '以下活动被禁止：',
                '• 将应用用于非教育目的',
                '• 侵犯应用的版权',
                '• 通过未经授权的方式操作应用',
                '• 对其他用户造成不便',
                '• 输入不适当的数学表达式'
              ]),
              
              _buildSection(context, '5. 知识产权', [
                '本应用的版权归开发者所有。',
                '用户输入的数学表达式的版权归用户所有。',
                '禁止未经授权复制或重新分发应用功能或设计。'
              ]),
              
              _buildSection(context, '6. 免责声明', [
                '开发者对因使用应用而产生的损害不承担任何责任。',
                '我们不保证应用内容的准确性。',
                '使用应用的风险由您自行承担。',
                '我们对学习或考试结果不承担责任。'
              ]),
              
              _buildSection(context, '7. 服务暂停/变更', [
                '开发者可能在不事先通知的情况下暂停或更改应用服务。',
                '我们对因服务暂停或变更造成的损害不承担责任。'
              ]),
              
              _buildSection(context, '8. 广告', [
                '本应用可能显示广告。',
                '我们对广告内容不承担责任。',
                '我们对点击广告的结果不承担责任。'
              ]),
              
              _buildSection(context, '9. 隐私', [
                '有关隐私事宜，请参阅我们的隐私政策。',
                '个人信息将得到适当保护。'
              ]),
              
              _buildSection(context, '10. 条款变更', [
                '这些条款可能会根据需要更改。',
                '我们将在应用内通知您更改。',
                '更改后的条款在应用内显示时生效。'
              ]),
              
              _buildSection(context, '11. 适用法律/管辖权', [
                '这些条款受日本法律管辖。',
                '任何有关这些条款的争议应受东京地方法院的专属管辖权管辖。'
              ]),
              
              _buildSection(context, '12. 联系我们', [
                '有关这些条款的问题，请通过应用设置联系我们。'
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
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green.shade700, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdated(BuildContext context, String date) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData ? snapshot.data!.version : '1.0.0';
        
        // 言語に応じてバージョン表示テキストを決定
        String versionText;
        if (date.contains('2025年10月1日')) {
          versionText = 'アプリバージョン: $version';
        } else if (date.contains('October 1, 2025')) {
          versionText = 'App Version: $version';
        } else if (date.contains('2025년 10월 1일')) {
          versionText = '앱 버전: $version';
        } else if (date.contains('2025年10月1日')) {
          versionText = '应用版本: $version';
        } else {
          versionText = 'App Version: $version';
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                versionText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
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
            color: Colors.green.shade700,
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
