module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
    # セッションリプレイ攻撃から保護する
    # 詳しくは https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443 を参照
    session[:session_token] = user.session_token
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember(user)
    # * ユーザーのremember_tokenを新規作成して、仮想属性remember_tokenに代入し、remember_digestをDBに保存
    user.remember
    # * [:user_id]: クッキーに保存するデータのキー（名前）です。この場合、user_id というキーでユーザーIDが保存されます。
    # * user.id: 保存されるデータの値で、ここではユーザーのIDが使われています。
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

    # # 現在ログイン中のユーザーを返す（いる場合）
    # def current_user
    #   if session[:user_id]
    #     @current_user ||= User.find_by(id: session[:user_id])
    #   end
    # end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
      # @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      # raise       # テストがパスすれば、この部分がテストされていないことがわかる
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget # app/models/user.rb #remember_digestをnilに更新
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    # app/helpers/sessions_helper.rb #cookieの永続的セッションを破棄
    forget(current_user)
    reset_session # Railsの組み込みメソッド
    @current_user = nil   # 安全のため
  end
end
