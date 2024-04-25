Rails.application.routes.draw do
  # Defines the root path route ("/")
  # root "application#hello"

  # root "static_pages#home"  # * root_path, root_url が作成される
  # get 'static_pages/home'
  # get 'static_pages/help'
  # get 'static_pages/about', to: 'static_pages#about'
  # get 'static_pages/contact'

  # - リスト 5.20などで使われたデフォルトのルーティング(上記)はやや回りくどいので、
  # - HelpページやAboutページ、Contactページなどの名前付きルーティングを定義していきましょう。
  root 'static_pages#home'  # * root_path, root_url が作成される
  get '/home', to: 'static_pages#home'  # home_path, home_url が作成される
  # * get('/help', {to: 'static_pages#help', as: 'help'}) # 省略なし
  get '/help', to: 'static_pages#help', as: :help    # help_path, help_url が作成される
  get '/about', to: 'static_pages#about' # about_path, about_url が作成される
  get '/contact', to: 'static_pages#contact' # contact_path, contact_url が作成される
  # * getを /new ではなく、 /signup というふうにわかりやすくしている
  # sign_up_path, sign_up_url が作成される
  get  "/signup",  to: "users#new"
  resources :users

  get '/login', to: 'sessions#new' # * ログインフォームのためのルーティング
  post '/login', to: 'sessions#create' # * ログインのためのルーティング
  delete '/logout', to: 'sessions#destroy' # * ログアウトのためのルーティング

  # * memberメソッド
  resources :users do
    member do
      get :following, :followers
    end
  end

  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  # * Micropostsリソースへのインターフェイスは主にプロフィールページとHomeページのコントローラを経由して実行されるので、Micropostsコントローラにはnewやeditのようなアクションは不要です。
  resources :microposts, only: [:create, :destroy]
  # railsの不具合:本チュートリアル執筆時点では、無効なマイクロポストを送信した後にブラウザ画面を再読み込みすると、一部のブラウザ（Chromeなど）でNo route matches [GET] "/microposts"エラーが発生します。この場合、このルーティングを追加することでエラーを修正できます。
  get '/microposts', to: 'static_pages#home'

  # フォロー、アンフォローの機能を実装する
  resources :relationships,       only: [:create, :destroy]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # ! 確認用　要削除
  resources :photos
  resources :cans

  # ! 確認用　要削除
  # * memberメソッドを使うとユーザーidを含むURLを扱うようになりますが、 idを指定せずにすべてのメンバーを表示するには、次のようにcollectionメソッドを使います。
  resources :users do
    collection do
      get :tigers
    end
  end

end

