require 'test_helper'

class SvnignoreTest < Test::Unit::TestCase

  should 'have a TEMPFILE_PREFIX' do
    assert Svnignore.const_defined?('TEMPFILE_PREFIX')
    assert !Svnignore::TEMPFILE_PREFIX.nil?
    assert !Svnignore::TEMPFILE_PREFIX.empty?
  end
  
  should 'parse the correct ignore rules from file' do
    assert_equal parsed_rules, Svnignore.send(:parse_ignore_rules_from_file, tempfile.path, Dir.pwd)
  end
  
  should 'find files with ignore rules' do
    assert_equal 2, Svnignore.send(:find_files_with_ignore_rules, fixtures_path, { :file => '.svnignore', :recursive => true }).size
    assert_equal 1, Svnignore.send(:find_files_with_ignore_rules, fixtures_path, { :file => '.svnignore', :recursive => false }).size
    assert_equal 1, Svnignore.send(:find_files_with_ignore_rules, fixtures_path, { :file => 'svnignore.txt', :recursive => true }).size
  end
  
  should 'generate svn commands for ignore rules' do
    parsed_svn_commands = Svnignore.send(:generate_svn_commands_for_ignore_rules, parsed_rules)
    svn_commands.each_with_index do |command, index|
      if command =~ / -F /
        assert_equal command.gsub(/ -F (\S+)/, ' -F ' + parsed_svn_commands[index].match(/ -F (\S+)/).captures[0]), parsed_svn_commands[index]
      else
        assert_equal command, parsed_svn_commands[index]
      end
    end
  end
  
  should 'execute svn commands' do
    Svnignore.ignore(fixtures_path, :recursive => false)
    assert_equal svn_commands.size, Svnignore.execute.size
  end
  
end