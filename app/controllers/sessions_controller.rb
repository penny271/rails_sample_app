class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    # * authenticateメソッド は、has_secure_passwordというRailsの機能を使用しているモデルで利用できるメソッドです
    # * このメソッドは、引数として渡されたパスワードがユーザーのパスワードと一致するかどうかを確認します。パスワードが一致する場合、authenticateメソッドはtrueを返します。一致しない場合はfalseを返します。
    if @user&.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
      reset_session      # ログインの直前に必ずこれを書くこと (セッション固定攻撃対策)
      # remember user      # app/helpers/sessions_helper.rb
      # * Remember me機能の実装 (app/helpers/sessions_helper.rb) 画面からON/OFFできるようにしている
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      # * ログインする = session[:user_id]を設定する (app/helpers/sessions_helper.rb)
      log_in @user
      redirect_to @user # redirect_to user は redirect_to user_url(user) と同じ
    else
      # Create an error message.
      # * flash.nowメソッドを使うと、リクエストが終了すると同時にメッセージが消える
      # * flash.nowメソッドは、flashメソッドと似ていますが、次のリクエストが来たときには消えてしまう点が異なります。
      # * つまり、flash.nowメソッドは、同じリクエストの中でのみメッセージを表示するためのものです。
      # * これにより、エラーメッセージが表示されたページにリダイレクトされることなく、エラーメッセージを表示できます。
      # ! NG flash[:danger] = 'Invalid email/password combination'
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    # log_out # app/helpers/sessions_helper.rb
    # 2つのログイン済みのタブによるバグの修正
    log_out if logged_in? # app/helpers/sessions_helper.rb
    # * RailsでTurboを使うときは、このように "303 See Other"ステータスを指定することで、DELETEリクエスト後のリダイレクトが正しく振る舞うようにする必要があります
    redirect_to root_url, status: :see_other
  end

end
