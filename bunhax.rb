#!/usr/bin/env ruby
$app_path = File.expand_path(File.dirname((FileTest.symlink?(__FILE__)) ? File.readlink(__FILE__) : __FILE__))

require 'getoptlong'
require "#{$app_path}/menu.rb"
require "#{$app_path}/cpuset.rb"
require "#{$app_path}/task.rb"
require "#{$app_path}/sync.rb"
require "#{$app_path}/parse.rb"

#init section ffs
$EndProg	= false #we dont want bunhax to close right away do we?
<<<<<<< HEAD
#$IMode		= false #using this for interactive mode...
=======
$IMode		= false #using this for interactive mode...
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
$cpuset_dir	= "/dev/cpuset"
$proc_dir	= "/proc"
$conf		= "#{$app_path}/.bunhax.conf"
$setlist	= []
delete_args	= []
edit_args	= []
new_args        = []
move_args       = []
ptasks_args     = []
have_options_f  = false

# app colors
info_char	= "~"
$c1		= "\033[0;36m" #accients
$c2		= "\033[0m" #main
$c3		= "\033[0;31m" #prompt
$head		= "#{$c1}#{info_char}#{$c2}"

#a couple of these are not even.. but i wanted them even when actually printing to the screen..
# and this fixes that for some strange reason
def printusage(error_code)
	case error_code
		when 0
		        print "Usage: bunhax [options]\n\n"
		        puts "-d, --delete CPUSET		Delete cpuset"
			puts "-e, --edit CPUSET,CPUS,MEMS	Edit CPUSET to use CPUS and MEMS"
		        puts "-h, --help			Display this help msg"
			puts "-y, --install			Install bunhax (recommended)"
			puts "-i, --interactive		Run interactive frontend"
		        puts "-l, --list-cpusets		List current cpusets"
		        puts "-m, --move PID,CPUSET		Move PID to CPUSET"
			puts "-a, --multipid			Move multiple PIDs to CPUSET"
		        puts "-n, --new CPUSET,CPUS,MEMS	Create new cpuset with usable cpus and mems as provided"
		        puts "-p, --print-tasks CPUSET	List tasks for CPUSET"
			puts "-c, --sync-config		Save your current cpusets to config"
			puts "-s, --sync-cpusets		Create cpusets based off config"
			puts "-t, --sync-tasks		Move tasks around cpusets based off config"
		        puts "-v, --version			Print version info"
			print "-z, --uninstall			Uninstall bunhax (shame on you)\n\n"
		
		        puts "Examples:"
			puts "bunhax -a cpuset,1523,4321	move 2 or more PIDs to specified cpuset"
			puts "bunhax --interactive		opens the interactive frontend"
		        puts "bunhax -d my_cpuset		delete cpuset 'user_apps'"
		        puts "bunhax -l			print list of current cpusets"
		        puts "bunhax --new user_apps,0-3,0	add cpuset 'user_apps' with usable cpus and mems as provided (defaults are 0)"
		        puts "bunhax --move 12345,my_cpuset	attach PID '12345' to cpuset 'my_cpuset'"
		        print "bunhax -p all			list and sort tasks for all cpusets\n\n"
	
<<<<<<< HEAD
			puts "Must be root"
=======
			puts "Must be root (0.2.4)."
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
		        puts "Report bugs to Jeremy Polley <imdeado@gmail.com>"
			puts " - irc.freenode.net #gentoo.et"
		        exit(error_code)
		when 1
			puts "#{$head} Exiting. Must be ran as root"
			exit(error_code)
	end
end
printusage(1) if `whoami`.strip != "root"

(FileTest.exists?($conf)) ? Parse.config : Sync.init

#define the options allowed to user, and set rather an argument is required or not
opts = GetoptLong.new(
	[ "--delete",		"-d",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--edit",		"-e",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--help",		"-h",	GetoptLong::NO_ARGUMENT ],
	[ "--install",		"-y",	GetoptLong::NO_ARGUMENT ],
	[ "--interactive",	"-i",	GetoptLong::NO_ARGUMENT ],
	[ "--list-cpusets",	"-l",	GetoptLong::NO_ARGUMENT ],
	[ "--move",		"-m",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--multipid",		"-a",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--new",		"-n",	GetoptLong::REQUIRED_ARGUMENT ],
	[ "--print-tasks",	"-p",	GetoptLong::OPTIONAL_ARGUMENT ],
	[ "--sync-config",	"-c",	GetoptLong::NO_ARGUMENT ],
	[ "--sync-cpusets",	"-s",	GetoptLong::NO_ARGUMENT ],
	[ "--sync-tasks",	"-t",	GetoptLong::NO_ARGUMENT ],
	[ "--uninstall",	"-z",	GetoptLong::NO_ARGUMENT ],
	[ "--usage",		"-u",	GetoptLong::NO_ARGUMENT ],
	[ "--version",		"-v",	GetoptLong::NO_ARGUMENT ]
)

#arguement parser
begin
	opts.each do |opt, arg|
		case opt
			when "--delete"
				#tell parser this is being used.. and grab out args
				delete_args = arg.split(",")
				have_options_f  = true
				Cpuset.delete(delete_args[0])
			when "--edit"
				edit_args	= arg.split(",")
				have_options_f	= true
				Cpuset.edit(edit_args[0], edit_args[1], edit_args[2])
			when "--install"
				Sync.install
<<<<<<< HEAD
				have_options_f = true
			when "--list-cpusets"
				Cpuset.list
				have_options_f = true
=======
				#exit(0)
			when "--list-cpusets"
				Cpuset.list
				#exit(0)
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
			when "--move"
				move_args = arg.split(",")
				have_options_f = true
				Task.domove(move_args[0], move_args[1])
			when "--multipid"
				cpuset = arg.slice(0, arg.index(","))
				pids = arg.slice((arg.index(",") + 1), arg.length)
				have_options_f = true
				Task.multi(pids, cpuset)
			when "--new"
				new_args = arg.split(",")
				have_options_f = true
				cpus = "0" if new_args[1].empty?
				mems = "0" if new_args[2].empty?
				Cpuset.add(new_args[0], cpus, mems)
			when "--print-tasks"
				ptasks_args = arg.split(",")
				have_options_f = true
				Task.list(ptasks_args[0])
			when "--sync-cpusets"
				Sync.cpusets
<<<<<<< HEAD
				have_options_f = true
			when "--sync-tasks"
				Sync.tasks
				have_options_f = true
			when "--sync-config"
				Sync.config
				have_options_f = true
			when "--version"
				Menu.version
				have_options_f = true
=======
				#exit(0)
			when "--sync-tasks"
				Sync.tasks
				#exit(0)
			when "--sync-config"
				Sync.config
				#exit(0)
			when "--version"
				Menu.version
				#exit(0)
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
			when "--help"
				printusage(0)
			when "--uninstall"
				Sync.uninstall
<<<<<<< HEAD
				have_options_f = true
=======
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
			when "--usage"
				printusage(0)
			when "--interactive"
				have_options_f = true
				Menu.help
				while !$EndProg
					begin
					        print "#{$c3}$#{$c2} "
						Parse.cmd(gets.strip.downcase)
					rescue
						$stderr.print "#{$head} Error #{$c1}->#{$c2} #{$_}\n"
					end
				end
<<<<<<< HEAD
				exit(0)
=======
>>>>>>> 42d616cf222f13535745734e8e8558b747bb76df
		else
			printusage(0)
		end
	end
	# test for missing options
	printusage(0) if !have_options_f
rescue
	$stderr.print "IO failed: " + $! + "\n"
	# all other errors
	printusage(0)
end
