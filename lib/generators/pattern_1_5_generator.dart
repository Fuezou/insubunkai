import 'dart:math';
import '../models/quiz_models.dart';
import '../utils/math_utils.dart';

/// パターン1: (ax+b)(cx+d)
/// パターン5: (ax+by)(cx+dy)
/// の問題生成を担当するクラス
class Pattern15Generator {
  final Random _random = Random();

  /// パターン1: (ax+b)(cx+d) の問題を生成
  QuizProblem generatePattern1() {
    int a, b, c, d;
    
    do {
      a = _random.nextInt(3) + 1;  // 1〜3
      b = _random.nextInt(13) - 6; // -6〜6
      if (b == 0) b = _random.nextBool() ? 1 : -1;
      
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(13) - 6; // -6〜6
      if (d == 0) d = _random.nextBool() ? 1 : -1;
    } while (
      gcd(a, b.abs()) != 1 || 
      gcd(c, d.abs()) != 1 ||
      (a == c && b == d) ||  // 完全平方を除外
      (a == c && b == -d)     // 平方の差を除外
    );

    // 展開形
    int coefX2 = a * c;
    int coefX = a * d + b * c;
    int coefConst = b * d;
    
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefX, 'x', false)}${formatTerm(coefConst, '', false)}';

    // 正答
    String correctAnswer = '(${formatTerm(a, 'x', true)}${formatTerm(b, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})';

    // 誤答生成
    List<String> wrongAnswers = _generatePattern1WrongAnswers(a, b, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 1,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン5: (ax+by)(cx+dy) の問題を生成
  QuizProblem generatePattern5() {
    int a, b, c, d;
    
    do {
      a = _random.nextInt(3) + 1;  // 1〜3
      b = _random.nextInt(13) - 6; // -6〜6
      if (b == 0) b = _random.nextBool() ? 1 : -1;
      
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(13) - 6; // -6〜6
      if (d == 0) d = _random.nextBool() ? 1 : -1;
    } while (
      gcd(a, b.abs()) != 1 || 
      gcd(c, d.abs()) != 1 ||
      (a == c && b == d) ||  // 完全平方を除外
      (a == c && b == -d)     // 平方の差を除外
    );

    // 展開形
    int coefX2 = a * c;
    int coefXY = a * d + b * c;
    int coefY2 = b * d;
    
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefXY, 'xy', false)}${formatTerm(coefY2, 'y^2', false)}';

    // 正答
    String correctAnswer = '(${formatTerm(a, 'x', true)}${formatTerm(b, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})';

    // 誤答生成
    List<String> wrongAnswers = _generatePattern5WrongAnswers(a, b, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 5,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン1の誤答を生成（元のロジック完全移植）
  List<String> _generatePattern1WrongAnswers(int a, int b, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 1つ目の括弧の符号を逆転
    String wrong1 = '(${formatTerm(a, 'x', true)}${formatTerm(-b, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})';
    wrongAnswers.add(wrong1);
    
    // 誤答2: 2つ目の括弧の符号を逆転
    String wrong2 = '(${formatTerm(a, 'x', true)}${formatTerm(b, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
    wrongAnswers.add(wrong2);
    
    // 誤答3: 条件によって分岐（元のロジックを完全再現）
    String wrong3 = '';
    
    // 優先順位1: a≠c かつ b≠d かつ gcd条件を満たす場合は入れ替え
    if (a != c && b != d && gcd(a, d.abs()) == 1 && gcd(c, b.abs()) == 1) {
      // 誤答3-1: 係数と定数項を入れ替え
      wrong3 = '(${formatTerm(c, 'x', true)}${formatTerm(b, '', false)})(${formatTerm(a, 'x', true)}${formatTerm(d, '', false)})';
    } 
    // 優先順位2: gcd(|b|,|d|)≠1 の場合は因数ペア変更
    else if (gcd(b.abs(), d.abs()) != 1) {
      // 誤答3-2: 因数ペア変更を試みる
      List<List<int>> pairs = getFactorPairs(b * d);
      
      // 使用済みの組み合わせを除外
      pairs.removeWhere((pair) => 
        (pair[0] == b && pair[1] == d) ||      // 正答
        (pair[0] == -b && pair[1] == d) ||     // 誤答1
        (pair[0] == b && pair[1] == -d) ||     // 誤答2
        (a * pair[1] + pair[0] * c == a * d + b * c) ||  // 展開すると正答と同じになるもの
        (pair[0] == -b && pair[1] == -d)       // 両方符号逆
      );
      
      // 共通因数が出ないペアのみを選択
      List<List<int>> validPairs = [];
      for (var pair in pairs) {
        if (gcd(a, pair[0].abs()) == 1 && gcd(c, pair[1].abs()) == 1) {
          validPairs.add(pair);
        }
      }
      
      if (validPairs.isNotEmpty) {
        var newPair = validPairs[_random.nextInt(validPairs.length)];
        wrong3 = '(${formatTerm(a, 'x', true)}${formatTerm(newPair[0], '', false)})(${formatTerm(c, 'x', true)}${formatTerm(newPair[1], '', false)})';
      } else {
        // 有効な因数ペアがない場合：両方の符号を逆転
        wrong3 = '(${formatTerm(a, 'x', true)}${formatTerm(-b, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
      }
    } 
    // 優先順位3: その他の場合（フォールバック）
    else {
      // 誤答3-3: 両方の符号を逆転
      wrong3 = '(${formatTerm(a, 'x', true)}${formatTerm(-b, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
    }
    
    wrongAnswers.add(wrong3);
    return wrongAnswers;
  }

  /// パターン5の誤答を生成（元のロジック完全移植）
  List<String> _generatePattern5WrongAnswers(int a, int b, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 1つ目の括弧の符号を逆転
    String wrong1 = '(${formatTerm(a, 'x', true)}${formatTerm(-b, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})';
    wrongAnswers.add(wrong1);
    
    // 誤答2: 2つ目の括弧の符号を逆転
    String wrong2 = '(${formatTerm(a, 'x', true)}${formatTerm(b, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    wrongAnswers.add(wrong2);
    
    // 誤答3: 条件によって分岐（元のロジックを完全再現）
    String wrong3 = '';
    
    // 優先順位1: a≠c かつ b≠d かつ gcd条件を満たす場合は入れ替え
    if (a != c && b != d && gcd(a, d.abs()) == 1 && gcd(c, b.abs()) == 1) {
      // 誤答3-1: 係数と定数項を入れ替え
      wrong3 = '(${formatTerm(c, 'x', true)}${formatTerm(b, 'y', false)})(${formatTerm(a, 'x', true)}${formatTerm(d, 'y', false)})';
    } 
    // 優先順位2: gcd(|b|,|d|)≠1 の場合は因数ペア変更
    else if (gcd(b.abs(), d.abs()) != 1) {
      // 誤答3-2: 因数ペア変更を試みる
      List<List<int>> pairs = getFactorPairs(b * d);
      
      // 使用済みの組み合わせを除外
      pairs.removeWhere((pair) => 
        (pair[0] == b && pair[1] == d) ||      // 正答
        (pair[0] == -b && pair[1] == d) ||     // 誤答1
        (pair[0] == b && pair[1] == -d) ||     // 誤答2
        (a * pair[1] + pair[0] * c == a * d + b * c) ||  // 展開すると正答と同じになるもの
        (pair[0] == -b && pair[1] == -d)       // 両方符号逆
      );
      
      // 共通因数が出ないペアのみを選択
      List<List<int>> validPairs = [];
      for (var pair in pairs) {
        if (gcd(a, pair[0].abs()) == 1 && gcd(c, pair[1].abs()) == 1) {
          validPairs.add(pair);
        }
      }
      
      if (validPairs.isNotEmpty) {
        var newPair = validPairs[_random.nextInt(validPairs.length)];
        wrong3 = '(${formatTerm(a, 'x', true)}${formatTerm(newPair[0], 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(newPair[1], 'y', false)})';
      } else {
        // 有効な因数ペアがない場合：両方の符号を逆転
        wrong3 = '(${formatTerm(a, 'x', true)}${formatTerm(-b, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
      }
    } 
    // 優先順位3: その他の場合（フォールバック）
    else {
      // 誤答3-3: 両方の符号を逆転
      wrong3 = '(${formatTerm(a, 'x', true)}${formatTerm(-b, 'y', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})';
    }
    
    wrongAnswers.add(wrong3);
    return wrongAnswers;
  }
}
