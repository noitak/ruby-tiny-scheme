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

  describe '#eval' do
    it 'リテラルはそのまま返す' do
      program = TinyScheme::parse('123')
      TinyScheme::eval(program, @global_env).should eq 123
    end

    it 'quote: 式をそのまま返す' do
      program = TinyScheme::parse('(quote 123)')
      TinyScheme::eval(program, @global_env).should eq 123

      program = TinyScheme::parse('(quote (1 2 3))')
      TinyScheme::eval(program, @global_env).should eq [1, 2, 3]
    end

    it '変数参照: 値を返す' do
      program = TinyScheme::parse('(define hoge)')
      TinyScheme::eval(program, @global_env)

      program = TinyScheme::parse('(set! hoge 123)')
      TinyScheme::eval(program, @global_env)

      program = TinyScheme::parse('hoge')
      TinyScheme::eval(program, @global_env).should eq 123
    end

    context '値を設定されてない変数' do
      it '変数参照すると: nilを返す' do
        program = TinyScheme::parse('(define hoge)')
        TinyScheme::eval(program, @global_env)

        program = TinyScheme::parse('hoge')
        TinyScheme::eval(program, @global_env).should be_nil
      end
    end

    context 'define されていない変数' do
      it '変数参照すると: NoMethodError' do
        program = TinyScheme::parse('hoge')
        lambda{TinyScheme::eval(program, @global_env)}.should raise_error(NoMethodError)
      end
    end
  end

  describe '#eval: リスト操作' do
    context '1以上の長さのリスト' do
      it 'list: リストを生成する' do
        program = TinyScheme::parse('(list 1 2 3)')
        TinyScheme::eval(program, @global_env).should eq [1, 2, 3]
      end

      it 'car: 先頭要素を返す' do
        program = TinyScheme::parse('(car (list 1 2 3))')
        TinyScheme::eval(program, @global_env).should eq 1
      end

      it 'cdr: 先頭を除いた残りの要素を返す' do
        program = TinyScheme::parse('(cdr (list 1 2 3))')
        TinyScheme::eval(program, @global_env).should eq [2, 3]
      end

      it 'cons: 先頭要素と残りの要素をつなげてリストにする' do
        program = TinyScheme::parse('(cons 1 (list 2 3))')
        TinyScheme::eval(program, @global_env).should eq [1, 2, 3]
      end

      it '(cons (car X) (cdr X)) は元のリストXと同じになる' do
        program = TinyScheme::parse('(cons (car (list 1 2 3)) (cdr (list 1 2 3)))')
        TinyScheme::eval(program, @global_env).should eq [1, 2, 3]
      end
    end

    context '長さ1のリスト' do
      it 'list: リストを生成する' do
        program = TinyScheme::parse('(list 9)')
        TinyScheme::eval(program, @global_env).should eq [9]
      end

      it 'car: 先頭要素を返す' do
        program = TinyScheme::parse('(car (list 9))')
        TinyScheme::eval(program, @global_env).should eq 9
      end

      it 'cdr: 空リストを返す' do
        program = TinyScheme::parse('(cdr (list 9))')
        TinyScheme::eval(program, @global_env).should eq []
      end
    end

    context '空リスト' do
      it 'list: 空リストを返す' do
        program = TinyScheme::parse('(list)')
        TinyScheme::eval(program, @global_env).should eq []
      end

      it 'car: nil (SchemeではError. raise exceptinすべき?)' do
        program = TinyScheme::parse('(car (list))')
        TinyScheme::eval(program, @global_env).should be_nil
      end

      it 'cdr: nil (SchemeではError. raise exceptinすべき?)' do
        program = TinyScheme::parse('(cdr (list))')
        TinyScheme::eval(program, @global_env).should be_nil
      end
    end

    context 'cons: 第2引数がlistでない時' do
      it 'ドット対には未対応: TypeError' do
        program = TinyScheme::parse('(cons 1 2)')
        lambda{TinyScheme::eval(program, @global_env)}.should raise_error(TypeError)

        program = TinyScheme::parse('(cons (list 1) 2)')
        lambda{TinyScheme::eval(program, @global_env)}.should raise_error(TypeError)
      end
    end

  end

end
