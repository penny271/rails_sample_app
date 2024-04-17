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

  resources :account_activations, only: [:edit]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

end