class Parse
	def Parse.config
		config = File.new($conf, "r")
		while config.gets
			case $_
				when /^c:/
					$_.slice!("c:")
					$setlist.push($_)
					#puts "cpuset: #{$_}"
				when /^v:/
					#puts "variable: #{$_}"
				when /^t:/
					#puts "task"
				when /^\s*#/ then next
				when /^\r?\n?$/ then next
				when /^END/ then break
			else
				puts "unknown line: #{$_}"
			end
		end
	end
	def Parse.cmd(cmd)
        	case cmd
	                when "h" then Menu.help
	                when "q" then Menu.quit
	                when "v" then Menu.version
	                when "w" then Menu.detach
	                when "x" then Menu.colors
	                when "m" then Task.imove
	                when "a" then Task.imulti
	                when "p" then Task.ilist
	                when "d" then Cpuset.idelete
	                when "e" then Cpuset.iedit
	                when "l" then Cpuset.list
	                when "n" then Cpuset.iadd
			when "k" then Cpuset.organize
			when "c" then Sync.config
			when "s" then Sync.cpusets
			when "t" then Sync.tasks
			when "y" then Sync.install
			when "z" then Sync.uninstall
	                else
	                        puts "#{$head} Invalid entry. Try 'h' for help."
	        end
	end
end
