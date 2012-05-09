# codinf: utf-8

module TinyScheme
  # Tiny Scheme for Ruby practice.
  # 

  def self.eval x, env
    # 環境の中で式を評価する

    if x.instance_of? String
      # 変数参照
      env.find(x)[x]
    elsif not x.instance_of? Array
      # リテラル
      x
    elsif x.first == 'quote'
      # (quote exp)
      (_, exp) = x
      exp
    elsif x.first == 'if'
      # (if test conseq alt)
      (_, test, conseq, alt) = x
      eval((eval(test, env) ? conseq : alt), env)
    elsif x.first == 'set!'
      # (set! var exp)
      (_, var, exp) = x
      env.find(var)[var] = eval(exp, env)
    elsif x.first == 'define'
      # (define var exp)
      (_, var, exp) = x
      env[var] = eval(exp, env)
    elsif x.first == 'lambda'
      # (lambda (var*) exp)
      (_, var, exp) = x
      ->(*args){ eval(exp, Env.new(var, args, env)) }
    elsif x.first == 'begin'
      # (begin exp*)
      val = nil
      x.shift
      x.each do |exp|
        val = eval(exp, env)
      end
      val
    else
      # (proc exp*)
      exps = []
      x.each do |exp|
        exps << eval(exp, env)
      end
      proc = exps.shift
      proc.call *exps
    end
  end

  def self.add_globals env
    # 環境にScheme標準の手続きをいくつか追加する
    env['+'] = ->(a, b){ a + b }
    env['-'] = ->(a, b){ a - b }
    env['*'] = ->(a, b){ a * b }
    env['/'] = ->(a, b){ a / b }
    env['>'] = ->(a, b){ a > b }
    env['<'] = ->(a, b){ a < b }
    env['>='] = ->(a, b){ a >= b }
    env['<='] = ->(a, b){ a <= b }
    env['='] = ->(a, b){ a == b }
    env['equal?'] = ->(a, b){ a == b }
    env['eq?'] = ->(a, b){ a == b }
    env['length'] = ->(lst){ lst.length }
    env['cons'] = ->(a, b){ [a].concat(b) }
    env['car'] = ->(lst){ lst[0] }
    env['cdr'] = ->(lst){ lst.slice(1, lst.length - 1) }
    env['append'] = ->(a, b){ a.concat b }
    env['list'] = ->(*x){ [*x] }
    env['list?'] = ->(x){ x.instance_of? Array }
    env['null?'] = ->(x){ x == nil }
    env['symbol?'] = ->(x){ x.instance_of? String }
    env
  end

  def self.parse s
    read_from(tokenize s)
  end

  def self.tokenize s
    s.gsub('(', ' ( ').gsub(')', ' ) ').split(' ')
  end

  def self.read_from tokens
    raise "SyntaxError: unexpected EOF while reading." if tokens.length == 0
    token = tokens.shift
    if token == '('
      l = []
      while tokens[0] != ')'
        l << read_from(tokens)
      end
      tokens.shift
      l
    elsif token == ')'
      raise "SyntaxError: unexpected )"
    else
      atom token
    end
  end

  def self.atom token
    return token.to_i if not token =~ /\D/
    return token.to_f if not token.gsub('.', '') =~ /\D/
    token
  end

  class Env < Hash
    def initialize params, args, outer=nil
      params.zip(args).each do |k, v|
        self[k] = v
      end
      @outer = outer
    end

    def find var
      (self.include? var) ? self : @outer.find(var)
    end
  end

  def self.repl prompt='tiny_scheme > '
    # read-eval-print-loop
    #
    global_env = self.add_globals(Env.new [],[])

    print prompt
    while gets
      begin
        break if $_.chomp == '(exit)'

        val = self.eval(self.parse($_.chomp), global_env)
        puts to_string(val) if not val == nil
      rescue => ex
        puts "#{ex.class}: #{ex.message}"
      end

      print prompt
    end
  end

  def self.to_string exp
    if exp.instance_of? Array
      "(#{exp.map{|e| to_string(e)}.join(' ')})"
    else
      exp.to_s
    end
  end

end
