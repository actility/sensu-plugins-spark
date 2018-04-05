module SensuPluginsSpark
  module SparkCommon
    def request
      RestClient::Request.execute(
        method: :get,
        url: config[:endpoint]
      )
    end
  end
end
