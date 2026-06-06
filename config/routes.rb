Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: "users/registrations" }

  root "home#show"

  get "agenda/week",  to: "agenda#week",  as: :agenda_week
  get "agenda/month", to: "agenda#month", as: :agenda_month
  get "agenda/day",   to: "agenda#day",   as: :agenda_day

  resources :habits, except: [ :show ] do
    resources :habit_completions, only: [ :new, :create, :destroy ], path: "completions" do
      collection do
        post :toggle
      end
    end
  end

  resources :agenda_items
  resources :biometric_metrics do
    resources :biometric_entries, only: [ :new, :create, :destroy ], shallow: false
  end
  resources :biometric_entries, only: [ :edit, :update ] do
    collection do
      get :picker
    end
  end
  resources :medications, except: [ :show ] do
    post "intakes/toggle", to: "medication_intakes#toggle", as: :toggle_intake
  end
  resources :lab_panels, except: [ :show ] do
    resources :lab_results, only: [ :new, :create ]
  end
  resources :lab_results, only: [ :edit, :update, :destroy ]

  get  "health", to: "health#show",   as: :health
  get  "health/tab", to: "health#tab", as: :health_tab

  resources :templates, only: [ :index, :show ]
  resources :template_applications, only: [ :create ]
  resource  :guest_reset, only: [ :create ]
  resource  :guest_fresh_start, only: [ :create ]
  resource  :help_acknowledgment, only: [ :create ]

  resource :settings, only: [ :show, :update ]

  namespace :api do
    namespace :v1 do
      post "login",  to: "sessions#create"
      delete "logout", to: "sessions#destroy"

      get "agenda", to: "agenda#index"

      resources :habits, except: [ :new, :edit, :show ] do
        post :toggle, on: :member
      end
      resources :agenda_items, except: [ :new, :edit, :show ]
      resources :biometric_metrics, only: [ :index, :create, :update, :destroy ] do
        resources :biometric_entries, only: [ :create ]
      end
      resources :medications, only: [ :index, :create, :update, :destroy ]
      resources :lab_panels, only: [ :index, :create, :update, :destroy ] do
        resources :lab_results, only: [ :create, :update, :destroy ]
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
