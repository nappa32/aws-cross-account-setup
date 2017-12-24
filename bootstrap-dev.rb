require 'colorize'
require 'json'
require 'csv'

TIMESTAMP = Time.now.to_i
CONFIGFILE = "accounts.json"
AWS_CREDS_FILE = "#{ENV['HOME']}/.aws/credentials"
AWS_CONFIG_FILE = "#{ENV['HOME']}/.aws/config"
AWS_MFA_FILE = "#{ENV['HOME']}/.aws/mfaconfig"

if File.file?(CONFIGFILE)
  CONFIG = JSON.parse(File.read(CONFIGFILE))
else
  puts "#{CONFIGFILE} does not exist in : #{`pwd`}".colorize(:red)
end

def run_cmd(cmd)
  # puts "Running Command : #{cmd}".colorize(:orange)
  # puts ""
  result = `#{cmd}`
  if $? != 0
    puts "Error!".colorize(:red)
    puts "#{result}".colorize(:blue)
  end
end

def proceed_prompt
  puts "Proceed? (y/n)"
end
def wait_before_more_instructions
  proceed_prompt
  until ["y","yes"].include?(gets.chomp.downcase.strip)
    proceed_prompt
  end
end

def main
  provision_aws_config_directory
  write_aws_credentialfile
  write_mfa_userfile
  write_aws_configfile
  write_shell_sourcefile
  instructions_for_password_change
  instructions_for_access_keys_change
  instructions_for_shell
  instructions_for_browser_bookmarks
end

def provision_aws_config_directory
  if File.file?(AWS_CONFIG_FILE)
    backup_aws_dir
  end
end

def backup_aws_dir
  puts "Existing ~/.aws directory found.".colorize(:blue)
  puts "Backup the directory? (n/y)"
  response = gets.chomp
  if ["y","yes"].include?(response.downcase.strip)
    puts "Backing up to :~/backup.aws-#{TIMESTAMP}".colorize(:blue)
    run_cmd "mv ~/.aws/ ~/backup.aws-#{TIMESTAMP}"
  else
    puts "Please backup the ~/.aws folder to somewhere else"
    puts "mv ~/.aws/ ~/backup.aws-#{TIMESTAMP}"
  end
end

def creds
  @creds ||= begin
    creds = {}
    creds['username'] = CSV.parse(File.read("credentials.csv"))[1][0]
    creds['password'] = CSV.parse(File.read("credentials.csv"))[1][1]
    creds['ACCESS_KEY'] = CSV.parse(File.read("credentials.csv"))[1][2]
    creds['SECRET_KEY'] = CSV.parse(File.read("credentials.csv"))[1][3]
    creds['link'] = CSV.parse(File.read("credentials.csv"))[1][4]
    creds
  end
end

def write_shell_sourcefile
  run_cmd "rm -f ~/.aws/auth.aws"
  run_cmd "cp -a auth.aws ~/.aws/"
  run_cmd "cp -a #{CONFIGFILE} ~/.aws/"
end

def write_aws_credentialfile
  run_cmd "aws configure set aws_access_key_id #{creds['ACCESS_KEY']}"
  run_cmd "aws configure set aws_secret_access_key #{creds['SECRET_KEY']}"
  run_cmd "aws configure set default.region us-west-1"
end

def write_mfa_userfile
  mfaserial = {"serial" => "arn:aws:iam::#{CONFIG['accounts']['parent']['id']}:mfa/#{creds['username']}"}
  run_cmd "touch #{AWS_MFA_FILE}"
  File.open(AWS_MFA_FILE,"w") do |f|
    f.write(mfaserial.to_json)
  end
end

def write_aws_configfile
  envs.each do |env|
    CONFIG['roles'].each do |role|
      env_id = CONFIG['accounts']['children'][env]['id']
      run_cmd "aws configure set role_arn arn:aws:iam::#{env_id}:role/#{role} --profile #{env.capitalize}#{role}"
      run_cmd "aws configure set source_profile default --profile #{env.capitalize}#{role}"
    end
  end
end

def envs
  CONFIG['accounts']['children'].keys
end

def instructions_for_password_change
  puts "1. Login to console to change password : #{creds['link']}".colorize(:blue)
  puts "   user: #{creds['username']}"
  puts "   pass: #{creds['password']}"
  wait_before_more_instructions
end

def instructions_for_access_keys_change
  puts "2. Delete existing AWS_ACCESS_KEY and create new ones".colorize(:blue)
  puts "   - https://console.aws.amazon.com/iam/home?region=us-east-1#/users/#{creds['username']}?section=security_credentials"
  puts "3. PASTE the AWS_ACCESS_KEY:"
  default_access_key = gets.chomp.strip
  run_cmd "aws configure set aws_access_key_id #{default_access_key}"
  puts "4. PASTE the AWS_SECRET_KEY:"
  default_secret_key = gets.chomp.strip
  run_cmd "aws configure set aws_secret_access_key #{default_secret_key}"
  wait_before_more_instructions
end


def instructions_for_shell
  puts "4. Manually Add 'source ~/.aws/auth.aws' in your '~/.bashrc' OR '~/.zshrc' file."
  wait_before_more_instructions
end

def instructions_for_browser_bookmarks
  puts "5. AWS Console Login will be a multi step process:"
  puts "   a. login : #{creds['link']} [bookmark]"
  puts "   b. switch role: via login.html file links. [bookmark]"

  puts "6. Open the login page in browser? (y/n)".colorize(:blue)
  response = gets.chomp
  if ["y","yes"].include?(response.downcase.strip)
    run_cmd "open login.html"
  else
    puts "visit https://s3.amazonaws.com/company-iam-login-s3-bucketname/login.html"
  end
end

main
