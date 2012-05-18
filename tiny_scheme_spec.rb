# coding: utf-8

require File.dirname(__FILE__) + '/tiny_scheme'

describe TinyScheme do
  before do
    @global_env = TinyScheme::add_globals(TinyScheme::Env.new [], [])
  end

  describe '#parse' do
    context '入れ子のないリスト' do
      it '() --> []' do
        TinyScheme::parse('()').should eq []
      end
      it '(hoge) --> ["hoge"]' do
        TinyScheme::parse('(hoge)').should eq ['hoge']
      end
      it '(foo bar 123) --> ["foo", "bar", 123]' do
        TinyScheme::parse('(foo bar 123)').should eq ['foo', 'bar', 123]
      end
    end

    context '入れ子のあるリスト' do
      it '(()) --> [[]]' do
        TinyScheme::parse('(())').should eq [[]]
      end
      it '(hoge (123)) --> ["hoge", [123]]' do
        TinyScheme::parse('(hoge (123))').should eq ['hoge', [123]]
      end
      it '(foo (bar (1 2 3))) --> ["foo", ["bar", [1, 2, 3]]]' do
        TinyScheme::parse('(foo (bar (1 2 3)))').should eq ['foo', ['bar', [1, 2, 3]]]
      end
    end

    context 'カッコが閉じていない' do
      it 'raise RuntimeError' do
        lambda{TinyScheme::parse('(')}.should raise_error(RuntimeError)
      end
    end

    context '閉じカッコしかない' do
      it 'raise RuntimeError' do
        lambda{TinyScheme::parse(')')}.should raise_error(RuntimeError)
      end
    end

  end

  describe 'Special Forms' do
    describe '定数リテラル: number' do
      it '数はそれ自身へと評価される' do
        TinyScheme::parse('123') do |program|
          TinyScheme::eval(program, @global_env).should eq 123
        end
      end
    end

    describe '定義: (define var exp)' do
      it '最も内側の環境に新しい変数を定義し, 式expを評価した値を設定する' do
        TinyScheme::parse('(define r 3)') do |program|
          TinyScheme::eval(program, @global_env).should eq 3
        end
      end
    end

    describe '変数参照: var' do
      it '変数の値を返す' do
        TinyScheme::parse('(define r 3)') do |program|
          TinyScheme::eval(program, @global_env).should eq 3
        end

        TinyScheme::parse('r') do |program|
          TinyScheme::eval(program, @global_env).should eq 3
        end
      end

      context '定義されていない変数の参照' do
        it 'NoMethodError' do
          TinyScheme::parse('X') do |program|
            lambda{TinyScheme::eval(program, @global_env)}.should raise_error(NoMethodError)
          end
        end
      end
    end

    describe '代入: (set! var exp)' do
      it 'expを評価してその値をvarに割り当てる' do
        TinyScheme::parse('(define r 3)') do |program|
          TinyScheme::eval(program, @global_env).should eq 3
        end

        TinyScheme::parse('(set! r 123)') do |program|
          TinyScheme::eval(program, @global_env).should eq 123
        end

        TinyScheme::parse('r') do |program|
          TinyScheme::eval(program, @global_env).should eq 123
        end
      end

      context '定義されていない変数への代入' do
        it 'NoMethodError' do
          TinyScheme::parse('(set! Y 123)') do |program|
            lambda{TinyScheme::eval(program, @global_env)}.should raise_error(NoMethodError)
          end
        end
      end
    end

    describe 'クオート: (quote exp)' do
      it 'expを解釈せずにそのまま返す' do
        TinyScheme::parse('(quote 123)') do |program|
          TinyScheme::eval(program, @global_env).should eq 123
        end

        TinyScheme::parse('(quote (a b c))') do |program|
          TinyScheme::eval(program, @global_env).should eq ['a', 'b', 'c']
        end
      end
    end

    describe '条件式: (if test conseq alt)' do
      context 'testが真の場合' do
        it 'conseqを返す' do
          TinyScheme::parse('(if (< 10 20) (+ 1 1) (+ 3 3))') do |program|
            TinyScheme::eval(program, @global_env).should eq 2
          end
        end
      end
      context 'testが偽の場合' do
        it 'altを返す' do
          TinyScheme::parse('(if (> 10 20) (+ 1 1) (+ 3 3))') do |program|
            TinyScheme::eval(program, @global_env).should eq 6
          end
        end
      end
    end

    describe '手続き: (lambda (var...) exp)' do
      it 'var... を引数名, 式exp を本体とする手続きを作る' do
        TinyScheme::parse('((lambda (x) (* x x)) 3)') do |program|
          TinyScheme::eval(program, @global_env).should eq 9
        end
      end
    end

    describe '逐次式: (begin exp...)' do
      it 'exp... のそれぞれの式を左から右へ評価していき, 最後の値を返す' do
        TinyScheme::parse('(define x 123)') do |program|
          TinyScheme::eval(program, @global_env)
        end

        TinyScheme::parse('(begin (set! x 1) (set! x (+ x 1)) (* x 2))') do |program|
          TinyScheme::eval(program, @global_env).should eq 4
        end
      end
    end

    describe '手続き呼び出し: (proc exp...)' do
      it 'procがSpecial Formsでない場合, 手続きとして扱われる' do
        TinyScheme::parse('(define square (lambda (x) (* x x)))') do |program|
          TinyScheme::eval(program, @global_env)
        end

        TinyScheme::parse('(square 12)') do |program|
          TinyScheme::eval(program, @global_env).should eq 144
        end
      end
    end
  end

  describe 'リスト操作' do
    context '1以上の長さのリスト' do
      it 'list: リストを生成する' do
        TinyScheme::parse('(list 1 2 3)') do |program|
          TinyScheme::eval(program, @global_env).should eq [1, 2, 3]
        end
      end

      it 'car: 先頭要素を返す' do
        TinyScheme::parse('(car (list 1 2 3))') do |program|
          TinyScheme::eval(program, @global_env).should eq 1
        end
      end

      it 'cdr: 先頭を除いた残りの要素を返す' do
        TinyScheme::parse('(cdr (list 1 2 3))') do |program|
          TinyScheme::eval(program, @global_env).should eq [2, 3]
        end
      end

      it 'cons: 先頭要素と残りの要素をつなげてリストにする' do
        TinyScheme::parse('(cons 1 (list 2 3))') do |program|
          TinyScheme::eval(program, @global_env).should eq [1, 2, 3]
        end
      end

      it '(cons (car X) (cdr X)) は元のリストXと同じになる' do
        TinyScheme::parse('(cons (car (list 1 2 3)) (cdr (list 1 2 3)))') do |program|
          TinyScheme::eval(program, @global_env).should eq [1, 2, 3]
        end
      end
    end

    context '長さ1のリスト' do
      it 'list: リストを生成する' do
        TinyScheme::parse('(list 9)') do |program|
          TinyScheme::eval(program, @global_env).should eq [9]
        end
      end

      it 'car: 先頭要素を返す' do
        TinyScheme::parse('(car (list 9))') do |program|
          TinyScheme::eval(program, @global_env).should eq 9
        end
      end

      it 'cdr: 空リストを返す' do
        TinyScheme::parse('(cdr (list 9))') do |program|
          TinyScheme::eval(program, @global_env).should eq []
        end
      end
    end

    context '空リスト' do
      it 'list: 空リストを返す' do
        TinyScheme::parse('(list)') do |program|
          TinyScheme::eval(program, @global_env).should eq []
        end
      end

      it 'car: nil (SchemeではError. raise exceptinすべき?)' do
        TinyScheme::parse('(car (list))') do |program|
          TinyScheme::eval(program, @global_env).should be_nil
        end
      end

      it 'cdr: nil (SchemeではError. raise exceptinすべき?)' do
        TinyScheme::parse('(cdr (list))') do |program|
          TinyScheme::eval(program, @global_env).should be_nil
        end
      end
    end

    context 'cons: 第2引数がlistでない時' do
      it 'ドット対には未対応: TypeError' do
        TinyScheme::parse('(cons 1 2)') do |program|
          lambda{TinyScheme::eval(program, @global_env)}.should raise_error(TypeError)
        end

        TinyScheme::parse('(cons (list 1) 2)') do |program|
          lambda{TinyScheme::eval(program, @global_env)}.should raise_error(TypeError)
        end
      end
    end
  end
end
