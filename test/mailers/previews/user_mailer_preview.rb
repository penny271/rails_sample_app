# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # - Preview this email at(下記urlでプレビュー可能)
  # http://localhost:3000/rails/mailers/user_mailer/account_activation
  # * account_activationの引数には有効なUserオブジェクトを渡す必要があるため、リスト 11.17はこのままでは動きません。これを回避するために、user変数が開発用データベースの1番目のユーザーになるように定義して、それをUserMailer.account_activationの引数として渡します（リスト 11.18）。このとき、リスト 11.18ではuser.activation_tokenの値にも代入している点にご注意ください
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)
  end

  # - Preview this email at(下記urlでプレビュー可能)
  # http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset
  end
end
