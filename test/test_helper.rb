require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'svnignore'

Svnignore.class_eval do
  def self.execute(command = nil)
    @commands ||= []
    @commands << command unless command.nil?
    @commands
  end
end

class Test::Unit::TestCase
  
  def fixtures_path
    File.join(File.dirname(__FILE__), 'fixtures')
  end
  
  def parsed_rules
    @parsed_rules ||= {
      '.'      => [{ :pattern => '.DS_Store', :recursive => true }],
      'config/' => [{ :pattern => 'application_settings.yml', :recursive => false }, { :pattern => 'database.yml', :recursive => false }],
      'db/'    => [{ :pattern => '*.sqlite3', :recursive => false }],
      'log/'    => [{ :pattern => '*.log', :recursive => false }],
      'tmp/'    => [{ :pattern => '*', :recursive => false }]
    }
  end
  
  def rules
    @rules ||= [
      '**/.DS_Store',
      'config/application_settings.yml',
      'config/database.yml',
      'db/*.sqlite3',
      'log/*.log',
      'tmp/*'
    ]
  end
  
  def svn_commands
    @svn_commands ||= [
      "svn propset svn:ignore -R '.DS_Store' .",
      "svn propset svn:ignore -F some_temp_file config/",
      "svn propset svn:ignore '*.sqlite3' db/",
      "svn propset svn:ignore '*.log' log/",
      "svn propset svn:ignore '*' tmp/"
    ]
  end
  
  def tempfile
    if @tempfile.nil?
      @tempfile = Tempfile.new('svnignore_test', Dir.pwd)
      @tempfile.print(rules.join("\n"))
      @tempfile.flush
    end
    @tempfile
  end
  
end