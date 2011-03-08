#class for working mainly with the cpusets...
# im sure there is probably a lot better way of doing this.. but at the time
# this is the best i could come up with... basicly, the class methods
# that have a 'g' infront of the actual method name.. is the shit for the interactive frontend
# since the interactive frontend will be outputting a little more information on
# the screen, and will have to get information from the user.. i had to do it
# seperately from the "real" methods that actually do the work, so that it
# doesnt mess with how our argv stuff works.
class Cpuset
        # for interactive
        def Cpuset.gadd
                puts "#{$head}Preparing to make cpuset..."
       	        print "#{$head}Enter cpuset name#{$c1}:#{$c2} "
                cpuset = gets.strip
                puts "#{$head}Error #{$c1}->#{$c2} empty cpuset name" if cpuset.empty?

		print "#{$head}Enter usable cpus#{$c1}:#{$c2}(0) "
		cpus = gets.strip
		cpus = "0" if cpus.empty?
		print "#{$head}Enter usable memory set#{$c1}:#{$c2}(0) "
		mems = gets.strip
                mems = "0" if mems.empty?
		Cpuset.add(cpuset, cpus, mems)
        end
        #does actual work
        def Cpuset.add(cpuset, cpus, mems)
                if !FileTest.exist?($cpuset_dir + "/" + cpuset)
                        puts "#{$head}Good, doesnt exist. Creating..."
                        Dir.mkdir($cpuset_dir + "/" + cpuset)
			edit_file = ($cpuset_dir + "/" + cpuset + "/mems")
			`echo #{mems} > #{edit_file}`
			edit_file = ($cpuset_dir + "/" + cpuset + "/cpus")
			`echo #{cpus} > #{edit_file}`
                else
                        puts "#{$head}That cpuset already exists!"
                end
        end
        #for interactive
        def Cpuset.gdelete
                print "#{$head}Enter cpuset name#{$c1}:#{$c2} "
                cpuset = gets.strip
                puts "#{$head}Error #{$c1}->#{$c2} empty cpuset name" if cpuset.empty?
                Cpuset.delete(cpuset)
        end
        #does actual work
        def Cpuset.delete(cpuset)
                if FileTest.exist?($cpuset_dir + "/" + cpuset)
                        puts "#{$head}Good, cpuset exist. Deleting..."
                        Dir.delete($cpuset_dir + "/" + cpuset)
                else
                        puts "#{$head}That cpuset doesn't exist!"
                end
        end
	def Cpuset.gedit
		print "#{$head}Enter cpuset name#{$c1}:#{$c2} "
		cpuset = gets.strip
		if cpuset.empty?
			puts "#{$head}Error #{$c1}->#{$c2} empty cpuset name"
		else
			#lets get the current settings for cpus and mems
			cpusFile = File.new($cpuset_dir + "/" + cpuset + "/cpus", "r")
			memsFile = File.new($cpuset_dir + "/" + cpuset + "/mems", "r")
			oldcpus = cpusFile.readline.strip
			cpusFile.close
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
			Cpuset.organize(cpuset)
		else
			puts "#{$head}Error #{$c1}->#{$c2} cpuset does not exist"
		end
	end
	def Cpuset.organize(cpuset)
		#after you edit a sets cpus this reorganizes the pids so they change to the correct cpus.
		pids = []
		pidFile = File.new($cpuset_dir + "/" + cpuset + "/tasks", "r")
		puts "#{$head}Organizing pids..."
		pidFile.each {|line| pids.push(line.strip)} while !pidFile.eof
		pids.each {|i| Task.domove(i, cpuset)}
	end
        # didnt need an interactive method for this one.. because the command doesnt
        # take any arguements..
        def Cpuset.list
                cpuDir = Dir.new($cpuset_dir)
                puts "#{$head}Listing cpusets..."
		puts "CPUSET		CPUS		\# Tasks"
		puts "------------------------------------------"
		Cpuset.getinfo("/")
                #trix to list only directories (cpusets are determined as directories... doesn't include "." or ".."
                cpuDir.entries[2..-1].each do |file|
                        Cpuset.getinfo(file) if File.ftype(cpuDir.path + "/" + file) == "directory"
                end
        end
	def Cpuset.getinfo(cpuset)
		getdir = $cpuset_dir + "/" + cpuset
		gettasks = getdir + "/tasks"
		getcpus = getdir + "/cpus"
		puts "#{$head}Error -> unable to locate cpuset file: tasks" if !FileTest.exist?(gettasks)
		puts "#{$head}Error -> unable to locate cpuset file: cpus" if !FileTest.exist?(getcpus)

		lines = `wc -l #{gettasks}`
		#lets trim it down a bit so we just get the number
		lines = lines.slice(0, lines.index(" "))
		cpusFile = File.new(getcpus, "r")
		cpus = cpusFile.readline.strip
		cpusFile.close
		
		if cpuset == "/"
			puts "#{cpuset}		#{cpus}		#{lines}"
		else
			puts "/#{cpuset}		#{cpus}		#{lines}"
		end
	end
end
