#Class working with cpusets... duh!
class Cpuset
	def initialize(cpuset, cpus, mems)
		@cpuset = cpuset
		@cpus = cpus
		@mems = mems
		puts "#{$head} Setup virtual cpuset: #{@cpuset} : #{@cpus} : #{@mems}"
<<<<<<< HEAD
		puts "#{$head} Auto-syncing config."
		Sync.config
=======
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
	end
        # for interactive
        def Cpuset.iadd
                puts "#{$head} Preparing to make cpuset..."
       	        print "#{$head} Enter cpuset name#{$c1}:#{$c2} "
                cpuset = gets.strip
		if cpuset.empty?
			puts "#{$head} Error #{$c1}->#{$c2} empty cpuset name"
			return
		end
		print "#{$head} Enter usable cpus#{$c1}:#{$c2}(0) "
		cpus = gets.strip
		cpus = "0" if cpus.empty?
		print "#{$head} Enter usable memory set#{$c1}:#{$c2}(0) "
		mems = gets.strip
                mems = "0" if mems.empty?
		Cpuset.add(cpuset, cpus, mems)
		$newSet = Cpuset.new(cpuset, cpus, mems)
        end
        #does actual work
        def Cpuset.add(cpuset, cpus, mems)
                if !FileTest.exist?($cpuset_dir + "/" + cpuset)
                        puts "#{$head} Good, doesnt exist. Creating..."
                        Dir.mkdir($cpuset_dir + "/" + cpuset)
			edit_file = ($cpuset_dir + "/" + cpuset + "/mems")
			`/bin/echo #{mems} > #{edit_file}`
			edit_file = ($cpuset_dir + "/" + cpuset + "/cpus")
			`/bin/echo #{cpus} > #{edit_file}`
<<<<<<< HEAD
			`/bin/echo 1 > #{$cpuset_dir + "/" + cpuset + "/cpu_exclusive"}`
=======
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
                else
                        puts "#{$head} That cpuset already exists!"
                end
        end
        #for interactive
        def Cpuset.idelete
                print "#{$head} Enter cpuset name#{$c1}:#{$c2} "
                cpuset = gets.strip
		(!cpuset.empty?) ? Cpuset.delete(cpuset) : (puts "#{$head} Error #{$c1}->#{$c2} empty cpuset name") && return 
        end
        #does actual work
        def Cpuset.delete(cpuset)
		newset = "#{$cpuset_dir}/#{cpuset}"
                if FileTest.exist?(newset)
                        puts "#{$head} Good, cpuset exist. Deleting..."
                        Dir.delete(newset)
<<<<<<< HEAD
			Sync.config
=======
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
                else
                        puts "#{$head} That cpuset doesn't exist!"
                end
        end
	def Cpuset.iedit
		print "#{$head} Enter cpuset name#{$c1}:#{$c2} "
		cpuset = gets.strip
		if cpuset.empty?
			puts "#{$head} Error #{$c1}->#{$c2} empty cpuset name"
		else
			#lets get the current settings for cpus and mems
			cpusFile = File.new($cpuset_dir + "/" + cpuset + "/cpus", "r")
			oldcpus = cpusFile.readline.strip
			cpusFile.close
			memsFile = File.new($cpuset_dir + "/" + cpuset + "/mems", "r")
			oldmems = memsFile.readline.strip
			memsFile.close

			#ask for new ones.. but keep the current if user doesnt enter anything
			print "New usable cpus (#{oldcpus}): "
			cpus = gets.strip
			cpus = oldcpus if cpus.empty?
			print "New usable mems (#{oldmems}): "
			mems = gets.strip
			mems = oldmems if mems.empty?

			#pass info to the next step...
			Cpuset.edit(cpuset, cpus, mems)
		end
	end
	def Cpuset.edit(cpuset, cpus, mems)
		if FileTest.exist?($cpuset_dir + "/" + cpuset)
			cpusFile = File.new($cpuset_dir + "/" + cpuset + "/cpus", "w+")
			cpusFile.puts(cpus)
			cpusFile.close
			memsFile = File.new($cpuset_dir + "/" + cpuset + "/mems", "w+")
			memsFile.puts(mems)
			memsFile.close
			puts "#{cpuset}: now using CPU: #{cpus} and MEM: #{mems}"
<<<<<<< HEAD
			Sync.config
=======
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
			Cpuset.organize(cpuset)
		else
			puts "#{$head} Error #{$c1}->#{$c2} cpuset does not exist"
		end
	end
	def Cpuset.organize
		print "What cpuset: "
		cpuset = gets.strip
		#after you edit a sets cpus this reorganizes the pids so they change to the correct cpus.
		pids = []
		pidFile = File.new($cpuset_dir + "/" + cpuset + "/tasks", "r")
		puts "#{$head} Organizing pids..."
		pidFile.each {|line| pids.push(line.strip)} while !pidFile.eof
		pids.each {|i| Task.domove(i, cpuset)}
		pidFile.close
	end
        # didnt need an interactive method for this one.. because the command doesnt
        # take any arguements..
        def Cpuset.list
                cpuDir = Dir.new($cpuset_dir)
                puts "#{$head} Listing cpusets..."
		puts "CPUSET		CPUS		MEMS		\# Tasks"
		puts "----------------------------------------------------------"
		puts (Cpuset.getinfo("/")).gsub(/[:]/, "\t\t")
                #trix to list only directories (cpusets are determined as directories... doesn't include "." or ".."
                cpuDir.entries[2..-1].each do |file|
                        puts (Cpuset.getinfo(file)).gsub(/[:]/, "\t\t") if File.ftype(cpuDir.path + "/" + file) == "directory"
                end
        end
	def Cpuset.getinfo(cpuset)
		getdir = $cpuset_dir + "/" + cpuset
		gettasks = getdir + "/tasks"
		getcpus = getdir + "/cpus"
		getmems = getdir + "/mems"
		puts "#{$head} Error -> unable to locate file: #{gettasks}" if !FileTest.exist?(gettasks)
		puts "#{$head} Error -> unable to locate file: #{getcpus}" if !FileTest.exist?(getcpus)
		puts "#{$head} Error -> unable to locate file: #{getmems}" if !FileTest.exist?(getmems)

		lines = `wc -l #{gettasks}`
		#lets trim it down a bit so we just get the number
		lines = lines.slice(0, lines.index(" "))
		cpusFile = File.new(getcpus, "r")
		cpus = cpusFile.readline.strip
		cpusFile.close
		memsFile = File.new(getmems, "r")
		mems = memsFile.readline.strip
		memsFile.close
		
		result = "#{cpuset}:#{cpus}:#{mems}:#{lines}"
	end
end
