import 'dart:math';
import '../models/quiz_models.dart';
import '../utils/math_utils.dart';

/// パターン2: a(cx+d)²
/// パターン6: a(cx+dy)²
/// の問題生成を担当するクラス（完全平方式）
class Pattern26Generator {
  final Random _random = Random();

  /// 最大公約数を求める
  int gcd(int x, int y) {
    x = x.abs();
    y = y.abs();
    while (y != 0) {
      int temp = y;
      y = x % y;
      x = temp;
    }
    return x;
  }

  /// 項をフォーマットする
  String formatTerm(int coef, String variable, bool isFirst) {
    if (coef == 0) return '';
    
    String sign = '';
    int absCoef = coef.abs();
    
    if (!isFirst) {
      sign = coef > 0 ? ' + ' : ' - ';
    } else {
      sign = coef < 0 ? '-' : '';
    }
    
    if (variable.isNotEmpty) {
      if (absCoef == 1) {
        return '$sign$variable';
      }
      return '$sign$absCoef$variable';
    }
    
    return '$sign$absCoef';
  }

  /// 因数ペアを取得する
  List<List<int>> getFactorPairs(int product) {
    List<List<int>> pairs = [];
    int absProduct = product.abs();
    
    for (int i = 1; i <= absProduct; i++) {
      if (absProduct % i == 0) {
        int j = absProduct ~/ i;
        if (product > 0) {
          pairs.add([i, j]);
          if (i != j) pairs.add([-i, -j]);
        } else {
          pairs.add([i, -j]);
          if (i != j) pairs.add([-i, j]);
        }
      }
    }
    return pairs;
  }

  /// パターン2: a(cx+d)² の問題を生成
  QuizProblem generatePattern2() {
    int a, c, d;
    
    do {
      a = _random.nextInt(6) - 2;  // -2〜3
      if (a == 0) {
        a = _random.nextBool() ? 1 : -1;  // 0の場合は1か-1に
      }
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(13) - 6; // -6〜6
      if (d == 0) d = _random.nextBool() ? 1 : -1;
    } while (gcd(c, d.abs()) != 1);  // gcd(c,|d|) = 1 を保証

    // 展開形：a(c²x² + 2cdx + d²)
    int coefX2 = a * c * c;
    int coefX = a * 2 * c * d;
    int coefConst = a * d * d;
    
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefX, 'x', false)}${formatTerm(coefConst, '', false)}';

    // 正答：因数分解形：a(cx+d)²
    String correctAnswer;
    if (a == 1) {
      correctAnswer = '(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    } else if (a == -1) {
      // -1の場合は - と表記
      correctAnswer = '-(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    } else {
      correctAnswer = '$a(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    }

    // 誤答生成
    List<String> wrongAnswers = _generatePattern2WrongAnswers(a, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 2,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン6: a(cx+dy)² の問題を生成
  QuizProblem generatePattern6() {
    int a, c, d;
    
    do {
      a = _random.nextInt(6) - 2;  // -2〜3
      if (a == 0) {
        a = _random.nextBool() ? 1 : -1;  // 0の場合は1か-1に
      }
      c = _random.nextInt(3) + 1;  // 1〜3
      d = _random.nextInt(13) - 6; // -6〜6
      if (d == 0) d = _random.nextBool() ? 1 : -1;
    } while (gcd(c, d.abs()) != 1);  // gcd(c,|d|) = 1 を保証

    // 展開形：a(c²x² + 2cdxy + d²y²)
    int coefX2 = a * c * c;
    int coefXY = a * 2 * c * d;
    int coefY2 = a * d * d;
    
    String expression = '${formatTerm(coefX2, 'x^2', true)}${formatTerm(coefXY, 'xy', false)}${formatTerm(coefY2, 'y^2', false)}';

    // 正答：因数分解形：a(cx+dy)²
    String correctAnswer;
    if (a == 1) {
      correctAnswer = '(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})^2';
    } else if (a == -1) {
      // -1の場合は - と表記
      correctAnswer = '-(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})^2';
    } else {
      correctAnswer = '$a(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})^2';
    }

    // 誤答生成
    List<String> wrongAnswers = _generatePattern6WrongAnswers(a, c, d);
    
    List<String> choices = [correctAnswer, ...wrongAnswers];
    choices.shuffle();

    return QuizProblem(
      pattern: 6,
      expression: expression,
      correctAnswer: correctAnswer,
      choices: choices,
    );
  }

  /// パターン2の誤答を生成（元のロジック完全移植）
  List<String> _generatePattern2WrongAnswers(int a, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 符号のミス a(cx-d)²
    String wrong1;
    if (a == 1) {
      wrong1 = '(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})^2';
    } else if (a == -1) {
      wrong1 = '-(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})^2';
    } else {
      wrong1 = '$a(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})^2';
    }
    wrongAnswers.add(wrong1);

    // 誤答2: 係数関連のミス
    String wrong2;
    if (a == 1 || a == -1) {
      // a=±1の時は係数2を付ける（正答と重複を避ける）
      wrong2 = '2(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    } else {
      // a≠±1の時は係数忘れ
      wrong2 = '(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    }
    wrongAnswers.add(wrong2);

    // 誤答3: 平方の差と混同 a(cx+d)(cx-d)
    String wrong3;
    if (a == 1) {
      wrong3 = '(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
    } else if (a == -1) {
      wrong3 = '-(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
    } else {
      wrong3 = '$a(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})(${formatTerm(c, 'x', true)}${formatTerm(-d, '', false)})';
    }
    wrongAnswers.add(wrong3);

    return wrongAnswers;
  }

  /// パターン6の誤答を生成（元のロジック完全移植）
  List<String> _generatePattern6WrongAnswers(int a, int c, int d) {
    List<String> wrongAnswers = [];

    // 誤答1: 符号のミス a(cx-dy)²
    String wrong1;
    if (a == 1) {
      wrong1 = '(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})^2';
    } else if (a == -1) {
      wrong1 = '-(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})^2';
    } else {
      wrong1 = '$a(${formatTerm(c, 'x', true)}${formatTerm(-d, 'y', false)})^2';
    }
    wrongAnswers.add(wrong1);

    // 誤答2: 係数関連のミス
    String wrong2;
    if (a == 1 || a == -1) {
      // a=±1の時は係数2を付ける（正答と重複を避ける）
      wrong2 = '2(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})^2';
    } else {
      // a≠±1の時は係数忘れ
      wrong2 = '(${formatTerm(c, 'x', true)}${formatTerm(d, 'y', false)})^2';
    }
    wrongAnswers.add(wrong2);

    // 誤答3: 変数yを忘れる a(cx+d)²
    String wrong3;
    if (a == 1) {
      wrong3 = '(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    } else if (a == -1) {
      wrong3 = '-(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    } else {
      wrong3 = '$a(${formatTerm(c, 'x', true)}${formatTerm(d, '', false)})^2';
    }
    wrongAnswers.add(wrong3);

    return wrongAnswers;
  }
}