require 'rubygems'
require 'chef'
require 'chef/handler'
require 'syslog'

class SyslogReporting < Chef::Handler
  attr_writer :identity, :facility, :fail_priority, :success_proirity

  def initialize(options = {})
    @identity = options[:identity]
    @facility = options[:facility]
    @fpriority = options[:fail_priority]
    @spriority = options[:success_priority]
  end

  def report
    if run_status.success?
      status = "success"
      priority = @spriority
      extra = ""
    else
      status = "failure"
      priority = @fpriority
      extra = " exception='#{run_status.exception}'"
    end

    Syslog.open(@identity, nil, @facility) unless Syslog.opened?
    begin
      logline = "status=#{status} total_resources=#{run_status.all_resources.length} updated_resources=#{run_status.updated_resources.length} elapsed_time=#{run_status.elapsed_time}#{extra}"
      Syslog.log(priority, logline)
      Syslog.close
    rescue => e
      Chef::Log.error("Error reporting to syslog")
    end
  end

end
