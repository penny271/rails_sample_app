# app/controllers/users_controller.rb

class UsersController < ApplicationController
  # ユーザーのindexページはログインしたユーザーにしか見せないようにし、未登録のユーザーがデフォルトで表示できるページを制限します
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  # 管理者しか destroyアクションを実行できないようにします
  before_action :admin_user,     only: :destroy

  def index
    # @users = User.all
    # * ページネーションを追加
    # @users = User.where(activated: true).paginate(page: params[:page])
    # メール認証にてすでに有効なユーザーのみを取得する
    @users = User.where(activated: true).paginate(page: params[:page])
  end


  def show
    # * （技術的な補足: params[:id]は文字列型の"1"ですが、findメソッドでは自動的に整数型に変換される）
    @user = User.find(params[:id])
    # binding.pry
    # debugger
    # * 今回の場合はUsersコントローラのコンテキストからマイクロポストをページネーションしたいため、コンテキストが異なる@microposts変数を明示的にwill_paginateに渡す必要があります。したがって、そのようなインスタンス変数をUsersコントローラのshowアクションで定義しなければなりません（
    @microposts = @user.microposts.paginate(page: params[:page])
    # * ユーザーが有効化されていない場合は、トップページにリダイレクトする
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    # @user = User.new(params[:user])
    @user = User.new(user_params)
    # * 上記は下記と同じ意味
    # @user = User.new(name: "Foo Bar", email: "foo@invalid",
    # password: "foo", password_confirmation: "bar")
    if @user.save
      # *ユーザー登録にアカウント有効化を追加する(メールにて有効化できるようにする)
      # UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email # 上記を user.rbで呼び出し、有効化用のメールを送信する
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      # flash[:success] = "Welcome to the Sample App!"
      # # * 新しく作成されたユーザーのプロフィールページにリダイレクトする
      # redirect_to @user
    else
      flash[:danger] = "Something went wrong"
      # * 422 Unprocessable Entityに対応するもので、Turboを用いて通常のHTMLをレンダリングする場合に必要です。
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
      if @user.update(user_params)
        flash[:success] = "Profile updated"
        redirect_to @user
      else
        flash[:error] = "Something went wrong"
        render 'edit', status: :unprocessable_entity
      end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    # * destroyの場合は status: :see_otherが必要
    redirect_to users_url, status: :see_other
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end

    # beforeフィルタ

    # ログイン済みユーザーかどうか確認
    # - microposts_controllerでも共通で使うため、application_controller.rbに記述し直したので重複しないようにコメントアウト
    # def logged_in_user
    #   puts("before_action :logged_in_user, only: [:edit, :update]でログイン済みユーザーかどうか確認する")
    #   unless logged_in?
    #     # フレンドリーフォワーディングのURL(当初飛びたかったpageのurl)を保存する
    #     store_location # app/helpers/sessions_helper.rb
    #     flash[:danger] = "Please log in."
    #     redirect_to login_url, status: :see_other
    #   end
    # end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id]) # urlの:idのユーザーを取得
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end

# status: :see_otherは必須ではありませんが、HTTPステータスコードを明示的に指定するために使用されます。

# redirect_toメソッドはデフォルトで302 Found（一時的なリダイレクト）を使用しますが、status: :see_otherを指定することで303 See Other（GETリクエストによるリダイレクト）を使用するように指定しています。

# * 303 See Otherは、POSTリクエストの結果としてリダイレクトを行う場合に特に有用です。これは、ブラウザがリダイレクト先をGETリクエストで取得することを強制します。これにより、リダイレクト先で誤ってPOSTリクエストが再度実行されることを防ぐことができます。

# したがって、このコードでは、ログインしていないユーザーがPOSTリクエストを送信した場合に、ログインページにGETリクエストでリダイレクトするように指定しています。
