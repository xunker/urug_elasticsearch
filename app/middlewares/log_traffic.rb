module UrugElasticsearch
  class LogTraffic
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      resp = @app.call(env)

      if ['/', '/search'].include?(request.path) # log only search, not suggest

        LogEntry.create(
          remote_ip: request.remote_ip,
          path: request.filtered_path,
          request_method: request.request_method,
          content_type: request.content_type,
          accepts: request.accepts.try(:to_sentence),
          params: request.params
        )
      end

      resp
    end

  end
end
