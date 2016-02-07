class Sync
	def Sync.cpusets
		#this simply calls Sync.init to mk $cpuset_dir and mount. then calls Cpuset.add for each c:line it finds in the config.
		puts "#{$head} Running recreation of cpusets, mounting and setting up the cpusets found in the config (if any)..."
		Sync.mkmnt
		#get set list to send to Cpuset.add
		@setpara = []
		$setlist.each {|s|
			@setpara = s.split(":")
			puts @setpara[0], @setpara[1], @setpara[2].strip
			Cpuset.add(@setpara[0],@setpara[1],@setpara[2].strip)
			@setpara.clear
		}
	end
	def Sync.tasks
		#mv tasks based on rules saved in config
		puts "Coming Soon..."
	end
	def Sync.config
		#hi. i copy yoursetup to my config
		puts "syncing config"
		`rm -rf #{$conf}`
		`touch #{$conf}`
		setdir = Dir.new($cpuset_dir)
		setdir.entries[2..-1].each do |file|
			line = Cpuset.getinfo(file) if File.ftype(setdir.path + "/" + file) == "directory"
			return if !line
			line.slice!(/:\d$/)
			line = "c:#{line}"
			puts line
			`/bin/echo #{line} >> #{$conf}` #write cpusets to config
		end
		`/bin/echo v:mounted:#{$mounted} >> #{$conf}`
		`/bin/echo v:enabled:#{$enabled} >> #{$conf}`
		return
	end
	def Sync.install
		puts "#{$head} Installing bunhax in a better place on your system"
		Dir.mkdir("/etc/bunhax")
		`cp bunhax.rb cpuset.rb task.rb sync.rb menu.rb parse.rb /etc/bunhax/`
		`ln -s /etc/bunhax/bunhax.rb /sbin/bunhax`
		puts "Done. Running 'bunhax' should now work. :)"
		#Sync.init
	end
	def Sync.init
	        puts "#{$head} Examining system..."
		if !FileTest.exist?("/etc/bunhax/bunhax.rb")
			puts "#{$head} It is highly recommended that you install bunhax."
			print "Would you like to do this now? (y/n): "
			$_.strip.downcase == "y" ? Sync.install : $_.strip.downcase == "n" ? break : "Invalid input. Continuing with init" while gets
		end
	        `touch #{$conf}`
	
	        if `cat /proc/filesystems | grep cpuset`.strip == "nodev\tcpuset"
	                puts "Congrats, cpusets are enabled! Checking to see if there are any existing cpusets..."
	                $enabled = true
	                if !FileTest.exist?($cpuset_dir) #if the dir isnt there no way it can be mounted.
	                        puts "#{$cpuset_dir} isn't there. Creating and mounting cpusets to the system..."
				Sync.mkmnt
	                        puts "#{$head} Done. Create a new cpuset to go any futher."
	                else
				#we still need to check and see if it is mounted at this point because $cpuset_dir exists.
				puts "#{$cpuset_dir} exists!"
	                        Cpuset.list
				Sync.config
	                end
	        else
	                puts "cpusets are not enabled in your kernel."
	                $enabled = false
	                exit(0)
	        end
	end
	def Sync.uninstall
		print "#{$head} Uninstalling bunhax..."
		`rm -rf /etc/bunhax/ /sbin/bunhax`
		puts "Done."
	end
	def Sync.mkmnt
		Dir.mkdir($cpuset_dir)
		$mounted = true if `mount -t cpuset cpuset /sys/fs/cgroup/cpuset`
	end
end
