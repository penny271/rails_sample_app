# app/controllers/account_activations_controller.rb

class AccountActivationsController < ApplicationController

  # メールでの認証によるアカウント有効化を行うためのアクション
  def edit
    user = User.find_by(email: params[:email])
    # * !user.activated?が重要
    # * 既に有効になっているユーザーを誤って再度有効化しないために必要です。実際に正当かどうかにかかわらず、有効化処理が行われればユーザーはログイン状態になります。このコードがなければ、攻撃者がユーザーの有効化リンクを後から盗みだしてクリックするだけで、本当のユーザーとしてログインできてしまいます。このコードは、そのような攻撃を防ぐうえで非常に重要です。
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # * update_attributesを1回呼び出すのではなく、update_attributeを2回呼び出していることにご注目ください。update_attributesだとバリデーションが実行されてしまうため、今回のようにパスワードを入力していない状態で更新すると、バリデーションで失敗してしまいます
      # user.update_attribute(:activated,    true)
      # user.update_attribute(:activated_at, Time.zone.now)
      user.activate # * 上記を app/models/user.rb Userモデルオブジェクト経由でアカウントを有効化する
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
