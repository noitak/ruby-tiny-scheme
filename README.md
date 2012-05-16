# TinyScheme

Tiny Scheme interpliter for Ruby practice.
Ruby練習用Scheme インタープリター

## Example

    $ ruby repl.rb
    tiny_scheme > (car (list 1 2 3))
    1
    tiny_scheme > (cdr (list 1 2 3))
    (2 3)
    tiny_scheme > (cons 1 (list 2 3))
    (1 2 3)
    tiny_scheme > ((lambda (x) (* x x)) 3)
    9
    tiny_scheme > (exit)
    $ 

## 参考
* [((Pythonで) 書く (Lisp) インタプリタ)](http://www.aoky.net/articles/peter_norvig/lispy.htm)

## Backlog
* [((Pythonで) 書く ((さらに良い) Lisp) インタプリタ)](http://www.aoky.net/articles/peter_norvig/lispy2.htm)
    * 新しいデータ型 - 文字列、論理型、複素数、ポート
    * 新しい構文 - 文字列、コメント、クォート、#リテラル
    * マクロ - ユーザ定義、ならびに組み込みの派生構文
    * 末尾再帰最適化するより良い eval
    * 継続 (call/cc)
    * 任意個の引数を持つ手続き
    * エラー検出と拡張構文
    * より多くのプリミティブな手続き
