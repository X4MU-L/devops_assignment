module ApiRoutes
    def self.draw(router)
      router.get '/health', to: 'api#health'
      router.get '/chain', to: 'api#chain'
    end
  end