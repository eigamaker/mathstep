class VoiceDictation {
  static const Map<String, String> _dictationMap = {
    // 基本演算
    'プラス': '+',
    'たす': '+',
    'マイナス': '-',
    'ひく': '-',
    'かける': '*',
    'わる': '/',
    'イコール': '=',
    '等しい': '=',
    
    // 括弧
    'かっこ': '(',
    'かっこ開く': '(',
    'かっこ閉じる': ')',
    'かっこ閉じ': ')',
    
    // 変数
    'エックス': 'x',
    'ワイ': 'y',
    'ゼット': 'z',
    'エー': 'a',
    'ビー': 'b',
    'シー': 'c',
    
    // 累乗
    '二乗': '^2',
    '三乗': '^3',
    '四乗': '^4',
    '五乗': '^5',
    '六乗': '^6',
    '七乗': '^7',
    '八乗': '^8',
    '九乗': '^9',
    '十乗': '^10',
    'の二乗': '^2',
    'の三乗': '^3',
    'の四乗': '^4',
    'の五乗': '^5',
    'の六乗': '^6',
    'の七乗': '^7',
    'の八乗': '^8',
    'の九乗': '^9',
    'の十乗': '^10',
    
    // 根号
    'ルート': 'sqrt(',
    '平方根': 'sqrt(',
    '三乗根': 'cbrt(',
    '立方根': 'cbrt(',
    '四乗根': 'root(4,',
    '五乗根': 'root(5,',
    '六乗根': 'root(6,',
    '七乗根': 'root(7,',
    '八乗根': 'root(8,',
    '九乗根': 'root(9,',
    '十乗根': 'root(10,',
    
    // 分数
    '分の': ')/(',
    'ぶんの': ')/(',
    '分数': 'frac(',
    'フラクション': 'frac(',
    
    // 関数
    'サイン': 'sin(',
    'コサイン': 'cos(',
    'タンジェント': 'tan(',
    'タン': 'tan(',
    'ログ': 'log(',
    'ログリズム': 'log(',
    '自然対数': 'ln(',
    'エルエヌ': 'ln(',
    
    // 定数
    'パイ': 'pi',
    '円周率': 'pi',
    'イー': 'e',
    '自然対数の底': 'e',
    'アイ': 'i',
    '虚数単位': 'i',
    
    // 絶対値
    '絶対値': 'abs(',
    'アブソリュート': 'abs(',
    
    // 階乗
    '階乗': '!',
    'ファクトリアル': '!',
    
    // 順列・組み合わせ
    '順列': 'Pr(',
    '組み合わせ': 'Cr(',
    'コンビネーション': 'Cr(',
    
    // 総和・総積
    '総和': 'sum(',
    'シグマ': 'sum(',
    '総積': 'prod(',
    'パイ記号': 'prod(',
    
    // 複素数
    '実部': 'Re(',
    '虚部': 'Im(',
    '共役': 'conj(',
    
    // 区切り文字
    'コンマ': ',',
    'カンマ': ',',
    '点': '.',
    'ドット': '.',
  };

  static String convertDictationToCalculatorSyntax(String dictation) {
    String result = dictation;
    
    // 辞書に基づいて置換
    for (final entry in _dictationMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    
    // 括弧の自動補完
    result = _autoCompleteParentheses(result);
    
    return result;
  }
  
  static String _autoCompleteParentheses(String input) {
    int openCount = 0;
    String result = input;
    
    // 開き括弧の数をカウント
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '(') {
        openCount++;
      } else if (input[i] == ')') {
        openCount--;
      }
    }
    
    // 不足している閉じ括弧を追加
    for (int i = 0; i < openCount; i++) {
      result += ')';
    }
    
    return result;
  }
  
  static List<String> getDictationSuggestions(String partial) {
    return _dictationMap.keys
        .where((key) => key.startsWith(partial))
        .toList();
  }
}
