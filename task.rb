#class for working with tasks...
class Task
        def Task.ilist
                print "#{$head} List tasks for: "
                cpuset = gets.strip
		(!cpuset.empty?) ? Task.list(cpuset) : (puts "#{$head} Invalid input")
        end
        def Task.list(cpuset)
                if !FileTest.exist?($cpuset_dir + "/" + cpuset + "/tasks")
                        (cpuset == "all") ? Task.listall : (puts "#{$head} I'm sorry that cpuset doesn't exist.")
                else
                        apidlist = []
                        puts "#{$head} Found cpuset, getting list. This may take a moment."
                        tfile = File.new($cpuset_dir + "/" + cpuset + "/tasks", "r")
                        #fill our array with the pids from our cpuset
                        tfile.each {|line| apidlist.push(line.strip)} while !tfile.eof
                        puts "#{$head} Task list for... #{cpuset}"
                        puts "PID  #{$c1}-#{$c2}  Name  #{$c1}-#{$c2}  CPU"
                        #transfer pids to a different class method for easier parsing...
                        apidlist.each {|i| Task.getinfo(i)}
			tfile.close
                end
        end
        def Task.listall
                #get list of all cpuset and set into array for easy axx
                list_cpuset = []
                cpuDir = Dir.new($cpuset_dir)
                #same as in Cpuset.list... but i didnt want to output the list.. so chaning it abit
                list_cpuset.push("/")
                cpuDir.entries[2..-1].each do |file|
                        list_cpuset.push("/" + file) if File.ftype(cpuDir.path + "/" + file) == 'directory'
                end
                #now we have our array of our cpusets
                list_cpuset.each do |cpuset|
                        #init apidlist here or else its all fucked up
                        apidlist = []
                        #unlike before, we wont be checking to make sure our cpusets are real
                        # because we just got the list of them... so we know they are there
                        tfile = File.new($cpuset_dir + "/" + cpuset + "/tasks", "r")
                        tfile.each {|line| apidlist.push(line.strip)} while !tfile.eof
                        #we now have our list of pids, so lets just pass them to Task.getinfo like before
                        #but first lets tell the user which cpuset we are listing...
                        print "\n\n#{$head} Task list for... #{cpuset}\n"
                        puts "PID  #{$c1}-#{$c2}  Name  #{$c1}-#{$c2}  CPU"
                        apidlist.each {|i| Task.getinfo(i)}
			tfile.close
                end
        end
        def Task.getinfo(pid)
                #this is really sick the way i did this.. but its the best way i could think of
                # and it works every time...
                pidFile = File.new($proc_dir + "/" + pid + "/stat", "r")
		pid_stat = pidFile.readline
                pidFile.close
                # we already have the pid, and we are outputing it differently later so only grab the app.name
		a = pid_stat.split(' ')
                pidName = (a[2] =~ /\)$/) ? "#{a[1]} #{a[2]}" : a[1]
                pidcpu = (a.length == 44) ? a[38] : a[39]
                #output in a nice format.. with colours!
                puts "#{pid} #{$c1}-#{$c2} #{pidName} #{$c1}-#{$c2} #{pidcpu}"
        end
        def Task.imove
                print "Move PID#{$c1}:#{$c2} "
                pid = gets.strip
                print "What cpuset#{$c1}:#{$c2} "
                cpuset = gets.strip
		((!pid.empty?) && (!cpuset.empty?)) ? Task.domove(pid, cpuset) : (puts "#{$head} There was a problem with your request... please try again.") && return
        end
        def Task.imulti
                puts "#{$head} When entering PIDS... use commas as your seperater and no spaces."
                print "PIDs to move#{$c1}:#{$c2} "
                pids = gets.strip
                print "Move to CPUSET#{$c1}:#{$c2} "
                cpuset = gets.strip
                Task.multi(pids, cpuset)
        end
        def Task.multi(pids, cpuset)
                #first check to see if either are empty
                #if !pids.empty? and !cpuset.empty?
                #        pida = []
                #        pida = pids.split((pids =~ /\w*-\w*/) ? "-" : ",")
                #        pida.each {|pid| Task.domove(pid, cpuset)}
                #else
                #        puts "#{$head} There was a problem with your request... please try again."
                #end
		if pids.empty? or cpuset.empty?
			puts "#{$head} pids and/or cpuset cannot be empty"
			return
		end
		pida = []
		case pids
			when /\w*\-\w*/
				puts "range"
				pida = pids.split("-")
				puts pida
				for i in pida[0]..pida[1]
					Task.domove(i, cpuset)
				end
				return
			when /\w*,\w*/
				puts "commas"
				pida = pids.split(",")
				pida.each {|i| Task.domove(i, cpuset)}
				return
		end
        end
        def Task.domove(pid, cpuset)
                pid_stat = ""
                if FileTest.exist?($proc_dir + "/" + pid)
                        pidFile = File.new($proc_dir + "/" + pid + "/stat", "r")
	                pid_stat = pidFile.readline
        	        pidFile.close
                        pid_name = pid_stat.slice(0, pid_stat.index(")") + 1)
                        puts "#{$head}Moving #{pid} #{$c1}->#{$c2} #{cpuset}"
                        #make sure cpuset is real
			(FileTest.exist?("#{$cpuset_dir}/#{cpuset}")) ? (`/bin/echo #{pid} > #{$cpuset_dir}/#{cpuset}/tasks`) : (puts "(#{cpuset}) doesn't exist.")
                else
                        puts "#{$head}PID #{$c1}(#{$c2}#{pid}#{$c1})#{$c2} doesn't exist."
                end
        end
end
