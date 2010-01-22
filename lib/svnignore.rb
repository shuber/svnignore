require 'tempfile'

class Svnignore
  
  TEMPFILE_PREFIX = 'svnignore-'
  
  def self.default_options
    @default_options ||= { :file => '.svnignore', :recursive => true }
  end
  
  def self.ignore(current_working_directory, options = {})
    options = default_options.merge(options)
    files = find_files_with_ignore_rules(current_working_directory, options)
    files.each do |file|
      ignore_rules = parse_ignore_rules_from_file(file, current_working_directory)
      commands = generate_svn_commands_for_ignore_rules(ignore_rules)
      commands.each { |command| execute command }
    end
  end
  
  protected
  
    def self.create_tempfile_for_patterns(patterns)
      tempfile = Tempfile.new(TEMPFILE_PREFIX, Dir.pwd)
      tempfile.print(patterns.map { |configuration| configuration[:pattern] }.join("\n"))
      tempfile.flush
      tempfile
    end
    
    def self.execute(command)
      system command
    end
    
    def self.find_files_with_ignore_rules(current_working_directory, options)
      path = [current_working_directory]
      path << '**' if options[:recursive]
      path << options[:file]
      Dir[File.join(*path)]
    end
    
    def self.generate_svn_commands_for_ignore_rules(ignore_rules)
      ignore_rules.sort.inject([]) do |commands, (relative_path, patterns)|
        if patterns.length == 1
          options = patterns.first[:recursive] ? '-R ' : ''
          pattern = "'#{patterns.first[:pattern].gsub(/'/, "\\\\'")}'"
        else
          tempfile = create_tempfile_for_patterns(patterns)
          options = '-F '
          pattern = File.basename(tempfile.path)
        end

        commands << "svn propset svn:ignore #{options}#{pattern} #{relative_path}"
      end
    end
    
    def self.parse_ignore_rules_from_file(file, current_working_directory)
      ignore_rules = Hash.new { |hash, key| hash[key] = [] }
      patterns = File.read(file).split("\n")
      
      patterns.each do |pattern|
        path = File.join(File.dirname(file), pattern)
        parent = File.dirname(path)
        relative_path = (parent == current_working_directory) ? '.' : File.join(parent.gsub(File.join(current_working_directory, ''), ''), '')

        if relative_path =~ /\*\*\// # recursive ignore
          relative_path.gsub!(/\*\*\/.*$/, '')
          relative_path = '.' if relative_path.empty?
          recursive = true
        else
          recursive = false
        end

        ignore_rules[relative_path] << { :pattern => File.basename(pattern), :recursive => recursive }
      end
      
      ignore_rules
    end
  
end