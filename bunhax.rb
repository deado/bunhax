#!/usr/bin/env ruby
require 'getoptlong'

require "./menu.rb"
require "./cpuset.rb"
require "./task.rb"

#init section ffs
$EndProg	= false #we dont want bunhax to close right away do we?
$IMode		= false #using this for interactive mode...

# app colors

$info_char	= "~"
$c1	= "\033[0;36;40m" #accients
$c2	= "\033[0m" #main
$c3	= "\033[0;31;40m" #prompt
$head	= "#{$c1}#{$info_char}#{$c2}"

#cpuset should be in /dev/cpuset.. if not change it here
$cpuset_dir	= "/dev/cpuset"
$proc_dir	= "/proc"
delete_f        = false
delete_args     = []
edit_f		= false
edit_args	= []
new_f           = false
new_args        = []
move_f          = false
move_args       = []
ptasks_f        = false
ptasks_args     = []
ex_options_n    = 0
have_options_f  = false

#user command parser
def Commands(cmd)
        #case > large if-statments
        case cmd
                when "h" then Menu.help
                when "m" then Task.gmove
		when "a" then Task.gmulti
		when "c" then Menu.colors
                when "d" then Cpuset.gdelete
		when "e" then Cpuset.gedit
                when "l" then Cpuset.list
                when "n" then Cpuset.gadd
                when "p" then Task.glist
                when "q" then Menu.quit
                when "v" then Menu.version
                when "z" then Menu.detach
                else
                        puts "#{$head}WTF... thats not a command!"
        end
end

#a couple of these are not even.. but i wanted them even when actually printing to the screen..
# and this fixes that for some strange reason
def printusage(error_code)
        print "Usage: bunhax [options]\n\n"
	puts "-a, --multipid			Move multiple PIDs to CPUSET"
        puts "-d, --delete CPUSET		Delete cpuset"
	puts "-e, --edit CPUSET,CPUS,MEMS	Edit CPUSET to use CPUS and MEMS"
        puts "-h, --help			Display this help msg"
	puts "-i, --interactive			Run interactive frontend"
        puts "-l, --list-cpusets		List current cpusets"
        puts "-n, --new CPUSET,CPUS,MEMS	Create new cpuset with usable cpus and mems as provided"
        puts "-m, --move PID,CPUSET		Move PID to CPUSET"
        puts "-p, --print-tasks CPUSET	List tasks for CPUSET"
        print "-v, --version			Print version info\n\n"

        puts "Examples:"
	puts "bunhax -a cpuset,1523,4321	move 2 or more PIDs to specified cpuset"
	puts "bunhax --interactive		opens the interactive frontend"
        puts "bunhax -d my_cpuset		delete cpuset 'user_apps'"
        puts "bunhax -l			print list of current cpusets"
        puts "bunhax --new newset,0-3,0	add cpuset 'user_apps' with usable cpus and mems as provided (defaults are 0)"
        puts "bunhax --move 12345,my_cpuset	attach PID '12345' to cpuset 'my_cpuset'"
        print "bunhax -p all			list and sort tasks for all cpusets\n\n"

	puts "You HAVE to either be root, or have rw permissions to /dev/cpuset/ AND at least have r permissions to /proc/"
        puts "Report bugs to Jeremy Polley <imdeado@gmail.com>"
	puts " - irc.freenode.net #gentoo.et"
        exit(error_code)
end

#define the options allowed to user, and set rather an argument is required or not
opts = GetoptLong.new(
	[ "--multipid",		"-a",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--delete",		"-d",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--edit",		"-e",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--help",		"-h",	GetoptLong::NO_ARGUMENT ],
	[ "--interactive",	"-i",	GetoptLong::NO_ARGUMENT ],
	[ "--list-cpusets",	"-l",	GetoptLong::NO_ARGUMENT ],
	[ "--move",		"-m",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--new",		"-n",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--print-tasks",	"-p",	GetoptLong::OPTIONAL_ARGUMENT ],
	[ "--usage",		"-u",	GetoptLong::NO_ARGUMENT ],
	[ "--version",		"-v",	GetoptLong::NO_ARGUMENT ]
)

#argument parser... we just figure out which arg the user has.. and then send it to the
# right class & method for doing the work. helps keep this part short, and the entire
# program organized, also very easy for adding on new functions, or just rewriting certain
# part of our code without disrrupting anything else.
begin
	opts.each do |opt, arg|
		case opt
			when "--delete"
				#tell parser this is being used.. and grab out args
				delete_f    = true
				delete_args = arg.split(",")
				have_options_f  = true
				Cpuset.delete(delete_args[0])
			when "--edit"
				edit_f		= true
				edit_args	= arg.split(",")
				have_options_f	= true
				Cpuset.edit(edit_args[0], edit_args[1], edit_args[2])
			when "--list-cpusets"
				have_options_f = true
				Cpuset.list
			when "--move"
				move_f = true
				move_args = arg.split(",")
				have_options_f = true
				Task.move(move_args[0], move_args[1])
			when "--multipid"
				cpuset = arg.slice(0, arg.index(","))
				pids = arg.slice((arg.index(",") + 1), arg.length)
				have_options_f = true
				Task.multi(pids, cpuset)
			when "--new"
				new_f = true
				new_args = arg.split(",")
				have_options_f = true
				cpus = new_args[1]
				cpus = "0" if cpus.empty?
				mems = new_args[2]
				mems = "0" if mems.empty?
				Cpuset.add(new_args[0], cpus, mems)
			when "--print-tasks"
				ptasks_f = true
				ptasks_args = arg.split(",")
				have_options_f = true
				Task.list(ptasks_args[0])
			when "--version"
				Menu.version
				exit(0)
			when "--help"
				printusage(0)
			when "--usage"
				printusage(0)
			when "--interactive"
				have_options_f = true
				Menu.help
				puts "#{$head}Please keep in mind that you either have to have root access"
				puts "OR rw permissions to #{$cpuset_dir} AND r permissions to #{$proc_dir}"
				while !$EndProg
					begin
					        print "#{$c3}$#{$c2} "
					        cmd = gets.strip.downcase
					        #send user input to our command parser
				        	Commands(cmd)
					rescue
						$stderr.print "#{$head}Error #{$c1}->#{$c2} #{$_}\n"
					end
				end
		else
			printusage(0)
		end
	end
	# test for missing options
	if !have_options_f
		printusage(1)
	end
rescue
	$stderr.print "IO failed: " + $! + "\n"
	# all other errors
	printusage(1)
end
