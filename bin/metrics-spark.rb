require 'sensu-plugin/metric/cli'
require 'rest-client'
require 'json'
require 'sensu-plugins-spark'

class MetricsSpark < Sensu::Plugin::Metric::CLI::Graphite
  include SensuPluginsSpark::SparkCommon

  option :endpoint,
         short: '-p ENDPOINT',
         long: '--endpoint ENDPOINT',
         description: 'Spark Endpoint',
         default: 'http://localhost:8080/metrics/master/json/'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-S SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.spark"

  def metrics
    response = request

    ::JSON.parse(response)
  end

  def print_metrics(h, path='')
    h.each do |key,val|
      if val.is_a? Hash
        print_metrics(val,"#{[path,key].join('.')}")
      else
        output "#{config[:scheme]}#{path}.#{key}", val
      end
    end
  end

  def run
    print_metrics(metrics)
    ok
  end
end
