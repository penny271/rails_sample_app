class User
  attr_accessor :name, :email

  def initialize(attributes = {})
    @name  = attributes[:name]
    @email = attributes[:email]
  end

  def formatted_email
    "#{@name} <#{@email}>"
  end
end

# このコードは、RubyでUserという名前のクラスを定義しています。このクラスは、ユーザーの名前とメールアドレスを表現するためのものです。

# attr_accessor :name, :emailは、nameとemailという名前のゲッターとセッターを自動的に作成します。これにより、Userオブジェクトのnameとemail属性にアクセスしたり、それらの値を変更したりすることができます。

# initializeメソッドは、Userオブジェクトが作成されるときに自動的に呼び出されます。このメソッドは、ハッシュ形式の引数を受け取り、その中の:nameと:emailキーの値をそれぞれ@nameと@emailインスタンス変数に設定します。引数が与えられなかった場合、デフォルトの空のハッシュが使用され、インスタンス変数はnilに設定されます。

# formatted_emailメソッドは、ユーザーの名前とメールアドレスを一つの文字列にフォーマットします。この文字列は、"名前 <メールアドレス>"という形式になります。このメソッドは、メール送信などでユーザーの情報を適切な形式で表示するために使用できます。