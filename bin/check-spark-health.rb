require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

class CheckSparkHealth < Sensu::Plugin::Check::CLI
  option :endpoint,
         short: '-p ENDPOINT',
         long: '--endpoint ENDPOINT',
         description: 'Spark Endpoint',
         default: 'http://localhost:8080/json'

  option :number,
         short: '-n NUMBER',
         long: '--number NUMBER',
         proc: proc(&:to_i),
         description: 'Spark Workers number'

  option :apps_number,
         short: '-A NUMBER',
         long: '--apps_number NUMBER',
         proc: proc(&:to_i),
         description: 'Spark Apps number'

  option :expecting_status,
         short: '-s STATUS',
         long: '--status STATUS',
         description: 'Expecting spark status',
         in: ['ALIVE', 'STANDBY'],
         default: 'ALIVE'

  def request
    RestClient::Request.execute(
      method: :get,
      url: config[:endpoint]
    )
  end

  def check_health
    response = request

    JSON.parse(response)
  end

  def run
    check = check_health
    workers_number = check['workers'].size
    apps_number = check['activeapps'].size

    if check['status'] == config[:expecting_status]
      if (config[:number] && config[:number] == workers_number) || config[:number].nil?
        if (config[:apps_number] && config[:apps_number] == apps_number) || config[:apps_number].nil?
          ok "CheckSparkHealth is ok"
        else
          critical "CheckSparkHealth found #{apps_number} apps instead of #{config[:apps_number]}"
        end
      else
        critical "CheckSparkHealth found #{workers_number} workers instead of #{config[:number]}"
      end
    else
      critical "CheckSparkHealth has status #{check['status']}"
    end
  end
end
